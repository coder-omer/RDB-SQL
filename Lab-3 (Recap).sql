



---------------------RDB & SQL Lab-3 11.03.2022----------------------------


----New York State' inde sipariþ verilen product_id' leri getiriniz.




SELECT  C.product_id
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE [state] = 'NY'
AND	A.customer_id = B.customer_id
AND B.order_id = C.order_id
ORDER BY 1




SELECT count (DISTINCT C.product_id) cnt_diff_prod
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE [state] = 'NY'
AND	A.customer_id = B.customer_id
AND B.order_id = C.order_id
ORDER BY 1




SELECT count (C.product_id) cnt_prod
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE [state] = 'NY'
AND	A.customer_id = B.customer_id
AND B.order_id = C.order_id
ORDER BY 1




SELECT count (1) cnt_row
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE [state] = 'NY'
AND	A.customer_id = B.customer_id
AND B.order_id = C.order_id
ORDER BY 1


-----------

---New York eyaletinde bulunan þehirlerde verilen farklý ürün sayýsýný getiriniz.


select * from sale.customer




SELECT A.city, COUNT (DISTINCT C.product_id)
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE [state] = 'NY'
AND	A.customer_id = B.customer_id
AND B.order_id = C.order_id
GROUP BY A.city
ORDER BY 1


--------------------------------------------------


WITH T1 AS 
(
SELECT A.city, COUNT (DISTINCT C.product_id) AS cnt_dif_prod
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE A.customer_id = B.customer_id
AND B.order_id = C.order_id
GROUP BY A.city
)
SELECT SUM(cnt_dif_prod)
FROM	T1



select count (DISTINCT product_id)
from sale.order_item





-----




WITH T1 AS 
(
SELECT A.city, COUNT (DISTINCT C.product_id) AS cnt_dif_prod
FROM sale.customer A, SALE.orders B, sale.order_item C
WHERE A.customer_id = B.customer_id
AND B.order_id = C.order_id
GROUP BY A.city
), T2 AS
(
SELECT T1.*
FROM T1 , sale.customer A
WHERE T1.city= a.city
AND A.state = 'CO'
)
SELECT DISTINCT  *
FROM T2



