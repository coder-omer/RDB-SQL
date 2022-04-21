----- Assignment 4 Solution


/*
Generate a report including product IDs and discount effects on whether 
the increase in the discount 
rate positively impacts the number of orders for the products.
*/


SELECT product_id, discount,
SUM (quantity) OVER(PARTITION BY product_id)
FROM sale.order_item


SELECT distinct product_id, discount,
SUM (quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
FROM sale.order_item
-----


WITH T1 AS(
SELECT distinct product_id, discount,
SUM (quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
FROM sale.order_item
), T2 AS(
SELECT product_id, discount, cnt_quantity,
LEAD(cnt_quantity, 1) OVER(PARTITION BY product_id ORDER BY discount) higher_discount_quantity,
LEAD(cnt_quantity, 1) OVER(PARTITION BY product_id ORDER BY discount) - cnt_quantity as diff
FROM T1
)
SELECT DISTINCT product_id, discount, cnt_quantity, higher_discount_quantity,  diff,
		CASE WHEN SUM(diff) OVER(PARTITION  BY product_id) > 0 THEN 'POSITIVE'
		     WHEN SUM(diff) OVER(PARTITION  BY product_id) < 0 THEN 'NEGATIVE'
			 ELSE 'NOTR' 
		END AS DISCOUNT_EFFECT
FROM T2
