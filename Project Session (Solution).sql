





---E-Commerce Data Analysis Project 


--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)



SELECT 
cd.Cust_id, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment, 
mf.Ord_id, mf.Prod_id, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Product_Base_Margin,
od.Order_Date, od.Order_Priority,
pd.Product_Category, pd.Product_Sub_Category,
sd.Ship_id, sd.Ship_Mode, sd.Ship_Date
FROM market_fact mf
INNER JOIN cust_dimen cd ON mf.Cust_id = cd.Cust_id
INNER JOIN orders_dimen od ON od.Ord_id = mf.Ord_id
INNER JOIN prod_dimen pd ON pd.Prod_id = mf.Prod_id
INNER JOIN shipping_dimen sd ON sd.Ship_id = mf.Ship_id



select * into #sample_table from orders_dimen where year (Order_Date) > 2009

select * from #sample_table




SELECT *
INTO
combined_table
FROM
(
SELECT 
cd.Cust_id, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment, 
mf.Ord_id, mf.Prod_id, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Product_Base_Margin,
od.Order_Date, od.Order_Priority,
pd.Product_Category, pd.Product_Sub_Category,
sd.Ship_id, sd.Ship_Mode, sd.Ship_Date
FROM market_fact mf
INNER JOIN cust_dimen cd ON mf.Cust_id = cd.Cust_id
INNER JOIN orders_dimen od ON od.Ord_id = mf.Ord_id
INNER JOIN prod_dimen pd ON pd.Prod_id = mf.Prod_id
INNER JOIN shipping_dimen sd ON sd.Ship_id = mf.Ship_id
) A;



----

--2. Find the top 3 customers who have the maximum count of orders.

select Cust_id, Customer_Name, count (Ord_id) as cnt_orders
from combined_table
group by Cust_id, Customer_Name
ORDER BY cnt_orders DESC


select TOP 3 Cust_id, Customer_Name, count (Ord_id) as cnt_orders
from combined_table
group by Cust_id, Customer_Name
ORDER BY cnt_orders DESC



select Cust_id, Customer_Name, count (DISTINCT Ord_id) as cnt_orders
from combined_table
group by Cust_id, Customer_Name
ORDER BY cnt_orders DESC


----


--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.


SELECT ord_id, Order_Date, Ship_Date, DaysTakenForDelivery
FROM combined_table


ALTER TABLE combined_table ADD DaysTakenForDelivery smallint

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(day, Order_Date, Ship_Date)



-----------


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

SELECT Cust_id, Customer_Name, Ord_id, DaysTakenForDelivery
FROM combined_table
ORDER BY 1,3


SELECT top 1 Cust_id, Customer_Name, MAX(DaysTakenForDelivery) MAX_DAY
FROM combined_table
GROUP BY Cust_id, Customer_Name
ORDER BY 3 desc



---

SELECT top 1 Cust_id, Customer_Name, Ord_id, DaysTakenForDelivery
FROM combined_table
ORDER BY 4 desc



-------------


--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries


SELECT COUNT (DISTINCT Cust_id)
FROM combined_table
WHERE YEAR(Order_Date) = 2011
AND MONTH(Order_Date ) = 1




WITH T1 AS (
SELECT Cust_id
FROM combined_table
WHERE YEAR(Order_Date) = 2011
AND MONTH(Order_Date ) = 1
) 
SELECT MONTH(Order_Date) ORD_MONTH, COUNT(DISTINCT A.Cust_id) CNT_CUST
FROM  combined_table A, T1 
WHERE	A.Cust_id = T1.Cust_id
AND		YEAR(Order_Date) = 2011
GROUP BY MONTH(Order_Date)



--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions


--Her müþterinin ilk sipariþi ile 3. sipariþi arasýndaki gün farkýný döndürün.


SELECT cust_id, MIN(Order_Date) OVER(PARTITION BY Cust_id) first_pur_date
FROM combined_table




select DISTINCT *, DATEDIFF (day, first_pur_date, Order_Date)  day_diff
from
(
		SELECT cust_id, ord_id, Order_Date, 
		dense_rank() OVER (PARTITION BY Cust_id ORDER BY Order_Date, Ord_id) ord_number
		FROM combined_table
) a ,
(
		SELECT cust_id, MIN(Order_Date) OVER(PARTITION BY Cust_id) first_pur_date
		FROM combined_table
)b
WHERE A.cust_id = B.cust_id
AND   ord_number = 3



-----------

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions


--Her bir müþterinin aldýðý ürünler içerisinden product 11 ve product 14' ü satýn alma oranýnýný hesaplayýn

