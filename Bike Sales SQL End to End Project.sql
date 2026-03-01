CREATE DATABASE bike_sales;
USE bike_sales;

ALTER TABLE sales
CHANGE COLUMN `ï»¿OrderDate` OrderDate VARCHAR(50);

SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;


-- executive overview; (1) get the total sales, total profit, profit margin, sales trend, top 5 products, and category --

-- (1) get the total sales

SELECT ROUND(SUM(SalesAmount),2) AS total_sales
FROM sales;

-- (2) get the total profit (FORMULA: total sales - total cost)

SELECT ROUND(SUM(SalesAmount) - SUM(TotalProductCost),2) AS total_profit
FROM sales;

-- (3) get the profit margin (FORMULA: profit / sales * 100)

SELECT ROUND(SUM(SalesAmount) - SUM(TotalProductCost),2) / ROUND(SUM(SalesAmount),2) * 100 AS profit_margin
FROM sales;

-- (4) sales trend by date

SELECT OrderDate, ROUND(SUM(SalesAmount),2) AS total_sales
FROM sales
GROUP BY OrderDate
ORDER BY total_sales DESC;

-- (5) top 5 products by sales

SELECT p.ProductKey, p.ProductName, ROUND(SUM(SalesAmount),2) AS total_sales
FROM products p
JOIN sales s ON p.ProductKey = s.ProductKey
GROUP BY 1,2
ORDER BY total_sales DESC
LIMIT 5;

-- (6) top 5 category by sales

SELECT p.Category, p.ProductName, ROUND(SUM(SalesAmount),2) AS total_sales
FROM products p
JOIN sales s ON p.ProductKey = s.ProductKey
GROUP BY 1,2
ORDER BY total_sales DESC
LIMIT 5;


-- Product Analysis: Sales by Category, Profit by Category, Sales by Color, Top & Bottom Products

SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;


-- sales by category
SELECT p.Category, p.ProductName, ROUND(SUM(SalesAmount),2) AS total_sales
FROM products p
JOIN sales s ON p.ProductKey = s.ProductKey
GROUP BY 1,2
ORDER BY total_sales DESC;

-- profit by category

SELECT p.category, 
	ROUND(SUM(SalesAmount) - SUM(TotalProductCost),2) AS total_profit
FROM sales s 
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY p.category;

-- sales by color
SELECT p.color, 
	ROUND(SUM(SalesAmount) - SUM(TotalProductCost),2) AS total_profit
FROM sales s 
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY p.color;


-- Customer Insights: Sales by Gender, Sales by Income Group, Sales by Occupation, Average Spend per Customer

SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- sales by gender

SELECT ROUND(SUM(SalesAmount),2) AS total_sales,
	CASE WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
    END AS gender
FROM customers c
JOIN sales s ON c.CustomerKey = s.CustomerKey
GROUP BY c.gender;

-- sales by IncomeGroup 

SELECT c.YearlyIncome, ROUND(SUM(SalesAmount),2) AS total_sales,
	CASE WHEN YearlyIncome BETWEEN 10000 AND 30000 THEN 'Low Compensated'
    WHEN YearlyIncome BETWEEN 40000 AND 70000 THEN 'Mid Compensated'
    ELSE 'Highly Compensated'
    END AS IncomeGroup
FROM customers c
JOIN sales s ON c.CustomerKey = s.CustomerKey
GROUP BY c.YearlyIncome
ORDER BY total_sales DESC;

-- sales by Occupation

SELECT c.Occupation, ROUND(SUM(SalesAmount),2) AS total_sales
FROM customers c
JOIN sales s ON c.CustomerKey = s.CustomerKey
GROUP BY c.Occupation
ORDER BY total_sales DESC;

-- average spend per customer

SELECT
    ROUND(SUM(SalesAmount) * 1.0 / COUNT(DISTINCT CustomerKey),2) AS avg_spend
FROM Sales;



