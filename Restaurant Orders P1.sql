USE coffee;
SELECT * FROM coffee_shop;

-- get the revenue per store_location, product_category, product_type
SELECT store_location, product_category, product_type,
	unit_price * transaction_qty AS revenue
FROM coffee_shop
GROUP BY store_location, product_category, product_type, revenue;

-- add column for month, and day of the week
ALTER TABLE coffee_shop
ADD COLUMN month VARCHAR(50);

ALTER TABLE coffee_shop
ADD COLUMN weekday VARCHAR(50);

-- update the month column
UPDATE coffee_shop
SET weekday = '1'
WHERE transaction_date LIKE '%/1/2023';

SELECT transaction_date,
       WEEKDAY(STR_TO_DATE(transaction_date, '%m/%d/%Y')) + 1 AS weekday_number
FROM coffee_shop;

