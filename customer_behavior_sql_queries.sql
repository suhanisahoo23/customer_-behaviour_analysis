select * from customer limit 20;

--Total revenue by gender
SELECT gender,
SUM(purchase_amount) as revenue
FROM customer
GROUP BY gender;

--customers who used a discount but spent above averagr
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes'
and purchase_amount > (select AVG(purchase_amount) from customer);

--Which are the top 5 products with the highest average review rating?
select item_purchased,
AVG(review_rating) as "Average Product Rating"
from customer
group by item_purchased
order by AVG(review_rating) desc
limit 5;

-- Q4. Compare the average purchase amounts between Standard and Express Shipping

select shipping_type,
ROUND(AVG(purchase_amount),2) as avg_purchase
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

-- Q5. Do subscribed customers spend more? Compare average spend and total revenue

select subscription_status,
count(customer_id) as total_customers,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;

-- Q6. Which 5 products have the highest percentage of purchases with discounts applied?

select item_purchased,
ROUND(
100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
2
) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

-- Q7. Segment customers into New, Returning, and Loyal based on number of previous purchases

with customer_type as (
    select customer_id,
    previous_purchases,
    case
        when previous_purchases = 1 then 'New'
        when previous_purchases between 2 and 10 then 'Returning'
        else 'Loyal'
    end as customer_segment
    from customer
)

select customer_segment,
count(*) as "Number of Customers"
from customer_type
group by customer_segment;

-- Q8. Top 3 most purchased products within each category

with item_counts as (
    select category,
    item_purchased,
    count(customer_id) as total_orders,
    row_number() over (
        partition by category
        order by count(customer_id) desc
    ) as item_rank
    from customer
    group by category, item_purchased
)

select item_rank,
category,
item_purchased,
total_orders
from item_counts
where item_rank <= 3;

-- Q9. Are repeat buyers (more than 5 previous purchases) likely to subscribe?

select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

-- Q10. Revenue contribution by each age group

select age_group,
sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;