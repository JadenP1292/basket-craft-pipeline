# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Basket Craft is an ETL pipeline that extracts order data from a remote MySQL database, transforms it into monthly sales aggregations, and loads it into a local PostgreSQL database for dashboard consumption.

## Commands

```bash
# Start PostgreSQL destination database
docker-compose up -d

# Run the ETL pipeline
python src/pipeline.py

# Stop databases
docker-compose down

# Reset databases (wipe data)
docker-compose down -v && docker-compose up -d

# Connect to PostgreSQL destination
docker exec basket_craft_postgres psql -U postgres -d basket_craft_dashboard

# Query MySQL source (uses .env credentials)
source .env && mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

## Architecture

```
MySQL (db.isba.co)      Python ETL           PostgreSQL (localhost:5433)
┌─────────────┐        ┌──────────┐         ┌───────────────────────┐
│ orders      │───────►│ Extract  │────────►│ monthly_sales_summary │
│ order_items │        │ Transform│         │                       │
│ products    │        │ Load     │         │ Views:                │
└─────────────┘        └──────────┘         │ • v_monthly_trends    │
                                            │ • v_category_perf     │
                                            │ • v_mom_growth        │
                                            └───────────────────────┘
```

- **Source**: Remote MySQL at `db.isba.co` (credentials in `.env`)
- **Destination**: Local PostgreSQL in Docker on port `5433`
- **Pipeline**: Single Python script with Extract → Transform → Validate → Load stages

## Database Connections

### MySQL Source (remote)
Credentials loaded from `.env` file:
- `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`

### PostgreSQL Destination (local Docker)
- Host: `localhost`
- Port: `5433`
- Database: `basket_craft_dashboard`
- User/Password: `postgres/postgres`

## Environment Setup

Use a Python virtual environment to manage dependencies.

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Required `.env` file (not in git):
```
MYSQL_HOST=db.isba.co
MYSQL_PORT=3306
MYSQL_USER=<user>
MYSQL_PASSWORD=<password>
MYSQL_DATABASE=basket_craft
```
