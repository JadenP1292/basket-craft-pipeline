# Basket Craft Data Pipeline Architecture

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BASKET CRAFT DATA PIPELINE                           │
│                     Monthly Sales Dashboard Pipeline                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   SOURCE    │      │   TRANSFORM      │      │   DESTINATION   │
│             │      │                  │      │                 │
│  ┌───────┐  │      │  ┌────────────┐  │      │  ┌───────────┐  │
│  │ MySQL │  │ ───► │  │  Python    │  │ ───► │  │PostgreSQL │  │
│  │  DB   │  │      │  │  Pandas    │  │      │  │  Docker   │  │
│  └───────┘  │      │  └────────────┘  │      │  └───────────┘  │
│             │      │                  │      │                 │
│ Basket Craft│      │  Aggregations:   │      │ Dashboard-Ready │
│ Orders &    │      │  • Monthly sums  │      │ Tables:         │
│ Products    │      │  • Category      │      │ • monthly_sales │
│             │      │    grouping      │      │ • category_     │
│             │      │  • Calculations  │      │   summary       │
└─────────────┘      └──────────────────┘      └─────────────────┘
```

## Data Flow Diagram

```
                              EXTRACT
    ┌──────────────────────────────────────────────────────────┐
    │                                                          │
    │   MySQL (Basket Craft)                                   │
    │   ┌─────────────┐    ┌─────────────┐    ┌────────────┐   │
    │   │   orders    │    │  products   │    │ categories │   │
    │   │             │    │             │    │            │   │
    │   │ order_id    │    │ product_id  │    │ category_  │   │
    │   │ order_date  │    │ name        │    │   id       │   │
    │   │ product_id  │◄──►│ category_id │◄──►│ name       │   │
    │   │ quantity    │    │ price       │    │            │   │
    │   │ unit_price  │    │             │    │            │   │
    │   │ total_amount│    │             │    │            │   │
    │   └─────────────┘    └─────────────┘    └────────────┘   │
    │                                                          │
    └────────────────────────────┬─────────────────────────────┘
                                 │
                                 ▼
                            TRANSFORM
    ┌──────────────────────────────────────────────────────────┐
    │                                                          │
    │   Python ETL Script (extract_transform.py)               │
    │                                                          │
    │   1. Extract: Pull raw data via SQLAlchemy/pymysql       │
    │                                                          │
    │   2. Join: Combine orders + products + categories        │
    │                                                          │
    │   3. Aggregate:                                          │
    │      ┌─────────────────────────────────────────────┐     │
    │      │  GROUP BY: year_month, category_name        │     │
    │      │                                             │     │
    │      │  CALCULATE:                                 │     │
    │      │    • total_revenue = SUM(total_amount)      │     │
    │      │    • order_count   = COUNT(DISTINCT order)  │     │
    │      │    • avg_order_value = revenue / orders     │     │
    │      └─────────────────────────────────────────────┘     │
    │                                                          │
    │   4. Validate: Check for nulls, data types, ranges       │
    │                                                          │
    └────────────────────────────┬─────────────────────────────┘
                                 │
                                 ▼
                               LOAD
    ┌──────────────────────────────────────────────────────────┐
    │                                                          │
    │   PostgreSQL (Docker - localhost:5432)                   │
    │   Database: basket_craft                                 │
    │                                                          │
    │   ┌─────────────────────────────────────────────────┐    │
    │   │  TABLE: monthly_sales_summary                   │    │
    │   │                                                 │    │
    │   │  year_month      VARCHAR(7)   -- '2025-01'      │    │
    │   │  category_name   VARCHAR(100)                   │    │
    │   │  total_revenue   DECIMAL(12,2)                  │    │
    │   │  order_count     INTEGER                        │    │
    │   │  avg_order_value DECIMAL(10,2)                  │    │
    │   │  created_at      TIMESTAMP                      │    │
    │   │                                                 │    │
    │   │  PRIMARY KEY (year_month, category_name)        │    │
    │   └─────────────────────────────────────────────────┘    │
    │                                                          │
    │   ┌─────────────────────────────────────────────────┐    │
    │   │  VIEW: v_dashboard_metrics                      │    │
    │   │                                                 │    │
    │   │  - Monthly trends                               │    │
    │   │  - Category comparisons                         │    │
    │   │  - YoY growth calculations                      │    │
    │   └─────────────────────────────────────────────────┘    │
    │                                                          │
    └──────────────────────────────────────────────────────────┘
```

## Component Details

### Source: MySQL (Basket Craft)
- **Connection**: MySQL database with order and product data
- **Tables needed**: orders, products, categories (or similar)
- **Access**: Read-only connection for extraction

### Transform: Python ETL
- **Technology**: Python with pandas, SQLAlchemy
- **Input**: Raw transactional data
- **Output**: Aggregated monthly summaries
- **Key operations**:
  - Date parsing and month extraction
  - Category denormalization (join)
  - Revenue/count/average calculations

### Destination: PostgreSQL (Docker)
- **Host**: localhost:5432
- **Database**: basket_craft (new database)
- **Schema**: Dashboard-optimized tables
- **Refresh**: Full reload or incremental (configurable)

## Pipeline Execution Flow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  START  │───►│ Connect │───►│ Extract │───►│Transform│───►│  Load   │
│         │    │ to DBs  │    │  Data   │    │  Data   │    │  Data   │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                   │              │              │              │
                   ▼              ▼              ▼              ▼
              ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
              │  Test   │    │  Log    │    │Validate │    │  Log    │
              │ Conns   │    │  Rows   │    │  Data   │    │ Success │
              └─────────┘    └─────────┘    └─────────┘    └─────────┘
                                                               │
                                                               ▼
                                                          ┌─────────┐
                                                          │   END   │
                                                          └─────────┘
```

## File Structure

```
basket-craft-pipeline/
├── docs/
│   └── pipeline-diagram.md      # This file
├── config/
│   └── database.yaml            # Connection configs
├── src/
│   ├── extract.py               # MySQL extraction
│   ├── transform.py             # Data transformations
│   ├── load.py                  # PostgreSQL loading
│   └── pipeline.py              # Main orchestrator
├── sql/
│   ├── source_queries.sql       # MySQL extraction queries
│   └── target_schema.sql        # PostgreSQL DDL
├── tests/
│   └── test_pipeline.py         # Unit tests
├── requirements.txt             # Python dependencies
└── README.md                    # Setup instructions
```
