



---Assignment-2 Solution

SELECT E.customer_id, E.first_name, E.last_name
		, ISNULL(NULLIF (ISNULL(STR(F.customer_id), 'No'), STR(F.customer_id)), 'Yes') First_product
		, ISNULL(NULLIF (ISNULL(STR(G.customer_id), 'No'), STR(G.customer_id)), 'Yes') Second_product
		, ISNULL(NULLIF (ISNULL(STR(H.customer_id), 'No'), STR(H.customer_id)), 'Yes') Third_product

FROM
	(
	SELECT	distinct D.customer_id, D.first_name, D.last_name
	FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
	WHERE	A.product_id=B.product_id
	AND		B.order_id = C.order_id
	AND		C.customer_id = D.customer_id
	AND		A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
	) E
	LEFT JOIN
	(
	SELECT	distinct D.customer_id, D.first_name, D.last_name
	FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
	WHERE	A.product_id=B.product_id
	AND		B.order_id = C.order_id
	AND		C.customer_id = D.customer_id
	AND		A.product_name = 'Polk Audio - 50 W Woofer - Black'
	) F
	ON E.customer_id = F.customer_id
	LEFT JOIN
	(
	SELECT	distinct D.customer_id, D.first_name, D.last_name
	FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
	WHERE	A.product_id=B.product_id
	AND		B.order_id = C.order_id
	AND		C.customer_id = D.customer_id
	AND		A.product_name = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)'
	) G
	ON E.customer_id = G.customer_id
		LEFT JOIN
	(
	SELECT	distinct D.customer_id, D.first_name, D.last_name
	FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
	WHERE	A.product_id=B.product_id
	AND		B.order_id = C.order_id
	AND		C.customer_id = D.customer_id
	AND		A.product_name = 'Virtually Invisible 891 In-Wall Speakers (Pair)'
	) H
	ON E.customer_id = H.customer_id






