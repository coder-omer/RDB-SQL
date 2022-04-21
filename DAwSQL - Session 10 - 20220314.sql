

--------------------------------------
-- DS 10/22 EU -- DAwSQL Session 10 --
----------- 14.03.2022 ---------------
--------------------------------------



-- Herbir kategori içinde ürünlerin fiyat sıralamasını yapınız (artan fiyata göre 1'den başlayıp birer birer artacak)
select	category_id, list_price,
		ROW_NUMBER() OVER(partition by category_id order by list_price ASC) Row_num
from	product.product
order by category_id, list_price
;

-- Aynı soruyu aynı fiyatlı ürünler aynı sıra numarasını alacak şekilde yapınız (RANK fonksiyonunu kullanınız)
select	category_id, list_price,
		ROW_NUMBER() OVER(partition by category_id order by list_price ASC) Row_num,
		RANK() OVER(partition by category_id order by list_price ASC) Rank_num
from	product.product
order by category_id, list_price
;

-- Aynı soruyu aynı fiyatlı ürünler aynı sıra numarasını alacak şekilde yapınız (DENSE_RANK fonksiyonunu kullanınız)
select	category_id, list_price,
		ROW_NUMBER() OVER(partition by category_id order by list_price ASC) Row_num,
		RANK() OVER(partition by category_id order by list_price ASC) Rank_num,
		DENSE_RANK() OVER(partition by category_id order by list_price ASC) Dense_Rank_num
from	product.product
order by category_id, list_price
;



-- Herbir marka içinde ürünlerin kümülatif yüzdesini hesaplayınız. (Artan fiyata göre hesaplayınız)
SELECT	brand_id, list_price, 
		ROUND (CUME_DIST() OVER (PARTITION BY brand_id ORDER BY list_price) , 3) AS CUM_DIST
FROM	product.product
;


-- Aynı soruyu PERCENT_RANK ile yapınız.
SELECT	brand_id, list_price, 
		ROUND (CUME_DIST() OVER (PARTITION BY brand_id ORDER BY list_price) , 3) AS CUM_DIST, 
		ROUND (PERCENT_RANK() OVER (PARTITION BY brand_id ORDER BY list_price) , 3) AS PERCENT_RANK
FROM	product.product
;


-- Herbir marka içinde ürünleri 4 kümede sınıflandırın. (Artan fiyata göre hesaplayınız)
SELECT	brand_id, list_price, 
		ROUND (CUME_DIST() OVER (PARTITION BY brand_id ORDER BY list_price) , 3) AS CUM_DIST, 
		ROUND (PERCENT_RANK() OVER (PARTITION BY brand_id ORDER BY list_price) , 3) AS PERCENT_RANK, 
		NTILE(4) OVER (PARTITION BY brand_id ORDER BY list_price) AS NTILE_NUM,
		COUNT(*) OVER(PARTITION BY brand_id) AS UrunSayisi
FROM	product.product
;



-- Sipariş bazında indirim oranlarını hesaplayınız.
/*
Veritabanındaki veriler incelendiğinde indirim oranlarının ürün bazında yapıldığı, sipariş bazında indirim oranı olmadığını görebilirsiniz.
Sipariş bazında indirim oranını hesaplamak için toplam sipariş tutarı ve liste fiyatı bazında toplam sipariş tutarlarını bilmemiz gerekir.
Daha sonra sipariş bazındaki indirim oranını bulabilirsiniz.
*/
with tbl as (
	select	a.order_id, b.item_id, b.product_id, b.quantity, b.list_price, b.discount,
			(b.list_price * (1 - b.discount)) * b.quantity ara_toplam,
			sum((b.list_price * (1 - b.discount)) * b.quantity) over(partition by a.order_id) siparis_toplami,
			sum(b.list_price * b.quantity) over(partition by a.order_id) siparis_toplami_liste_fiyati,
			sum(quantity) over(partition by a.order_id) urun_adedi
	from	sale.orders a, sale.order_item b
	where	a.order_id = b.order_id
)

select	distinct order_id, siparis_toplami, siparis_toplami_liste_fiyati, urun_adedi,
		1 - (siparis_toplami / siparis_toplami_liste_fiyati) discount_ratio_order,
		cast( 100 * (1 - (siparis_toplami / siparis_toplami_liste_fiyati))
			as INT)
		discount_ratio_order_INT
from	tbl
order by 1 - (siparis_toplami / siparis_toplami_liste_fiyati) desc
;



-- SORU:
-- Herbir ay için şu alanları hesaplayınız:
--  O aydaki toplam sipariş sayısı
--  Bir önceki aydaki toplam sipariş sayısı
--  Bir sonraki aydaki toplam sipariş sayısı
--  Aylara göre yıl içindeki kümülatif sipariş yüzdesi

/*
Burada yer alan 4 soruyu hesaplamak için ilk olarak tarih verisinden herbir ay için unique bir id oluşturmalıyız.
Format olarak 'YYYYMM' kullanalım.
Bu formatı elde etmek için SQL Server de tanımlı olan stilleri kullanabiliriz.
Bu stiller CONVERT fonksiyonu ile çalışmaktadır.
Detaylı bilgi için: https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-ver15

İlk 3 sorunun cevabı aşağıdaki SQL scriptinde yer almaktadır.
Aşağıda yer alan 4. sorunun cevabı ise doğru değildir.
Çünkü CUM_DIST() fonksiyonu satır sayısını esas alıp kümülatif yüzdeyi hesaplamaktadır.
Yani ocak ayına ait 1 satır var ve içinde bulunduğu yılda 12 ay var ve bu ay için CUM_DIST() fonksiyonu 1/12 değerini döndürecektir.
Aynı şekilde şubat ayı için 2/12 değerini döndürecektir. Yılları birbiriyle karşılaştırdığınızda bu durumu rahat görebilirsiniz.
Peki 4. soruda istenen değerleri nasıl hesaplayabiliriz?
Bunun için aşağıdaki ikinci SQL sorgusuna bakabilirsiniz :)
*/

-- 1. Çözüm
with tbl as (
		select	distinct
				year(order_date) yil,
				convert(nvarchar(6), order_date, 112) ay,
				count(*) over(partition by convert(nvarchar(6), order_date, 112)) toplam_siparis
		from	sale.orders
)

select	*,
		lag(toplam_siparis) over(order by ay) onceki_toplam_siparis,
		lead(toplam_siparis) over(order by ay) sonraki_toplam_siparis,
		CUME_DIST() over(partition by yil order by ay) kumulatif_yuzde
from	tbl
;



-- 2. Çözüm
with tbl as (
		select	year(order_date) yil,
				convert(nvarchar(6), order_date, 112) ay,
				count(*) toplam_siparis
		from	sale.orders
		group by year(order_date),
				convert(nvarchar(6), order_date, 112)
)

select	yil, ay, toplam_siparis,
		lag(toplam_siparis) over(order by ay) onceki_ay_toplam_siparis,
		lead(toplam_siparis) over(order by ay) sonraki_ay_toplam_siparis,
		sum(toplam_siparis) over(partition by yil order by ay rows between unbounded preceding and current row) kumulatif_toplam_siparis,
		sum(toplam_siparis + 0.0) over(partition by yil order by ay rows between unbounded preceding and current row)
			/ sum(toplam_siparis) over(partition by yil) kumulatif_siparis_yuzdesi
from	tbl

/*
Bu sorguda kümülatif sipariş yüzdesini CUM_DIST fonksiyonu ile değil de manuel olarak hesaplamış olduk.
Çünkü CUM_DIST fonksiyonu satır sayısına göre bir hesaplama yapıyor. Fakat biz zaten with clause içinde hesapladığımız aylık sipariş sayısı üzerinden hesaplama yapmak istiyoruz.
Dolayısıyla ilk olarak mevcut aya kadar toplam sipariş sayısını hesapladık (rows between kuralına dikkat edin, bir yıl içinde söz konusu aya gelene kadar tüm ayların toplamı)
Daha sonra bu değeri o yıldaki toplam sipariş sayısına oranladık.
Son kod içinde toplam_siparis değerini 0.0 ile topladık. Bunun sebebini Sizlere bırakıyorum :)
*/