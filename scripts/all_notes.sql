--###########################################################
--                     5. DDL                              --
--###########################################################

	-- CREATE
	-- ALTER
	-- DROP

--CREATE
CREATE TABLE persons (
	id INT NOT NULL,
	person_name VARCHAR(50) NOT NULL,
	birth_date DATE,
	phone VARCHAR(15) NOT NULL,
	CONSTRAINT pk_persons PRIMARY KEY (id)
)

-- ALTER
ALTER TABLE persons
ADD email VARCHAR(50) NOT NULL	

ALTER TABLE persons
DROP COLUMN phone

-- DROP
DROP TABLE persons


SELECT 
	* 
FROM persons




--###########################################################
--                     5. DML                              --
--###########################################################

	-- INSERT
	-- UPDATE
	-- DELETE

-- INSERT

-- Manually
INSERT INTO  customers (
	id,
	first_name,
	country,
	score
)
VALUES (
	6,
	'Mattia',
	'Netherlands',
	NULL
), (
	7,
	'Sjeetje',
	'Netherlands',
	1000
)

-- Insert using SELECT
INSERT INTO persons (id, person_name, birth_date, phone)
	SELECT
		id,
		first_name,
		NULL,
		'Unknown'
	FROM customers


-- UPDATE (remember WHERE!!)
UPDATE persons
SET birth_date = '01/01/2000',
	phone = '+316151515'
WHERE id = 1

UPDATE customers
SET score = 0
WHERE score IS NULL


-- DELETE
DELETE FROM customers
WHERE id > 5

-- TRUNCATE
-- When removing all data from a table, it's faster




--###########################################################
--                     6. JOINS                            --
--###########################################################

-- Already known

-- Using Sales DB, retrieve a list of all orders, along with the related customer, product, and employee details.
-- For each order, display: 
-- Order ID
-- Customer name
-- Product name
-- Sales Amount
-- Product Price
-- SAlesperson name

USE SalesDB

SELECT
	o.OrderID,
	c.FirstName AS CustomerName,
	c.LastName AS CustomerLastName,
	p.Product AS ProductName,
	o.Sales,
	p.Price,
	e.FirstName AS EmployeenName,
	e.LastName AS EmployeeLastName
FROM Sales.Orders o
LEFT JOIN Sales.Customers c 
	ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Products p
	ON o.ProductID = p.ProductID
LEFT JOIN Sales.Employees e
	ON o.SalesPersonID = e.EmployeeID





--###########################################################
--                     7. SET operators                    --
--###########################################################

-- Use case with SET operators

-- COMBINE INFORMATION before analysis

SELECT 
    'Orders' AS SourceTable,
	[OrderID]
    ,[ProductID]
    ,[CustomerID]
    ,[SalesPersonID]
    ,[OrderDate]
    ,[ShipDate]
    ,[OrderStatus]
    ,[ShipAddress]
    ,[BillAddress]
    ,[Quantity]
    ,[Sales]
    ,[CreationTime]
FROM Sales.Orders

UNION

SELECT 
    'OrdersArchive' AS SourceTable,
	[OrderID]
    ,[ProductID]
    ,[CustomerID]
    ,[SalesPersonID]
    ,[OrderDate]
    ,[ShipDate]
    ,[OrderStatus]
    ,[ShipAddress]
    ,[BillAddress]
    ,[Quantity]
    ,[Sales]
    ,[CreationTime]
FROM Sales.OrdersArchive

ORDER BY OrderID


-- USE CASE 2: Find Differences or changes (Delta), to then add only that to the warehouse
-- DATA COMPLETENESS CHECK (during data migration)
-- EXCEPT (both ways)






--###########################################################
--                     8. Date & Time                      --
--###########################################################

SELECT 
	OrderID,
	CreationTime,
	YEAR(CreationTime) AS Year,
	MONTH(CreationTime) as Month,
	DAY(CreationTime) as Day,
	-- DateName ==>  STRING!
	DATENAME(month, CreationTime) AS Month_DN,
	DATENAME(weekday, CreationTime) AS Weekday_DN,
	-- DATEPART ==> INT
	DATEPART(quarter, CreationTime) AS Quarter,
	DATEPART(week, CreationTime) AS Week,
	DATEPART(hour, CreationTime) AS Hour,
	DATEPART(minute, CreationTime) AS Minute,
	-- DATETRUNC (good for GROUP BY, zoom in-out)
	DATETRUNC(minute, CreationTime) AS TruncatedToMin,
	DATETRUNC(month, CreationTime) AS TruncatedToMonth,
	-- EOMONTH ==> DATE
	EOMONTH(CreationTime) as EoMonth,
	-- FORMAT - only to Str!
	FORMAT(CreationTime, 'MM-dd-yyyy') USA_format,
	FORMAT(CreationTime, 'dd-MM-yyyy') EU_format,
	FORMAT(CreationTime, 'dd') format_dd, -- INT with leading 0
	FORMAT(CreationTime, 'ddd') format_ddd, -- Day abbreviation
	FORMAT(CreationTime, 'dddd') format_dddd, -- Full day name
	FORMAT(CreationTime, 'MM') format_MM, -- INT with leading 0
	FORMAT(CreationTime, 'MMM') format_MMM, -- Month abbreviation
	FORMAT(CreationTime, 'MMMM') format_MMMM -- Full month name
FROM Sales.Orders


-- TASK 
-- Show CreationTime using the format:
-- Day Wed Jan Q1 2025 12:34:PM

SELECT 
	OrderID,
	CreationTime,
	'Day ' + FORMAT(CreationTime, 'ddd') + ' ' + FORMAT(CreationTime, 'MMM') + ' ' +
	'Q' + DATENAME(quarter, CreationTime) + ' ' +
	FORMAT(CreationTime, 'yyyy hh:mm:ss tt') -- remember tt!
	AS CustomFormat

FROM Sales.Orders


-- Aggregate at different levels
SELECT
	FORMAT(CreationTime, 'MMM yy') AS Month,
	COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY FORMAT(CreationTime, 'MMM yy')


-- CONVERT
SELECT
	CONVERT(INT, '123') AS [String to INT],
	CONVERT(DATE, '2025-11-30') AS [STR to DATE],
	CONVERT(DATE, CreationTime) AS [DateTime to Date],
	CONVERT(VARCHAR, CreationTime, 32) AS [US Std. Style:32],
	CONVERT(VARCHAR, CreationTime, 34) AS [EU Std. Style:34]
FROM Sales.Orders


-- CAST
SELECT
	CAST('123' AS INT) [Str to Int],
	CAST(123 AS VARCHAR) [int > Str],
	CAST('01/01/2025' AS DATE) [str > Date],
	CAST('2025-08-20' AS DATE) [str > Date],
	CAST('2025-08-20' AS DATETIME) [str > Datetime],
	CAST(CreationTime AS DATE) AS [DateTime to Date]
FROM Sales.Orders


-- DATEADD(part, interval, date)
SELECT 
	CAST(CreationTime AS DATE) [Og creationTime Date],
	DATEADD(year, 3, CAST(CreationTime AS DATE)) [3 years added],
	DATEADD(month, -2, CAST(CreationTime AS DATE)) [2 months subtracted]
FROM Sales.Orders

--DATEDIFF(part, date1, date2)
SELECT
	CAST(CreationTime AS DATE) CreationDate,
	CURRENT_DATE CurrentDate,
	DATEDIFF(month, CAST(CreationTime AS DATE), CURRENT_DATE) MonthsPassed,
	DATEDIFF(day, CAST(CreationTime AS DATE), CURRENT_DATE) DaysPassed
FROM Sales.Orders

-- Time Gap Analysis | LAG(..) OVER (ORDER BY.. )
-- Find how many days passed between each order and the previous order
SELECT 
	OrderID,
	OrderDate CurrentOrder,
	LAG(OrderDate) OVER (ORDER BY OrderDate) PreviousOrderDate,
	DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) NrOfDays
FROM Sales.Orders


-- ISDATE
SELECT
	ISDATE(123) DateCheck1,
	ISDATE('2025-11-30') DateCheck2,
	ISDATE('20-08-2025') DateCheck3,
	ISDATE('2025') DateCheck4,
	ISDATE('08') DateCheck4

-- Find corrupted dates with ISDATE()
SELECT 
	-- CAST(OrderDate AS DATE) OrderDate,
	OrderDate,
	ISDATE(OrderDate),
	CASE
		WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
	END NewOrderDate
FROM (
	SELECT '2025-08-20' OrderDate UNION
	SELECT '2025-08-21' UNION
	SELECT '2025-08-23' UNION
	SELECT '2025-08'
)
WHERE ISDATE(OrderDate) = 0


--###########################################################
--                     9. NULL Fx                          --
--###########################################################

-- ISNULL(value, replacement)

SELECT 
	ShipAddress,
	BillAddress,
	ISNULL(ShipAddress, BillAddress) AS Address_isnull
