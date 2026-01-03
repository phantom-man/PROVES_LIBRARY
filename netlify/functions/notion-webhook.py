"""
Netlify Function: Notion Webhook Handler

Receives webhook events from Notion and updates PostgreSQL.
Handles human approval decisions with full audit trail.
"""

import os
import json
import hmac
import hashlib

import psycopg
from notion_client import Client

# Database URL from environment (Netlify Neon integration uses DATABASE_URL)
DATABASE_URL = os.environ.get('DATABASE_URL') or os.environ.get('NEON_DATABASE_URL')
WEBHOOK_SECRET = os.environ.get('NOTION_WEBHOOK_SECRET', '')
NOTION_TOKEN = os.environ.get('NOTION_TOKEN') or os.environ.get('NOTION_API_KEY')

# Initialize Notion client
notion_client = Client(auth=NOTION_TOKEN, notion_version="2025-09-03") if NOTION_TOKEN else None


def verify_signature(body: bytes, signature: str) -> bool:
    """Verify Notion webhook signature"""
    if not WEBHOOK_SECRET:
        print("⚠️  WARNING: NOTION_WEBHOOK_SECRET not set - signature verification disabled")
        return True

    expected = hmac.new(
        WEBHOOK_SECRET.encode('utf-8'),
        body,
        hashlib.sha256
    ).hexdigest()

    return hmac.compare_digest(expected, signature)


def map_status_to_action(notion_status: str) -> tuple:
    """Map Notion status to (action_type, db_status) tuple"""
    status_map = {
        'Pending': ('flag_for_review', 'pending'),
        'Approved': ('accept', 'accepted'),
        'Rejected': ('reject', 'rejected'),
        'Needs Review': ('flag_for_review', 'flagged'),
        'Needs Context': ('request_more_evidence', 'needs_context')
    }
    return status_map.get(notion_status, ('flag_for_review', 'pending'))


