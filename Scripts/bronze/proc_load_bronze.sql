 /*
===============================================================================
Procedure:   bronze.load_bronze
Database:    DataWarehouse
Purpose:
    Loads raw data from the CRM and ERP source CSV files into the Bronze layer
    of the data warehouse.

Description:
    This stored procedure performs a full refresh of the Bronze layer by:
    1. Truncating the existing Bronze tables.
    2. Loading raw data from the corresponding CRM and ERP CSV files using
       BULK INSERT.
    3. Logging the start and end time of each table load.
    4. Reporting the total execution time for the entire Bronze loading batch.
    5. Handling errors using TRY/CATCH and printing the related error details.

Source Systems:
    CRM:
        - cust_info.csv
        - prd_info.csv
        - sales_details.csv

    ERP:
        - CUST_AZ12.csv
        - LOC_A101.csv
        - PX_CAT_G1V2.csv

Target Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

Important:
    - This procedure performs a destructive full refresh of the Bronze layer.
    - Existing Bronze data will be deleted before new data is loaded.
    - The source file paths are currently configured for the local environment
      and may need to be updated when the procedure is deployed elsewhere.

===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY 
		SET @batch_start_time = GETDATE();
		PRINT '========================================'
		PRINT 'Loading Bronze Layer '
		PRINT '========================================'

		PRINT '>> Loading CRM Source'

		SET @start_time = GETDATE();
		PRINT 'Loading bronze.crm_cust_info...';

		TRUNCATE TABLE bronze.crm_cust_info;

		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Desktop\sql\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loaded bronze.crm_cust_info in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
		print '-------------';

		SET @start_time = GETDATE();
		PRINT 'Loading bronze.crm_prd_info...';

		TRUNCATE TABLE bronze.crm_prd_info;

		BULK INSERT bronze.crm_prd_info
		FROM 'D:\Desktop\sql\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loaded bronze.crm_prd_info in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
		print '-------------';

		SET @start_time = GETDATE();
		PRINT 'Loading bronze.crm_sales_details...';

		TRUNCATE TABLE bronze.crm_sales_details;

		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Desktop\sql\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loaded bronze.crm_sales_details in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
		print '-------------';


		PRINT '>> Loading ERP Source'

		SET @start_time = GETDATE();
		PRINT 'Loading bronze.erp_cust_az12...';

		TRUNCATE TABLE bronze.erp_cust_az12;

		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\Desktop\sql\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loaded bronze.erp_cust_az12 in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
		print '-------------';

		SET @start_time = GETDATE();
		PRINT 'Loading bronze.erp_loc_a101...';

		TRUNCATE TABLE bronze.erp_loc_a101;

		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\Desktop\sql\datasets\source_erp\LOC_A101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loaded bronze.erp_loc_a101 in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
		print '-------------';

		SET @start_time = GETDATE();
		PRINT 'Loading bronze.erp_px_cat_g1v2...';

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\Desktop\sql\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loaded bronze.erp_px_cat_g1v2 in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
		print '-------------';

		SET @batch_end_time = GETDATE();

		PRINT '========================================================='
		PRINT 'Bronze layer loaded successfully in ' + CAST(DATEDIFF(SECOND, @batch_start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '========================================================='


	END TRY

	BEGIN CATCH
		PRINT '========================================'
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '========================================'
	END CATCH
END
