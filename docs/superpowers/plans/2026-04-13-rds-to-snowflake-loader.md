# RDS-to-Snowflake Loader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Python script that extracts all 8 raw Basket Craft tables from AWS RDS PostgreSQL and loads them into Snowflake's `basket_craft.raw` schema.

**Architecture:** Single-script loader using pandas for data transfer. Read from RDS via SQLAlchemy, write to Snowflake via `write_pandas()`. Truncate-and-reload strategy ensures idempotent runs.

**Tech Stack:** Python, pandas, SQLAlchemy, snowflake-connector-python, python-dotenv

---

## File Structure

| File | Responsibility |
|------|----------------|
| `requirements.txt` | Add `snowflake-connector-python[pandas]` dependency |
| `src/load_to_snowflake.py` | Main loader script with all functions |

---

## Task 1: Add Snowflake Dependency

**Files:**
- Modify: `requirements.txt`

- [ ] **Step 1: Add snowflake-connector-python to requirements.txt**

Open `requirements.txt` and add this line at the end:

```
snowflake-connector-python[pandas]
```

- [ ] **Step 2: Install the new dependency**

Run:
```bash
source venv/bin/activate && pip install -r requirements.txt
```

Expected: Installation completes with "Successfully installed snowflake-connector-python-X.X.X"

- [ ] **Step 3: Verify installation**

Run:
```bash
python -c "import snowflake.connector; print('Snowflake connector installed successfully')"
```

Expected: "Snowflake connector installed successfully"

- [ ] **Step 4: Commit**

```bash
git add requirements.txt
git commit -m "Add snowflake-connector-python dependency"
```

---

## Task 2: Create Loader Script with Connection Functions

**Files:**
- Create: `src/load_to_snowflake.py`

- [ ] **Step 1: Create the loader script with imports and connection functions**

Create `src/load_to_snowflake.py` with the following content:

```python
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
```

- [ ] **Step 2: Verify syntax is correct**

Run:
```bash
python -c "import src.load_to_snowflake; print('Syntax OK')"
```

Expected: "Syntax OK"

- [ ] **Step 3: Commit**

```bash
git add src/load_to_snowflake.py
git commit -m "Add loader script with connection functions"
```

---

## Task 3: Add the load_table Function

**Files:**
- Modify: `src/load_to_snowflake.py`

- [ ] **Step 1: Add the load_table function**

Add this function to `src/load_to_snowflake.py` after the `get_table_list()` function:

```python
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
```

- [ ] **Step 2: Verify syntax is correct**

Run:
```bash
python -c "import src.load_to_snowflake; print('Syntax OK')"
```

Expected: "Syntax OK"

- [ ] **Step 3: Commit**

```bash
git add src/load_to_snowflake.py
git commit -m "Add load_table function"
```

---

## Task 4: Add the main Function

**Files:**
- Modify: `src/load_to_snowflake.py`

- [ ] **Step 1: Add the main function and entry point**

Add this code at the end of `src/load_to_snowflake.py`:

```python
def main():
    """Main entry point for the loader."""
    # Load environment variables
    load_dotenv()

    print("=" * 50)
    print("RDS to Snowflake Loader")
    print("=" * 50)

    # Test RDS connection
    print("\nConnecting to RDS...", end=" ", flush=True)
    try:
        rds_engine = get_rds_engine()
        with rds_engine.connect() as conn:
            conn.execute("SELECT 1")
        print("OK")
    except Exception as e:
        print(f"FAILED\nError: {e}")
        return 1

    # Test Snowflake connection
    print("Connecting to Snowflake...", end=" ", flush=True)
    try:
        sf_connection = get_snowflake_connection()
        sf_connection.cursor().execute("SELECT 1")
        print("OK")
    except Exception as e:
        print(f"FAILED\nError: {e}")
        return 1

    # Load all tables
    tables = get_table_list()
    results = {}
    failures = []

    print(f"\nLoading {len(tables)} tables...\n")

    for table in tables:
        print(f"[{table}]")
        try:
            row_count = load_table(table, rds_engine, sf_connection)
            results[table] = row_count
        except Exception as e:
            print(f"  ERROR: {e}")
            failures.append(table)
        print()

    # Close connections
    sf_connection.close()
    rds_engine.dispose()

    # Print summary
    print("=" * 50)
    print("Summary")
    print("=" * 50)

    total_rows = 0
    for table, count in results.items():
        print(f"  {table}: {count:,} rows")
        total_rows += count

    print(f"\nTotal: {total_rows:,} rows across {len(results)} tables")

    if failures:
        print(f"\nFailed tables: {', '.join(failures)}")
        return 1

    print("\nComplete! All tables loaded successfully.")
    return 0


if __name__ == "__main__":
    exit(main())
```

