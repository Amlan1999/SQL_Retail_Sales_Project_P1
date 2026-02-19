-- SQL Retail Sales Analysis --P1

CREATE DATABASE SQL_PROJECT_P1;
USE SQL_PROJECT_P1;
-- CREATE TABLE

DROP TABLE IF EXISTS RETAIL_SALES;
CREATE TABLE retail_sales (
    transactions_id INT,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(30),
    quantity INT,
    price_per_unit DECIMAL(10,2),
    cogs DECIMAL(10,2),
    total_sale DECIMAL(10,2)
);


SELECT * FROM RETAIL_SALES;

-- REMOVE NULL VALUES ROWS IF NOT NEEDED
 -- CHECK NULL VALUE ROWS
SELECT * FROM RETAIL_SALES
WHERE TRANSACTIONS_ID IS NULL OR SALE_DATE IS NULL OR SALE_TIME IS NULL OR CUSTOMER_ID IS NULL OR GENDER IS NULL OR
		AGE IS NULL OR CATEGORY IS NULL OR QUANTITY IS NULL OR PRICE_PER_UNIT IS NULL OR COGS IS NULL OR TOTAL_SALE IS NULL;

-- DELETE NULL VALUES ROWS        
DELETE FROM RETAIL_SALES
WHERE TRANSACTIONS_ID IS NULL OR SALE_DATE IS NULL OR SALE_TIME IS NULL OR CUSTOMER_ID IS NULL OR GENDER IS NULL OR
		AGE IS NULL OR CATEGORY IS NULL OR QUANTITY IS NULL OR PRICE_PER_UNIT IS NULL OR COGS IS NULL OR TOTAL_SALE IS NULL;
        
        
 -- COUNT HOW MANY ROWS ARE NULL IN AGE COLUMN

SELECT COUNT(*) 
FROM retail_sales
WHERE age IS NULL;

-- REPLACE NULL IN AGE COL WITH (AVERAGE AGE IN TABLE) 

SET SQL_SAFE_UPDATES = 0;

UPDATE RETAIL_SALES
SET AGE = (SELECT AVG(AGE) 
		FROM (SELECT AGE 
				FROM RETAIL_SALES
                WHERE AGE IS NOT NULL)AS TEMP)
WHERE AGE IS NULL;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) FROM RETAIL_SALES;

SELECT * FROM RETAIL_SALES;
-- 3. Data Analysis & Findings
-- The following SQL queries were developed to answer specific business questions:

-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
-- ANS
SELECT * FROM RETAIL_SALES
WHERE SALE_DATE = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the 
--    category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
-- ANS
SELECT * 
FROM RETAIL_SALES
WHERE CATEGORY = 'CLOTHING' 
		AND 
        QUANTITY >= 4 
		AND 
        sale_date >= '2022-11-01'
		AND sale_date < '2022-12-01' ;

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category.:
-- ANS
SELECT CATEGORY,
		SUM(TOTAL_SALE) AS TOTAL_SALES,
        COUNT(*) AS TOTAL_ORDER
FROM RETAIL_SALES
GROUP BY CATEGORY;

-- 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
-- ANS 

SELECT ROUND(AVG(AGE), 2) AS AVG_AGE
FROM RETAIL_SALES
WHERE CATEGORY = 'BEAUTY';

-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:
-- ANS

SELECT *
FROM RETAIL_SALES
WHERE TOTAL_SALE > 1000;

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
-- ANS 
SELECT CATEGORY,
		GENDER, 
        COUNT(*) AS TOTAL_TRANSACTION 
FROM RETAIL_SALES
GROUP BY CATEGORY,
			GENDER
ORDER BY CATEGORY;

-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
-- ANS 
SELECT YEAR,
		MONTH,
        AVG_SALE
FROM (SELECT 
			EXTRACT(YEAR FROM SALE_DATE) AS YEAR,
            EXTRACT(MONTH FROM SALE_DATE) AS MONTH,
            AVG(TOTAL_SALE) AS AVG_SALE,
            RANK() OVER(PARTITION BY EXTRACT(YEAR FROM SALE_DATE) ORDER BY AVG(TOTAL_SALE) DESC) RNK
		FROM RETAIL_SALES
        GROUP BY 1, 2) AS T1
WHERE RNK = 1;

-- ANOTHER METHOD USING CTE

WITH monthly_avg AS (
    SELECT 
        YEAR(sale_date) AS yr,
        MONTH(sale_date) AS mn,
        AVG(total_sale) AS avg_sale
    FROM retail_sales
    GROUP BY yr, mn
)
SELECT *
FROM (
        SELECT *,
               RANK() OVER (PARTITION BY yr ORDER BY avg_sale DESC) AS rnk
        FROM monthly_avg
     ) t
WHERE rnk = 1;

-- 8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
-- ANS

SELECT CUSTOMER_ID,
		SUM(TOTAL_SALE) AS TOTAL_SALES
FROM retail_sales
GROUP  BY 1
ORDER BY 2 DESC
LIMIT 5;

-- IF YOU WANT RANK

SELECT CUSTOMER_ID,
		SUM(TOTAL_SALE) AS TOTAL_SALES,
        RANK() OVER (ORDER BY SUM(TOTAL_SALE) DESC) AS RNK
FROM RETAIL_SALES
GROUP BY CUSTOMER_ID
LIMIT 5;

-- WITHOUT USING LIMIT
SELECT CUSTOMER_ID,
		TOTAL_SALES
FROM (SELECT
			CUSTOMER_ID,
            SUM(TOTAL_SALE) AS TOTAL_SALES,
            RANK() OVER (ORDER BY SUM(TOTAL_SALE) DESC) AS RNK
            FROM RETAIL_SALES
            GROUP BY CUSTOMER_ID
            ) AS T
WHERE RNK <= 5;

-- 9. Write a SQL query to find the number of unique customers who purchased items from each category.:
-- ANS
SELECT CATEGORY,
		COUNT(DISTINCT CUSTOMER_ID) AS UNIQUE_CUSROMER_COUNT
FROM RETAIL_SALES
GROUP BY CATEGORY;

-- 10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
-- ANS 

WITH HOURLY_SALE AS
(
	SELECT *,
		CASE 
			WHEN HOUR(SALE_TIME) < 12 THEN 'MORNING'
			WHEN HOUR(SALE_TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			ELSE 'EVENING'
		END AS SHIFT
	FROM RETAIL_SALES
)
SELECT SHIFT,
		COUNT(*) AS TOTAL_ORDER
FROM HOURLY_SALE
GROUP BY SHIFT;

-- ---------------------------------FINDINGS----------------------------

-- Customer Demographics: The dataset includes customers from various age groups, 
-- 		with sales distributed across different categories such as Clothing and Beauty.
-- High-Value Transactions: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
-- Sales Trends: Monthly analysis shows variations in sales, helping identify peak seasons.
-- Customer Insights: The analysis identifies the top-spending customers and the most popular product categories.


-- ---------------------------------REPORTS -----------------------

-- Sales Summary: A detailed report summarizing total sales, customer demographics, and category performance.
-- Trend Analysis: Insights into sales trends across different months and shifts.
-- Customer Insights: Reports on top customers and unique customer counts per category.

-- ---------------------------------CONCLUSION --------------------

-- This project serves as a comprehensive introduction to SQL for data analysts, 
-- 		covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. 
-- The findings from this project can help drive business decisions by understanding sales patterns, 
-- 		customer behavior, and product performance.