FROM Sales.Orders


-- COALESCE(val1, val2, val3, ...)
-- Go to solution on all DBs
SELECT 
	ShipAddress,
	BillAddress,
	COALESCE(ShipAddress, BillAddress, 'unknown') AS Address_coalesce
FROM Sales.Orders


-- EX: Find the average score of customers
SELECT 
	CustomerID,
	Score,
	AVG(Score) OVER() avg_score,
	AVG(COALESCE(Score, 0)) OVER() avg_score_coalesce
FROM Sales.Customers

-- EX: Display full name of customers in a single field, and add 10 points to each
SELECT 
	CustomerID,
	FirstName,
	LastName,
	CONCAT(COALESCE(FirstName, ''), ' ', COALESCE(LastName, '')) FullName,
	Score,
	COALESCE(Score, 0) + 10 AS bonus_score
FROM Sales.Customers


-- EX Sort customers by score, with NULLs appearing last
SELECT 
	CustomerID,
	FirstName,
	LastName,
	COALESCE(Score, 99999) AS Score,
	CASE
		WHEN Score IS NULL THEN 1 ELSE 0 END Flag_score
FROM Sales.Customers
ORDER BY Score


-- NULLIF(val1, val2)
-- If val1 = val2 ==> return NULL
-- Good to correct DQ issues

-- NULLIF(Price, -1)
-- NULLIF(og_price, discount_price)

-- EX: Find Sales Price for each order dividing the sale by quantity
SELECT 
	OrderID,
	Quantity,
	Sales,
	Sales / NULLIF(Quantity, 0) Price
FROM Sales.Orders


-- IS NULL | IS NOT NULL
-- Ex identify cx that have no score
SELECT
	CustomerID,
	Score
FROM Sales.Customers
WHERE Score IS NULL


-- Find all Cx that didn't place any orders
SELECT
	c.*,
	o.OrderID
FROM Sales.Customers c
LEFT JOIN Sales. Orders o
	ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL


-- How to deal with NULLs and empty values
-- Policy1: Avoid blank spaces ==> TRIM
-- Policy2: Avoid empty strings ==> NULLIF(val, '')
-- Policy3: Replace all NULLs with 'unknown'

WITH Orders AS (
	SELECT 1 id, 'A' Category 
	UNION
	SELECT 2, NULL
	UNION
	SELECT 3, ''
	UNION
	SELECT 4, '  '
)
SELECT 
	*,
	DATALENGTH(Category) AS data_len,
	DATALENGTH(TRIM(Category)) AS Policy1,
	NULLIF(TRIM(Category), '') AS Policy2,
	COALESCE(NULLIF(TRIM(Category), ''), 'unknown') Policy3
FROM Orders




--###########################################################
--                     11. CASE WHEN                       --
--###########################################################


-- CASE WHEN THEN (ELSE) END
-- Main purpose: Data Transformation

-- Categorization
SELECT 
	Category,
	SUM(Sales) AS total_sales
FROM (
	SELECT
		OrderID,
		Sales,
		CASE 
			WHEN Sales > 50 THEN 'High'
			WHEN Sales > 20 THEN 'Medium'
			ELSE 'Low'
		END AS Category
	FROM Sales.Orders
)t
GROUP BY Category
ORDER BY total_sales DESC


-- Values Mapping
-- Retrieve employee details with gender displayed as full text
SELECT
	EmployeeID,
	FirstName,
	LastName,
	CASE 
		WHEN Gender = 'M' THEN 'Male'
		WHEN Gender = 'F' THEN 'Female'
		ELSE 'Unknown'
	END AS full_gender
FROM Sales.Employees

-- QUICK FORM
SELECT
	EmployeeID,
	FirstName,
	LastName,
	CASE Gender
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'Unknown'
	END AS full_gender
FROM Sales.Employees


-- EX: Find AVG score and treat NULLs as 0. Provide also details like CustomerID and last name
SELECT
	CustomerID,
	FirstName,
	CASE
		WHEN Score IS NULL THEN 0
		ELSE Score
	END AS score_clean,
	AVG(CASE
		WHEN Score IS NULL THEN 0
		ELSE Score
	END) OVER () as avg_score
FROM Sales.Customers

-- EX: How many times did each customer make an order with sales > 30?

SELECT 
	CustomerID,
	SUM(CASE 
		WHEN Sales > 30 THEN 1
		ELSE 0
	END) AS high_sales,
	COUNT(*) AS total_orders
FROM Sales.Orders
GROUP BY CustomerID
ORDER BY SUM(CASE 
		WHEN Sales > 30 THEN 1
		ELSE 0
	END) DESC





--###########################################################
--                     12. Window Fx | BASICS              --
--###########################################################


-- AGGREGATE fx
-- COUNT, SUM, AVG, MIN, MAX

-- WINDOW FUNCTIONS
-- Also perform aggregations (like above with GROUP BY), but it keeps the level of detail.
-- Window functions better for advanced analytics. Many more available functions also.

-- SYNTAX
-- WINDOW FX() OVER (PARTITION BY ... ORDER BY... FRAME CLAUSE)


-- EX: Find total sales for each product, provide also details like orderID and order date
SELECT
	OrderID,
	ProductID,
	OrderDate,
	SUM(Sales) OVER (PARTITION BY ProductID) AS total_sales
FROM Sales.Orders


-- EX: Find Total Sales across all orders 
-- Provide details like OrderID, OrderDate

SELECT 
	OrderID,
	OrderDate,
	ProductID,
	OrderStatus,
	Sales,
	SUM(Sales) OVER() total_sales,
	SUM(Sales) OVER(PARTITION BY ProductID) total_sales_by_product,
	SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) total_sales_by_product_and_status
FROM Sales.Orders


-- ORDER BY clause (2)
-- EX: Rank each order based on their sales from highest to lowest; provide OrderID and Orderdate
SELECT 
	RANK() OVER (ORDER BY Sales DESC) ranked,
	OrderID,
	OrderDate,
	Sales
FROM Sales.Orders


-- WINDOW FRAME (3)
-- Defines a subset of rows within each window that is relevant for the calculation. A Window inside a window.
-- Check slides for for the syntax
-- must use ORDER BY!
-- Lower values must go BEFORE higher value

SELECT 
	FORMAT(OrderDate, 'MMM') Month,
	Sales,
	SUM(Sales) OVER (ORDER BY MONTH(OrderDate) ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) sum_over_month_2_rows
FROM Sales.Orders

-- Higher UNBOUNDED
SELECT 
	FORMAT(OrderDate, 'MMM') Month,
	Sales,
	SUM(Sales) OVER (ORDER BY MONTH(OrderDate) ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) sum_over_month_until_end
FROM Sales.Orders
ORDER BY SUM(Sales) OVER (ORDER BY MONTH(OrderDate) ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) DESC

-- Lower UNBOUNDED
SELECT 
	FORMAT(OrderDate, 'MMM') Month,
	Sales,
	SUM(Sales) OVER (ORDER BY MONTH(OrderDate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sum_over_month_until_end
FROM Sales.Orders

-- between rows
SELECT 
	FORMAT(OrderDate, 'MMM') Month,
	Sales,
	SUM(Sales) OVER (ORDER BY MONTH(OrderDate) ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) sum_over_month_until_end
FROM Sales.Orders


-- Window Fx RULES

-- 1) WF can be used only in SELECT and ORDER BY
SELECT
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus) total_sales
FROM Sales.Orders
ORDER BY SUM(Sales) OVER (PARTITION BY OrderStatus) DESC

-- 2) WF cannot be nested

-- 3) SQL executes WF after WHERE clause
-- Find total sales for each orderStatus, for products 101 and 102
SELECT 
	OrderID,
	ProductID,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus) total_sales_by_status
FROM Sales.Orders
WHERE ProductID IN (101, 102)

-- 4) WF can be used with GROUP BY only if the SAME COLUMNS are used
-- Rank Customers based on their total sales
SELECT 
	CustomerID,
	SUM(Sales) total_sales,
	RANK() OVER (ORDER BY SUM(Sales) DESC) ranked_customers
FROM Sales.Orders
GROUP BY CustomerID




--###########################################################
--                     13. AGGREGATE Window Fx             --
--###########################################################


-- COUNT()
-- r. nr of Rows in that window
-- careful with what you count! If there is a NULL, it won't count.
-- Counts the no. of values in a column, regardless of the type

SELECT 
	OrderID,
	CustomerID,
	OrderDate,
	COUNT(*) OVER() total_orders,
	COUNT(*) OVER(PARTITION BY CustomerID) total_order_by_customer
FROM Sales.Orders

-- EX find total nr of Cx, provide all Cx details
SELECT 
	*,
	COUNT(*) OVER() total_cx,
	COUNT(Score) OVER() total_scores
FROM Sales.Customers


