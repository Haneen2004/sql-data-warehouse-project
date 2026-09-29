 /*
===============================================================================
Script:      Gold Layer - Dimensions & Fact Views
Database:    DataWarehouse
Purpose:
    Creates the business-ready dimensional model used for analytics and
    reporting.

Description:
    - Creates customer and product dimension views.
    - Creates the sales fact view.
    - Combines and enriches data from the Silver layer.
    - Generates surrogate keys for dimensions using ROW_NUMBER().
    - Resolves customer and product attributes from their respective source
      systems.
    - Filters historical product records to keep the current product version.
    - Links sales transactions to customer and product dimensions.

Gold Views:
    Dimensions:
        - gold.dim_customers
        - gold.dim_products

    Fact:
        - gold.fact_sales

Model Structure:
    - dim_customers: Customer attributes and demographic information.
    - dim_products: Current product, category, and product-line information.
    - fact_sales: Sales transactions linked to customer and product dimensions.

Important:
    - Gold views are built on top of the cleaned Silver layer.
    - No source data is modified by these views.

===============================================================================
*/

-------------------------------------------
-- Create dimention: gold.dim_customers
-------------------------------------------
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	cf.cst_id AS customer_id,
	cf.cst_key AS customer_number,
	cf.cst_firstname AS first_name,
	cf.cst_lastname AS last_name,
	cl.cntry AS country,
	cf.cst_marital_status AS marital_status,
	CASE WHEN cf.cst_gndr != 'n/a' THEN cf.cst_gndr -- CRM is master for gender
		 ELSE ISNULL(ca.gen,'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	cf.cst_create_date AS create_date
FROM silver.crm_cust_info cf
LEFT JOIN silver.erp_cust_az12 ca
ON cf.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cl
ON cf.cst_key = cl.cid
GO

-------------------------------------------
-- Create dimention: gold.dim_products
-------------------------------------------
CREATE VIEW gold.dim_products AS 
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line  AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical data
GO


-------------------------------------------
-- Create fact: gold.fact_sales
-------------------------------------------
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id
GO
