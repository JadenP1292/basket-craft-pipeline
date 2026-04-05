# Basket Craft ETL Plan

## Executive Summary

Build an ETL pipeline to extract order data from the Basket Craft MySQL database, transform it into monthly aggregated metrics, and load it into a local PostgreSQL database for dashboard consumption.

---

## Phase 1: Extraction

### 1.1 Source Database Discovery

**Questions to answer:**
- [ ] What is the MySQL connection string/host?
- [ ] What tables contain order data?
- [ ] What tables contain product/category data?
- [ ] What is the date range of historical data?
- [ ] Is there a preferred extraction window (e.g., last 12 months)?

### 1.2 Extraction Strategy

| Approach | Description | Use When |
|----------|-------------|----------|
| **Full Extract** | Pull all historical data | Initial load, small datasets |
| **Incremental** | Pull only new/changed records | Large datasets, frequent runs |
| **Date-Bounded** | Pull specific date range | Backfills, testing |

**Recommended**: Start with **Full Extract** for simplicity, add incremental later if needed.

### 1.3 Extraction Query Template

```sql
-- Adjust based on actual Basket Craft schema
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
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
WHERE o.order_date >= :start_date
  AND o.order_date < :end_date;
```

---

## Phase 2: Transformation

### 2.1 Data Cleaning Steps

| Step | Operation | Rationale |
|------|-----------|-----------|
| 1 | Parse dates to datetime | Ensure consistent date handling |
| 2 | Extract year_month | Enable monthly grouping |
| 3 | Handle nulls | Replace or flag missing categories |
| 4 | Validate amounts | Check for negative/zero values |
| 5 | Deduplicate | Remove any duplicate order lines |

### 2.2 Aggregation Logic

```python
# Pandas transformation pseudocode
monthly_summary = (
    df
    .assign(year_month=lambda x: x['order_date'].dt.to_period('M').astype(str))
    .groupby(['year_month', 'category_name'])
    .agg(
        total_revenue=('line_total', 'sum'),
        order_count=('order_id', 'nunique'),
        items_sold=('quantity', 'sum')
    )
    .assign(avg_order_value=lambda x: x['total_revenue'] / x['order_count'])
    .reset_index()
)
```

### 2.3 Output Schema

| Column | Type | Description |
|--------|------|-------------|
| year_month | VARCHAR(7) | Format: '2025-01' |
| category_name | VARCHAR(100) | Product category |
| total_revenue | DECIMAL(12,2) | Sum of line totals |
| order_count | INTEGER | Distinct orders |
| items_sold | INTEGER | Total quantity |
| avg_order_value | DECIMAL(10,2) | Revenue / Orders |

---

## Phase 3: Load

### 3.1 Target Database Setup

```sql
-- Create new database for Basket Craft
CREATE DATABASE basket_craft;

-- Connect to basket_craft, then create schema
CREATE TABLE monthly_sales_summary (
    year_month VARCHAR(7) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    total_revenue DECIMAL(12,2) NOT NULL,
    order_count INTEGER NOT NULL,
    items_sold INTEGER NOT NULL,
    avg_order_value DECIMAL(10,2) NOT NULL,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (year_month, category_name)
);

-- Index for dashboard queries
CREATE INDEX idx_monthly_sales_month ON monthly_sales_summary(year_month);
CREATE INDEX idx_monthly_sales_category ON monthly_sales_summary(category_name);
```

### 3.2 Load Strategy

| Strategy | Method | Pros | Cons |
|----------|--------|------|------|
| **Truncate & Load** | Delete all, insert new | Simple, consistent | Downtime during load |
| **Upsert** | INSERT ON CONFLICT UPDATE | No downtime | More complex |
| **Partition Swap** | Load to staging, swap | Zero downtime | Most complex |

**Recommended**: Start with **Truncate & Load** for simplicity.

### 3.3 Dashboard Views

```sql
-- View for monthly trend analysis
CREATE VIEW v_monthly_trends AS
SELECT
    year_month,
    SUM(total_revenue) as monthly_revenue,
    SUM(order_count) as monthly_orders,
    SUM(total_revenue) / SUM(order_count) as monthly_aov
FROM monthly_sales_summary
GROUP BY year_month
ORDER BY year_month;

-- View for category comparison
CREATE VIEW v_category_performance AS
SELECT
    category_name,
    SUM(total_revenue) as total_revenue,
    SUM(order_count) as total_orders,
    AVG(avg_order_value) as avg_aov
FROM monthly_sales_summary
GROUP BY category_name
ORDER BY total_revenue DESC;
```

---

## Implementation Checklist

### Prerequisites
- [ ] MySQL connection credentials for Basket Craft
- [ ] Basket Craft database schema documentation
- [ ] Docker running with PostgreSQL
- [ ] Python environment with dependencies

### Development Steps
1. [ ] Get MySQL connection details and test connectivity
2. [ ] Explore Basket Craft schema (tables, columns, relationships)
3. [ ] Write and test extraction query
4. [ ] Create PostgreSQL target database and tables
5. [ ] Build Python ETL script with extract/transform/load functions
6. [ ] Test with sample data
7. [ ] Run full pipeline
8. [ ] Validate output against source

### Files to Create
- [ ] `config/database.yaml` - Connection configurations
- [ ] `sql/target_schema.sql` - PostgreSQL DDL
- [ ] `src/extract.py` - MySQL extraction module
- [ ] `src/transform.py` - Pandas transformations
- [ ] `src/load.py` - PostgreSQL loading module
- [ ] `src/pipeline.py` - Main orchestrator
- [ ] `requirements.txt` - Python dependencies

---

## Questions for Stakeholder

Before proceeding with implementation, please clarify:

1. **MySQL Access**: What are the connection details for the Basket Craft MySQL database?

2. **Schema**: Can you share the table structure? Specifically:
   - Orders table name and columns
   - Products/Items table name and columns
   - Categories table name and columns (if separate)

3. **Data Volume**: Approximately how many orders are in the database?

4. **Date Range**: Should we include all historical data or a specific time period?

5. **Refresh Frequency**: How often should the pipeline run (daily, weekly, monthly)?

6. **Dashboard Tool**: What tool will consume this data (Tableau, Power BI, Metabase, etc.)?
