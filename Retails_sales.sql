SELECT *
FROM retail_sales_p1
;

-- CREATING DUPLICATE TABLE FOR DATA CLEANING

CREATE TABLE `retail_sales_p1` (
  `transactions_id` int DEFAULT NULL,
  `sale_date` text,
  `sale_time` text,
  `customer_id` int DEFAULT NULL,
  `gender` text,
  `age` int DEFAULT NULL,
  `category` text,
  `quantity` int DEFAULT NULL,
  `price_per_unit` int DEFAULT NULL,
  `cogs` int DEFAULT NULL,
  `total_sale` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

INSERT INTO retail_sales_p1
SELECT *,
		ROW_NUMBER ()
					OVER (
						PARTITION BY transactions_id, sale_date, sale_time, customer_id, gender, age, 
                        category, quantity, price_per_unit, cogs, total_sale) AS row_num
FROM retail_sales
;

SELECT 
	COUNT(*)
FROM retail_sales_p1
;

-- 	DATA EXPLORATION
-- How Many Sales Do We Have?

SELECT COUNT(*) AS total_sales
FROM retail_sales_p1
;

-- How many unqiue customer do we have?

SELECT 
	COUNT(DISTINCT customer_id) AS total_sales
FROM retail_sales_p1
;
 
 -- Checking how many unqiue category we have
 
SELECT 
	DISTINCT category AS total_sales
FROM retail_sales_p1
;


-- DATA ANALYSIS & BUSINESS KEY PROBLEM & ANSWERS

-- Q.1 Retrieving all column for sales in 2022-11-05

SELECT *
FROM retail_sales_p1
WHERE sale_date = '2022-11-05'
;

-- Q.2 Retrieving all transaction where category is 'clothing' and the quantity sold is more than '10' in the month of 'NOV- 2022'

SELECT *
FROM retail_sales_p1
WHERE category = 'clothing' 
	AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
HAVING quantity >= 4
;

-- Q.3 Write a query to calculate the total sales for each category

SELECT DISTINCT 
	category, SUM(total_sale) AS net_sales,
	COUNT(*) AS total_orders			
FROM retail_sales_p1
GROUP BY 1
ORDER BY 2 DESC
;

-- Q.4 Write a query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT ROUND(AVG(age), 2) AS Avg_Age
FROM retail_sales_p1
WHERE category = 'beauty'
;

-- Q.5 Write a query to find all transactions where the total_sale is greater than 1000

SELECT *
FROM retail_sales_p1
WHERE total_sale > 1000
;

-- Q.6 Write a query to find the total number of transactions made by each category

SELECT 
	category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales_p1
GROUP BY 
	category, gender
    ORDER BY 1
;

-- Q.7 Write a query to calculate the average sale for each year

SELECT * FROM
(
	SELECT 
		YEAR(sale_date) AS `year`,
		EXTRACT(MONTH FROM sale_date) AS `month`,
		AVG(total_sale) AS total_sale,
		RANK()
			OVER(
				PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS `Rank`
	FROM retail_sales_p1
	GROUP BY 1, 2
) AS t1
WHERE `rank` = 1
;

-- Q.8 Write a query to find the top customers based on the highest sales

SELECT 
	customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales_p1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
;

-- Q.9 Write query to find the number of unqiue customer who purchased items from each category

SELECT 
	category,
    COUNT(DISTINCT customer_id) AS cst_unq
FROM retail_sales_p1
GROUP BY category
;

-- Q.10 Write a query to create each shift and number of order (e.g morning <= 12, Afternoon between 12 and 17, Evening > 17)

WITH Hourly_sale
AS
(
SELECT *, 
	CASE
		WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END AS Shift
FROM retail_sales_p1
)
SELECT 
	Shift,
	COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
;

-- END OF PROJECT