# Data Warehouse Project

The goal of this project is to build a data warehouse leveraging SQL server and SSMS, for reporting purposes, working from raw csv files. 

The files come from two data sources:
- CRM
  - cust_info
  - prd_info
  - sales_details
- ERP
    - cust_az12
    - loc_a1-1
    - px_cat_g1v2

The ETL process is managed according to the Medallion Architecture principles: 
- Bronze: Staging layer
- Silver: data cleaning, transformation, feature engineering, NULL handling, columns renaming
- Gold: creation of STAR schema for analytical purposes

#### Data Analysis performed on Gold layer:
- Customer Behaviour
- Product Performance
- Sales Trends