WITH T1 AS 
(
SELECT Cust_id , 
		SUM (CASE WHEN Prod_id = 'Prod_11' Then Order_Quantity else 0 end) CNT_P11,
		SUM(CASE WHEN Prod_id = 'Prod_14' Then Order_Quantity else 0 end) CNT_P14
FROM combined_table
GROUP BY Cust_id
HAVING
		SUM (CASE WHEN Prod_id = 'Prod_11' Then Order_Quantity else 0 end) > 0
		AND
		SUM(CASE WHEN Prod_id = 'Prod_14' Then Order_Quantity else 0 end) > 0
)
SELECT DISTINCT A.Cust_id, T1.*, SUM (Order_Quantity) OVER (PARTITION BY A.Cust_id) TOTAL_PROD
FROM combined_table A, T1 
WHERE A.Cust_id = T1.Cust_id
ORDER BY 1




WITH T1 AS 
(
SELECT Cust_id , 
		SUM (CASE WHEN Prod_id = 'Prod_11' Then Order_Quantity else 0 end) CNT_P11,
		SUM(CASE WHEN Prod_id = 'Prod_14' Then Order_Quantity else 0 end) CNT_P14
FROM combined_table
GROUP BY Cust_id
HAVING
		SUM (CASE WHEN Prod_id = 'Prod_11' Then Order_Quantity else 0 end) > 0
		AND
		SUM(CASE WHEN Prod_id = 'Prod_14' Then Order_Quantity else 0 end) > 0
), T2 AS
(
SELECT A.Cust_id, SUM (Order_Quantity) TOTAL_PROD
FROM combined_table A, T1 
WHERE A.Cust_id = T1.Cust_id
GROUP BY A.Cust_id
)
SELECT DISTINCT A.Cust_id, CAST ((1.0*CNT_P11 / TOTAL_PROD) AS NUMERIC(3,2)) P11_RATIO, 
CAST((1.0*CNT_P14 / TOTAL_PROD) AS NUMERIC (3,2)) P14_RATIO
FROM combined_table A, T2 , T1 
WHERE A.Cust_id = T2.Cust_id
AND T1.Cust_id = T2.Cust_id



--------------------



--CUSTOMER SEGMENTATION


--Müþterileri sýnýflandýracaðýz
--Sipariþ sýklýðýna göre
--Kaç ay arayla alýþveriþ yapýldýðýna göre
--Müþterilerin sipariþleri arasýndaki ay farkýna göre / time_gap


CREATE VIEW CUST_MONTH AS

WITH T1 AS 
(
SELECT DISTINCT Cust_id, year (order_date) ord_year, month(Order_Date) ord_month,
				dense_rank () OVER (ORDER BY year (order_date) , month(Order_Date)) data_month
FROM combined_table
)
SELECT DISTINCT cust_id, data_month, LAG(data_month) OVER (PARTITION BY cust_id ORDER BY data_month) prev_data_month
FROM t1




SELECT *,  data_month-prev_data_month DIFF_MONTH
FROM CUST_MONTH


--------Aylara rakam atarken sadece alýþveriþ yapýlmýþ olan aylarý hesaba kattýðýmýz için
-------alýþveriþ yapýlmamýþ olan aylar arasýndaki zaman farkýný atlamýþ oluyoruz. Bunu kontrol etmeliyiz.


SELECT DATEDIFF(MONTH, '2009-01-01', '2012-12-12')


----

SELECT year (order_date) ord_year, month(Order_Date) ord_month,
				dense_rank () OVER (ORDER BY year (order_date) , month(Order_Date)) data_month
FROM combined_table



----Müþterilerin ortalama aylýk Time_gap' leri

CREATE VIEW TIME_GAP AS
SELECT *,  data_month-prev_data_month time_gaps
FROM CUST_MONTH



SELECT Cust_id , CASE WHEN AVG(time_gaps) > 2 THEN 'irregular'
						WHEN AVG(time_gaps) BETWEEN 1 AND 2 THEN 'Retained'
							WHEN AVG(time_gaps) IS NULL THEN 'churn'
							ELSE 'UNKNOWN'
				END cust_segment
FROM TIME_GAP
GROUP BY Cust_id



--------------------



--MONTH-WISE RETENTION RATE


--her ay için kendisinden bir önceki aydan kazandýðý müþteri oranýný hesaplayýnýz.
--Örn. 2009 Þubat ayýnda toplam 100 müþterimiz var. Bunlardan 10 tanesi 2009 Ocak ayýndan kazandýðým müþteriler
--Dolayýsýyla 2009 Þubat ayý için month wise retention rate 10/100 %10 = 0.1

--1. Her ay için önceki aydan kazanýlan müþteri sayýsý
--2. Her ayýn toplam müþteri sayýsý


WITH T1 AS 
(
SELECT data_month, count (DISTINCT cust_id) total_cust
FROM TIME_GAP
GROUP BY data_month
), T2 AS
(
SELECT data_month, count (DISTINCT cust_id) retained_cust
FROM TIME_GAP
WHERE time_gaps = 1
GROUP BY data_month
) 
SELECT t1.data_month, CAST(1.0*retained_cust/total_cust AS NUMERIC(3,2)) Retention_Rate, FORMAT(((1.0*retained_cust)/total_cust), 'P', 'en-us')
FROM T1, T2
WHERE T1.data_month = T2.data_month















