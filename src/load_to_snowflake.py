"""
RDS-to-Snowflake Loader

Extracts raw Basket Craft tables from AWS RDS PostgreSQL
and loads them into Snowflake basket_craft.raw schema.
"""

import os
from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas


def get_rds_engine():
    """Create SQLAlchemy engine for RDS PostgreSQL."""
    connection_string = (
        f"postgresql://{os.getenv('RDS_USER')}:{os.getenv('RDS_PASSWORD')}"
        f"@{os.getenv('RDS_HOST')}:{os.getenv('RDS_PORT')}/{os.getenv('RDS_DATABASE')}"
    )
    return create_engine(connection_string)


def get_snowflake_connection():
    """Create Snowflake connection."""
    return snowflake.connector.connect(
        account=os.getenv('SNOWFLAKE_ACCOUNT'),
        user=os.getenv('SNOWFLAKE_USER'),
        password=os.getenv('SNOWFLAKE_PASSWORD'),
        role=os.getenv('SNOWFLAKE_ROLE'),
        warehouse=os.getenv('SNOWFLAKE_WAREHOUSE'),
        database=os.getenv('SNOWFLAKE_DATABASE'),
        schema=os.getenv('SNOWFLAKE_SCHEMA')
    )


def get_table_list():
    """Return list of tables to transfer."""
    return [
        'orders',
        'order_items',
        'products',
        'users',
        'employees',
        'order_item_refunds',
        'website_sessions',
        'website_pageviews'
    ]


def load_table(table_name, rds_engine, sf_connection):
    """
    Load a single table from RDS to Snowflake.

    Args:
        table_name: Name of the table to load
        rds_engine: SQLAlchemy engine for RDS
        sf_connection: Snowflake connection

    Returns:
        int: Number of rows loaded
    """
    # Read from RDS
    print(f"  Reading {table_name} from RDS...", end=" ", flush=True)
    df = pd.read_sql_table(table_name, rds_engine)
    row_count = len(df)
    print(f"{row_count:,} rows")

    # Convert column names to lowercase for Snowflake/dbt compatibility
    df.columns = df.columns.str.lower()

    # Truncate target table if it exists
    cursor = sf_connection.cursor()
    try:
        cursor.execute(f"TRUNCATE TABLE IF EXISTS {table_name}")
    except Exception:
        pass  # Table may not exist yet, that's fine
    finally:
        cursor.close()

    # Load to Snowflake
    print(f"  Writing to Snowflake...", end=" ", flush=True)
    write_pandas(
        conn=sf_connection,
        df=df,
        table_name=table_name.upper(),  # Snowflake table names are uppercase
        auto_create_table=True,
        quote_identifiers=False  # Keep column names lowercase
    )
    print("done")

    return row_count
