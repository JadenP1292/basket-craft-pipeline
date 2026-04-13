# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Basket Craft is an ETL pipeline that extracts order data from a remote MySQL database and loads it into multiple destinations for dashboard consumption and analytics. There are three destinations: local Docker PostgreSQL for development, AWS RDS PostgreSQL for cloud deployment, and Snowflake for data warehousing.

## Commands

```bash
# Extract raw tables from MySQL → AWS RDS (no transformations)
python src/extract_to_rds.py

# Load raw tables from AWS RDS → Snowflake
python src/load_to_snowflake.py

# Run aggregation pipeline to local Docker PostgreSQL
python src/pipeline.py

# Start local PostgreSQL container
docker-compose up -d

# Stop local PostgreSQL container
docker-compose down

# Reset local PostgreSQL (wipe data)
docker-compose down -v && docker-compose up -d

# Query MySQL source
source .env && mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"

# Connect to local Docker PostgreSQL
docker exec basket_craft_postgres psql -U postgres -d basket_craft_dashboard

# Query AWS RDS via Python (psql not installed locally)
python -c "
from dotenv import load_dotenv; import os; load_dotenv()
from sqlalchemy import create_engine, text
engine = create_engine(f\"postgresql://{os.getenv('RDS_USER')}:{os.getenv('RDS_PASSWORD')}@{os.getenv('RDS_HOST')}:{os.getenv('RDS_PORT')}/{os.getenv('RDS_DATABASE')}\")
with engine.connect() as c: print(c.execute(text('SELECT * FROM products')).fetchall())
"
```

## Architecture

```
MySQL (db.isba.co)                    Destinations
┌─────────────────────┐              ┌─────────────────────────────────┐
│ 8 tables:           │              │ Local Docker (localhost:5433)  │
│ • orders            │──pipeline.py─│ • monthly_sales_summary (agg)  │
│ • order_items       │              │ • dashboard views              │
│ • products          │              └─────────────────────────────────┘
│ • users             │
│ • employees         │              ┌─────────────────────────────────┐
│ • order_item_refunds│extract_to_   │ AWS RDS (us-east-1)             │
│ • website_sessions  │──rds.py─────►│ • All 8 raw tables (1.77M rows) │
│ • website_pageviews │              │ • basket_craft database         │
└─────────────────────┘              └─────────────────────────────────┘
                                                    │
                                                    │ load_to_
                                                    │ snowflake.py
                                                    ▼
                                     ┌─────────────────────────────────┐
                                     │ Snowflake (us-east-1)           │
                                     │ • BASKET_CRAFT.RAW schema       │
                                     │ • All 8 raw tables (1.77M rows) │
                                     └─────────────────────────────────┘
```

## Scripts

| Script | Purpose | Destination |
|--------|---------|-------------|
| `src/extract_to_rds.py` | Raw table extraction (all 8 tables, no transforms) | AWS RDS |
| `src/load_to_snowflake.py` | Load raw tables from RDS to Snowflake | Snowflake |
| `src/pipeline.py` | Monthly aggregation pipeline | Local Docker PostgreSQL |

## Database Connections

### MySQL Source
Credentials from `.env`: `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`

### AWS RDS PostgreSQL (cloud)
Credentials from `.env`: `RDS_HOST`, `RDS_PORT`, `RDS_USER`, `RDS_PASSWORD`, `RDS_DATABASE`

### Local Docker PostgreSQL (development)
- Host: `localhost`
- Port: `5433`
- Database: `basket_craft_dashboard`
- User/Password: `postgres/postgres`

### Snowflake (data warehouse)
Credentials from `.env`: `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_SCHEMA`
- Database: `BASKET_CRAFT`
- Schema: `RAW`
- Warehouse: `BASKET_CRAFT_WH`

## Environment Setup

Use a Python virtual environment:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Required `.env` file (not in git):
```
# MySQL Source
MYSQL_HOST=db.isba.co
MYSQL_PORT=3306
MYSQL_USER=<user>
MYSQL_PASSWORD=<password>
MYSQL_DATABASE=basket_craft

# AWS RDS PostgreSQL
RDS_HOST=<instance>.us-east-1.rds.amazonaws.com
RDS_PORT=5432
RDS_USER=<user>
RDS_PASSWORD=<password>
RDS_DATABASE=basket_craft

# Snowflake
SNOWFLAKE_ACCOUNT=<account>.us-east-1
SNOWFLAKE_USER=<user>
SNOWFLAKE_PASSWORD=<password>
SNOWFLAKE_ROLE=ACCOUNTADMIN
SNOWFLAKE_WAREHOUSE=basket_craft_wh
SNOWFLAKE_DATABASE=basket_craft
SNOWFLAKE_SCHEMA=raw
```
