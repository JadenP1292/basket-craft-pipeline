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
