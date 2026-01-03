import os
from typing import Optional
from dotenv import load_dotenv

# Load environment variables from .env file
# We load this at module level to ensure env vars are available when class attributes are initialized
load_dotenv()

class CuratorConfig:
    """Centralized configuration for Curator Agent"""
    
    # Database
    NEON_DATABASE_URL: str = os.getenv('NEON_DATABASE_URL', '')
    
    # Notion
    NOTION_API_KEY: str = os.getenv('NOTION_API_KEY', '')
    NOTION_WEBHOOK_SECRET: str = os.getenv('NOTION_WEBHOOK_SECRET', '')
    
    # Notion Database IDs
    NOTION_ERRORS_DB_ID: Optional[str] = os.getenv('NOTION_ERRORS_DB_ID')
    NOTION_EXTRACTIONS_DB_ID: Optional[str] = os.getenv('NOTION_EXTRACTIONS_DB_ID')
    NOTION_EXTRACTIONS_DATA_SOURCE_ID: Optional[str] = os.getenv('NOTION_EXTRACTIONS_DATA_SOURCE_ID')
    NOTION_REPORTS_DB_ID: Optional[str] = os.getenv('NOTION_REPORTS_DB_ID')
    NOTION_SUGGESTIONS_DB_ID: Optional[str] = os.getenv('NOTION_SUGGESTIONS_DB_ID')
    
    @classmethod
    def validate(cls):
        """Validate critical configuration"""
        missing = []
        if not cls.NEON_DATABASE_URL:
            missing.append("NEON_DATABASE_URL")
        if not cls.NOTION_API_KEY:
            missing.append("NOTION_API_KEY")
            
        if missing:
            raise ValueError(f"Missing required configuration: {', '.join(missing)}")

# Global configuration instance
config = CuratorConfig()
