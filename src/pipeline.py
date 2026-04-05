"""
Basket Craft ETL Pipeline
=========================
Extracts order data from MySQL, transforms into monthly aggregations,
and loads into PostgreSQL for dashboard consumption.

Usage:
    python src/pipeline.py
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


# =============================================================================
# CONFIGURATION
# =============================================================================

# MySQL Source (Basket Craft transactional database)
# Credentials loaded from .env file
MYSQL_CONFIG = {
    'host': os.getenv('MYSQL_HOST'),
    'port': int(os.getenv('MYSQL_PORT', 3306)),
    'database': os.getenv('MYSQL_DATABASE'),
    'user': os.getenv('MYSQL_USER'),
    'password': os.getenv('MYSQL_PASSWORD')
}

# PostgreSQL Destination (Dashboard database)
POSTGRES_CONFIG = {
    'host': 'localhost',
    'port': 5433,  # Using 5433 to avoid conflict with other PostgreSQL
    'database': 'basket_craft_dashboard',
    'user': 'postgres',
    'password': 'postgres'
}


def get_mysql_engine():
    """Create SQLAlchemy engine for MySQL source."""
    connection_string = (
        f"mysql+pymysql://{MYSQL_CONFIG['user']}:{MYSQL_CONFIG['password']}"
        f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}"
    )
    return create_engine(connection_string)


def get_postgres_engine():
    """Create SQLAlchemy engine for PostgreSQL destination."""
    connection_string = (
        f"postgresql://{POSTGRES_CONFIG['user']}:{POSTGRES_CONFIG['password']}"
        f"@{POSTGRES_CONFIG['host']}:{POSTGRES_CONFIG['port']}/{POSTGRES_CONFIG['database']}"
    )
    return create_engine(connection_string)


# =============================================================================
# EXTRACT
# =============================================================================

def extract_orders(engine) -> pd.DataFrame:
    """
    Extract order data from MySQL with product and category information.

    Returns a denormalized DataFrame with all fields needed for aggregation.
    """
    query = """
    SELECT
        o.order_id,
        o.order_date,
        o.customer_id,
        oi.item_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.line_total,
        p.product_name,
        p.category_id,
        c.category_name
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    WHERE o.order_status = 'completed'
    ORDER BY o.order_date, o.order_id
    """

    print("📥 Extracting data from MySQL...")
    df = pd.read_sql(query, engine)
    print(f"   ✓ Extracted {len(df):,} order line items")
    print(f"   ✓ Date range: {df['order_date'].min()} to {df['order_date'].max()}")
    print(f"   ✓ Categories: {df['category_name'].nunique()}")

    return df


# =============================================================================
# TRANSFORM
# =============================================================================

def transform_to_monthly_summary(df: pd.DataFrame) -> pd.DataFrame:
    """
    Transform raw order data into monthly aggregated summary by category.

    Calculations:
    - total_revenue: Sum of all line totals
    - order_count: Count of distinct orders
    - items_sold: Total quantity sold
    - avg_order_value: Revenue divided by orders
    """
    print("\n🔄 Transforming data...")

    # Ensure order_date is datetime
    df['order_date'] = pd.to_datetime(df['order_date'])

    # Extract year-month for grouping
    df['year_month'] = df['order_date'].dt.to_period('M').astype(str)

    # Aggregate by year_month and category
    summary = (
        df
        .groupby(['year_month', 'category_name'])
        .agg(
            total_revenue=('line_total', 'sum'),
            order_count=('order_id', 'nunique'),
            items_sold=('quantity', 'sum')
        )
        .reset_index()
    )

    # Calculate average order value
    summary['avg_order_value'] = (
        summary['total_revenue'] / summary['order_count']
    ).round(2)

    # Round revenue to 2 decimal places
    summary['total_revenue'] = summary['total_revenue'].round(2)

    print(f"   ✓ Generated {len(summary)} monthly category summaries")
    print(f"   ✓ Months covered: {summary['year_month'].nunique()}")
    print(f"   ✓ Total revenue: ${summary['total_revenue'].sum():,.2f}")

    return summary


def validate_data(df: pd.DataFrame) -> bool:
    """
    Validate transformed data before loading.

    Checks:
    - No null values in key columns
    - No negative amounts
    - Reasonable value ranges
    """
    print("\n🔍 Validating data...")

    issues = []

    # Check for nulls
    null_counts = df.isnull().sum()
    if null_counts.any():
        issues.append(f"Null values found: {null_counts[null_counts > 0].to_dict()}")

    # Check for negative values
    if (df['total_revenue'] < 0).any():
        issues.append("Negative revenue values found")
    if (df['order_count'] < 0).any():
        issues.append("Negative order counts found")

    # Check for zero orders with non-zero revenue
    invalid_aov = (df['order_count'] == 0) & (df['total_revenue'] > 0)
    if invalid_aov.any():
        issues.append("Records with zero orders but positive revenue")

    if issues:
        print("   ⚠️  Validation issues:")
        for issue in issues:
            print(f"      - {issue}")
        return False
    else:
        print("   ✓ All validations passed")
        return True


# =============================================================================
# LOAD
# =============================================================================

def setup_target_schema(engine):
    """Create the target table and views in PostgreSQL if they don't exist."""
    print("\n🏗️  Setting up target schema...")

    # Read and execute the schema SQL file
    schema_path = 'sql/target_schema.sql'
    try:
        with open(schema_path, 'r') as f:
            schema_sql = f.read()

        with engine.connect() as conn:
            # Execute each statement separately
            for statement in schema_sql.split(';'):
                statement = statement.strip()
                if statement:
                    conn.execute(text(statement))
            conn.commit()

        print("   ✓ Target schema ready")
    except FileNotFoundError:
        print(f"   ⚠️  Schema file not found at {schema_path}, creating table inline...")
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS monthly_sales_summary (
            year_month VARCHAR(7) NOT NULL,
            category_name VARCHAR(100) NOT NULL,
            total_revenue DECIMAL(12, 2) NOT NULL,
            order_count INTEGER NOT NULL,
            items_sold INTEGER NOT NULL,
            avg_order_value DECIMAL(10, 2) NOT NULL,
            loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (year_month, category_name)
        )
        """
        with engine.connect() as conn:
            conn.execute(text(create_table_sql))
            conn.commit()
        print("   ✓ Created monthly_sales_summary table")


def load_to_postgres(df: pd.DataFrame, engine):
    """
    Load transformed data into PostgreSQL using truncate-and-load strategy.
    """
    print("\n📤 Loading data to PostgreSQL...")

    table_name = 'monthly_sales_summary'

    # Truncate existing data
    with engine.connect() as conn:
        conn.execute(text(f"TRUNCATE TABLE {table_name}"))
        conn.commit()
    print(f"   ✓ Truncated {table_name}")

    # Load new data
    df.to_sql(
        table_name,
        engine,
        if_exists='append',
        index=False,
        method='multi'
    )
    print(f"   ✓ Loaded {len(df)} records to {table_name}")


# =============================================================================
# MAIN PIPELINE
# =============================================================================

def run_pipeline():
    """Execute the full ETL pipeline."""
    print("=" * 60)
    print("🚀 BASKET CRAFT ETL PIPELINE")
    print(f"   Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    try:
        # Create database connections
        mysql_engine = get_mysql_engine()
        postgres_engine = get_postgres_engine()

        # EXTRACT
        raw_data = extract_orders(mysql_engine)

        # TRANSFORM
        summary_data = transform_to_monthly_summary(raw_data)

        # VALIDATE
        if not validate_data(summary_data):
            raise ValueError("Data validation failed - aborting load")

        # LOAD
        setup_target_schema(postgres_engine)
        load_to_postgres(summary_data, postgres_engine)

        # Summary
        print("\n" + "=" * 60)
        print("✅ PIPELINE COMPLETED SUCCESSFULLY")
        print("=" * 60)
        print("\n📊 Summary Statistics:")
        print(f"   • Records loaded: {len(summary_data)}")
        print(f"   • Total revenue: ${summary_data['total_revenue'].sum():,.2f}")
        print(f"   • Total orders: {summary_data['order_count'].sum():,}")
        print(f"   • Date range: {summary_data['year_month'].min()} to {summary_data['year_month'].max()}")

        # Show sample of loaded data
        print("\n📋 Sample Data (first 5 rows):")
        print(summary_data.head().to_string(index=False))

        return True

    except Exception as e:
        print("\n" + "=" * 60)
        print(f"❌ PIPELINE FAILED: {str(e)}")
        print("=" * 60)
        raise


if __name__ == "__main__":
    run_pipeline()