-- Use COUNT to find DUPLICATES
-- Check PK first
SELECT *
FROM (
	SELECT 
		OrderID,
		COUNT(*) OVER(PARTITION BY OrderID) check_pk
	FROM Sales.OrdersArchive
)t
WHERE check_pk > 1

-- COUNT Use cases:
	-- 1) Overall analysis (see how many rows you have)
	-- 2) Category analysis
	-- 3) Identify NULLs
	-- 4) Identify Duplicates

--------------------------------------------

-- SUM

-- Find total sales
-- Find total sales for each product
-- Provide details like OrderID, OrderDate
SELECT
	OrderID,
	ProductID,
	OrderDate,
	Sales,
	SUM(Sales) OVER() total_sales,
	SUM(Sales) OVER(PARTITION BY ProductID) total_per_product
FROM Sales.Orders

-- COMPARISON Analysis (part-to-whole; compare to extremes; compare to avg)
-- EX Find percentage contribution of each product's sales to the total sales
SELECT 
	OrderID,
	ProductID,
	Sales,
	SUM(Sales) OVER() total_sales,
	ROUND(CAST(Sales AS Float) / SUM(Sales) OVER() * 100, 2) percentage_to_total
FROM Sales.Orders
ORDER BY CAST(Sales AS Float) / SUM(Sales) OVER() * 100 DESC


--------------------------------------------

-- AVG
-- Careful with NULLs! Treat them as 0.

-- EX: Find avg sales across all orders
-- and avg sales for each product
SELECT 
	OrderID,
	OrderDate,
	ProductID,
	AVG(Sales) OVER() avg_sales,
	AVG(Sales) OVER(PARTITION BY ProductID) avg_sales_product
FROM Sales.Orders

-- EX: Find avg scores of cx
-- provide cx ID and name
SELECT 
	CustomerID,
	FirstName,
	Score,
	AVG(Score) OVER() no_cleaned_avg,
	COALESCE(Score, 0) cleaned,
	AVG(COALESCE(Score, 0)) OVER() clean_avg_score
FROM Sales.Customers

-- EX: Find orders where sales are higher than the sales average
SELECT *
FROM (
	SELECT 
		OrderID,
		ProductID,
		Sales,
		AVG(Sales) OVER() avg_sales
	FROM Sales.Orders
)t
WHERE Sales > avg_sales

--------------------------------------------

-- MIN / MAX

-- Ex: Find min and max across all orders and for each product
SELECT 
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	MIN(Sales) OVER() min_sales,
	MAX(Sales) OVER() max_sales,
	MIN(Sales) OVER(PARTITION BY ProductID) min_per_product,
	MAX(Sales) OVER(PARTITION BY ProductID) max_per_product
FROM Sales.Orders

-- Ex: Find employees with highest salary
SELECT *
FROM (
SELECT 
	*,
	MAX(Salary) OVER() highest_salary
FROM Sales.Employees
)t
WHERE Salary = highest_salary

-- Ex: Find deviation of each sales from the minimum and the maximum Sales Amount
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	MAX(Sales) OVER() highest_sales,
	MIN(Sales) OVER() lowest_sales,
	Sales - MIN(Sales) OVER() dev_from_min,
	ABS(Sales - MAX(Sales) OVER()) dev_from_max
FROM Sales.Orders

--------------------------------------------

-- ROLLING and RUNNING totals
-- good for:
	-- TRACKING
	-- TREND ANALYSIS
-- Aggregation of a sequence, updated each time a new item is added

-- RUNNING ==> Aggregates everything, from beginning up to current
	-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- ROLLING ==> Aggregates all values within a fixed time window (eg 30 days). New data added -> oldest point dropped
	-- ROWS BETWEEN N PRECEDING AND CURRENT ROW

-- Compare
SELECT
	FORMAT(OrderDate, 'MMM') order_month,
	Sales,
	SUM(Sales) OVER(ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_total,
	SUM(Sales) OVER(ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) rolling_total
FROM Sales.Orders

--------------------------------------------

-- MOVING AVG
SELECT
	OrderID,
	ProductID,
	FORMAT(OrderDate, 'MMM') order_month,
	Sales,
	AVG(Sales) OVER (PARTITION BY ProductID) avg_by_product,
	AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate) moving_avg,
	AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) rolling_avg
FROM Sales.Orders





--###########################################################
--                     14. RANKING Window Fx               --
--###########################################################


-- INTEGER r. ==> Discrete values (1,2,3...)

	-- ROW_NUMBER()
	-- RANK()
	-- DENSE_RANK()
	-- NTILE()

-- PERCENTAGE r. ==> 0, 0.25, 0.5...1
-- Good to find eg. "Find top 20% of.."

	-- CUME_DIST()
	-- PERCENT_RANK()

-- NO ARGUMENT in any fx.
-- ORDER BY required
-- NO FRAME clause

-------------------------------------------

SELECT 
	ROW_NUMBER() OVER (ORDER BY Sales DESC) row_num,
	RANK() OVER (ORDER BY Sales DESC) ranked,
	DENSE_RANK() OVER (ORDER BY Sales DESC) dense_ranked,
	Sales
FROM Sales.Orders


-- Ex: Find Highest sales for each product
SELECT *
FROM (
	SELECT 
		OrderID,
		ProductID,
		Sales,
		ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) rank_by_product
	FROM Sales.Orders
)t
WHERE rank_by_product = 1

-- Ex: Find lowest 2 customers based on total sales
SELECT *
FROM (
	SELECT 
		CustomerID,
		SUM(Sales) total_sales,
		ROW_NUMBER() OVER (ORDER BY SUM(Sales)) rank_customers
	FROM Sales.Orders
	GROUP BY CustomerID
)t
WHERE rank_customers <= 2


-- Use case: assign unique IDs to OrderArchive table
SELECT 
	ROW_NUMBER() OVER (ORDER BY OrderID, OrderDate) unique_id,
	*
FROM Sales.OrdersArchive

-- Use case: identify duplicates
-- Pick most recent rows
SELECT *
FROM (
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC) row_num,
 		*
	FROM Sales.OrdersArchive
)t
WHERE row_num = 1


-------------------------------------------

-- CUME_DIST()
	-- Cumulative Distribution; calculates data distribution in a window
	-- cume_dist = position/nr. rows
	-- if TIE, SQL takes the LAST row position of the same value
	-- How many rows have a value less than or equal to this one?

-- PERCENT_RANK()
	-- Calculates relative position of each row
	-- Percent_rank = (position -1) / (nr. rows - 1)
	-- if TIE, SQL takes the FIRST row position of the same value
	-- How this row ranks relative to the others, scaled between 0 and 1.

SELECT
	CUME_DIST() OVER (ORDER BY Sales) c_distribution,
	ROUND(PERCENT_RANK() OVER (ORDER BY Sales), 2) perc_rank,
	Sales
FROM Sales.Orders

-- Ex: Find products that fall within 40% of prices
SELECT 
	*,
	CONCAT(dist_rank * 100, '%') dist_rank_percentage
FROM (
	SELECT
		Product,
		Price,
		CUME_DIST() OVER (ORDER BY Price DESC) dist_rank
	FROM Sales.Products
)t
WHERE dist_rank <= 0.4

-------------------------------------------

-- NTILE(n)
	-- Divides the data into buckets
	-- bucket size = nr. Rows / nr buckets
	-- with odd numbers: larger bucket comes first

SELECT 
	OrderID,
	Sales,
	NTILE(1) OVER (ORDER BY Sales DESC) one_bucket,
	NTILE(2) OVER (ORDER BY Sales DESC) two_buckets,
	NTILE(3) OVER (ORDER BY Sales DESC) three_buckets,
	NTILE(4) OVER (ORDER BY Sales DESC) four_buckets
FROM Sales.Orders

-- USE CASE 1: DATA SEGMENTATION (analyst)
-- USE CASE 2: EQUALIZE LOAD PROCESSING / LOAD BALANCING (engineer)

-- Ex1: Segment all orders into 3 categories - high, medium, low
SELECT 
	CASE segmented
		WHEN 1 THEN 'High'
		WHEN 2 THEN 'Medium'
		ELSE 'Low'
	END caegories,
	*
FROM (
	SELECT
		*,
		NTILE(3) OVER (ORDER BY Sales DESC) segmented
	FROM Sales.Orders
)t

-- Ex2: Equalize load
	-- split data before making a full (initial)





--###########################################################
--                     15. VALUE Window Fx                 --
--###########################################################


-- VALUE Functions
	-- Used to access values in ANOTHER row

		-- LEAD --> returns value a subsequent row
		-- LAG --> a previous row
		-- FIRST
		-- LAST
		-- ORDER BY mandatory


-- LEAD(expr, offset, default[val if next row not available]) 
-- LAG(expr, offset, default[val if previous row not available]) 
SELECT 
	OrderDate,
	Sales,
	LEAD(Sales, 2,0) OVER (ORDER BY OrderDate ) lead_val,
	LAG(Sales, 2, 0) OVER (ORDER BY OrderDate) lag_val
