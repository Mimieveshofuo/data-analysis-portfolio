-- ============================================================
-- CUSTOMER SEGMENTATION ANALYSIS
-- Author: Elizabeth
-- Tools: SQL
-- Description: Queries to segment customers by purchase behavior
--              and identify high-value vs at-risk customers
-- ============================================================


-- ── 1. OVERVIEW: TOTAL CUSTOMERS & REVENUE ───────────────────────────────────
SELECT
    COUNT(customer_id)              AS total_customers,
    ROUND(SUM(total_spend), 2)      AS total_revenue,
    ROUND(AVG(total_spend), 2)      AS avg_spend_per_customer,
    ROUND(AVG(total_purchases), 2)  AS avg_orders_per_customer
FROM customers;


-- ── 2. SEGMENT CUSTOMERS BY SPEND & PURCHASE FREQUENCY ──────────────────────
-- Classify each customer into a segment

SELECT
    customer_id,
    age,
    gender,
    location,
    total_purchases,
    total_spend,
    CASE
        WHEN total_spend >= 5000 AND total_purchases >= 20 THEN 'High Value'
        WHEN total_spend >= 2000 AND total_purchases >= 10 THEN 'Mid Value'
        WHEN total_purchases <= 3                          THEN 'At Risk'
        ELSE 'Low Value'
    END AS segment
FROM customers
ORDER BY total_spend DESC;


-- ── 3. SEGMENT SUMMARY ───────────────────────────────────────────────────────
-- Count customers and revenue per segment

SELECT
    segment,
    COUNT(customer_id)              AS num_customers,
    ROUND(SUM(total_spend), 2)      AS total_revenue,
    ROUND(AVG(total_spend), 2)      AS avg_spend,
    ROUND(AVG(total_purchases), 2)  AS avg_purchases
FROM (
    SELECT
        customer_id,
        total_purchases,
        total_spend,
        CASE
            WHEN total_spend >= 5000 AND total_purchases >= 20 THEN 'High Value'
            WHEN total_spend >= 2000 AND total_purchases >= 10 THEN 'Mid Value'
            WHEN total_purchases <= 3                          THEN 'At Risk'
            ELSE 'Low Value'
        END AS segment
    FROM customers
) segmented
GROUP BY segment
ORDER BY total_revenue DESC;


-- ── 4. HIGH VALUE CUSTOMERS ──────────────────────────────────────────────────
-- List all high value customers for targeted campaigns

SELECT
    customer_id,
    age,
    gender,
    location,
    total_purchases,
    ROUND(total_spend, 2)       AS total_spend,
    ROUND(avg_order_value, 2)   AS avg_order_value
FROM customers
WHERE total_spend >= 5000 AND total_purchases >= 20
ORDER BY total_spend DESC;


-- ── 5. AT RISK CUSTOMERS ─────────────────────────────────────────────────────
-- Identify customers who haven't purchased much — re-engagement targets

SELECT
    customer_id,
    age,
    gender,
    location,
    total_purchases,
    ROUND(total_spend, 2)           AS total_spend,
    last_purchase_months_ago
FROM customers
WHERE total_purchases <= 3
ORDER BY last_purchase_months_ago DESC;


-- ── 6. CUSTOMERS BY LOCATION ─────────────────────────────────────────────────
-- Understand geographic distribution of customers

SELECT
    location,
    COUNT(customer_id)              AS num_customers,
    ROUND(SUM(total_spend), 2)      AS total_spend,
    ROUND(AVG(total_spend), 2)      AS avg_spend
FROM customers
GROUP BY location
ORDER BY total_spend DESC;


-- ── 7. GENDER BREAKDOWN BY SEGMENT ──────────────────────────────────────────
-- Understand gender distribution within each customer segment

SELECT
    segment,
    gender,
    COUNT(customer_id) AS num_customers,
    ROUND(AVG(total_spend), 2) AS avg_spend
FROM (
    SELECT
        customer_id,
        gender,
        total_spend,
        CASE
            WHEN total_spend >= 5000 AND total_purchases >= 20 THEN 'High Value'
            WHEN total_spend >= 2000 AND total_purchases >= 10 THEN 'Mid Value'
            WHEN total_purchases <= 3                          THEN 'At Risk'
            ELSE 'Low Value'
        END AS segment
    FROM customers
) segmented
GROUP BY segment, gender
ORDER BY segment, gender;


-- ── 8. AGE GROUP ANALYSIS ────────────────────────────────────────────────────
-- Group customers by age band and analyze spending behavior

SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(customer_id)              AS num_customers,
    ROUND(AVG(total_spend), 2)      AS avg_spend,
    ROUND(AVG(total_purchases), 2)  AS avg_purchases
FROM customers
GROUP BY age_group
ORDER BY age_group;
