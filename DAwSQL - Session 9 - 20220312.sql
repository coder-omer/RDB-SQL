


-------------------------------------
-- DS 10/22 EU -- DAwSQL Session 9 --
----------- 12.03.2022 --------------
-------------------------------------



-- Ürünlerin stock sayılarını bulunuz

select	product_id, sum(quantity) total_stock
from	product.stock
group by product_id
order by product_id
;

select	*, sum(quantity) over (partition by product_id) total_stock
from	product.stock
order by product_id
;

-- Markalara göre ortalama ürün fiyatlarını hem Group By hem de Window Functions ile hesaplayınız.

select	brand_id, avg(list_price) avg_price
from	product.product
group by brand_id
;

select	distinct brand_id, avg(list_price) over(partition by brand_id) avg_price
from	product.product
order by 2 desc
;



-- Windows frame i anlamak için birkaç örnek:
-- Herbir satırda işlem yapılacak olan frame in büyüklüğünü (satır sayısını) tespit edip window frame in nasıl oluştuğunu aşağıdaki sorgu sonucuna göre konuşalım.


SELECT	category_id, product_id,
		COUNT(*) OVER() NOTHING,
		COUNT(*) OVER(PARTITION BY category_id) countofprod_by_cat,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) whole_rows,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id) countofprod_by_cat_2,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) prev_with_current,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) current_with_following,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) specified_columns_1,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) specified_columns_2
FROM	product.product
ORDER BY category_id, product_id

;


-- en ucuz ürünün fiyatı

select	top 1 list_price
from	product.product
order by list_price
;

-- en ucuz ürünlerin isimlerini vi fiyatlarını getiriniz.
select	*
from	(
		select	product_name, list_price, min(list_price) over() cheapest
		from	product.product
		) A
where	A.list_price = A.cheapest
;


-- Herbir kategorideki en ucuz ürünün fiyatı

select	distinct category_id, min(list_price) over(partition by category_id) cheapest_by_cat
from	product.product
;


-- Product tablosunda toplam kaç faklı product bulunduğu

select	distinct count(*) over()
from	product.product
;

-- Order_item tablosunda kaç farklı ürün bulunmaktadır?

select	count(distinct product_id)
from	sale.order_item
;

-- Aynı sorguyu Window Functions ile yaptığınız hata alırsınız.
-- Çünkü windows functions içinde count(distinct ...) kullanamazsınız
select	count(distinct product_id) over ()
from	sale.order_item
;

-- Her siparişte kaç farklı ürün olduğunu döndüren bir sorgu yazın?
select	distinct order_id, count(item_id) over(partition by order_id) cnt_product
from	sale.order_item
;

-- Herbir kategorideki herbir markada kaç farklı ürünün bulunduğu
select	distinct category_id, brand_id, count(*) over(partition by brand_id, category_id) num_of_prod
from	product.product
order by brand_id, category_id
;


-- Müşterilerin sipariş tarihini ve ayrıca tüm siparişler içinde en eski sipariş tarihini getiriniz
select	a.customer_id, a.first_name, b.order_date,
		FIRST_VALUE(b.order_date) over(order by b.order_date, b.order_id) min_order_date
from	sale.customer a, sale.orders b
where	a.customer_id = b.customer_id
;


-- Müşterilerin sipariş tarihini ve ayrıca tüm siparişler içinde en yeni sipariş tarihini getiriniz
select	a.customer_id, a.first_name, b.order_date,
		FIRST_VALUE(b.order_date) over(order by b.order_date desc, b.order_id desc) store_id
from	sale.customer a, sale.orders b
where	a.customer_id = b.customer_id
;
-- Bu sorguyu LAST_VALUE ile yaptığımızda window frame i belirlememiz gerekiyor.
-- Aksi taktirde order by kullandığımızda default window frame UNBOUNDED PRECEDING AND CURRENT ROW oluyor.
select	a.customer_id, a.first_name, b.order_date,
		FIRST_VALUE(b.order_date) over(order by b.order_date desc, b.order_id desc ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) store_id
from	sale.customer a, sale.orders b
where	a.customer_id = b.customer_id
;



-- Liste fiyatı en düşük olan ürünün adını getiriniz.
select	distinct first_value(product_name) over (order by list_price, model_year DESC) cheapest_product
from	product.product
;

-- Liste fiyatı en düşük olan ürünün adını e fiyatını getiriniz.
select	distinct
		first_value(product_name) over (order by list_price, model_year DESC) cheapest_product_name,
		first_value(list_price) over (order by list_price, model_year DESC) cheapest_product_price
from	product.product
;

-- Çalışanların satış yaptıkları tarihleri listeleyin ve ayrıca bir önceki satış tarihlerini de yanına yazdırınız.
select	b.order_id, a.staff_id, a.first_name, a.last_name, b.order_date,
		lag(b.order_date) over(partition by a.staff_id order by b.order_id) previous_order_date
from	sale.staff a, sale.orders b
where	a.staff_id = b.staff_id
order by a.staff_id, b.order_date
;

-- Çalışanların satış yaptıkları tarihleri listeleyin ve ayrıca bir sonraki satış tarihlerini de yanına yazdırınız.
select	b.order_id, a.staff_id, a.first_name, a.last_name, b.order_date,
		lead(b.order_date) over(partition by a.staff_id order by b.order_id) previous_order_date
from	sale.staff a, sale.orders b
where	a.staff_id = b.staff_id
order by a.staff_id, b.order_date
;

-- Lead ve lag fonksiyonları ile yapabileceğiniz başka örnekler:
-- Çalışanların 2 önceki satış tarihi, bir önceki satış tarihi, bir sonraki satış tarihi ve 2 sonraki satış tarihi
select	b.order_id, a.staff_id, a.first_name, a.last_name, b.order_date,
		lag(b.order_date, 2) over(partition by a.staff_id order by b.order_date, b.order_id) lag2,
		lag(b.order_date, 1) over(partition by a.staff_id order by b.order_date, b.order_id) lag1,
		lead(b.order_date, 1) over(partition by a.staff_id order by b.order_date, b.order_id) lead1,
		lead(b.order_date, 2) over(partition by a.staff_id order by b.order_date, b.order_id) lead2
from	sale.staff a, sale.orders b
where	a.staff_id = b.staff_id
order by a.staff_id, b.order_date
;