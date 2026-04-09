select * from customers;
select * from geolocation;
select * from order_items;
select * from order_payments;
select * from order_reviews;
select * from orders;
select * from products;
select * from product_category;
select * from sellers;


select geolocation_city, count(*) as count
from geolocation
group by geolocation_city
order by count DESC;



Sales on a Specific day for analysis

select SUM(p.payment_value::numeric) as total_sales
from orders o
join order_payments p on o.order_id = p.order_id
where DATE(o.order_purchase_timestamp::timestamp) = '2018-10-17';




select pc.product_category_name_english as Products_Names,
       '2017-11-24' as Datetime,
       SUM(op.payment_value::numeric)::int as total_sales,
       AVG(op.payment_value::numeric)::int as Average
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
join order_payments op on o.order_id = op.order_id
join product_category pc on p.product_category_name = pc.product_category_name 
where DATE(o.order_purchase_timestamp::timestamp) = '2017-11-24'
group by Products_Names
order by total_sales DESC
limit 5;



SELECT 
    DATE(o.order_purchase_timestamp::timestamp) AS sales_date,
    SUM(p.payment_value::numeric)::int AS total_sales
FROM orders o
join order_payments p ON o.order_id = p.order_id
GROUP BY DATE(o.order_purchase_timestamp::timestamp)
ORDER BY total_sales DESC;

--Monthly Sales

SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)::DATE AS sales_month,
    SUM(p.payment_value::numeric) AS total_sales
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)
ORDER BY sales_month ASC;

-- Yearly Sales

select 
  TO_CHAR(DATE_TRUNC('year', o.order_purchase_timestamp::timestamp), 'YYYY-MM') AS year_sales,
  SUM(p.payment_value::numeric) as total_sales 
from orders o
join order_payments p ON o.order_id = p.order_id
group by DATE_TRUNC('year', o.order_purchase_timestamp::timestamp)
order by year_sales;


-- Top Paying customers including city, Products they bought

select c.customer_id as custom,
       c.customer_city as city,
       p.product_category_name as productss,
       SUM(pay.payment_value::numeric) as total_spend
from customers c  
join orders o on c.customer_id = o.customer_id
join order_payments pay on o.order_id = pay.order_id
join order_items oi on pay.order_id = oi.order_id
join products p on oi.product_id = p.product_id
group by custom, city, productss
order by total_spend desc
limit 10;


WITH customer_product_stats AS (
    SELECT 
        c.customer_id,
        p.product_category_name,
        COUNT(DISTINCT oi.order_id) AS times_bought,
        AVG(r.review_score::numeric) AS avg_review_score,
        SUM(pay.payment_value::numeric) AS total_spent_on_category
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN order_payments pay ON o.order_id = pay.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    GROUP BY c.customer_id, p.product_category_name
)
SELECT 
    customer_id,
    product_category_name,
    times_bought,
    ROUND(avg_review_score, 2) AS avg_review_score,
    ROUND(total_spent_on_category, 2) AS spent
FROM customer_product_stats
WHERE times_bought > 1
ORDER BY customer_id, times_bought DESC;
 

-- Getting average reviews

select 
     ROUND(AVG(om.review_score::numeric), 2) as Reviewss,
     p.product_category_name as Producttt,
     SUM(op.payment_value::numeric) as total_sales
from orders o
join order_reviews om on o.order_id = om.order_id
join order_payments op on o.order_id = op.order_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
group by Producttt
order by reviewss ASC;

-- Highest Customers paying by Rank

with Highest_Customers as (
    select
       c.customer_id,
       SUM(op.payment_value::numeric) as total_sales
     from orders o
     join order_payments op on o.order_id = op.order_id
     join customers c on o.customer_id = c.customer_id
     join order_items ol on o.order_id = ol.order_id
     join products p on ol.product_id = p.product_id 
     group by c.customer_id
)
select
   customer_id,
   total_sales,
   rank() OVER( order by total_sales DESC) as Rankk
from Highest_Customers
order by rankk;

-- Highest Paying Customers and repeated customer

select COUNT(distinct o.order_id) as orders_count,
       c.customer_id as custom,
       c.customer_city as city,
       p.product_category_name as productss,
       SUM(pay.payment_value::numeric) as total_spend
from customers c  
join orders o on c.customer_id = o.customer_id
join order_payments pay on o.order_id = pay.order_id
join order_items oi on pay.order_id = oi.order_id
join products p on oi.product_id = p.product_id
group by custom, city, productss
having COUNT(distinct o.order_id) > 1
order by total_spend desc;

-- Time it took to deliver packages to customers

select 
      COUNT(*)FILTER(where o.order_delivered_customer_date = '') as keepr, 
      Count(*)filter(where o.order_purchase_timestamp = '') as bought,
      COUNT(*)FILTER(where o.order_approved_at = '') as approve
from orders o
order by keepr, bought, approve;


-- Finding out the Datetime Ordered and Delivered, whats the average days it takes to deliver.

