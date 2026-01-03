#!/usr/bin/env python3
"""
Database connection manager for PROVES Library
Provides connection pooling and query utilities
"""
import os
from typing import Optional, Any, Dict, List
from contextlib import contextmanager
import psycopg
from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


class DatabaseConnector:
    """Manages database connections and provides query utilities"""

    def __init__(self, db_url: Optional[str] = None):
        """
        Initialize database connector

        Args:
            db_url: Database URL (defaults to NEON_DATABASE_URL from .env)
        """
        self.db_url = db_url or os.getenv('NEON_DATABASE_URL')
        if not self.db_url:
            raise ValueError("Database URL not provided and NEON_DATABASE_URL not set")

        # Connection pool (min 1, max 10 connections)
        self.pool = ConnectionPool(self.db_url, min_size=1, max_size=10)

    @contextmanager
    def get_connection(self):
        """
        Get a connection from the pool (context manager)

        Usage:
            with db.get_connection() as conn:
                cur = conn.cursor()
                ...
        """
        with self.pool.connection() as conn:
            yield conn

    @contextmanager
    def get_cursor(self, dict_cursor: bool = True):
        """
        Get a cursor (context manager)

        Args:
            dict_cursor: If True, returns rows as dicts

        Usage:
            with db.get_cursor() as cur:
                cur.execute("SELECT * FROM table")
                rows = cur.fetchall()
        """
        with self.get_connection() as conn:
            row_factory = dict_row if dict_cursor else None
            cur = conn.cursor(row_factory=row_factory)
            try:
                yield cur
            finally:
                cur.close()

    def execute(self, query: str, params: Optional[tuple] = None) -> None:
        """
        Execute a query (INSERT, UPDATE, DELETE)

        Args:
            query: SQL query
            params: Query parameters
        """
        with self.get_cursor() as cur:
            cur.execute(query, params)

    def fetch_one(self, query: str, params: Optional[tuple] = None) -> Optional[Dict[str, Any]]:
        """
        Fetch a single row

        Args:
            query: SQL query
            params: Query parameters

        Returns:
            Row as dict or None
        """
        with self.get_cursor() as cur:
            cur.execute(query, params)
            return cur.fetchone()

    def fetch_all(self, query: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """
        Fetch all rows

        Args:
            query: SQL query
            params: Query parameters

        Returns:
            List of rows as dicts
        """
        with self.get_cursor() as cur:
            cur.execute(query, params)
            return cur.fetchall()

    def insert_many(self, table: str, columns: List[str], values: List[tuple]) -> None:
        """
        Bulk insert rows

        Args:
            table: Table name
            columns: Column names
            values: List of value tuples
        """
        with self.get_cursor(dict_cursor=False) as cur:
            placeholders = ", ".join(["%s"] * len(columns))
            query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
            cur.executemany(query, values)

    def close(self):
        """Close all connections in the pool"""
        if self.pool:
            self.pool.close()

    def __enter__(self):
        """Context manager support"""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager cleanup"""
        self.close()


# Singleton instance
_db_instance: Optional[DatabaseConnector] = None


def get_db() -> DatabaseConnector:
    """Get or create singleton database connector instance"""
    global _db_instance
    if _db_instance is None:
        _db_instance = DatabaseConnector()
    return _db_instance


if __name__ == '__main__':
    # Test connection
    print("Testing database connection...")
    try:
        db = get_db()
        result = db.fetch_one("SELECT version() as version")
        if result:
            print(f"[YES] Connected to PostgreSQL: {result['version']}")
        else:
            print("[NO] Connected but returned no version info.")

        # Test statistics view
        try:
            stats = db.fetch_all("SELECT * FROM database_statistics ORDER BY table_name")
            print("\n📊 Database Statistics:")
            for row in stats:
                print(f"  {row['table_name']}: {row['row_count']} rows")
        except Exception as e:
            print(f"\n[WARN] Could not fetch statistics: {e}")

    except Exception as e:
        print(f"[NO] Connection failed: {e}")
