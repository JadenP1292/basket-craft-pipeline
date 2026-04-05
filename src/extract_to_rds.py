"""
Extract raw tables from MySQL and load into AWS RDS PostgreSQL.

Extracts all 8 Basket Craft tables as-is with no transformations.
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MySQL Source (instructor's database)
MYSQL_CONFIG = {
    'host': os.getenv('MYSQL_HOST'),
    'port': int(os.getenv('MYSQL_PORT', 3306)),
    'database': os.getenv('MYSQL_DATABASE'),
    'user': os.getenv('MYSQL_USER'),
    'password': os.getenv('MYSQL_PASSWORD')
}

# AWS RDS PostgreSQL (cloud destination)
RDS_CONFIG = {
    'host': os.getenv('RDS_HOST'),
    'port': int(os.getenv('RDS_PORT', 5432)),
    'database': os.getenv('RDS_DATABASE'),
    'user': os.getenv('RDS_USER'),
    'password': os.getenv('RDS_PASSWORD')
}

# All tables to extract
TABLES = [
    'employees',
    'order_item_refunds',
    'order_items',
    'orders',
    'products',
    'users',
    'website_pageviews',
    'website_sessions'
]


def get_mysql_engine():
    """Create SQLAlchemy engine for MySQL source."""
    connection_string = (
        f"mysql+pymysql://{MYSQL_CONFIG['user']}:{MYSQL_CONFIG['password']}"
        f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}"
    )
    return create_engine(connection_string)


def get_rds_engine():
    """Create SQLAlchemy engine for RDS PostgreSQL destination."""
    connection_string = (
        f"postgresql://{RDS_CONFIG['user']}:{RDS_CONFIG['password']}"
        f"@{RDS_CONFIG['host']}:{RDS_CONFIG['port']}/{RDS_CONFIG['database']}"
    )
    return create_engine(connection_string)


def extract_and_load_table(table_name, mysql_engine, rds_engine):
    """Extract a single table from MySQL and load into RDS."""
    print(f"  📥 Extracting {table_name}...", end=" ")

    # Extract from MySQL
    df = pd.read_sql_table(table_name, mysql_engine)
    row_count = len(df)
    print(f"{row_count:,} rows", end=" ")

    # Load to RDS PostgreSQL (replace if exists)
    df.to_sql(
        table_name,
        rds_engine,
        if_exists='replace',
        index=False,
        method='multi',
        chunksize=1000
    )
    print("→ ✅ Loaded to RDS")

    return row_count


def main():
    """Extract all tables from MySQL and load into RDS."""
    print("=" * 60)
    print("🚀 MYSQL → RDS EXTRACTION")
    print("=" * 60)
    print(f"\nSource: {MYSQL_CONFIG['host']}/{MYSQL_CONFIG['database']}")
    print(f"Destination: {RDS_CONFIG['host']}/{RDS_CONFIG['database']}")
    print()

    # Create database connections
    mysql_engine = get_mysql_engine()
    rds_engine = get_rds_engine()

    # Test connections
    print("🔌 Testing connections...")
    with mysql_engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("  ✅ MySQL connected")

    with rds_engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("  ✅ RDS PostgreSQL connected")
    print()

    # Extract and load each table
    print(f"📦 Extracting {len(TABLES)} tables:\n")

    total_rows = 0
    for table in TABLES:
        rows = extract_and_load_table(table, mysql_engine, rds_engine)
        total_rows += rows

    # Summary
    print()
    print("=" * 60)
    print("✅ EXTRACTION COMPLETE")
    print("=" * 60)
    print(f"\n📊 Summary:")
    print(f"   • Tables loaded: {len(TABLES)}")
    print(f"   • Total rows: {total_rows:,}")
    print(f"   • Destination: {RDS_CONFIG['host']}")
    print()


if __name__ == "__main__":
    main()