FROM Sales.Orders

-- Use Case: Analyze MoM (month-over-month) performance by finding the percentage change in sales between current and previous month
SELECT 
	*,
	current_month_sales - previous_month_sales MoM_change,
	ROUND(CAST((current_month_sales - previous_month_sales) AS FLOAT) / previous_month_sales * 100, 2) MoM_percentage_change
FROM (
	SELECT 
		MONTH(OrderDate) order_month,
		SUM(Sales) current_month_sales,
		LAG(SUM(Sales)) OVER (ORDER BY MONTH(OrderDate)) previous_month_sales
	FROM Sales.Orders
	GROUP BY MONTH(OrderDate)
)t

-- Use Case: Customer Retention
-- Analyze cx loyality by ranking cx based on avg days between orders.
SELECT 
	CustomerID,
	AVG(days_between_orders) avg_days_between_orders,
	RANK() OVER (ORDER BY COALESCE(AVG(days_between_orders), 99999)) rank_avg
FROM (
	SELECT 
		OrderID,
		CustomerID,
		OrderDate current_order,
		LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) next_order,
		DATEDIFF(day, OrderDate, LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate)) days_between_orders
	FROM Sales.Orders
)t
GROUP BY CustomerID


-------------------------------------------

-- FIRST_VALUE (in window)
-- LAST_VALUE (in window)
SELECT 
	OrderDate,
	Sales,
	FIRST_VALUE(Sales) OVER (ORDER BY OrderDate) first_value,
	LAST_VALUE(Sales) OVER (ORDER BY OrderDate) last_value
FROM Sales.Orders

-- Ex: Find lowest and highest sales for each product
-- FInd the difference between current and lowest sales
SELECT
	OrderID,
	Sales,
	lowest_sales,
	Sales - lowest_sales diff
FROM (
	SELECT
		ProductID,
		OrderID,
		Sales,
		FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) lowest_sales,
		LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales
			ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) highest_sales,
		FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC) highest_sales_2,
		MIN(Sales) OVER (PARTITION BY ProductID) lowest_sales_with_min,
		MAX(Sales) OVER (PARTITION BY ProductID) highest_sales_with_max
	FROM Sales.Orders
)t
ORDER BY Sales - lowest_sales




--###########################################################
--                     16. SUBQUERIES                      --
--###########################################################


-- Check slides for common DB challenges and solutions, DB architecture
-- DB has 3 storages:

	-- USER storage (the normal we query)
	-- SYSTEM Storage (metadata)
	-- TEMP storage (In "System databases")

-- INFORMATION SCHEMA -> Where all metadata is stored
SELECT 
	DISTINCT TABLE_NAME 
FROM INFORMATION_SCHEMA.COLUMNS


-- SUBQUERIES
	-- Query in a query.
	-- Can be in 
		-- SELECT
		-- FROM
		-- JOIN
		-- WHERE 
			-- can use COMPARISON OPS
			-- can use LOGICAL ops (IN, ANY, ALL, EXISTS)
-- Result of SUBQ is saved in the CASHW, so the main query can use it


-- SQ in SELECT; only SCALAR (1 value)
-- SQ in FROM; already used it a lot in the course

-- SQ in JOIN
-- Ex: Show all cx details and find the toal orders for each customer
SELECT 
	c.*,
	o.total_orders
FROM Sales.Customers c
LEFT JOIN (
	SELECT 
		CustomerID,
		COUNT(*) total_orders
	FROM Sales.Orders
	GROUP BY CustomerID
) o ON c.CustomerID = o.CustomerID

-- SQ in WHERE; only SCALAR 
-- For more complex filtering
-- Ex: Find products that have a price higher than the avg price of all products
SELECT 
	ProductID,
	Price
FROM Sales.Products
WHERE Price > (SELECT AVG(Price) avg_price FROM Sales.Products)

-- Ex: Show the details of orders made by cx (not) in Germany
SELECT * FROM Sales.Orders
WHERE CustomerID NOT IN (
	SELECT CustomerID 
	FROM Sales.Customers
	WHERE Country = 'Germany'
)

----------------------------------------

-- ALL (Checks if a value matches ALL values in a list)
-- ANY

