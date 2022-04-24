


--List the products ordered the last 10 orders in Buffalo city.
-- Buffalo �ehrinde son 10 sipari�te sipari� verilen �r�nleri listeleyin.


SELECT	B.product_id, B.product_name, A.order_id
FROM	sale.order_item A, product.product B
WHERE	A.product_id = B.product_id
AND		A.order_id IN (
						SELECT	TOP 10 order_id
						FROM	sale.customer A, sale.orders B
						WHERE	A.customer_id = B.customer_id
						AND		A.city = 'Buffalo'
						ORDER BY order_id desc
						)
order by 3


--Report the number of customers' orders, the number of products they ordered, and the total net amount they paid for the products.
--M��terilerin sipari� say�lar�n�, sipari� ettikleri �r�n say�lar�n� ve �r�nlere �dedikleri toplam net miktar� raporlay�n�z.





SELECT	A.customer_id, A.first_name, A.last_name,
		COUNT (DISTINCT C.order_id) AS cnt_order,
		SUM(B.quantity) cnt_product,
		SUM(quantity*list_price*(1-discount)) net_amount
FROM	sale.customer A, sale.order_item B, sale.orders C
WHERE	A.customer_id = C.customer_id
AND		B.order_id = C.order_id
GROUP BY  A.customer_id, A.first_name, A.last_name



--Report the number of customers' orders, the number of products they ordered, and the total net amount they paid for the products.
--(Customers who have never placed an order should also be included in the report.)
--Hi� sipari� vermemi� m��teriler de rapora dahil olsun.



SELECT	A.customer_id, A.first_name, A.last_name,
		COUNT (DISTINCT C.order_id) AS cnt_order,
		SUM(C.quantity) cnt_product,
		SUM(quantity*list_price*(1-discount)) net_amount
FROM	sale.customer A
		LEFT JOIN sale.orders B ON A.customer_id = B.customer_id
		LEFT JOIN sale.order_item C ON B.order_id = C.order_id
GROUP BY  A.customer_id, A.first_name, A.last_name
ORDER BY 1 DESC

--Report the number of orders placed in the cities, the number of products ordered and the total net amount paid to the products.
--�ehirlerde verilen sipari� say�lar�n�, sipari� edilen �r�n say�lar�n� ve �r�nlere �denen toplam net miktarlar� raporlay�n�z.



SELECT	a.state, A.city,
		COUNT (DISTINCT C.order_id) AS cnt_order,
		SUM(B.quantity) cnt_product,
		SUM(quantity*list_price*(1-discount)) net_amount
FROM	sale.customer A, sale.order_item B, sale.orders C
WHERE	A.customer_id = C.customer_id
AND		B.order_id = C.order_id
GROUP BY  a.state, A.city
order by 2


--Eyaletlerde verilen sipari� say�lar�n�, sipari� edilen �r�n say�lar�n� ve �r�nlere �denen toplam net miktarlar� raporlay�n�z.



SELECT	a.state,
		COUNT (DISTINCT C.order_id) AS cnt_order,
		SUM(B.quantity) cnt_product,
		SUM(quantity*list_price*(1-discount)) net_amount
FROM	sale.customer A, sale.order_item B, sale.orders C
WHERE	A.customer_id = C.customer_id
AND		B.order_id = C.order_id
GROUP BY  a.state
order by 1




-------------


----State ortalamas�n�n alt�nda ortalama ciroya sahip �ehirleri listeleyin.

WITH T1 AS
(
SELECT	DISTINCT A.state, A.city, 
		AVG(quantity*list_price*(1-discount)) OVER (PARTITION BY A.state) avg_turnover_ofstate,
		AVG(quantity*list_price*(1-discount)) OVER (PARTITION BY A.state, A.city) avg_turnover_ofcity
FROM	sale.customer A, sale.orders B, sale.order_item C
WHERE	A.customer_id = B.customer_id 
AND		B.order_id = C.order_id
)
SELECT *
FROM T1
WHERE	avg_turnover_ofcity < avg_turnover_ofstate




------


--Create a report shows daywise turnovers of the BFLO Store.
--BFLO Store Ma�azas�n�n haftan�n g�nlerine g�re elde etti�i ciro miktar�n� g�steren bir rapor haz�rlay�n�z.




SELECT	DATENAME(WEEKDAY, order_date) dayofweek_, SUM (quantity*list_price*(1-discount)) daywise_turnover
FROM	sale.store A, sale.orders B, sale.order_item C
WHERE	A.store_name = 'The BFLO Store'
AND		A.store_id = B.store_id
AND		B.order_id = C.order_id
GROUP BY DATENAME(WEEKDAY, order_date)





SELECT *
FROM
(
SELECT	DATENAME(WEEKDAY, order_date) dayofweek_, quantity*list_price*(1-discount) net_amount, datepart(ISOWW, order_date) WEEKOFYEAR
FROM	sale.store A, sale.orders B, sale.order_item C
WHERE	A.store_name = 'The BFLO Store'
AND		A.store_id = B.store_id
AND		B.order_id = C.order_id
AND		YEAR(B.order_date) = 2018
) A
PIVOT
(
SUM (net_amount)
FOR dayofweek_
IN ([Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday],[Sunday] )
) AS PIVOT_TABLE




---------------



--Write a query that returns how many days are between the third and fourth order dates of each staff.
--Her bir personelin ���nc� ve d�rd�nc� sipari�leri aras�ndaki g�n fark�n� bulunuz.


WITH T1 AS 
(
SELECT staff_id, order_date, order_id, 
		LEAD(order_date) OVER (PARTITION BY staff_id ORDER BY order_id) next_ord_date,
		ROW_NUMBER () OVER (PARTITION BY staff_id ORDER BY order_id) row_num
FROM sale.orders
)
SELECT *, DATEDIFF(DAY, order_date, next_ord_date) DIFF_OFDATE
FROM T1
WHERE row_num = 3


















