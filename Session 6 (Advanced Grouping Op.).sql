----- MARCH 7, 2022


/*
JOINLER: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF 

VIEW

*/


---- CROSS JOIN QUESTIONS

/*
In the stocks table, there are not all products held on the product table and you 
want to insert these products into the stock table.

You have to insert all these products for every three stores with �0� quantity.

Write a query to prepare this data.
*/

SELECT product_id, quantity
FROM product.stock



SELECT B.store_id, A.product_id, 0 QUATITY
FROM product.product A
CROSS JOIN sale.store B
WHERE A.product_id NOT IN (
	SELECT product_id
	FROM product.stock
	)
ORDER BY A.product_id, B.store_id


----- ADVANCED GROUP OPERATION 



------Write a query that checks if any product id is repeated in more than one row in the product table.


SELECT *
FROM product.product

SELECT product_id, COUNT(product_id) num_of_rows
FROM product.product
GROUP BY product_id
HAVING COUNT(product_id) > 1



----
--Write a query that returns category ids with a maximum list price above 4000 or a minimum list price below 500.

SELECT category_id, list_price
FROM product.product
ORDER BY category_id, list_price

SELECT category_id, MAX(list_price) as max_price, MIN(list_price) as min_price
FROM product.product
GROUP BY category_id
HAVING MAX(list_price) > 4000 OR MIN(list_price) < 500


--Find the average product prices of the brands.
--As a result of the query, the average prices should be displayed in descending order.

--Markalara ait ortalama �r�n fiyatlar?n? bulunuz.
--ortalama fiyatlara g�re azalan s?rayla g�steriniz.

SELECT B.brand_name, B.brand_id, A.list_price
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
ORDER BY B.brand_name




SELECT B.brand_name,B.brand_id,AVG(list_price) avg_list_price
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
GROUP BY B.brand_name, B.brand_id
ORDER BY avg_list_price DESC




--Write a query that returns BRANDS with an average product price of more than 1000.


SELECT B.brand_name, B.brand_id, A.list_price
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
ORDER BY B.brand_name


SELECT B.brand_name,B.brand_id,AVG(list_price) avg_list_price
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
GROUP BY B.brand_name, B.brand_id
HAVING AVG(list_price) > 1000
ORDER BY avg_list_price ASC


----- HOMEWORK

----Write a query that returns the net price paid by the customer for each order. (Don't neglect discounts and quantities)

-- quantity * list_price * (1-discount)  ---NET PRICE





---- GROUPING SETS 

--- SUMMARY TABLE OLUSTURMA

SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year, 
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price
INTO	sale.sales_summary

FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year




--- GROUPING SETS

SELECT * 
FROM sale.sales_summary


-- 1. Calculate the total sales price.

SELECT SUM(total_sales_price)
FROM sale.sales_summary


--- 2. Calculate the total sales price of the brands

SELECT Brand, SUM(total_sales_price) total
FROM sale.sales_summary
GROUP BY Brand

--- 3. Calculate the total sales price of the categories

SELECT * 
FROM sale.sales_summary


SELECT Category, SUM(total_sales_price) total
FROM sale.sales_summary
GROUP BY Category



---4. Calculate the total sales price by brands and categories.


SELECT  Brand, Category ,SUM(total_sales_price)
FROM sale.sales_summary
GROUP BY Brand, Category


--- grouping set ile yukardaki 4 kodu birlestirme

SELECT Brand, Category, SUM(total_sales_price) TOTAL
FROM sale.sales_summary
GROUP BY 
	GROUPING SETS(
	
	(Brand),
	(Category),
	(Brand, Category),
	()
)
ORDER BY Brand, Category

SELECT *
FROM sale.sales_summary

---------- ROLLUP ---------

--Generate different grouping variations that can be produced with the brand and category columns using 'ROLLUP'.
-- Calculate sum total_sales_price


--brand, category, model_year s�tunlar? i�in Rollup kullanarak total sales hesaplamas? yap?n.
--3 sutun icin  4 farkl? gruplama varyasyonu �retiyor
SELECT Brand, Category,Model_Year, SUM(total_sales_price) TOTAL
FROM sale.sales_summary
GROUP BY 
	ROLLUP(		
		(Brand, Category, Model_Year)
)
ORDER BY Brand, Category, Model_Year