-- Ex: Find female employees whose salary are greater than salaries of any male employee
SELECT *
FROM Sales.Employees
WHERE Gender = 'F' 
	AND Salary > ANY (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')

-- Ex: Find female employees whose salary are greater than salaries of any male employee
SELECT *
FROM Sales.Employees
WHERE Gender = 'F' 
	AND Salary > ALL (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')


----------------------------------------

-- NON-CORRELATED SQ: can run independently
-- CORRELATED SQ: relies on main query values (check slides)
	-- Slower and more complex

-- Ex: Show all cx details and find total orders of each cx
SELECT
	*,
	(SELECT COUNT(*) FROM Sales.Orders o WHERE o.CustomerID = c.CustomerID) total_sales
FROM Sales.Customers c


----------------------------------------

-- EXISTS

-- Ex: Show details of orders made by customers in Germany
SELECT 
	*
FROM Sales.Orders o
WHERE EXISTS (
	SELECT 1 -- it doesn't matter the value used, SQL checks only if something is returned.
	FROM Sales.Customers c 
	WHERE Country = 'Germany'
	AND o.CustomerID = c.CustomerID) -- here is the relationship with main query


--###########################################################
--                     17. CTE                           --
--###########################################################

-- CTE
-- temporary named table (stored in cache) that you can use multiple times in query. Cleaner than Subquery
-- Why use a CTE?
	-- REUSABILITY
	-- READABILITY
	-- MODULARITY

-- CTE types:
	-- NON-RECURSIVE
		-- STANDALONE
		-- NESTED
	-- RECURSIVE

-- DO NOT ADD too many CTEs in a query; about 5 is max

-- STANDALONE
-- Independent


-- Ex
-- Step 1: Find total sales per customer, add details (other way: window fx)
WITH cte_total_sales AS (
	SELECT 
		CustomerID,
		SUM(Sales) total_sales
	FROM Sales.Orders
	GROUP BY CustomerID
),
-- Step 2: Find last order date for each customer
cte_last_order AS  (
	SELECT 
		CustomerID,
		MAX(OrderDate) latest_order
	FROM Sales.Orders
	GROUP BY CustomerID
),
-- Step 3: Rank customers based on total sales per customer (NESTED)
cte_ranked AS (
	SELECT 
		*,
		RANK() OVER (ORDER BY total_sales DESC) customer_ranked
	FROM cte_total_sales
),
-- Step 4: Segment customers based on total sales
cte_customer_segments AS (
	SELECT 
		CustomerID,
		CASE
			WHEN total_sales > 100 THEN 'High'
			WHEN total_sales > 70 THEN 'Medium'
			ELSE 'Low'
	END customer_segmentation
	FROM cte_total_sales
)
SELECT
	COALESCE(cte_ranked.customer_ranked, 999999) customer_ranked,
	c.CustomerID,
	c.FirstName,
	cte_sales.total_sales,
	cte_customer_segments.customer_segmentation,
	cte_order.latest_order
FROM Sales.Customers c
LEFT JOIN cte_total_sales cte_sales
	ON c.CustomerID = cte_sales.CustomerID
LEFT JOIN cte_last_order cte_order
	ON c.CustomerID = cte_order.CustomerID
LEFT JOIN cte_ranked
	ON c.CustomerID = cte_ranked.CustomerID
LEFT JOIN cte_customer_segments
	ON c.CustomerID = cte_customer_segments.CustomerID
ORDER BY customer_ranked -- Cannot use ORDER BY in CTE


------------------------------------

-- RECURSIVE CTE 
-- Self referencing query that repeatedly processes data until a condition is met (a loop)

-- Syntax
WITH CTE AS (
	-- Anchor
	SELECT
	FROM

	UNION ALL 

	-- Recursive
	SELECT
	FROM CTE
	WHERE break_condition
);


-- Ex: Generate a sequence from 1 to 20
WITH Series AS (
	-- Anchor
	SELECT 1 my_number

	UNION ALL 

	-- Recursive
	SELECT my_number + 1 
	FROM Series
	WHERE my_number < 20
)
SELECT * FROM Series


-- Ex: Show the employee hierarchy by displaying each employee's level within the organization

WITH cte_hierarchy AS (
-- Anchor
	SELECT 
		EmployeeID,
		FirstName,
		ManagerID,
		1 AS Level
	FROM Sales.Employees
	WHERE ManagerID IS NULL

	UNION ALL

	SELECT
		e.EmployeeID,
		e.FirstName,
		e.ManagerID,
		Level + 1
	FROM Sales.Employees AS e
	JOIN cte_hierarchy ch
		ON e.ManagerID = ch.EmployeeID
)
SELECT * FROM cte_hierarchy




--###########################################################
--                     18. VIEWS                           --
--###########################################################

-- HIERARCHY (DB Structure | DDL):
	-- 1. Server
	-- 2. DataBase(s)
	-- 3. Schemas
	-- 4. Tables (where data physically lives) | Columns, Rows
	-- 5. View (view that shows data without storing it physically) | Columns, Rows


-- DataBases are structured in 3 levels / abstractions:
	-- 1. PHYSICAL (internal)
		-- Where data is physically saved.
		-- Accessed only by DB Admins (DBA)
		-- Dta files, partitions, logs, catalog, blocks, caches

	-- 2. LOGICAL (Conceptual)
		-- App Developer / Data Engineers
		-- Create tables, relationships, views, stored procedures, indexes, functions

	-- 3. VIEW (External)
		-- Custom views for analysts, powerBI, end_users


-- What are VIEWS? ==> Virtual tables that are the RESULTING FROM A QUERY. NO Data Storage!
	-- Each time you query a view, you also trigger its underlying query 

-- TABLE vs VIEW
-- +-----------------------+-----------------------------+------------------------------+
-- | Feature               | TABLE                       | VIEW                         |
-- +-----------------------+-----------------------------+------------------------------+
-- | Data Storage          | Real physical data          | No physical data (virtual)   |
-- | Performance           | Fast                        | Slower                       |
-- | Maintenance           | Harder                      | Easier                       |
-- | Usage                 | Read/Write                  | Read-only (usually)          |
-- | Purpose               | Main data store             | Simplified/restricted view   |
-- +-----------------------+-----------------------------+------------------------------+


-- Why use views?
	-- Store central, complex query logic in the DB, so multiple end users can access the same data

-- VIEW vs CTE
-- +----------------------------+-------------------------------+-------------------------------+
-- | Feature                    | VIEW                          | CTE                          |
-- +----------------------------+-------------------------------+-------------------------------+
-- | Reusability                | Multiple queries              | Single query                 |
-- | Logic Type                 | Persisted (saved in DB)       | Temporary (query-scoped)     |
-- | Redundancy Reduction       | Across queries                | Within one query             |
-- | Maintenance                | Requires CREATE/DROP          | No maintenance needed        |
-- +-----------------------------+-------------------------------+------------------------------+


-- USE CASE 1: SAVE REUSABLE LOGIC

-- Take this logic, that can be used by several teams, and put it in a view. 
-- If you don't specify the schema, it defaults to dbo.
/* 
WITH monthly_summary AS (
	SELECT 
		DATETRUNC(month, OrderDate) order_month,
		SUM(Sales) total_sales,
		COUNT(OrderID) total_orders,
		SUM(Quantity) total_quantity
	FROM Sales.Orders
	GROUP BY DATETRUNC(month, OrderDate)
)

Create the view
CREATE VIEW Sales.monthly_summary_vw AS (
	SELECT 
		DATETRUNC(month, OrderDate) order_month,
		SUM(Sales) total_sales,
		COUNT(OrderID) total_orders,
		SUM(Quantity) total_quantity
	FROM Sales.Orders
	GROUP BY DATETRUNC(month, OrderDate)
)

Find running total of sales for each month

*/
SELECT
	order_month,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_month) running_total
FROM monthly_summary_vw


-- How does the DB execute views?
	-- Saves in the Catalog (metadata): Metadata + SQL query for the view
	-- IF you drop the view you just dropthe query, not real data.


-- USE CASE 2: Hide complexity, improve abstraction
-- Developer should create views that are user friendly, with full English and readable names, so that not each end user has to fully understand the database.
-- Provde view that combines details from orders, products, customers, employees.

CREATE VIEW Sales.orders_details_vw AS (
	SELECT
		o.*,
		p.Product,
		p.Category,
		p.Price,
		c.FirstName + ' ' + COALESCE(c.LastName, '') cx_name,
		c.Score cx_score,
		e.FirstName + ' ' + COALESCE(e.LastName, '') employee_name,
		e.Department,
		e.Salary,
		e.ManagerID
	FROM Sales.Orders o
	LEFT JOIN Sales.Products p
		ON o.ProductID = p.ProductID
	LEFT JOIN Sales.Customers c
		ON o.CustomerID = c.CustomerID
	LEFT JOIN Sales.Employees e
		ON o.SalesPersonID = e.EmployeeID
)

-- Other USE CASES:
	-- 3. SECURITY: Enforce security by hiding rows/columns in view from og table
	-- 4. FLEXIBILITY:  If you need to update the Tables, update also the query for the view for the end users, 
						-- so they can keep working. SImilar concept as a DataFlow, it's there to update things only once
	-- 5. TRANSLATION: Use views to provide translated versions of table(s)
	-- 6. VIRTUAL DATA MARTS Use views as  IN a Data Warehouse. Sales Mart, Finance Mart. 



--###########################################################
--                     19. TABLES                          --
--###########################################################

-- They live in the LOGICAL Layer
-- WHAT is a Table? ==> 
	-- Structured collection of data, similar to a spreadsheet or grid.
	-- Saved in DB physically as file

-- Table TYPES: PERMANENT, TEMPORARY


--------
-- CREATE / INSERT (permanent)
--------

-- Classical method; you create (1) the table and then insert (2) data in it.
CREATE TABLE test_table AS (
	ID INT NOT NULL,
	Name VARCHAR(50)
)

INSERT INTO test_table 
	(ID, Name) -- optional
VALUES
	(1, 'Frank')


--------
-- CTAS (permanent)
--------

-- Create a table from the result of a query
-- Difference with VIEWS? ==> 
		-- View is impermanent, CTAS is stored physically. 
		-- query VIEW is slower, but data will be updated if og tables are updated
		-- query CTAS is faster, but data won't update if og tables are updated

-- USE CASES:
	-- Create a snapshot (not relevant if you use Delta)
	-- Can use CTAS instead of views to create data marts if reports become too slow

CREATE TABLE ctas_table AS (
	-- QUERY
)

-- OR

SELECT *
INTO table_name
FROM


--------------
-- TEMPORARY TABLES
-------------- 

-- They are dropped when session end
-- Seldom used (better to use CTEs or Views instead)

-- USE CASES
	-- 1. Create you own copy of the data, transform it, and save it in a real table. 

SELECT *
INTO #temp_table 
FROM 



-- Compare all methods: Check table 90 in 09_Advanced_SQL_Techniques




--###########################################################
--                     20. STORED PROCEDURES               --
--###########################################################

-- Used to avoid repetitive actions and queries. It's like a program to perform several actions.
-- Saved on the DB Server side.

-- STORED PROCEDURE vs PYTHON SCRIPT (better python!)
-- +-------------------------+---------------------------------------------+---------------------------------------------+
-- | Feature                 | STORED PROCEDURE                            | PYTHON SCRIPT                               |
-- +-------------------------+---------------------------------------------+---------------------------------------------+
-- | Location                | Runs inside the DB                          | Runs externally, connects to DB             |
-- | Performance             | Pre-compiled, faster                        | Slight overhead due to DB connection        |
-- | Logic Complexity        | Harder for complex logic                    | Great for complex workflows                 |
-- | Flexibility             | Limited                                     | Very flexible                               |
-- | Version Control         | None / limited                              | Full version control (Git, etc.)            |
-- | Integration             | SQL-only                                    | Mix SQL + Python + libraries                |
-- | Maintenance             | Harder                                      | Easier                                      |
-- +-------------------------+---------------------------------------------+---------------------------------------------+

-- SYNTAX
CREATE PROCEDURE ProcedureName AS 
BEGIN
	-- SQL CODE
END

-- Call
EXEC stored_procedure 


-- Ex1: Find total nr of cx and avg score for US customers
SELECT 
	COUNT(*) as total_customers,
	AVG(COALESCE(Score, 0)) avg_score
FROM Sales.Customers
WHERE Country = 'USA'

-- Create procedure with a parameter. Saved in "Programmability"
CREATE PROCEDURE get_customer_summary AS 
BEGIN
	SELECT 
		COUNT(*) as total_customers,
		AVG(COALESCE(Score, 0)) avg_score
	FROM Sales.Customers
	WHERE Country = 'USA'
END

-- Call
EXEC get_customer_summary

--=========================
-- STORED PROCEDURE EXAMPLE
--=========================

ALTER PROCEDURE get_customer_summary @Country VARCHAR(50) = 'USA' AS -- Added a parameter
BEGIN
	BEGIN TRY
		-- =================
		-- Declare VARIABLES
		-- =================
		DECLARE @TotalCustomers INT,
				@AvgScore FLOAT;

		-- ================================
		-- IF / ELSE | prepare & Clean data
		-- ================================
		IF EXISTS (
			SELECT 1 FROM Sales.Customers
			WHERE Score IS NULL AND Country = @Country)
		BEGIN 
			PRINT 'Updating NULL Scores to 0';
			UPDATE Sales.Customers
			SET Score = 0
			WHERE Score IS NULL AND Country = @Country;
		END

		ELSE 
		BEGIN
			PRINT 'No NULL Scores Found'
		END;
			
			-- ================================
			-- Step 2: Generate Summary reports
			-- ================================
			-- Calculate Total Customers and Average Score for specific Country
			SELECT 
				@TotalCustomers = COUNT(*),
				@AvgScore = AVG(Score)
			FROM Sales.Customers
			WHERE Country = @Country;

			PRINT 'Total Customers from ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR)
			PRINT 'Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR);

			-- Calculate Total nr of Customers and Total Sales for specific Country
			SELECT
				COUNT(OrderID) total_orders,
				SUM(Sales) total_sales,
				1/0 -- Add an error for TRY/CATCH
			FROM Sales.Orders o
			JOIN Sales.Customers c
				ON c.CustomerID = o.CustomerID
			WHERE c.Country = @Country
	END TRY

	-- ==============
	-- Error Handling
	-- ==============
	BEGIN CATCH
		PRINT('An error occurred');
		PRINT('Error message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR));
		PRINT('Error Procedure: ' + ERROR_PROCEDURE());
	END CATCH
END


EXEC get_customer_summary


-- TRIGGERS
-- They start other actions 

-- USE CASE: Create a LOG each time a table is updated
-- For example you can attach a trigger to the table, which inserts a new log each time an INSERT query is ran on it.

CREATE TRIGGER TriggerName ON TableName
AFTER INSERT, UPDATE, DELETE
AS
	BEGIN
		-- SQL satement
	END

-- 1. Create LOG table
CREATE TABLE Sales.EmployeeLogs (
	LogID INT identity(1,1) PRIMARY KEY,
	EmployeeID INT,
	LogMessage VARCHAR(255),
	LogDate DATE
)

-- 2. Creaete TRIGGER
CREATE TRIGGER trg_after_insert_employee ON Sales.Employees
AFTER INSERT AS
	BEGIN
		INSERT INTO Sales.EmployeeLogs (EmployeeID, LogMessage, LogDate)
		SELECT 
			EmployeeID,
			'New Employee Added: ' + CAST(EmployeeID AS VARCHAR),
			GETDATE()
		FROM INSERTED -- virtual table that holds a copy of the rows that are being inserted in the target table
	END

-- 3. Trigger the trigger
INSERT INTO Sales.Employees
VALUES (
	6,
	'Maria',
	'Doe',
	'HR',
	'1988-01-12',
	'F',
	80000,
	3
)

SELECT * FROM Sales.EmployeeLogs



--###########################################################
--                     21. INDEXES                         --
--###########################################################

-- WHAT's an INDEX: Data structure that provides quick access to data > more speed. Same as book index

-- TYPES
	-- STRUCTURE (Clustered / non-clustered)
	-- STORAGE   (RowStore / ColumnStore)
	-- FUNCTIONS (Unique I. / Filtered I.)

-- Some Indexes are better for READING, some for WRITING


--===============
-- HEAP STRUCTURE
--===============

-- Tables > saved in Files on Disk > saved in PAGES of 8kb per page (.mdf)
-- PAGE: Can store anything: Data, Metadata, Indexes..
	-- Check slide 4 in "10_Performance_Optimization"

-- HEAP TABLE: Table where rows are saved randomly, wihtout a clustered Index. FAST WRITE, SLOW READ


--================
-- CLUSTERED INDEX
--================
-- SQL sorts data in order in the "leaves" pages, then in the Intermediate Nodes (INDEX Pages) it gives a range of indexes for each page. 
-- Then on the root page, it provides another range for each Intermediate node. There can be as many intermediate Nodes as needed.
-- All that makes querying much faster


--=====================
-- NON- CLUSTERED INDEX
--=====================
-- SQL does NOT sort data in order, but creates an Index page with a RID (Wor Identifier) for each record; basically an "address"
-- with Page ID : Row offset for each row. 
-- Data in INDEX Pages is SORTED, but original data is not.
-- requires an extra layer than clustered_index

-- MAIN DIFFERENCE 
-- The clustered Index physically sorts data and the dta pages are included in the B-Tree structure ==> Can have only one Clustered inxed
-- NON-Clustered Index DOES NOT rearrange the data, so data pages are not in the B-tree. You can have as many non-clustered indexes as you want.


--=====================
-- Create INDEX
--=====================
CREATE [CLUSTERED | NON-CLUSTERED] INDEX index_name
ON table_name (col1, col2...)

-- If you define a column as PK, SQL automatically creates a CLUSTERED INDEX on that column.

-- Ex: Create a new table without clustered index and then create an index for it
-- This table has a heap structure
SELECT * 
INTO Sales.DBCustomers
FROM Sales.Customers

-- Create clustered idx for it
CREATE CLUSTERED INDEX idx_DBCustomers_CustomerID 
ON Sales.DBCustomers (CustomerID)

-- Drop Clustered IDX if creating other clustered indexes
DROP INDEX idx_DBCustomers_CustomerID ON Sales.DBCustomers

-- Create NON clustered IDXes
CREATE NONCLUSTERED INDEX idx_DBCustomers_LastName
ON Sales.DBCustomers (LastName)

CREATE INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers (FirstName)


--=====================
-- COMPOSITE INDEX
--=====================
-- NON Clustered.
-- Add the columns in the same order as in the WHERE clause in the query to use the composite index.

CREATE INDEX idx_DBCustomers_CountryScore
ON Sales.DBCustomers (Country, Score)




--=====================
-- COLUMNSTORE
--=====================
-- Data Pages store data by Column, not by Row (row: traditional). 
-- HOW? (Slide 21 in "10_Performance_Optimization")
	-- Data is segmented in Row Groups (1M per Group)
	-- Columns are separated
	-- Columns are compressed
	-- Data is stored in LoB (Large Object) Pages

-- CLUSTERED column Store INDEX: original table is removed
-- NON CLUSTERED column store INDEX: og table and new index can coexist

-- WHY Store data in columns?
	-- 1. Queries are FASTER: To fetch rows based on a condition, it will be faster for SQL to scan only the LoB page (a dictionary) of that
	-- column and then retrieve these rows, than scanning all rows and fetching only the ones where the condition is met.
	-- 2. Data COMPRESSION: Much better for storage

-- ROWSTORE vs COLUMNSTORE INDEX
-- +---------------------------+--------------------------------------------+-----------------------------------------------+
-- | Feature                   | ROWSTORE INDEX                              | COLUMNSTORE INDEX                              |
-- +---------------------------+--------------------------------------------+-----------------------------------------------+
-- | Data Organization         | Row-by-row                                  | Column-by-column                               |
-- | Storage Efficiency        | Less efficient                              | More efficient (compression)                   |
-- | Read Speed                | Fair                                        | Very fast                                      |
-- | Write Speed               | Fair                                        | Slower                                         |
-- | I/O Efficiency            | Low (retrieves all columns)                 | High (reads only needed columns)               |
-- | Best Use Case             | OLTP (transactional workloads)              | OLAP (analytical workloads)                    |
-- +---------------------------+--------------------------------------------+-----------------------------------------------+

-- SYNTAX
DROP INDEX idx_DBCustomers_CustomerID ON Sales.DBCustomers
CREATE CLUSTERED COLUMNSTORE INDEX IDX_DBCustomers ON Sales.DBCustomers --(No column here)
CREATE COLUMNSTORE INDEX IDX_DBCustomers_Country ON Sales.DBCustomers (Country)


--=====================
-- UNIQUE INDEX
--=====================
-- Slower writing
-- Faster reading
-- Use only when Index is on an ID, or columns where values are supposed to be unique


--=====================
-- FILTERED INDEX
--=====================
-- Index that includes only rows that meet a specific condition
-- Optimizes query (less data to check)
-- Less storage
-- Can only use on ROWSTORE, NONCLUSTERED Index
-- Create it simply by adding a WHERE clause at the end of the idx create statement.



--=====================
-- MONITOR INDEX USAGE
--=====================
-- First thing in new project: Check if there are unused indexes, discuss them with the team; if not used, drop them!
-- Saved Storage, improved writing time.

-- List all indexes on a table
sp_helpindex 'Sales.DBCustomers'

SELECT * FROM sys.indexes
SELECT * FROM sys.tables
SELECT * FROM sys.dm_db_index_usage_stats

-- Join these tables, check if indexes are used; if not, drop them.
SELECT 
	tbl.name AS TableName,
    idx.name AS IndexName,
    idx.type_desc AS IndexType,
    idx.is_primary_key AS IsPrimaryKey,
    idx.is_unique AS IsUnique,
    idx.is_disabled AS IsDisabled,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    COALESCE(s.last_user_seek, s.last_user_scan) AS LastUpdate
FROM sys.indexes idx
JOIN sys.tables tbl
    ON idx.object_id = tbl.object_id
LEFT JOIN sys.dm_db_index_usage_stats s
    ON s.object_id = idx.object_id
    AND s.index_id = idx.index_id
ORDER BY tbl.name, idx.name



--=====================
-- FIND MISSING INDEXES
--=====================
SELECT * FROM sys.dm_db_missing_index_details

--=======================
-- FIND DUPLICATE INDEXES
--=======================
SELECT  
	tbl.name AS TableName,
	col.name AS IndexColumn,
	idx.name AS IndexName,
	idx.type_desc AS IndexType,
	COUNT(*) OVER (PARTITION BY  tbl.name , col.name ) ColumnCount -- If this more than 1, then there's probably a duplicate index
FROM sys.indexes idx
JOIN sys.tables tbl ON idx.object_id = tbl.object_id
JOIN sys.index_columns ic ON idx.object_id = ic.object_id AND idx.index_id = ic.index_id
JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
ORDER BY ColumnCount DESC


--=======================
-- UPDATE STATISTICS
--=======================
-- Before executing a query, SQL makes an execution plan based on the Statistics it has about the tables in a DB.
-- If Statistics are outdated, the Execution Plan might choose the wrong path (eg deciding how to query 50 rows but the table has now 1M rows)
-- WHEN to update statistics
	-- Schedule to update in the weekends
	-- After migrating data



SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    s.name AS StatisticName,
    sp.last_updated AS LastUpdate,
    DATEDIFF(day, sp.last_updated, GETDATE()) AS LastUpdateDay,
    sp.rows AS 'Rows',
    sp.modification_counter AS ModificationsSinceLastUpdate
FROM sys.stats AS s
JOIN sys.tables AS t
    ON s.object_id = t.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
ORDER BY sp.modification_counter DESC

-- When modification_counter shows > 0, run
UPDATE STATISTICS table_name

-- Or, to upadte Statistics of the whole DB:
EXEC sp_updatestats



--=======================
-- UPDATE STATISTICS
--=======================
-- When there are empty spaces in the Data Pages
-- When data is not sorted correctly anymore

-- REORGANIZE => Light op
-- REBUILD => Drops and recreates index from scratch

-- Retrieve index fragmentation statistics for the current DB
SELECT 
    tbl.name AS TableName,
    idx.name AS IndexName,
    s.avg_fragmentation_in_percent,
    s.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS s
INNER JOIN sys.tables tbl 
    ON s.object_id = tbl.object_id
INNER JOIN sys.indexes AS idx 
    ON idx.object_id = s.object_id
    AND idx.index_id = s.index_id
ORDER BY s.avg_fragmentation_in_percent DESC

-- When to take action?
	-- 0 - 10% ==> Ok
	-- 10% - 30% ==> Reorganize
	-- 30%+		 ==> Rebuild

ALTER INDEX index_name ON table_name REORGANIZE
ALTER INDEX index_name ON table_name REBUILD

SELECT * FROM Sales.DBCustomers


--==================
-- INDEXING STRATEGY
--==================

-- Check Slide 34 in 10_Performance_Optimization




--###########################################################
--                     22. PARTITIONING                    --
--###########################################################
-- The process of dividing large tables in smaller - logical - batches
-- For example you can divide a big table into partitions by date, so you can work better with the most recent one while the older ones stay more idle.
-- Other benefits: 
	-- With parallel processing, the DB can work on each partition independently
	-- Can create an index for each partition; small index = faster query


-- How to create Partitions?

--======================
-- 1. PARTITION FUNCTION
--======================
-- Define the LOGIC on how to divide data into partitions. Define the PARTITION KEY (Date, Region)

CREATE PARTITION FUNCTION PartitionByYear (DATE)
AS RANGE LEFT FOR VALUES ('2023-12-31', '2024-12-31', '2025-12-31')

-- Query all existing Partition Functions in DB
SELECT 
	name, 
	function_id,
	type,
	type_desc,
	boundary_value_on_right
FROM sys.partition_functions


--=====================
-- 2. CREATE FILEGROUPS
--=====================
-- Logical container of one or more data files

ALTER DATABASE SalesDB ADD FILEGROUP FG_2023;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2024;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2025;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2026;

-- How to remove a FG:
ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2023;

-- Query all FGs:
SELECT *
FROM sys.filegroups
WHERE type = 'FG'


--==============
-- 3. DATA FILES
--==============
-- Add .ndf files to each FileGroup

-- for 2023
ALTER DATABASE SalesDB ADD FILE (
	NAME = P_2023, -- Logical Name
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
) TO FILEGROUP FG_2023

-- for 2024
ALTER DATABASE SalesDB ADD FILE (
	NAME = P_2024, -- Logical Name
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'
) TO FILEGROUP FG_2024

-- for 2025
ALTER DATABASE SalesDB ADD FILE (
	NAME = P_2025, -- Logical Name
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'
) TO FILEGROUP FG_2025

-- for 2026
ALTER DATABASE SalesDB ADD FILE (
	NAME = P_2026, -- Logical Name
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2026.ndf'
) TO FILEGROUP FG_2026


-- Query all
SELECT 
	fg.name AS FileGroupName,
	mf.name AS LogicalFileName,
	mf.physical_name AS PhysicalFilePath,
	mf.size / 128 AS SizeInMB
FROM sys.filegroups fg
JOIN sys.master_files mf 
	ON fg.data_space_id = mf.data_space_id
WHERE mf.database_id = DB_ID('SalesDB')


--===========================
-- 4. CREATE PARTITION SCHEME
--===========================
-- This is mapping each partition with its File Group.

CREATE PARTITION SCHEME SchemePartitionByYear
AS PARTITION PartitionByYear -- Name of the partition Fx
TO (FG_2023, FG_2024, FG_2025, FG_2026) -- Sort the FG, according to the result of the Function's partitions!

-- Query all partition schemes
SELECT
	ps.name AS partition_scheme_name,
	pf.name AS partition_function_name,
	ds.destination_id AS partition_number,
	fg.name AS filegroup_name_
FROM sys.partition_schemes ps
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN sys.destination_data_spaces ds ON ps.data_space_id = ds.partition_scheme_id
JOIN sys.filegroups fg ON ds.data_space_id = fg.data_space_id


--============================
-- 5. CREATE PARTITIONED TABLE
--============================
CREATE TABLE Sales.Orders_Partitioned (
	OrderID INT,
	OrderDate DATE,
	Sales INT
) ON SchemePartitionByYear (OrderDate)


--==========================================
-- 6. INSERT DATA INTO THE PARTITIONED TABLE
--==========================================
INSERT INTO Sales.Orders_Partitioned
VALUES (
	1,
	'2023-05-15',
	100
)

INSERT INTO Sales.Orders_Partitioned
VALUES (
	2,
	'2024-08-01',
	150
)

INSERT INTO Sales.Orders_Partitioned
VALUES (
	3,
	'2025-03-16',
	200
)

INSERT INTO Sales.Orders_Partitioned
VALUES (
	4,
	'2026-10-20',
	250
)


-- Check that each row went into the right partition
SELECT
	p.partition_number,
	fg.name AS partition_file_group,
	p.rows AS number_of_rows
FROM sys.partitions p
JOIN sys.destination_data_spaces dds ON p.Partition_number = dds.destination_id
JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'Orders_Partitioned'


--===============================
-- 7. Check Partition PERFORMANCE
--===============================

SELECT *
INTO Sales.Orders_NoPartition
FROM Sales.Orders_Partitioned

-- Now run query on both tables and compare execution plan.
SELECT * FROM Sales.Orders_NoPartition WHERE OrderDate LIKE '2026%'
SELECT * FROM Sales.Orders_Partitioned WHERE OrderDate LIKE '2026%'



--###########################################################
--                     23. BEST PRACTICES                  --
--###########################################################

-- GOLDEN RULE: Always check the EXECUTION PLAN to confirm performance improvements when optmizing the query. 
	-- If there is no improvement, aways pick the easiest to read.

-- FETCHING
--====================================
-- 1. SELECT ONLY THE COLUMNS YOU NEED
--====================================


--=========================================
-- 2. AVOID unnecessary DISTINCT & ORDER BY
--=========================================
-- They're expensive operations


--===================================
-- 3. For EXPLORATION, LIMIT the Rows
--===================================
SELECT TOP 10
FROM Sales.Orders

----------------------------------------------------------------

-- FILTERING
--=========================================================================
-- 4. Create NON-CLUSTERED INDEX on frequently used columns in WHERE clause
--=========================================================================
SELECT * FROM Sales.Orders WHERE OrderStatus = 'Delivered'
CREATE NONCLUSTERED INDEX Idx_Orders_OrderStatus ON Sales.Orders(OrderStatus)


--=========================================================================
-- 5. Avoid applying FUNCTIONS to columns in the WHERE clause
--=========================================================================
-- Functions on columns can block INDEX usage
-- Bad Practice
SELECT *
FROM Sales.Orders
WHERE LOWER(OrderStatus) = 'delivered'

-- Good Practice
SELECT * FROM Sales.Orders
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-12-31'


--===========================
-- 6. Avoid Leading WILDCARDS
--===========================
-- They also prevent INDEX usage
-- Bad practice
SELECT * FROM Sales.Orders
WHERE LastName LIKE '%Gold%'


--===================================
-- 7. Use IN Instead of multiple 'OR'
--===================================
SELECT * FROM Sales.Orders
WHERE CustomerID IN (1, 2, 3)

----------------------------------------------------------------

-- JOINS

--===================================
-- 8. Understand JOIN speed
--===================================

	-- INNER      ==> fastest
	-- RIGHT/LEFT ==> middle
	-- OUTER      ==> slowest


--===================================
-- 9. Use Explicit JOINS (ANSI Joins)
--===================================
-- BAD Practice
SELECT o.ORderID, c.FirstName
FROM Sales.Customers c, Sales.Orders o
WHERE c.CustomerID = o.CustomerID


--=======================================
-- 10. INDEX the columns in the ON clause
--=======================================
SELECT o.ORderID, c.FirstName
FROM Sales.Customers c
JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID

CREATE NONCLUSTERED INDEX Idx_Orders_CustomerID ON Sales.Orders(CustomerID)


--===========================================
-- 11. FILTER Data BEFORE JOINING (Big Tables)
--===========================================
-- Best Practice For Small-Medium Tables
-- Filter After Join (WHERE)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus = 'Delivered';

-- Filter During Join (ON)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
   AND o.OrderStatus = 'Delivered';

-- Best Practice For Big Tables
-- Filter Before Join (SUBQUERY/CTE)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers AS c
INNER JOIN (
    SELECT OrderID, CustomerID
    FROM Sales.Orders
    WHERE OrderStatus = 'Delivered'
) AS o
    ON c.CustomerID = o.CustomerID;


--===========================================
-- 12. AGGREGATE Data BEFORE JOINING (Big Tables)
--===========================================

-- Best Practice For Small-Medium Tables
-- Grouping and Joining
SELECT c.CustomerID, c.FirstName, COUNT(o.OrderID) AS OrderCount
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName;

-- Best Practice For Big Tables
-- Pre-aggregated Subquery
SELECT c.CustomerID, c.FirstName, o.OrderCount
FROM Sales.Customers AS c
INNER JOIN (
    SELECT CustomerID, COUNT(OrderID) AS OrderCount
    FROM Sales.Orders
    GROUP BY CustomerID
) AS o
    ON c.CustomerID = o.CustomerID;

-- Bad Practice
-- Correlated Subquery
SELECT 
    c.CustomerID, 
    c.FirstName,
    (SELECT COUNT(o.OrderID)
     FROM Sales.Orders AS o
     WHERE o.CustomerID = c.CustomerID) AS OrderCount
FROM Sales.Customers AS c


----------------------------------------------------

-- UNION

--===========================================
-- 13. Use UNION instead of OR in JOINS
--===========================================

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
    OR c.CustomerID = o.SalesPersonID;

-- Best Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
UNION
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.SalesPersonID;


--======================================================
-- 14. Check for NESTED LOOPS in JOINS and use SQL HINTS
--======================================================
-- They happen when joining a big table with a small one

SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o 
ON c.CustomerID = o.CustomerID

-- Good Practice for Having Big Table & Small Table
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
OPTION (HASH JOIN); -- best to join 2 tables very different in size


--======================================================
-- 15. Use UNION ALL if duplicates are acceptable
--======================================================

--==============================================================
-- 16. Use UNION ALL + DISTINCT if duplicates are NOT acceptable
--==============================================================
-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive 

-- Best Practice
SELECT DISTINCT CustomerID
FROM (
    SELECT CustomerID FROM Sales.Orders
    UNION ALL
    SELECT CustomerID FROM Sales.OrdersArchive
) AS CombinedData


----------------------------------------------------

-- AGGREGATIONS

--==============================================================
-- 17. Use COLUMNSTORE INDEX for Aggregations on LARGE TABLES
--==============================================================

SELECT CustomerID, COUNT(OrderID) AS OrderCount
FROM Sales.Orders 
GROUP BY CustomerID

CREATE CLUSTERED COLUMNSTORE INDEX Idx_Orders_Columnstore ON Sales.Orders


--=================================================================
-- 18. Pre-Aggregate Data and store it in a new table for REPORTING
--=================================================================

SELECT MONTH(OrderDate) OrderYear, SUM(Sales) AS TotalSales
INTO Sales.SalesSummary
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

SELECT OrderYear, TotalSales FROM Sales.SalesSummary -- Make sure to always update this table!


----------------------------------------------------

-- SUBQUERIES | CTEs

--==========================================
-- 19. JOIN vs EXISTS vs IN (Avoid using IN)
--==========================================

-- JOIN (Best Practice: If the Performance equals to EXISTS)
SELECT o.OrderID, o.Sales
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA';

-- EXISTS (Best Practice: Use it for Large Tables)
SELECT o.OrderID, o.Sales
FROM Sales.Orders AS o
WHERE EXISTS (
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'USA'
);

-- IN (Bad Practice)
SELECT o.OrderID, o.Sales
FROM Sales.Orders AS o
WHERE o.CustomerID IN (
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'USA'
);


--==========================
-- 20. AVOID REDUNDANT LOGIC
--==========================

-- Bad Practice
SELECT EmployeeID, FirstName, 'Above Average' AS Status
FROM Sales.Employees
WHERE Salary > (SELECT AVG(Salary) FROM Sales.Employees)
UNION ALL
SELECT EmployeeID, FirstName, 'Below Average' AS Status
FROM Sales.Employees
WHERE Salary < (SELECT AVG(Salary) FROM Sales.Employees);

-- Good Practice
SELECT 
    EmployeeID, 
    FirstName, 
    CASE 
        WHEN Salary > AVG(Salary) OVER () THEN 'Above Average'
        WHEN Salary < AVG(Salary) OVER () THEN 'Below Average'
        ELSE 'Average'
    END AS Status
FROM Sales.Employees;


----------------------------------------------------

-- DDL

/*
=============================================================================
Tip 21: Avoid VARCHAR, TEXT Data Type If Possible
=============================================================================
Tip 22: Avoid Using MAX or Overly Large Lengths
=============================================================================
Tip 23: Use NOT NULL If possible 
=============================================================================
Tip 24: Make sure all tables have a CLUSTERED PRIMARY KEY
=============================================================================
Tip 25: Creeate Nonclustered Index on Foreign Key if they are frequently used
=============================================================================
*/
-- Bad Practice 
CREATE TABLE CustomersInfo (
    CustomerID INT,
    FirstName VARCHAR(MAX),
    LastName TEXT,
    Country VARCHAR(255),
    TotalPurchases FLOAT, 
    Score VARCHAR(255),
    BirthDate VARCHAR(255),
    EmployeeID INT,
    CONSTRAINT FK_Bad_Customers_EmployeeID FOREIGN KEY (EmployeeID)
        REFERENCES Sales.Employees(EmployeeID)
);

-- Good Practice 
CREATE TABLE CustomersInfo (
    CustomerID INT PRIMARY KEY CLUSTERED,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    TotalPurchases FLOAT,
    Score INT,
    BirthDate DATE,
    EmployeeID INT,
    CONSTRAINT FK_CustomersInfo_EmployeeID FOREIGN KEY (EmployeeID)
        REFERENCES Sales.Employees(EmployeeID)
);
CREATE NONCLUSTERED INDEX IX_CustomersInfo_EmployeeID
ON CustomersInfo(EmployeeID);


----------------------------------------------------

-- INDEXING

/*
=================================================================================================================================
Tip 26: Avoid Over Indexing, as it can slow down insert, update, and delete operations
=================================================================================================================================
Tip 27: Regularly review and drop unused indexes to save space and improve write performance
=================================================================================================================================
Tip 28: Update table statistics weekly to ensure the query optimizer has the most up-to-date information
=================================================================================================================================
Tip 29: Reorganize and rebuild fragmented indexes weekly to maintain query performance.
=================================================================================================================================
Tip 30: For large tables (e.g., fact tables), partition the data and then apply a columnstore index for best performance results
=================================================================================================================================
*/



--###########################################################
--                     24. COPILOT & CHATGPT for SQL       --
--###########################################################

-- Always find the solution on your own!
-- When prompting use this structure:
	-- 1. Task
	-- 2. Context
	-- 3. Specifications
	-- 4. Roles 
	-- 5. Tone

-- Use it to:
	-- Add comments
	-- Make code leaner
	-- make code more efficient
	-- explain code
	-- Create a personalized course
	-- Understand more specific SQL concepts
	-- Compare concepts
	-- Ask for help to practice
	-- Prepare fro SQL interview


