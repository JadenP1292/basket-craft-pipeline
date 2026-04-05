# Basket Craft Data Pipeline

An ETL pipeline for Basket Craft, an e-commerce company selling gift baskets. The project extracts order data from MySQL and loads it into two PostgreSQL destinations: AWS RDS (raw data for analytics) and local Docker (aggregated dashboard).

## Architecture

```
                                    ┌─────────────────────────────────────┐
                                    │ AWS RDS PostgreSQL (us-west-2)      │
                    extract_to_     │ basket-craft-db.xxx.rds.amazonaws.com│
                   ┌──rds.py───────►│                                     │
                   │                │ Raw tables (1.77M rows):            │
MySQL (Remote)     │                │ • orders, order_items, products     │
┌─────────────────┐│                │ • users, employees                  │
│ db.isba.co      ││                │ • website_sessions, website_pageviews│
│                 ││                │ • order_item_refunds                │
│ 8 source tables │┘                └─────────────────────────────────────┘
│ 1.77M rows      │
│                 │                 ┌─────────────────────────────────────┐
│                 │  pipeline.py    │ Local Docker PostgreSQL (:5433)     │
│                 │──(aggregation)─►│                                     │
│                 │                 │ • monthly_sales_summary             │
└─────────────────┘                 │ • v_monthly_trends                  │
                                    │ • v_category_performance            │
                                    │ • v_mom_growth                      │
                                    └─────────────────────────────────────┘
```

## Setup

### 1. Create a Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables

Create a `.env` file in the project root (this file is gitignored):

```
# MySQL Source (instructor's database)
MYSQL_HOST=db.isba.co
MYSQL_PORT=3306
MYSQL_USER=your_username
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=basket_craft

# AWS RDS PostgreSQL (cloud destination)
RDS_HOST=basket-craft-db.xxxx.us-west-2.rds.amazonaws.com
RDS_PORT=5432
RDS_USER=student
RDS_PASSWORD=your_password
RDS_DATABASE=basket_craft
```

### 4. Start the Local PostgreSQL Database (optional)

```bash
docker-compose up -d
```

This starts PostgreSQL on port `5433` for local development.

## Running the Pipelines

### Extract Raw Data to AWS RDS

Loads all 8 MySQL tables into AWS RDS PostgreSQL with no transformations:

```bash
python src/extract_to_rds.py
```

### Run Aggregation Pipeline (Local Docker)

Transforms data into monthly summaries for dashboards:

```bash
python src/pipeline.py
```

## AWS RDS Database

The cloud PostgreSQL database contains all raw Basket Craft data:

| Table | Rows | Description |
|-------|------|-------------|
| orders | 32,313 | Order headers with timestamps |
| order_items | 40,025 | Line items with product and price |
| products | 4 | Product catalog |
| users | 31,696 | Customer records |
| employees | 20 | Staff records |
| order_item_refunds | 1,731 | Refund transactions |
| website_sessions | 472,871 | Web analytics sessions |
| website_pageviews | 1,188,124 | Page view events |
| **Total** | **1,766,784** | |

### Products

| Product | Price |
|---------|-------|
| The Original Gift Basket | $49.99 |
| The Valentine's Gift Basket | $59.99 |
| The Birthday Gift Basket | $45.99 |
| The Holiday Gift Basket | $29.99 |

## Commands Reference

```bash
# Extract all tables to AWS RDS
python src/extract_to_rds.py

# Run aggregation pipeline to local Docker
python src/pipeline.py

# Start local PostgreSQL
docker-compose up -d

# Stop local PostgreSQL
docker-compose down

# Reset local PostgreSQL (wipe all data)
docker-compose down -v && docker-compose up -d

# Connect to local PostgreSQL
docker exec -it basket_craft_postgres psql -U postgres -d basket_craft_dashboard

# Query MySQL source directly
source .env && mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

## Querying AWS RDS

Connect via DBeaver or any PostgreSQL client:

| Setting | Value |
|---------|-------|
| Host | `basket-craft-db.xxxx.us-west-2.rds.amazonaws.com` |
| Port | `5432` |
| Database | `basket_craft` |
| Username | `student` |

Example queries:

```sql
-- Top products by revenue
SELECT p.product_name, SUM(oi.price_usd) as revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Monthly order counts
SELECT DATE_TRUNC('month', created_at) as month, COUNT(*) as orders
FROM orders
GROUP BY month
ORDER BY month;
```

## Project Structure

```
basket-craft-pipeline/
├── src/
│   ├── pipeline.py          # Aggregation ETL (MySQL → local PostgreSQL)
│   └── extract_to_rds.py    # Raw extraction (MySQL → AWS RDS)
├── sql/
│   └── target_schema.sql    # Local PostgreSQL schema
├── docs/
│   ├── pipeline-diagram.md  # Architecture documentation
│   └── etl-plan.md          # Implementation planning notes
├── docker-compose.yml       # Local PostgreSQL container
├── requirements.txt         # Python dependencies
├── .env                     # Database credentials (not in git)
└── README.md
```
