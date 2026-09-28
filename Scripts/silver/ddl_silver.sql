 /*
===============================================================================
Script:      Silver Layer - Table Creation
Database:    DataWarehouse
Purpose:
    Creates the physical tables required for the Silver layer of the data
    warehouse.

Description:
    - Drops existing Silver layer tables if they already exist.
    - Recreates the tables with schemas designed to store cleaned,
      standardized, and transformed data from the Bronze layer.
    - Adds warehouse-specific metadata columns used for data lineage and
      load tracking.

Source Layer:
    - Bronze layer tables containing raw CRM and ERP source data.

Target Tables:
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_cust_az12
        - silver.erp_loc_a101
        - silver.erp_px_cat_g1v2

Silver Layer Responsibilities:
    - Store cleansed and standardized source data.
    - Apply appropriate data types for transformed values.
  
Important:
    - Existing Silver tables are dropped before recreation, so any existing
      data in these tables will be permanently removed.
===============================================================================
*/

USE DataWarehouse;
GO

IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info
(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE,
	dwh_ceare_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info
(
	prd_id INT,
	cat_id VARCHAR(50),
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_ceare_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details
(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_ceare_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12
(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50),
	dwh_ceare_date DATETIME2 DEFAULT GETDATE()
);
GO


IF OBJECT_ID('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101
(
	cid VARCHAR(50),
	cntry VARCHAR(50),
	dwh_ceare_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2
(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50),
	dwh_ceare_date DATETIME2 DEFAULT GETDATE()
);
GO
