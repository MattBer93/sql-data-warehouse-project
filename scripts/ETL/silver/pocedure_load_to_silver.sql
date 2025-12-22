/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Purpose:
    This stored procedure applied the necessary transformations to the data before being uploaded to the silver layer, according to the ETL
	design and principles.
	Actions Performed:
		- Truncates Silver tables (batch processing)
		- Inserts transformed and cleansed data from Bronze into Silver tables.

No Parameters nor Variables.

To use: EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	
	DECLARE @start_time DATETIME, @end_time DATETIME, @total_start_time DATETIME, @total_end_time DATETIME
	
	BEGIN TRY
		
		SET @total_start_time = GETDATE();

		PRINT '=====================================================================';
		PRINT 'Loading SILVER Layer';
		PRINT '=====================================================================';
		
		PRINT '=========================================================================================';
		PRINT 'LOADING CRM';
		PRINT '=========================================================================================';
		PRINT ' '

		-- CRM_CUST_INFO
		PRINT '#############'
		PRINT 'crm_cust_info'
		PRINT '#############'
		SET @start_time = GETDATE();
		PRINT '>> Truncating: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting data into: silver.crm_cust_info';
		WITH ranked AS (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
			FROM bronze.crm_cust_info
		)
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) cst_firstname,
			TRIM(cst_lastname) cst_lastname,
			CASE UPPER(TRIM(cst_marital_status))
				WHEN 'S' THEN 'Single'
				WHEN 'M' THEN 'Married'
				ELSE 'n/a'
			END cst_marital_status,
			CASE UPPER(TRIM(cst_gndr))
				WHEN 'F' THEN 'Female'
				WHEN 'M' THEN 'Male'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM ranked 
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT 'Total processing time for silver.crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time ) AS VARCHAR);
		PRINT ' '
		PRINT ' '


		-- CRM_PRD_INFO
		PRINT '#############'
		PRINT 'crm_prd_info'
		PRINT '#############'
		SET @start_time = GETDATE();
		PRINT '>> Truncating: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting data into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Needed to connect with erp_px_cat_g1v2; CHANGE DDL!
			SUBSTRING(prd_key, 7, LEN(prd_key)) prd_key, -- Needed to connect with crm_sales_details CHANGE DDL!
			[prd_nm],
			ISNULL(prd_cost, 0) prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt, -- CHANGE DDL!
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt -- subtracts 1 day from the next start date; CHANGE DDL!
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT 'Total processing time for silver.crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time ) AS VARCHAR) + ' seconds';
		PRINT ' '
		PRINT ' '


		-- CRM_SALES_DETAILS
		PRINT '#################'
		PRINT 'crm_sales_details'
		PRINT '#################'
		SET @start_time = GETDATE();
		PRINT '>> Truncating: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting data into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) -- cannot cast to date straight from INT
			END  sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END  sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END  sls_due_dt,
			CASE 
				WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_quantity) * ABS(sls_price)
					THEN ABS(sls_quantity) * ABS(sls_price)
				ELSE sls_sales
			END sls_sales,
			ABS(sls_quantity) sls_quantity,
			CASE 
				WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT 'Total processing time for silver.crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time ) AS VARCHAR) + ' seconds';
		PRINT ' '
		PRINT ' '


		PRINT '=========================================================================================';
		PRINT 'LOADING CRM';
		PRINT '=========================================================================================';

		-- ERP_CUST_AZ12
		PRINT '#################'
		PRINT 'erp_cust_az12'
		PRINT '#################'
		SET @start_time = GETDATE();
		PRINT '>> Truncating: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting data into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT 
			-- Correct all IDs with 'NAS...'
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END bdate,
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT 'Total processing time for silver.erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time ) AS VARCHAR) + ' seconds';
		PRINT ' '
		PRINT ' '


		-- ERP_LOC_A101
		PRINT '#################'
		PRINT 'erp_loc_a101'
		PRINT '#################'
		PRINT '>> Truncating: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting data into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (cid, cntry)
		SELECT 
			REPLACE(cid, '-', '') cid,
			CASE 
				WHEN UPPER(TRIM(cntry)) = 'GERMANY' THEN 'DE'
				WHEN UPPER(TRIM(cntry)) IN ('UNITED STATES', 'US') THEN 'USA'
				WHEN UPPER(TRIM(cntry)) = 'AUSTRALIA' THEN 'AUS'
				WHEN UPPER(TRIM(cntry)) = 'UNITED KINGDOM' THEN 'UK'
				WHEN UPPER(TRIM(cntry)) = 'CANADA' THEN 'CA'
				WHEN UPPER(TRIM(cntry)) = 'FRANCE' THEN 'FR'
				WHEN UPPER(TRIM(cntry)) IS NULL OR UPPER(TRIM(cntry)) = '' THEN 'N/A'
				ELSE cntry
			END cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT 'Total processing time for silver.erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time ) AS VARCHAR) + ' seconds';
		PRINT ' '
		PRINT ' '


		-- ERP_PX_CAT_G1V2
		PRINT '#################'
		PRINT 'erp_px_cat_g1v2'
		PRINT '#################'
		SET @start_time = GETDATE();
		PRINT '>> Truncating: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting data into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT 'Total processing time for silver.erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time ) AS VARCHAR) + ' seconds';
		PRINT ' '
		PRINT ' '

		SET @total_end_time = GETDATE();
		PRINT 'PROCESSING TIME FOR ALL TABLES: ' + CAST(DATEDIFF(SECOND, @total_start_time, @total_end_time) AS VARCHAR) + ' seconds';

	END TRY

	BEGIN CATCH
		PRINT 'An Error has occurred.'
		PRINT 'Error Message: ' + ERROR_MESSAGE()
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR)
	END CATCH

END;
