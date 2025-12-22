/*
================================================
STORED PROCEDURE: Load Data from Source > Bronze
================================================

This script loads data into the Bronze tables from external CSV files.
What it does:
	- Truncate the table first
	- It BULK INSERT data from the csv files.

No parameters.
Variables:
	- start_time (to calculate loading time for each table)
	- end_time (to calculate loading time for each table)
	- total_start_time (to calculate loading time for all the tables)
	- total_end_time (to calculate loading time for all the tables)

To use: EXEC bronze.load_bronze

*/

-- Create a stored procedure
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN

	-- Declare variables
	DECLARE @start_time DATETIME, @end_time DATETIME, @total_start_time DATETIME, @total_end_time DATETIME;

	-- Error handling
	BEGIN TRY
		
		SET @total_start_time = GETDATE();
		PRINT '=====================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=====================================================================';

		PRINT '---------------------------------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '---------------------------------------------------------------------';

		-- crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\MattiaM\Desktop\SQL_with_Baraa\Project_Files\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration bronze.crm_cust_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '==========';

		-- crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\MattiaM\Desktop\SQL_with_Baraa\Project_Files\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration bronze.crm_prd_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '==========';


		-- crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncating bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\MattiaM\Desktop\SQL_with_Baraa\Project_Files\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration bronze.crm_sales_details: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '==========';

		PRINT '---------------------------------------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '---------------------------------------------------------------------';

		-- erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncating bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\MattiaM\Desktop\SQL_with_Baraa\Project_Files\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration bronze.erp_cust_az12: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '==========';

		-- erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncating bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\MattiaM\Desktop\SQL_with_Baraa\Project_Files\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration bronze.erp_loc_a101: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '==========';

		-- erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\MattiaM\Desktop\SQL_with_Baraa\Project_Files\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '==========';

		SET @total_end_time = GETDATE();
		PRINT '======================================';
		PRINT '>> TOTAL LOAD DURATION: ' + CAST(DATEDIFF(second, @total_start_time, @total_end_time) AS VARCHAR) + ' seconds';
		PRINT '======================================';

	END TRY

	BEGIN CATCH
		PRINT '=====================================================================';
		PRINT 'ERROR WHILE LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT '=====================================================================';
	END CATCH

END

