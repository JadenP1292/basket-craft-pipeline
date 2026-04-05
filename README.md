# Basket Craft Data Pipeline

An ETL pipeline that builds a monthly sales dashboard for Basket Craft, an e-commerce company selling gift baskets. The pipeline extracts order data from MySQL, transforms it into monthly aggregations by product category, and loads it into PostgreSQL for reporting.

## Architecture

```
MySQL (Remote)              Python ETL              PostgreSQL (Local Docker)
┌─────────────────┐        ┌──────────────┐        ┌─────────────────────────┐
│ db.isba.co      │        │              │        │ localhost:5433          │
│                 │        │   Extract    │        │                         │
│ • orders        │───────►│   Transform  │───────►│ • monthly_sales_summary │
│ • order_items   │        │   Validate   │        │                         │
│ • products      │        │   Load       │        │ Views:                  │
│                 │        │              │        │ • v_monthly_trends      │
└─────────────────┘        └──────────────┘        │ • v_category_performance│
                                                   │ • v_mom_growth          │
                                                   └─────────────────────────┘
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
MYSQL_HOST=db.isba.co
MYSQL_PORT=3306
MYSQL_USER=your_username
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=basket_craft
```

### 4. Start the PostgreSQL Database

```bash
docker-compose up -d
```

This starts PostgreSQL on port `5433` (to avoid conflicts with other databases).

### 5. Run the Pipeline

```bash
python src/pipeline.py
```

## Pipeline Output

The pipeline creates a `monthly_sales_summary` table in PostgreSQL:

| Column | Type | Description |
|--------|------|-------------|
| year_month | VARCHAR(7) | Month in YYYY-MM format |
| category_name | VARCHAR(100) | Product category (e.g., "The Original Gift Basket") |
| total_revenue | DECIMAL(12,2) | Sum of sales for the month |
| order_count | INTEGER | Number of distinct orders |
| items_sold | INTEGER | Total quantity sold |
| avg_order_value | DECIMAL(10,2) | Revenue divided by orders |

## Querying the Dashboard

Connect to PostgreSQL and use the pre-built views:

```bash
docker exec -it basket_craft_postgres psql -U postgres -d basket_craft_dashboard
```

```sql
-- Monthly revenue trends
SELECT * FROM v_monthly_trends;

-- Category performance ranking
SELECT * FROM v_category_performance;

-- Month-over-month growth rates
SELECT * FROM v_mom_growth;
```

## Source Data

The Basket Craft MySQL database contains:

| Table | Description |
|-------|-------------|
| `orders` | Order headers with timestamps and totals |
| `order_items` | Line items with product and price |
| `products` | Product catalog (4 gift basket types) |

**Products:**
- The Original Gift Basket ($49.99)
- The Valentine's Gift Basket ($59.99)
- The Birthday Gift Basket ($45.99)
- The Holiday Gift Basket ($29.99)

## Commands Reference

```bash
# Start PostgreSQL
docker-compose up -d

# Stop PostgreSQL
docker-compose down

# Reset PostgreSQL (wipe all data)
docker-compose down -v && docker-compose up -d

# Run the ETL pipeline
python src/pipeline.py

# Connect to PostgreSQL
docker exec -it basket_craft_postgres psql -U postgres -d basket_craft_dashboard

# Query MySQL source directly
source .env && mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

## Project Structure

```
basket-craft-pipeline/
├── src/
│   └── pipeline.py          # Main ETL script
├── sql/
│   └── target_schema.sql    # PostgreSQL table and view definitions
├── docs/
│   ├── pipeline-diagram.md  # Architecture documentation
│   └── etl-plan.md          # Implementation planning notes
├── docker-compose.yml       # PostgreSQL container configuration
├── requirements.txt         # Python dependencies
├── .env                     # MySQL credentials (not in git)
└── README.md
```
