-- ============================================================
-- SALES PERFORMANCE ANALYSIS - 2024
-- Author: Elizabeth
-- Tools: SQL
-- Description: Queries to analyze sales trends, top products,
--              and regional performance
-- ============================================================


-- ── 1. TOTAL REVENUE & UNITS SOLD ────────────────────────────────────────────
-- Overview of overall business performance

SELECT
    SUM(total_sales)  AS total_revenue,
    SUM(units_sold)   AS total_units_sold,
    ROUND(AVG(profit_margin) * 100, 2) AS avg_profit_margin_pct
FROM sales_data;


-- ── 2. MONTHLY SALES TREND ────────────────────────────────────────────────────
-- Identify which months performed best throughout the year

SELECT
    month,
    SUM(total_sales)  AS monthly_revenue,
    SUM(units_sold)   AS monthly_units
FROM sales_data
GROUP BY month
ORDER BY
    CASE month
        WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
    END;


-- ── 3. SALES BY REGION ───────────────────────────────────────────────────────
-- Determine which regions are driving the most revenue

SELECT
    region,
    SUM(total_sales)                        AS regional_revenue,
    SUM(units_sold)                         AS regional_units,
    ROUND(SUM(total_sales) * 100.0 /
        (SELECT SUM(total_sales) FROM sales_data), 2) AS revenue_share_pct
FROM sales_data
GROUP BY region
ORDER BY regional_revenue DESC;


-- ── 4. TOP PERFORMING PRODUCTS ───────────────────────────────────────────────
-- Rank products by total revenue generated

SELECT
    product,
    SUM(total_sales)                         AS product_revenue,
    SUM(units_sold)                          AS units_sold,
    ROUND(AVG(unit_price), 2)                AS avg_unit_price,
    ROUND(AVG(profit_margin) * 100, 2)       AS avg_margin_pct
FROM sales_data
GROUP BY product
ORDER BY product_revenue DESC;


-- ── 5. BEST MONTH PER REGION ─────────────────────────────────────────────────
-- Find each region's strongest sales month

SELECT
    region,
    month,
    SUM(total_sales) AS revenue
FROM sales_data
GROUP BY region, month
HAVING SUM(total_sales) = (
    SELECT MAX(monthly_total)
    FROM (
        SELECT region AS r, month AS m, SUM(total_sales) AS monthly_total
        FROM sales_data
        GROUP BY region, month
    ) sub
    WHERE sub.r = sales_data.region
)
ORDER BY region;


-- ── 6. PRODUCT PERFORMANCE BY REGION ─────────────────────────────────────────
-- Cross-tabulate products and regions to find hidden opportunities

SELECT
    product,
    region,
    SUM(total_sales) AS revenue,
    SUM(units_sold)  AS units
FROM sales_data
GROUP BY product, region
ORDER BY product, revenue DESC;


-- ── 7. MONTHLY GROWTH RATE ────────────────────────────────────────────────────
-- Calculate month-over-month revenue growth (using a subquery approach)

SELECT
    curr.month,
    curr.monthly_revenue,
    prev.monthly_revenue                                      AS prev_month_revenue,
    ROUND((curr.monthly_revenue - prev.monthly_revenue) * 100.0
        / NULLIF(prev.monthly_revenue, 0), 2)                AS growth_pct
FROM (
    SELECT month,
           CASE month
               WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
               WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
               WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
               WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
           END AS month_num,
           SUM(total_sales) AS monthly_revenue
    FROM sales_data
    GROUP BY month
) curr
LEFT JOIN (
    SELECT month,
           CASE month
               WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
               WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
               WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
               WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
           END AS month_num,
           SUM(total_sales) AS monthly_revenue
    FROM sales_data
    GROUP BY month
) prev ON curr.month_num = prev.month_num + 1
ORDER BY curr.month_num;
