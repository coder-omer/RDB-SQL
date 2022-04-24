----- MARCH 9, 2022

--Write a query that returns the net price paid by the customer for each order. (Don't neglect discounts and quantities)


--bir sipari?in toplam net tutar?n? getiriniz. (mü?terinin sipari? için ödedi?i tutar)
--discount' ? ve quantity' yi ihmal etmeyiniz.






---------- ROLLUP ---------
--Generate different grouping variations that can be produced with the brand and category columns using 'ROLLUP'.
-- Calculate sum total_sales_price

--brand, category, model_year sütunlar? için Rollup kullanarak total sales hesaplamas? yap?n.
--üç sütun için 4 farkl? gruplama varyasyonu üretiyor


SELECT Brand, Category, Model_Year, SUM(total_sales_price) TOTAL 
FROM sale.sales_summary
GROUP BY 
	ROLLUP (Brand, Category, Model_Year)
ORDER BY Model_Year, Category

----- CUBE

SELECT Brand, Category, Model_Year, SUM(total_sales_price)
FROM sale.sales_summary
GROUP BY
	CUBE (Brand, Category, Model_Year)
ORDER BY Brand, Category


----- pivot table


--Write a query that returns total sales amount by categories

SELECT Category, total_sales_price
FROM sale.sales_summary

SELECT *
FROM 
(
SELECT Category, total_sales_price
FROM sale.sales_summary
) B
PIVOT
(
		SUM(total_sales_price)
		FOR Category
		IN
		([Audio & Video Accessories]
		,[Bluetooth]
		,[Car Electronics]
		,[Computer Accessories]
		,[Earbud]
		,[gps]
		,[Hi-Fi Systems]
		,[Home Theater]
		,[mp4 player]
		,[Receivers Amplifiers]
		,[Speakers]
		,[Televisions & Accessories]
		)
) AS PIVOT_TABLE


----- SET OPERATORS

-- UNION-UNIONALL

---- 
--List Customer's last names in Charlotte and Aurora

SELECT last_name
FROM sale.customer 
WHERE city = 'Charlotte'
UNION ALL
SELECT last_name
FROM sale.customer 
WHERE city = 'Aurora'


SELECT last_name
FROM sale.customer 
WHERE city = 'Charlotte'
UNION
SELECT last_name
FROM sale.customer 
WHERE city = 'Aurora'


SELECT last_name
FROM sale.customer 
WHERE city IN ('Charlotte', 'Aurora') --- UNION ALL GIBI BUTUN VERILER GELIR


--Write a query that returns customers who name is ‘Thomas’ or surname is ‘Thomas’. (Don't use 'OR')


SELECT first_name, last_name
FROM sale.customer
WHERE first_name = 'Thomas'
UNION ALL
SELECT first_name, last_name
FROM sale.customer
WHERE last_name = 'Thomas'



------ --Even if the contents of to be unified columns are different, the data type must be the same.

SELECT *
FROM product.brand 
UNION 
SELECT *
FROM product.category

SELECT *
FROM product.brand 
UNION ALL
SELECT *
FROM product.category


--- COLUMN SAYISI FARKLI OLMA DURUMU 


SELECT city, 'CLEAN' AS STREET
FROM sale.store
UNION ALL
SELECT city
FROM sale.store


---- INTERSECT

-- Write a query that returns brands that have products for both 2018 and 2019.

SELECT *
FROM product.brand
WHERE brand_id IN
(
SELECT brand_id
FROM product.product
WHERE model_year = 2018
INTERSECT
SELECT brand_id
FROM product.product
WHERE model_year = 2019
) ;



------- Write a query that returns customers who have orders for both 2018, 2019, and 2020

SELECT first_name, last_name
FROM sale.customer
WHERE customer_id IN
(
SELECT customer_id
FROM sale.orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-12-31' 
INTERSECT
SELECT customer_id
FROM sale.orders
WHERE order_date BETWEEN '2019-01-01' AND '2019-12-31' 
INTERSECT 
SELECT customer_id
FROM sale.orders
WHERE order_date BETWEEN '2020-01-01' AND '2020-12-31' 
)


----- EXCEPT 

-- Write a query that returns brands that have a 2018 model product but not a 2019 model product.

SELECT *
FROM product.brand
WHERE brand_id IN 
(
SELECT brand_id
FROM product.product
WHERE model_year = 2018
EXCEPT
SELECT brand_id
FROM product.product
WHERE model_year = 2019
)



--- CASE EXPRESSION


--- SIMPLE CASE EXPRESSION 


-- Generate a new column containing what the mean of the values in the Order_Status column.

-- 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT order_id, order_status
FROM sale.orders


SELECT order_id, order_status,
		CASE order_status
					WHEN 1 THEN 'Pending'
					WHEN 2 THEN 'Processing'
					WHEN 3 THEN 'Rejected'
					WHEN 4 THEN 'Completed'
		END ORDER_STATUS_DESC
FROM sale.orders


-- Add a column to the sales.staffs table containing the store names of the employees.

SELECT first_name, last_name, store_id,
		CASE store_id
			WHEN 1 THEN 'Davi techno Retail'
			WHEN 2 THEN 'The BFLO Store'
			ELSE 'Burkes Outlet'
		END STORE_NAME 
FROM sale.staff



---- SEARCHED CASE EXPRESSION

-- Generate a new column containing what the mean of the values in the Order_Status column. (use searched case ex.)
-- 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT order_id, order_status,
			CASE 
				WHEN order_status = 1 THEN 'Pending'
				WHEN order_status = 2 THEN 'Processing'
				WHEN order_status = 3 THEN 'Rejected'
				WHEN order_status = 4 THEN 'Completed'
			END ORDER_STATUS_NEW
FROM sale.orders


-- Create a new column containing the labels of the customers' email service providers ( "Gmail", "Hotmail", "Yahoo" or "Other" )

SELECT first_name, last_name, email
FROM sale.customer



SELECT first_name, last_name, email,
			CASE
				WHEN email LIKE '%@gmail.%' THEN 'GMAIL'
				WHEN email LIKE '%@hotmail.%' THEN 'HOTMAIL'
				WHEN email LIKE '%@yahoo.%' THEN 'YAHOO'
				WHEN email IS NOT NULL THEN 'OTHER'
				ELSE NULL 
			END EMAIL_SERVICE_PROVIDER
FROM sale.customer