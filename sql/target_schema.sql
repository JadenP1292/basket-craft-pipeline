-- PostgreSQL Target Schema for Basket Craft Dashboard
-- This schema is optimized for monthly sales reporting

-- Main aggregated table for dashboard
CREATE TABLE IF NOT EXISTS monthly_sales_summary (
    year_month VARCHAR(7) NOT NULL,           -- Format: '2024-10'
    category_name VARCHAR(100) NOT NULL,
    total_revenue DECIMAL(12, 2) NOT NULL,    -- Sum of all line totals
    order_count INTEGER NOT NULL,              -- Count of distinct orders
    items_sold INTEGER NOT NULL,               -- Total quantity sold
    avg_order_value DECIMAL(10, 2) NOT NULL,  -- Revenue / Orders
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (year_month, category_name)
);

-- Indexes for common dashboard queries
CREATE INDEX IF NOT EXISTS idx_monthly_sales_month
    ON monthly_sales_summary(year_month);
CREATE INDEX IF NOT EXISTS idx_monthly_sales_category
    ON monthly_sales_summary(category_name);
CREATE INDEX IF NOT EXISTS idx_monthly_sales_revenue
    ON monthly_sales_summary(total_revenue DESC);

-- View: Monthly trends (all categories combined)
CREATE OR REPLACE VIEW v_monthly_trends AS
SELECT
    year_month,
    SUM(total_revenue) as monthly_revenue,
    SUM(order_count) as monthly_orders,
    SUM(items_sold) as monthly_items,
    ROUND(SUM(total_revenue) / NULLIF(SUM(order_count), 0), 2) as monthly_aov
FROM monthly_sales_summary
GROUP BY year_month
ORDER BY year_month;

-- View: Category performance summary
CREATE OR REPLACE VIEW v_category_performance AS
SELECT
    category_name,
    SUM(total_revenue) as total_revenue,
    SUM(order_count) as total_orders,
    SUM(items_sold) as total_items,
    ROUND(AVG(avg_order_value), 2) as avg_aov,
    COUNT(DISTINCT year_month) as months_active
FROM monthly_sales_summary
GROUP BY category_name
ORDER BY total_revenue DESC;

-- View: Month-over-month growth
CREATE OR REPLACE VIEW v_mom_growth AS
WITH monthly_totals AS (
    SELECT
        year_month,
        SUM(total_revenue) as revenue
    FROM monthly_sales_summary
    GROUP BY year_month
)
SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY year_month) as prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year_month)) /
        NULLIF(LAG(revenue) OVER (ORDER BY year_month), 0) * 100,
        2
    ) as mom_growth_pct
FROM monthly_totals
ORDER BY year_month;
