SELECT * FROM coffee_shop;

-- check for duplicates --
SELECT transaction_id, COUNT(*) AS count
FROM coffee_shop
GROUP BY transaction_id
HAVING COUNT(count) > 1;


-- Which store location has the highest sales? lowest sales?
-- SOLUTION: since there is no sales column in the dataset, i create one by multiplying unit price to transaction quantity,
-- then to get the highest and lowest sales per location, i use CTE to return only columns that I need.

WITH sales_data AS (
SELECT store_location, product_category,
	unit_price * transaction_qty AS sales
FROM coffee_shop
GROUP BY store_location, product_category, sales
ORDER BY sales DESC
)
SELECT store_location, ROUND(SUM(sales),2) AS total_sales
FROM sales_data
GROUP BY store_location;

-- What is the sales trend over time? 

WITH sales_data AS (
SELECT transaction_date, store_location, product_category,
	unit_price * transaction_qty AS sales
FROM coffee_shop
GROUP BY store_location, product_category, transaction_date, sales
)
SELECT transaction_date, ROUND(SUM(sales),2) AS total_sales
FROM sales_data
GROUP BY transaction_date;

-- what is the maximum and minimum and average sales per store location? 

WITH cte AS (
SELECT store_location, unit_price * transaction_qty AS total_sales
FROM coffee_shop
GROUP BY store_location, total_sales
)
SELECT store_location,
	MAX(total_sales) AS max_sales,
    MIN(total_sales) AS min_sales,
    ROUND(AVG(total_sales),2) AS avg_sales
FROM cte
GROUP BY store_location;

-- what time of the day is the most popular? Does the same trend hold across all locations?
WITH cte AS (
SELECT transaction_date, transaction_time, 
	unit_price * transaction_qty AS total_sales
FROM coffee_shop
GROUP BY transaction_date, transaction_time, total_sales
)
SELECT transaction_date, transaction_time
FROM (
	SELECT transaction_date, transaction_time, total_sales,
    RANK() OVER(ORDER BY total_sales DESC) AS rank_num
    FROM cte
) ranked
WHERE rank_num = 1;

-- Which products are sold most and least often? Which drive the most revenue for the business?
WITH cte AS (
SELECT product_category, product_type,
	unit_price * transaction_qty AS total_sales
FROM coffee_shop
GROUP BY product_category, product_type, total_sales
)
SELECT product_category, product_type, total_sales
FROM (
	SELECT product_category, product_type, total_sales,
    RANK() OVER(ORDER BY total_sales DESC) AS rank_num
    FROM cte
) ranked
WHERE rank_num = 1;
