Consumer Goods SQL Queries 


1) Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.

select distinct market from dim_customer 
where region='APAC' and customer='Atliq Exclusive' 


2)What is the percentage of unique product increase in 2021 vs. 2020? 

WITH product_2020 AS (
	SELECT COUNT(DISTINCT product_code) AS unique_product_2020 FROM fact_sales_monthly WHERE fiscal_year = 2020
),
 product_2021 AS (
	SELECT COUNT(DISTINCT product_code) AS unique_product_2021 FROM fact_sales_monthly WHERE fiscal_year = 2021
)
SELECT unique_product_2020,unique_product_2021,
ROUND(((unique_product_2021/unique_product_2020)-1)*100,2) AS percentage_change
FROM product_2020
CROSS JOIN product_2021;


3) Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts.

select segment,COUNT( distinct product_code) AS product_count from dim_product
GROUP BY segment 
ORDER BY product_count DESC;


4) Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? 

WITH main_table AS (
SELECT f.product_code AS product_code,fiscal_year,segment
FROM fact_sales_monthly f JOIN dim_product d ON d.product_code=f.product_code
),
product_2020 AS (
	SELECT COUNT(DISTINCT product_code) AS product_count_2020,segment
    FROM main_table
    WHERE fiscal_year=2020
    GROUP BY segment
),
product_2021 AS (
	SELECT COUNT(DISTINCT product_code) AS product_count_2021,segment
    FROM main_table
    WHERE fiscal_year=2021
    GROUP BY segment
)
SELECT product_2020.segment,product_count_2020,product_count_2021,
(product_count_2021-product_count_2020) AS difference 
FROM product_2020 JOIN product_2021 ON product_2020.segment=product_2021.segment
ORDER BY difference DESC;


5)Get the products that have the highest and lowest manufacturing costs.


SELECT product,dim_product.product_code,manufacturing_cost
FROM fact_manufacturing_cost JOIN dim_product ON fact_manufacturing_cost.product_code=dim_product.product_code
WHERE manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
UNION
SELECT product,dim_product.product_code,manufacturing_cost
FROM fact_manufacturing_cost JOIN dim_product ON fact_manufacturing_cost.product_code=dim_product.product_code
WHERE manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost)


6) Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. 


SELECT d.customer_code,customer,ROUND(avg(pre_invoice_discount_pct),2) 
FROM fact_pre_invoice_deductions f JOIN dim_customer d ON d.customer_code=f.customer_code
WHERE fiscal_year=2021 AND market='India'
GROUP BY customer_code 
ORDER BY pre_invoice_discount_pct DESC
LIMIT 5;


7) Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month . This analysis helps to get an idea of low and
high-performing months and take strategic decisions

SELECT month(date) AS month,year(date) AS year,
SUM(sold_quantity*gross_price) AS sales_amount
from fact_sales_monthly 
JOIN fact_gross_price 
ON fact_gross_price.product_code=fact_sales_monthly.product_code
JOIN dim_customer 
ON dim_customer.customer_code=fact_sales_monthly.customer_code
WHERE customer='Atliq Exclusive' 
AND fact_sales_monthly.fiscal_year=fact_gross_price.fiscal_year
GROUP BY month;

8)In which quarter of 2020, got the maximum total_sold_quantity?

SELECT 
CASE 
	WHEN month(date) IN (9,10,11) THEN 'Q1'
    WHEN month(date) IN (12,1,2) THEN 'Q2'
    WHEN month(date) IN (3,4,5) THEN 'Q3'
    WHEN month(date) IN (6,7,8) THEN 'Q4'
    END AS quarter,
SUM(sold_quantity) AS total_sold_quantity 
FROM fact_sales_monthly
GROUP BY quarter
ORDER BY total_sold_quantity DESC;

9) Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? 

WITH combined_t AS(
SELECT channel,SUM(sold_quantity*gross_price) AS gross_sales_mln 
FROM fact_sales_monthly f JOIN dim_customer d ON d.customer_code=f.customer_code 
JOIN fact_gross_price fg ON fg.product_code=f.product_code AND fg.fiscal_year=f.fiscal_year
WHERE f.fiscal_year=2020
GROUP BY channel
ORDER BY gross_sales_mln DESC)
SELECT channel,gross_sales_mln,100*gross_sales_mln/SUM(gross_sales_mln) OVER() AS percentage 
FROM combined_t;


10) Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? 

WITH main_cte AS (
SELECT d.product_code, d.product,d.division, SUM(sold_quantity) AS total_sold_quantity,
RANK() OVER(partition by division ORDER BY SUM(sold_quantity) DESC) AS rank_order
FROM fact_sales_monthly f 
JOIN dim_product d
ON f.product_code=d.product_code
WHERE fiscal_year=2021
GROUP BY d.product_code)
SELECT *
FROM main_cte
WHERE rank_order<4;




































