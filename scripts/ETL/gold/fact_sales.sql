-- sls_prd_key and sls_cust_id have to be replaced with the surrogate keys created before in dim_products and dim_customers

--=======================
-- CREATE FACT_SALES VIEW
--=======================

CREATE VIEW gold.fact_sales_vw AS 
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key, -- previously generated SURROGATE KEY
	cst.customer_key, -- previously generated SURROGATE KEY
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_price AS unit_price,
	sd.sls_quantity AS quantity,
	sd.sls_sales AS sales_total
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products_vw pr
	ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers_vw cst
	ON sd.sls_cust_id = cst.customer_id



--====================
-- FK INTEGRITY (Dims)
--====================

-- Check if dims can join with fact table
SELECT * FROM gold.fact_sales_vw f
LEFT JOIN gold.dim_products_vw pr ON f.product_key = pr.product_key
LEFT JOIN gold.dim_customers_vw cst ON f.customer_key = cst.customer_key
WHERE pr.product_key IS NULL OR cst.customer_key IS NULL
