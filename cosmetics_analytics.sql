USE sales_analytics;
--a few other queries were written for minor cleaning purposes such as changing and permanently setting the data type from bigint to int for some columns to avoid any excessiveness

--top 10 highest total revenue generating products
SELECT product, SUM(`amount_($)`) AS total_revenue FROM cosmetics_analytics 
GROUP BY product
ORDER BY SUM(`amount_($)`) DESC
LIMIT 10;

--top 5 highest sold products in each country
WITH cte AS (
    SELECT 
        country, 
        product, 
        SUM(boxes_shipped) AS sales 
    FROM cosmetics_analytics
    GROUP BY country, product
)
SELECT *
FROM (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY sales DESC) AS rn
    FROM cte
) ranked
WHERE rn <= 5;

--top 5 highest revenue generating products in each month
WITH monthly_product_revenue AS (
  SELECT
    MONTH(date) AS mm,
    product,
    SUM(`amount_($)`) AS total_revenue
  FROM cosmetics_analytics
  GROUP BY mm, product
)
SELECT
  mm,
  product,
  total_revenue
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY mm ORDER BY total_revenue DESC) AS rn
  FROM monthly_product_revenue
) ranked
WHERE rn <= 5
ORDER BY mm, total_revenue DESC;

--for each product which month had the highest sales
with cte as (SELECT product, MONTH(date) AS mon, SUM(boxes_shipped) AS sold_boxes FROM cosmetics_analytics
GROUP BY product, mon)

SELECT * FROM
(
SELECT *, row_number() over(PARTITION BY product ORDER BY sold_boxes DESC) as rn FROM cte
) ranked
WHERE rn = 1;

--for each product which month did they bring in the most revenue
with cte as (SELECT product, MONTH(date) AS mon, SUM(`amount_($)`) AS total_revenue FROM cosmetics_analytics
GROUP BY product, mon)

SELECT * FROM
(
SELECT *, row_number() over(PARTITION BY product ORDER BY total_revenue DESC) as rn FROM cte
) ranked
WHERE rn = 1; 

--month over month growth comparison %
SELECT 
  MONTH(date) AS month,
  SUM(`amount_($)`) AS total_revenue,
  LAG(SUM(`amount_($)`)) OVER (ORDER BY MONTH(date)) AS previous_month_revenue,
  ROUND(
    (SUM(`amount_($)`) - LAG(SUM(`amount_($)`)) OVER (ORDER BY MONTH(date)))
    / LAG(SUM(`amount_($)`)) OVER (ORDER BY MONTH(date)) * 100, 2
  ) AS growth_percent
FROM cosmetics_analytics
GROUP BY MONTH(date)
ORDER BY month;
 
--rank the countries based off of how much revenue was generated from sales in those countries
SELECT country, SUM(`amount_($)`) AS total_revenue FROM cosmetics_analytics
GROUP BY country
ORDER BY total_revenue DESC;