/*
===============================================================================
Script:      Bronze Layer - Table Creation
Database:    DataWarehouse
Purpose:
    Creates the physical tables required for the Bronze layer of the data
    warehouse.

Description:
    - Drops existing Bronze layer tables if they already exist.
    - Recreates the tables with the expected schema for raw CRM and ERP data.

Source Systems:
    - CRM: Customer, Product, and Sales data
    - ERP: Customer, Location, and Product Category data

Tables Created:
    CRM:
        bronze.crm_cust_info
        bronze.crm_prd_info
        bronze.crm_sales_details

    ERP:
        bronze.erp_cust_az12
        bronze.erp_loc_a101
        bronze.erp_px_cat_g1v2

Important:
    - Existing tables are dropped before recreation, so any existing data in
      these tables will be permanently removed.

===============================================================================
*/

USE DataWarehouse;
GO


IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info
(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status CHAR,
	cst_gndr CHAR,
	cst_create_date DATE
);
GO

IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info
(
	prd_id INT,
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);
GO

IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details
(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);
GO

IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12
(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50)
);
GO


IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101
(
	cid VARCHAR(50),
	cntry VARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2
(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);
GO