with deliverChecker as (
	select
		o.order_id,
    	o.order_purchase_timestamp as time_ordered,
    	o.order_delivered_customer_date as time_delivered,
    	p.product_category_name,
    	EXTRACT(DAY FROM AGE(
        	o.order_delivered_customer_date::timestamp, 
        	o.order_purchase_timestamp::timestamp
    	)) as delivery_days
	FROM orders o
	join order_items oi on o.order_id = oi.order_id
	join products p on oi.product_id = p.product_id 
	WHERE o.order_delivered_customer_date != ''
	and o.order_purchase_timestamp != ''
	AND o.order_delivered_customer_date IS NOT null
	and o.order_status = 'delivered'
)
select
	   AVG(delivery_days)::int as avg_delivery_days,
	   COUNT(*) filter(where delivery_days <= 3) as quickDelivery,
       COUNT(*) FILTER(where delivery_days between 4 and 7) as fastDelivery,
       COUNT(*) FILTER(where delivery_days between 7 and 15) as LateDelivery,
       COUNT(*) FILTER(where delivery_days >= 16) as VerylateDelivery,
       ROUND(100.0 * COUNT(*) FILTER(WHERE delivery_days > 7) / COUNT(*), 2) as PercentageDelivery,
       COUNT(*) as totalorders
from deliverChecker;

-- Finding out which Categories are generating the most money

select pc.product_category_name_english as Productsss,
	   sum(op.payment_value::numeric)::int Total_Sales
from order_items oL
join order_payments op on oL.order_id = op.order_id
join products p on oL.product_id = p.product_id
join product_category pc on p.product_category_name = pc.product_category_name
group by Productsss
order by Total_Sales DESC;


-- Customer Rentention

WITH first_purchase AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(order_purchase_timestamp::timestamp))::date as first_month
    FROM orders
    GROUP BY customer_id
), monthly_activity AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', order_purchase_timestamp::timestamp) as purchase_month
    FROM orders
    GROUP BY customer_id, DATE_TRUNC('month', order_purchase_timestamp::timestamp)
)
SELECT 
    fp.first_month,
    COUNT(DISTINCT fp.customer_id) as total_customers,
    COUNT(DISTINCT CASE WHEN ma.purchase_month = fp.first_month + INTERVAL '1 month' 
          THEN ma.customer_id END) as retained_month_1,
    COUNT(DISTINCT CASE WHEN ma.purchase_month = fp.first_month + INTERVAL '2 month' 
          THEN ma.customer_id END) as retained_month_2
FROM first_purchase fp
LEFT JOIN monthly_activity ma ON fp.customer_id = ma.customer_id
GROUP BY fp.first_month
ORDER BY fp.first_month;

--RFM analysis

WITH max_date AS (
    SELECT MAX(order_purchase_timestamp) as last_date FROM orders
), Subfunc as (
	select
		c.customer_id,
		(SELECT last_date FROM max_date)::date - MAX(o.order_purchase_timestamp::date) as days_since_last,
		count(distinct o.order_id) as order_count,
		sum(pay.payment_value::numeric) total_spend
	from customers c
	LEFT JOIN orders o ON c.customer_id = o.customer_id
	left join order_payments pay on o.order_id = pay.order_id
	group by c.customer_id
), rfm_scores AS (
	select
		customer_id,
		days_since_last,
		order_count,
		total_spend,
		NTILE(5) OVER(order BY days_since_last DESC) recency_score,
		NTILE(5) OVER(order by order_count DESC) as frequency_score,
		NTILE(5) OVER(order by total_spend desc nulls LAST) as monetary_score
	from subfunc
	where total_spend is not null
)
select 
	customer_id,
	days_since_last,
	order_count,
	ROUND(total_spend::numeric, 2) as total_spend,
	recency_score,
	frequency_score,
	monetary_score,
	CONCAT(recency_score, frequency_score, monetary_score) as rfm_score,
	case
		when CONCAT(recency_score, frequency_score, monetary_score) in ('555', '554', '545', '455') 
		THEN 'champions'
		WHEN CONCAT(recency_score, frequency_score, monetary_score) LIKE '5%' THEN 'Recent customer'
		WHEN frequency_score >= 4 AND monetary_score >= 4 THEN 'Loyal customers'
		WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost customers'
		ELSE 'Regular customers'
	END as customer_segment
FROM rfm_scores
ORDER BY recency_score DESC, frequency_score DESC, monetary_score desc;


	
-- Calculate cumulative revenue over time.


with Funt as (
	select
		o.order_id as orderss,
		sum(pay.payment_value::numeric) as total_sales,
		o.order_purchase_timestamp::date as Datetimess
	from orders o 
	left join order_payments pay on o.order_id = pay.order_id
	group by orderss, o.order_purchase_timestamp::date
)
select
	orderss,
	Datetimess,
	sum(total_sales::numeric) OVER(order by DateTimess ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::int as Sales_over_time
from Funt;

-- Where revenue dropped compared to previous month.

with badmonth as (
	select
		TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp::timestamp), 'YYYY-MM') as monthly,
		sum(pay.payment_value::numeric) total_sales
	from orders o
	left join order_payments pay on o.order_id = pay.order_id
	group by DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)
), secondcte as (
	select
		monthly,
		total_sales,
		total_sales - lag(total_sales) OVER(order by monthly) as droppedrevenue
	from badmonth
	where total_sales is not null
)
select 
	monthly,
	droppedrevenue::int,
	CASE
        WHEN droppedrevenue > 0 THEN 'Increase_Sales'
        WHEN droppedrevenue < 0 THEN 'Sales_Drop'
        ELSE 'No Change'
    END AS sales_trend
from secondcte
where droppedrevenue < 0;








