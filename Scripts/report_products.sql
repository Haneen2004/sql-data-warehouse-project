/*
===============================================================================
View:        gold.report_products
Database:    DataWarehouse
Purpose:
    Provides product-level analytics for reporting and product performance
    analysis.

Description:
    - Combines sales transactions with product dimension data.
    - Aggregates sales activity at the product level.
    - Calculates product sales, quantity, customer, and order metrics.
    - Calculates recency and product lifespan.
    - Segments products based on total sales.
    - Calculates average order revenue and average monthly revenue.

Key Metrics:
    - Total orders, sales, quantity, and customers.
    - Average selling price.
    - Last order date and product lifespan.
    - Recency since the last sale.
    - Average order revenue.
    - Average monthly revenue.

Product Segmentation:
    - High-Performer: total sales > 50,000.
    - Mid-Range: total sales between 10,000 and 50,000.
    - Low-Performer: total sales < 10,000.

Source:
    - gold.fact_sales
    - gold.dim_products

===============================================================================
*/

CREATE VIEW gold.report_products AS

WITH base_query AS(
-- (1) Retrieve core sales and product attributes
SELECT 
	s.order_number,
	s.sales_amount,
	s.quantity,
	s.customer_key,
	s.order_date,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
)

, product_aggregation AS(
-- (2) Aggregate sales activity and performance metrics at the product level
SELECT 
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query 
GROUP BY 
	product_name,
	category,
	subcategory,
	cost
)

-- (3) Derive product segments and additional performance metrics
SELECT 
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	last_order_date,

	-- Calculate months since the product's last sale
	DATEDIFF(month,last_order_date,GETDATE()) AS recency,

	lifespan,

	-- Segment products based on total sales
	CASE 
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,

	-- Calculate average revenue per order
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders 
	END AS avg_order_revenue,

	-- Calculate average monthly revenue
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan 
	END AS avg_monthly_revenue

FROM product_aggregation;
