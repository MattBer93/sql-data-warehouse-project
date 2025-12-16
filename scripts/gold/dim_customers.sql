-- Check first if the join was correct and there are no duplicates

--==========================
-- CREATE DIM_CUSTOMERS VIEW
--==========================

CREATE VIEW gold.dim_customers_vw AS 
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		CASE 
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
			ELSE COALESCE(ca.gen, 'n/a')
		END gender,
		ci.cst_marital_status AS marital_status,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca -- With a LEFT join you avoid losing customers from the main table in the result
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
	WHERE cst_id IS NOT NULL




/*
=================
 Data INTEGRATION
=================
Notice ca.gen and ci.cst_gndr both show the gender. Make sure that the values are consistent.
NULLS in the joined table don't come from a bad data cleaning between bronze > silver. They appear because
	SQL didn't find a match in the RIGHT TABLE.

REAL ISSUE: Opposite data (Male | Female) for the same person depending on source ==> Ask data source experts which is the master data: ERP or CRM?
	Master Data: CRM

Correct data, then Apply the correct script to the previous JOIN.

*/

/*
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END new_gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
ORDER BY 1, 2
*/