def handle_extraction_page_updated(page_id: str, props: dict, webhook_payload: dict = None) -> dict:
    """
    Handle extraction page updates from Notion with full audit trail.

    Returns dict with status and details.
    """
    try:
        # Extract extraction ID
        extraction_id_prop = props.get('Extraction ID', {})
        if not extraction_id_prop.get('rich_text'):
            return {"status": "no_extraction_id"}

        extraction_id = extraction_id_prop['rich_text'][0]['plain_text']

        # Get webhook source ID for idempotency
        webhook_source = None
        if webhook_payload:
            webhook_source = webhook_payload.get('id')

        # Check idempotency
        if webhook_source:
            conn = psycopg.connect(DATABASE_URL)
            with conn.cursor() as cur:
                cur.execute("SELECT webhook_already_processed(%s)", (webhook_source,))
                already_processed = cur.fetchone()[0]
            conn.close()

            if already_processed:
                print(f"⚠️  Webhook {webhook_source} already processed - skipping")
                return {
                    "status": "already_processed",
                    "webhook_id": webhook_source
                }

        # Extract actor and reason
        actor_id = webhook_payload.get('user', {}).get('id', 'unknown') if webhook_payload else "unknown"

        review_notes_prop = props.get('Review Notes', {})
        reason = None
        if review_notes_prop.get('rich_text') and len(review_notes_prop['rich_text']) > 0:
            reason = review_notes_prop['rich_text'][0]['plain_text']

        # Determine action type
        action_type = None
        db_status = None

        review_decision_prop = props.get('Accept/Reject', {})
        if review_decision_prop.get('select'):
            review_decision = review_decision_prop['select']['name']

            if review_decision == 'Approved':
                action_type = 'accept'
                db_status = 'accepted'

                # Auto-update Notion Status
                if notion_client:
                    try:
                        notion_client.pages.update(
                            page_id=page_id,
                            properties={"Status": {"select": {"name": "Approved"}}}
                        )
                    except Exception as e:
                        print(f"⚠️  Could not auto-update Notion Status: {e}")

            elif review_decision == 'Rejected':
                action_type = 'reject'
                db_status = 'rejected'

                if notion_client:
                    try:
                        notion_client.pages.update(
                            page_id=page_id,
                            properties={"Status": {"select": {"name": "Rejected"}}}
                        )
                    except Exception as e:
                        print(f"⚠️  Could not auto-update Notion Status: {e}")

            elif review_decision == 'Modified':
                action_type = 'edit'
                db_status = 'flagged'

                if notion_client:
                    try:
                        notion_client.pages.update(
                            page_id=page_id,
                            properties={"Status": {"select": {"name": "Needs Review"}}}
                        )
                    except Exception as e:
                        print(f"⚠️  Could not auto-update Notion Status: {e}")
            else:
                status_prop = props.get('Status', {})
                if not status_prop.get('select'):
                    return {"status": "no_status"}
                notion_status = status_prop['select']['name']
                action_type, db_status = map_status_to_action(notion_status)
        else:
            status_prop = props.get('Status', {})
            if not status_prop.get('select'):
                return {"status": "no_status"}

            notion_status = status_prop['select']['name']
            action_type, db_status = map_status_to_action(notion_status)

        # Record decision in audit trail
        conn = psycopg.connect(DATABASE_URL)
        with conn.cursor() as cur:
            cur.execute("""
                SELECT record_human_decision(
                    %s::uuid, %s, %s, %s, NULL, NULL, %s
                )
            """, (extraction_id, action_type, actor_id, reason, webhook_source))
            decision_id = cur.fetchone()[0]

            # Update staging_extractions
            cur.execute("""
                UPDATE staging_extractions
                SET status = %s::candidate_status,
                    updated_at = NOW(),
                    reviewed_at = NOW(),
                    review_decision = %s
                WHERE extraction_id = %s::uuid
                RETURNING extraction_id
            """, (db_status, action_type, extraction_id))

            result = cur.fetchone()
            conn.commit()
        conn.close()

        if result:
            print(f"✓ Extraction {extraction_id} → {db_status}")
            print(f"✓ Decision {decision_id} by {actor_id}")
            return {
                "status": "success",
                "extraction_id": extraction_id,
                "new_status": db_status,
                "action_type": action_type,
                "decision_id": str(decision_id),
                "actor_id": actor_id
            }
        else:
            return {"status": "error", "message": "Database update failed"}

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return {"status": "error", "message": str(e)}


def handler(event, context):
    """
    Netlify Function handler for Notion webhooks.

    event: dict with httpMethod, headers, body, etc.
    context: Netlify function context

    Returns: dict with statusCode, body, headers
    """
    try:
        # Parse request
        if event.get('httpMethod') != 'POST':
            return {
                'statusCode': 405,
                'body': json.dumps({'error': 'Method not allowed'})
            }

        body = event.get('body', '')
        signature = event.get('headers', {}).get('x-notion-signature', '')

        # Verify signature
        if not verify_signature(body.encode('utf-8'), signature):
            return {
                'statusCode': 401,
                'body': json.dumps({'error': 'Invalid signature'})
            }

        # Parse webhook payload
        payload = json.loads(body) if isinstance(body, str) else body

        # Get page update info
        page_obj = payload.get('data', {}).get('object', {})
        if page_obj.get('object') != 'page':
            return {
                'statusCode': 200,
                'body': json.dumps({'status': 'not_a_page'})
            }

        page_id = page_obj.get('id')
        props = page_obj.get('properties', {})

        # Determine which database this came from
        parent = page_obj.get('parent', {})
        database_id = parent.get('database_id', '')

        # Check if this is an extraction page
        if 'Extraction ID' in props:
            result = handle_extraction_page_updated(page_id, props, payload)
            return {
                'statusCode': 200,
                'body': json.dumps(result),
                'headers': {'Content-Type': 'application/json'}
            }
        else:
            return {
                'statusCode': 200,
                'body': json.dumps({'status': 'unknown_page_type'})
            }

    except Exception as e:
        print(f"❌ Function error: {e}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}),
            'headers': {'Content-Type': 'application/json'}
        }
