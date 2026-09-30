/*
===============================================================================
View:        gold.report_customers
Database:    DataWarehouse
Purpose:
    Provides customer-level analytics for reporting and customer segmentation.

Description:
    - Combines sales and customer dimension data.
    - Aggregates sales activity at the customer level.
    - Calculates customer age and age groups.
    - Segments customers based on lifespan and total sales.
    - Calculates recency, average order value, and average monthly spend.

Key Metrics:
    - Total orders, sales, quantity, and products.
    - Last order date and customer lifespan.
    - Recency since the last order.
    - Average order value (AOV).
    - Average monthly spend.

Customer Segmentation:
    - VIP: lifespan >= 12 months and total sales > 5000.
    - Regular: lifespan >= 12 months and total sales <= 5000.
    - New: lifespan < 12 months.

Source:
    - gold.fact_sales
    - gold.dim_customers

===============================================================================
*/

CREATE VIEW gold.report_customers AS

WITH base_query AS(
-- (1) Retrieve core customer and sales attributes
SELECT 
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	DATEDIFF(year,c.birthdate,GETDATE()) AS customer_age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = C.customer_key
WHERE order_date IS NOT NULL
)

, customer_aggregation AS(
-- (2) Aggregate sales activity and customer metrics at the customer level
SELECT 
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	customer_age
)

-- (3) Derive customer segments and additional performance metrics
SELECT 
	customer_key,
	customer_number,
	customer_name,
	customer_age,

	-- Group customers by age range
	CASE 
		WHEN customer_age < 20 THEN 'Under 20'
		WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
		WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
		WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,

	-- Segment customers based on lifespan and total sales
	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,

	last_order_date,

	-- Calculate months since the customer's last order
	DATEDIFF(month,last_order_date,GETDATE()) AS recency,

	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,

	-- Calculate average order value (AOV)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders 
	END AS avg_order_value,

	-- Calculate average monthly spend
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan 
	END AS avg_monthly_spend

FROM customer_aggregation;