- [ ] **Step 2: Verify syntax is correct**

Run:
```bash
python -c "import src.load_to_snowflake; print('Syntax OK')"
```

Expected: "Syntax OK"

- [ ] **Step 3: Commit**

```bash
git add src/load_to_snowflake.py
git commit -m "Add main function and entry point"
```

---

## Task 5: Run the Loader and Verify

**Files:**
- None (execution only)

- [ ] **Step 1: Run the loader**

Run:
```bash
source venv/bin/activate && python src/load_to_snowflake.py
```

Expected output (row counts may vary):
```
==================================================
RDS to Snowflake Loader
==================================================

Connecting to RDS... OK
Connecting to Snowflake... OK

Loading 8 tables...

[orders]
  Reading orders from RDS... X,XXX rows
  Writing to Snowflake... done

[order_items]
  Reading order_items from RDS... XX,XXX rows
  Writing to Snowflake... done

... (continues for all 8 tables)

==================================================
Summary
==================================================
  orders: X,XXX rows
  order_items: XX,XXX rows
  products: X rows
  users: X,XXX rows
  employees: XX rows
  order_item_refunds: XXX rows
  website_sessions: XXX,XXX rows
  website_pageviews: X,XXX,XXX rows

Total: X,XXX,XXX rows across 8 tables

Complete! All tables loaded successfully.
```

- [ ] **Step 2: Verify data in Snowflake**

Open Snowsight, go to your worksheet, and run:

```sql
USE DATABASE basket_craft;
USE SCHEMA raw;

SELECT 'orders' as table_name, COUNT(*) as row_count FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'order_item_refunds', COUNT(*) FROM order_item_refunds
UNION ALL SELECT 'website_sessions', COUNT(*) FROM website_sessions
UNION ALL SELECT 'website_pageviews', COUNT(*) FROM website_pageviews;
```

Expected: Row counts match the loader output.

- [ ] **Step 3: Verify column names are lowercase**

In Snowsight, run:

```sql
DESCRIBE TABLE orders;
```

Expected: Column names should be lowercase (e.g., `order_id`, not `ORDER_ID`).

---

## Task 6: Final Commit and Documentation Update

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update CLAUDE.md with Snowflake loader documentation**

Add a new section to `CLAUDE.md` documenting the Snowflake loader:

```markdown
## Snowflake Loader

### Command
```bash
python src/load_to_snowflake.py
```

### Purpose
Extracts all 8 raw Basket Craft tables from AWS RDS PostgreSQL and loads them into Snowflake `basket_craft.raw` schema.

### Credentials
Reads from `.env`:
- `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_SCHEMA`

### Tables Loaded
orders, order_items, products, users, employees, order_item_refunds, website_sessions, website_pageviews
```

- [ ] **Step 2: Commit all changes**

```bash
git add -A
git commit -m "Add Snowflake loader script

Implements RDS-to-Snowflake data transfer for all 8 raw Basket Craft tables.
Uses truncate-and-reload strategy with lowercase column names for dbt compatibility.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

- [ ] **Step 3: Push to GitHub**

```bash
git push origin main
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] `requirements.txt` includes `snowflake-connector-python[pandas]`
- [ ] `src/load_to_snowflake.py` exists and runs without errors
- [ ] All 8 tables exist in Snowflake `basket_craft.raw` schema
- [ ] Row counts in Snowflake match RDS source
- [ ] Column names in Snowflake are lowercase
- [ ] `CLAUDE.md` documents how to run the Snowflake loader
- [ ] All changes committed and pushed to GitHub
