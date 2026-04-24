-- ============================================================
-- Customer Behaviour Analysis — SQL Query Workbook
-- Author  : Suhani Sahoo
-- DB      : PostgreSQL 15
-- Dataset : customer_shopping_behavior.csv (3,900 rows)
-- Purpose : Business intelligence queries for retail analytics
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: BASIC EXPLORATION
-- ────────────────────────────────────────────────────────────

-- Q1. Preview dataset
SELECT * FROM customer LIMIT 20;

-- Q2. Summary statistics
SELECT
    COUNT(*)                              AS total_records,
    COUNT(DISTINCT customer_id)           AS unique_customers,
    ROUND(AVG(purchase_amount), 2)        AS avg_purchase,
    MIN(purchase_amount)                  AS min_purchase,
    MAX(purchase_amount)                  AS max_purchase,
    ROUND(STDDEV(purchase_amount), 2)     AS stddev_purchase
FROM customer;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: REVENUE ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q3. Total revenue by gender
SELECT
    gender,
    COUNT(customer_id)                    AS total_transactions,
    ROUND(SUM(purchase_amount), 2)        AS total_revenue,
    ROUND(AVG(purchase_amount), 2)        AS avg_spend
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;

-- Q4. Revenue contribution by age group
-- Business insight: identifies highest-value demographic segments
SELECT
    age_group,
    COUNT(customer_id)                    AS customers,
    ROUND(SUM(purchase_amount), 2)        AS total_revenue,
    ROUND(AVG(purchase_amount), 2)        AS avg_spend,
    ROUND(
        100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 2
    )                                     AS revenue_share_pct
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

-- Q5. Compare average purchase amounts: Standard vs Express Shipping
-- Hypothesis: premium shipping users have higher basket sizes
SELECT
    shipping_type,
    COUNT(*)                              AS orders,
    ROUND(AVG(purchase_amount), 2)        AS avg_purchase,
    ROUND(SUM(purchase_amount), 2)        AS total_revenue
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: PRODUCT ANALYTICS
-- ────────────────────────────────────────────────────────────

-- Q6. Top 5 products by average review rating
SELECT
    item_purchased,
    COUNT(*)                              AS total_orders,
    ROUND(AVG(review_rating), 2)          AS avg_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;

-- Q7. Top 3 most purchased products WITHIN each category
-- Uses window function: ROW_NUMBER() OVER (PARTITION BY category)
WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id)                AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        )                                 AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank;

-- Q8. Products with highest discount uptake rate
-- Flags which items are heavily discount-driven (margin risk)
SELECT
    item_purchased,
    COUNT(*)                              AS total_orders,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_orders,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    )                                     AS discount_rate_pct
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate_pct DESC
LIMIT 5;


-- ────────────────────────────────────────────────────────────
-- SECTION 4: CUSTOMER SEGMENTATION
-- ────────────────────────────────────────────────────────────

-- Q9. Segment customers into New / Returning / Loyal by purchase history
WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        purchase_amount,
        CASE
            WHEN previous_purchases = 1          THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE                                      'Loyal'
        END                                   AS customer_segment
    FROM customer
)
SELECT
    customer_segment,
    COUNT(*)                              AS total_customers,
    ROUND(AVG(purchase_amount), 2)        AS avg_spend,
    ROUND(SUM(purchase_amount), 2)        AS segment_revenue
FROM customer_type
GROUP BY customer_segment
ORDER BY segment_revenue DESC;

-- Q10. Customers who used a discount but still spent above average
-- Identifies high-value discount users worth nurturing
SELECT
    customer_id,
    purchase_amount,
    item_purchased
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer)
ORDER BY purchase_amount DESC
LIMIT 20;

-- Q11. Do subscribed customers spend more?
-- Key metric for subscription ROI analysis
SELECT
    subscription_status,
    COUNT(customer_id)                    AS total_customers,
    ROUND(AVG(purchase_amount), 2)        AS avg_spend,
    ROUND(SUM(purchase_amount), 2)        AS total_revenue,
    ROUND(
        100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 2
    )                                     AS revenue_share_pct
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- Q12. Are repeat buyers more likely to subscribe?
-- Supports churn analysis: loyalty → subscription correlation
SELECT
    subscription_status,
    COUNT(customer_id)                    AS repeat_buyers,
    ROUND(AVG(previous_purchases), 2)     AS avg_previous_purchases
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status
ORDER BY repeat_buyers DESC;


-- ────────────────────────────────────────────────────────────
-- SECTION 5: ADVANCED — RANKING & RUNNING TOTALS
-- ────────────────────────────────────────────────────────────

-- Q13. Customer lifetime value ranking with running total
-- Demonstrates: RANK(), SUM() OVER (ORDER BY), cumulative contribution
WITH customer_ltv AS (
    SELECT
        customer_id,
        gender,
        age_group,
        SUM(purchase_amount)              AS lifetime_value
    FROM customer
    GROUP BY customer_id, gender, age_group
)
SELECT
    customer_id,
    gender,
    age_group,
    ROUND(lifetime_value, 2)              AS lifetime_value,
    RANK() OVER (ORDER BY lifetime_value DESC) AS ltv_rank,
    ROUND(
        SUM(lifetime_value) OVER (ORDER BY lifetime_value DESC
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        / SUM(lifetime_value) OVER () * 100, 2
    )                                     AS cumulative_revenue_pct
FROM customer_ltv
ORDER BY ltv_rank
LIMIT 20;

-- Q14. Category revenue share with percentile banding
-- Shows SQL NTILE() for decile/quartile analysis
SELECT
    category,
    ROUND(SUM(purchase_amount), 2)        AS category_revenue,
    NTILE(4) OVER (ORDER BY SUM(purchase_amount)) AS revenue_quartile
FROM customer
GROUP BY category
ORDER BY category_revenue DESC;
