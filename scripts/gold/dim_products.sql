--=========================
-- CREATE DIM_PRODUCTS VIEW
--=========================

CREATE VIEW gold.dim_products_vw AS 
  SELECT 
  	ROW_NUMBER() OVER (ORDER BY i.prd_id) AS product_key, -- Create surrogate key
  	i.prd_id AS product_id,
  	i.prd_key AS product_number,
  	i.prd_nm AS product_name,
  	i.cat_id AS category_id,
  	c.cat AS category,
  	c.subcat AS sub_category,
  	i.prd_line AS product_line,
  	i.prd_cost AS cost,
  	c.maintenance,
  	i.prd_start_dt AS sart_date
  FROM silver.crm_prd_info i
  LEFT JOIN silver.erp_px_cat_g1v2 c
  	ON i.cat_id = c.id
  WHERE i.prd_end_dt IS NULL --> Filter out historical data
