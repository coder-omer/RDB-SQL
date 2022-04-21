

-------------------------------------
-- DS 10/22 EU -- DAwSQL Session 8 --
----------- 10.03.2022 --------------
-------------------------------------

-- Davis Thomas'nın çalıştığı mağazadaki tüm personelleri listeleyin.

select	*
from	sale.staff
where	store_id = (
			Select	store_id
			from	sale.staff
			where	first_name = 'Davis' and last_name = 'Thomas'
		)
;


-- Charles	Cussona 'ın yöneticisi olduğu personelleri listeleyin.

select	*
from	sale.staff
where	manager_id = (
			select	staff_id
			from	sale.staff
			where	first_name = 'Charles' and last_name = 'Cussona'
		)

-- 'The BFLO Store' isimli mağazanın bulunduğu şehirdeki müşterileri listeleyin.

select	*
from	sale.customer
where	city = (
			select	city
			from	sale.store
			where	store_name = 'The BFLO Store'
		)



-- 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)' isimli üründen pahalı olan Televizyonları listeleyin.

select	*
from	product.product
where	list_price > (
			select	list_price
			from	product.product
			where	product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'
		) and
		category_id = (
			select	category_id
			from	product.category
			where	category_name = 'Televisions & Accessories'
		)

-- Laurel Goldammer isimli müşterinin alışveriş yaptığı tarihte/tarihlerde alışveriş yapan tüm müşterileri listeleyin.

select	b.first_name, b.last_name, a.order_date
from	sale.orders a, sale.customer b
where	a.customer_id = b.customer_id and
		a.order_date IN (
			select	a.order_date
			from	sale.orders a, sale.customer b
			where	a.customer_id = b.customer_id and
					b.first_name = 'Laurel' and
					b.last_name = 'Goldammer'
		)
;



-- Game, gps veya Home Theater haricindeki kategorilere ait ürünleri listeleyin.
--	Sadece 2021 model yılına ait bisikletlerin adı ve fiyat bilgilerini listeleyin.

select	*
from	product.product
where	model_year = 2021 and
		category_id NOT IN (
			select	category_id
			from	product.category
			where	category_name in ('Game', 'gps', 'Home Theater')
		)
;

-- 2020 model olup Receivers Amplifiers kategorisindeki en pahalı üründen daha pahalı ürünleri listeleyin.
-- Ürün adı, model_yılı ve fiyat bilgilerini yüksek fiyattan düşük fiyata doğru sıralayınız.

select	product_name, model_year, list_price
from	product.product
where	model_year = 2020 and
		list_price >ALL (
			select	b.list_price
			from	product.category a, product.product b
			where	a.category_name = 'Receivers Amplifiers' and
					a.category_id = b.category_id
		)
order by list_price DESC


-- Receivers Amplifiers kategorisindeki ürünlerin herhangi birinden yüksek fiyatlı ürünleri listeleyin.
-- Ürün adı, model_yılı ve fiyat bilgilerini yüksek fiyattan düşük fiyata doğru sıralayınız.

select	product_name, model_year, list_price
from	product.product
where	model_year = 2020 and
		list_price >ANY (
			select	b.list_price
			from	product.category a, product.product b
			where	a.category_name = 'Receivers Amplifiers' and
					a.category_id = b.category_id
		)
order by list_price DESC


-- correleted sub queries
-- 'Apple - Pre-Owned iPad 3 - 32GB - White' isimli ürünün hiç sipariş edilmediği eyaletleri listeleyiniz.
-- Not: Eyalet olarak müşterinin adres bilgisini baz alınız.

select	distinct [state]
from	sale.customer d
where	not exists (
			select	*
			from	sale.orders a, sale.order_item b, product.product c, sale.customer e
			where	a.order_id = b.order_id and
					b.product_id = c.product_id and
					c.product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White' and
					a.customer_id = e.customer_id and
					d.state = e.state
		)
;

-- 2020-01-01 tarihinden önce sipariş vermeyen müşterileri döndüren bir sorgu yazın. 
-- Bu sorguda 2020-01-01 tarihinden önce sipariş vermiş bir müşteri varsa sorgu herhangi bir sonuç döndürmemelidir.

select	b.customer_id, b.first_name, b.last_name, a.order_date
from	sale.orders a, sale.customer b
where	a.customer_id = b.customer_id and
		NOT EXISTS (
			select	*
			from	sale.orders c
			where	c.order_date < '2020-01-01' and
					b.customer_id = c.customer_id
		)
;

-- Jerald Berray isimli müşterinin son siparişinden önce sipariş vermiş 
-- ve Austin şehrinde ikamet eden müşterileri listeleyin.
;
WITH table_name AS (
		SELECT	MAX(B.order_date) last_order_date
		FROM	sale.customer A, sale.orders B
		WHERE	A.first_name = 'Jerald' AND
					A.last_name = 'Berray' AND
					A.customer_id = B.customer_id
	)

SELECT	*
FROM	table_name
;



-- Recursive CTE
-- 1'den 10'a kadar herbir rakam bir satırda olacak şekide bir tablo oluşturun.
;
with tbl as (
		select	1 rakam
		
		union all

		select	rakam + 1
		from	tbl
		where	rakam < 10
)

select	*
from	tbl
;