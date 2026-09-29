/*
===============================================================================
Script:      Gold Layer - Data Quality Checks
Database:    DataWarehouse
Purpose:
    Validates the integrity, consistency, and quality of the Gold layer before
    it is consumed for reporting and analytics.

Checks Performed:
    - Customer uniqueness
    - Gender standardization
    - Product uniqueness
    - Fact-to-dimension foreign key integrity

Important:
    These queries are validation checks only and do not modify any data.
===============================================================================
*/


-- Check for duplicate customer records after joining CRM and ERP customer data
SELECT COUNT(*) 
FROM(	
	SELECT 
		cf.cst_id,
		cf.cst_key,
		cf.cst_firstname,
		cf.cst_lastname,
		cf.cst_marital_status,
		CASE WHEN cf.cst_gndr != 'n/a' THEN cf.cst_gndr -- CRM is master for gender
			 ELSE ISNULL(ca.gen,'n/a')
		END AS gender,
		cf.cst_create_date,
		ca.bdate,
		cl.cntry
	FROM silver.crm_cust_info cf
	LEFT JOIN silver.erp_cust_az12 ca
	ON cf.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 cl
	ON cf.cst_key = cl.cid
)t
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check the distinct gender values to verify standardization
SELECT DISTINCT gender 
FROM gold.dim_customers;


-- Check for duplicate current product records after joining CRM and ERP data
SELECT COUNT(*) 
FROM(
	SELECT
		pn.prd_id,
		pn.cat_id,
		pn.prd_key,
		pn.prd_nm,
		pn.prd_cost,
		pn.prd_line,
		pn.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
	FROM silver.crm_prd_info pn
	LEFT JOIN silver.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL -- Filter out historical product records
)t
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- Check foreign key integrity between the sales fact and customer/product dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
