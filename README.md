# Basket Craft Data Pipeline

ETL pipeline that extracts order data from the Basket Craft MySQL database, transforms it into monthly sales aggregations, and loads it into PostgreSQL for dashboard consumption.

## Architecture

```
MySQL (Source)          Python ETL           PostgreSQL (Destination)
┌─────────────┐        ┌──────────┐         ┌───────────────────────┐
│ orders      │───────►│ Extract  │────────►│ monthly_sales_summary │
│ order_items │        │ Transform│         │                       │
│ products    │        │ Load     │         │ Views:                │
│ categories  │        └──────────┘         │ • v_monthly_trends    │
└─────────────┘                             │ • v_category_perf     │
                                            └───────────────────────┘
```

## Quick Start

### 1. Start the Databases

```bash
cd basket-craft-pipeline
docker-compose up -d
```

This starts:
- **MySQL** on port `3306` (source database with sample data)
- **PostgreSQL** on port `5433` (destination for dashboard)

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run the Pipeline

```bash
python src/pipeline.py
```

## Database Connections

### MySQL Source
- **Host**: localhost
- **Port**: 3306
- **Database**: basket_craft
- **User**: basket_craft_user
- **Password**: basket_craft_pass

### PostgreSQL Destination
- **Host**: localhost
- **Port**: 5433
- **Database**: basket_craft_dashboard
- **User**: postgres
- **Password**: postgres

## Pipeline Output

The pipeline produces a `monthly_sales_summary` table with:

| Column | Description |
|--------|-------------|
| year_month | Month in YYYY-MM format |
| category_name | Product category |
| total_revenue | Sum of sales |
| order_count | Number of distinct orders |
| items_sold | Total quantity sold |
| avg_order_value | Revenue / Orders |

## Query Examples

```sql
-- Connect to PostgreSQL
docker exec -it basket_craft_postgres psql -U postgres -d basket_craft_dashboard

-- Monthly revenue trends
SELECT * FROM v_monthly_trends;

-- Top categories by revenue
SELECT * FROM v_category_performance;

-- Month-over-month growth
SELECT * FROM v_mom_growth;
```

## Commands Reference

```bash
# Start databases
docker-compose up -d

# Stop databases
docker-compose down

# Reset (wipe data and reinitialize)
docker-compose down -v && docker-compose up -d

# View MySQL data
docker exec -it basket_craft_mysql mysql -u basket_craft_user -pbasket_craft_pass basket_craft

# View PostgreSQL data
docker exec -it basket_craft_postgres psql -U postgres -d basket_craft_dashboard
```

## File Structure

```
basket-craft-pipeline/
├── docker-compose.yml       # MySQL + PostgreSQL containers
├── requirements.txt         # Python dependencies
├── README.md               # This file
├── docs/
│   ├── pipeline-diagram.md # Architecture diagrams
│   └── etl-plan.md         # Implementation plan
├── sql/
│   ├── mysql_init/         # MySQL schema + sample data
│   │   ├── 01_schema.sql
│   │   └── 02_sample_data.sql
│   └── target_schema.sql   # PostgreSQL target tables
└── src/
    └── pipeline.py         # Main ETL script
```
