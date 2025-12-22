
/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- SOLUTION ==> Pick only the row with the most recent date
WITH ranked AS (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
	FROM bronze.crm_cust_info
)
SELECT * FROM ranked WHERE flag_last = 1


    
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);



-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;



-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;



-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- SOLUTION ==> Pick as end date the NEXT (LEAD()) start date, and subtract 1 DAY.
SELECT 
    prd_id,
    prd_key,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS prd_end_dt_test -- Add this row to the final INSERT INTO statement
FROM bronze.crm_prd_info



-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8  -- The integer indicating the date always has 8 digits: 20251216
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;



-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- CORRECTION RULES:
    -- If sls_sales negative, 0, null ==> derive it from quantity & price.
    -- If price is 0 or null ==> Derive it from sales & quantity.
    -- If quantity is negative, convert it to positive.
SELECT DISTINCT
    sls_sales,
    CASE 
        WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_quantity) * ABS(sls_price)
            THEN ABS(sls_quantity) * ABS(sls_price)
        ELSE sls_sales
    END sls_sales_NEW,
    ABS(sls_quantity) sls_quantity,
    CASE 
        WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / sls_quantity
        ELSE sls_price
    END sls_price_NEW,
    sls_price
FROM bronze.crm_sales_details
WHERE 
    sls_sales != sls_quantity * sls_price OR
    sls_sales IS NULL OR
    sls_quantity IS NULL OR
    sls_sales <= 0 OR
    sls_quantity <= 0 OR
    sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price
