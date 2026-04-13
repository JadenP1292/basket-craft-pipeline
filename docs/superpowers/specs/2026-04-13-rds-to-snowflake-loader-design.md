# RDS-to-Snowflake Loader Design

**Date:** 2026-04-13
**Status:** Approved
**Purpose:** Extract raw Basket Craft tables from AWS RDS PostgreSQL and load into Snowflake

---

## Overview

This loader is the second hop in the Basket Craft ELT pipeline:
- **Hop 1:** MySQL (db.isba.co) → AWS RDS PostgreSQL *(completed in Session 02)*
- **Hop 2:** AWS RDS PostgreSQL → Snowflake *(this design)*

The loader transfers all 8 raw tables without transformation. Transformations happen later in dbt (Session 04).

---

## Architecture

```
AWS RDS PostgreSQL                    Snowflake
┌─────────────────────┐              ┌─────────────────────────────────┐
│ basket_craft DB     │              │ BASKET_CRAFT.RAW schema         │
│                     │              │                                 │
│ • orders            │              │ • orders                        │
│ • order_items       │   Python     │ • order_items                   │
│ • products          │──────────────│ • products                      │
│ • users             │  loader      │ • users                         │
│ • employees         │              │ • employees                     │
│ • order_item_refunds│              │ • order_item_refunds            │
│ • website_sessions  │              │ • website_sessions              │
│ • website_pageviews │              │ • website_pageviews             │
└─────────────────────┘              └─────────────────────────────────┘
```

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Re-run behavior** | Truncate and reload | Simple, guarantees source/destination match, matches existing pipeline pattern |
| **Column casing** | Lowercase everywhere | Prevents dbt "column not found" errors in Part 4 |
| **Memory strategy** | Load entire table | Dataset is small (~1.77M rows total), keeps code simple |
| **Loading method** | `snowflake-connector-python` with `write_pandas()` | Clean API, bulk loading via internal COPY INTO |

---

## Script Structure

**File:** `src/load_to_snowflake.py`

### Functions

1. **`get_rds_engine()`**
   - Create SQLAlchemy engine for RDS
   - Read credentials from `.env`

2. **`get_snowflake_connection()`**
   - Create Snowflake connection using `snowflake.connector`
   - Read credentials from `.env`

3. **`get_table_list()`**
   - Return list of 8 tables to transfer

4. **`load_table(table_name, rds_engine, sf_connection)`**
   - Read entire table from RDS into pandas DataFrame
   - Convert column names to lowercase
   - Truncate target table in Snowflake (if exists)
   - Use `write_pandas()` to bulk load
   - Return row count

5. **`main()`**
   - Load environment variables
   - Test both connections before starting
   - Loop through all tables
   - Print summary with row counts

---

## Configuration

### Environment Variables (from `.env`)

**RDS Source (existing):**
- `RDS_HOST`
- `RDS_PORT`
- `RDS_USER`
- `RDS_PASSWORD`
- `RDS_DATABASE`

**Snowflake Destination (new):**
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_WAREHOUSE`
- `SNOWFLAKE_DATABASE`
- `SNOWFLAKE_SCHEMA`

---

## Dependencies

Add to `requirements.txt`:
```
snowflake-connector-python[pandas]
```

---

## Error Handling

1. **Connection validation:** Test both RDS and Snowflake connections before starting any transfers
2. **Connection failure:** Exit immediately with clear error message
3. **Table failure:** Log error, continue with remaining tables, report all failures at end
4. **Success logging:** Print row count for each table as it completes

---

## Expected Output

```
Connecting to RDS... OK
Connecting to Snowflake... OK

Loading orders... 12,345 rows
Loading order_items... 45,678 rows
Loading products... 4 rows
Loading users... 1,234 rows
Loading employees... 20 rows
Loading order_item_refunds... 567 rows
Loading website_sessions... 472,871 rows
Loading website_pageviews... 1,188,124 rows

Complete! 8 tables loaded successfully.
```

---

## Verification

After running, verify in Snowflake:
```sql
USE DATABASE basket_craft;
USE SCHEMA raw;

SELECT 'orders' as table_name, COUNT(*) as rows FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'users', COUNT(*) FROM users;
```

Row counts should match RDS source.
