

-------------------------------------
-- DS 10/22 EU -- RDB & SQL Session 2 --
----------- 02.03.2022 --------------
-------------------------------------


CREATE DATABASE LibDatabase;

Use LibDatabase;


--Create Two Schemas
CREATE SCHEMA Book;
---
CREATE SCHEMA Person;



--create Book.Book table
CREATE TABLE [Book].[Book](
	[Book_ID] [int] PRIMARY KEY NOT NULL,
	[Book_Name] [nvarchar](50) NOT NULL,
	Author_ID INT NOT NULL,
	Publisher_ID INT NOT NULL
);


--create Book.Author table

CREATE TABLE [Book].[Author](
	[Author_ID] [int],
	[Author_FirstName] [nvarchar](50) Not NULL,
	[Author_LastName] [nvarchar](50) Not NULL
);



--create Publisher Table

CREATE TABLE [Book].[Publisher](
	[Publisher_ID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Publisher_Name] [nvarchar](100) NULL
);




--create Person.Person table

CREATE TABLE [Person].[Person](
	[SSN] [bigint] PRIMARY KEY NOT NULL,
	[Person_FirstName] [nvarchar](50) NULL,
	[Person_LastName] [nvarchar](50) NULL
);


--create Person.Loan table

CREATE TABLE [Person].[Loan](
	[SSN] BIGINT NOT NULL,
	[Book_ID] INT NOT NULL,
	PRIMARY KEY ([SSN], [Book_ID])
);




--cretae Person.Person_Phone table

CREATE TABLE [Person].[Person_Phone](
	[Phone_Number] [bigint] PRIMARY KEY NOT NULL,
	[SSN] [bigint] NOT NULL	
);


--cretae Person.Person_Mail table

CREATE TABLE [Person].[Person_Mail](
	[Mail_ID] INT PRIMARY KEY IDENTITY (1,1),
	[Mail] NVARCHAR(MAX) NOT NULL,
	[SSN] BIGINT UNIQUE NOT NULL	
);



----------INSERT

----!!! ilgili kolonun özelliklerine ve kısıtlarına uygun veri girilmeli !!!


-- Insert işlemi yapacağınız tablo sütunlarını aşağıdaki gibi parantez içinde belirtebilirsiniz.
-- Bu kullanımda sadece belirttiğiniz sütunlara değer girmek zorundasınız. Sütun sırası önem arz etmektedir.

INSERT INTO Person.Person (SSN, Person_FirstName, Person_LastName) VALUES (75056659595,'Zehra', 'Tekin')

INSERT INTO Person.Person (SSN, Person_FirstName) VALUES (889623212466,'Kerem')


--Aşağıda Person_LastName sütununa değer girilmemiştir. 
--Person_LastName sütunu Nullable olduğu için Person_LastName yerine Null değer atayarak işlemi tamamlar.

INSERT INTO Person.Person (SSN, Person_FirstName) VALUES (78962212466,'Kerem')

--Insert edeceğim değerler tablo kısıtlarına ve sütun veri tiplerine uygun olmazsa aşağıdaki gibi işlemi gerçekleştirmez.


--Insert keywordunden sonra Into kullanmanıza gerek yoktur.
--Ayrıca Aşağıda olduğu gibi insert etmek istediğiniz sütunları belirtmeyebilirsiniz. 
--Buna rağmen sütun sırasına ve yukarıdaki kurallara dikkat etmelisiniz.
--Bu kullanımda tablonun tüm sütunlarına insert edileceği farz edilir ve sizden tüm sütunlar için değer ister.

INSERT Person.Person VALUES (15078893526,'Mert','Yetiş')

--Eğer değeri bilinmeyen sütunlar varsa bunlar yerine Null yazabilirsiniz. 
--Tabiki Null yazmak istediğiniz bu sütunlar Nullable olmalıdır.

INSERT Person.Person VALUES (55556698752, 'Esra', Null)



--Aynı anda birden fazla kayıt insert etmek isterseniz;

INSERT Person.Person VALUES (35532888963,'Ali','Tekin');
INSERT Person.Person VALUES (88232556264,'Metin','Sakin')


--Aynı tablonun aynı sütunlarına birçok kayıt insert etmek isterseniz aşağıdaki syntaxı kullanabilirsiniz.
--Burada dikkat edeceğiniz diğer bir konu Mail_ID sütununa değer atanmadığıdır.
--Mail_ID sütunu tablo oluşturulurken identity olarak tanımlandığı için otomatik artan değerler içerir.
--Otomatik artan bir sütuna değer insert edilmesine izin verilmez.

INSERT INTO Person.Person_Mail (Mail, SSN) 
VALUES ('zehtek@gmail.com', 75056659595),
	   ('meyet@gmail.com', 15078893526),
	   ('metsak@gmail.com', 35532558963)

--Yukarıdaki syntax ile aşağıdaki fonksiyonları çalıştırdığınızda,
--Yaptığınız son insert işleminde tabloya eklenen son kaydın identity' sini ve tabloda etkilenen kayıt sayısını getirirler.
--Not: fonksiyonları teker teker çalıştırın.

SELECT @@IDENTITY--last process last identity number
SELECT @@ROWCOUNT--last process row count



--Aşağıdaki syntax ile farklı bir tablodaki değerleri daha önceden oluşturmuş olduğunuz farklı bir tabloya insert edebilirsiniz.
--Sütun sırası, tipi, constraintler ve diğer kurallar yine önemli.

select * into Person.Person_2 from Person.Person-- Person_2 şeklinde yedek bir tablo oluşturuyouruz burada


INSERT Person.Person_2 (SSN, Person_FirstName, Person_LastName)
SELECT * FROM Person.Person where Person_FirstName like 'M%'


--Aşağıdaki syntaxda göreceğiniz üzere hiçbir değer belirtilmemiş. 
--Bu şekilde tabloya tablonun default değerleriyle insert işlemi yapılacaktır.
--Tabiki sütun constraintleri buna elverişli olmalı. 

INSERT Book.Publisher
DEFAULT VALUES


--Update


--Update işleminde koşul tanımlamaya dikkat ediniz. Eğer herhangi bir koşul tanımlamazsanız 
--Sütundaki tüm değerlere değişiklik uygulanacaktır.


UPDATE Person.Person_2 SET Person_FirstName = 'Default_Name'--burayı çalıştırmadan önce yukarıdaki scripti çalıştırın

--Where ile koşul vererek 88963212466 SSN ' ye sahip kişinin adını Can şeklinde güncelliyoruz.
--Kişinin önceki Adı Kerem' di.

UPDATE Person.Person_2 SET Person_FirstName = 'Can' WHERE SSN = 78962212466


select * from Person.Person_2




--Join ile update

----Aşağıda Person_2 tablosunda person id' si 78962212466 olan şahsın (yukarıdaki şahıs) adını,
----Asıl tablomuz olan Person tablosundaki haliyle değiştiriyoruz.
----Bu işlemi yaparken iki tabloyu SSN üzerinden Join ile birleştiriyoruz
----Ve kaynak tablodaki SSN' ye istediğimiz şartı veriyoruz.

UPDATE Person.Person_2 SET Person_FirstName = B.Person_FirstName 
FROM Person.Person_2 A Inner Join Person.Person B ON A.SSN=B.SSN
WHERE B.SSN = 78962212466




---
----delete
--Delete kullanımında, Delete ile tüm verilerini sildiğiniz bir tabloya yeni bir kayıt eklediğinizde,
--Eğer tablonuzda otomatik artan bir identity sütunu var ise eklenen yeni kaydın identity'si, 
--silinen son kaydın identity'sinden sonra devam edecektir.


--örneğin aşağıda otomatik artan bir identity primary keye sahip Book.Publisher tablosuna örnek olarak veri ekleniyor.

insert Book.Publisher values ('İş Bankası Kültür Yayıncılık'), ('Can Yayıncılık'), ('İletişim Yayıncılık')


--Delete ile Book.Publisher tablosunun içi tekrar boşaltılıyor.

Delete from Book.Publisher 

--kontrol
select * from Book.Publisher 

--Book.Publisher tablosuna yeni bir veri insert ediliyor
insert Book.Publisher values ('İLETİŞİM')

--Tekrar kontrol ettiğimizde yeni insert edilen kaydın identity'sinin eski tablodaki sıradan devam ettiği görülecektir.
select * from Book.Publisher



---/////////////////////////////

--//////////////////////////////


--Buradan sonraki kısımda Constraint ve Alter Table örnekleri yapılacaktır.
--Yapacağımız işlemlerin tutarlı olması için öncelikle yukarıda örnek olarak veri insert ettiğimiz tablolarımızı boşaltalım.


DROP TABLE Person.Person_2;--Artık ihtiyacımız yok.

TRUNCATE TABLE Person.Person_Mail;
TRUNCATE TABLE Person.Person;
TRUNCATE TABLE Book.Publisher;





---------Book tablomuz bir primary key' e sahip

-- Foreign key konstraint' leri belirlememiz gerekiyor

ALTER TABLE Book.Book ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Book.Author (Author_ID)

ALTER TABLE Person.Book ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Book.Publisher (Publisher_ID)

---------Author

--Author tablomuza primary key atamamız gerekli, çünkü oluştururken atanmamış
--Burada bir hata alacaksınız ve tabloda bir düzenleme yapmanız gerekecek, 
--Aksi taktirde bir sonraki tabloda da hata alırsınız. :)

ALTER TABLE Book.Author ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)

ALTER TABLE Book.Author ALTER COLUMN Author_ID INT NOT NULL

--publisher ve person tabloları da primary key' e sahip.

--Person.Loan tablosuna Constraint eklemeliyiz.

---------Person.Loan tablosuna foreign key constraint eklemeliyiz

ALTER TABLE Person.Loan ADD CONSTRAINT FK_PERSON FOREIGN KEY (SSN) REFERENCES Person.Person (SSN)

ALTER TABLE Person.Loan ADD CONSTRAINT FK_book FOREIGN KEY (Book_ID) REFERENCES Book.Book (Book_ID)

--Publisher tablosu normal.

---------Person.Person tablosundaki SSN sütununa 11 haneli olması gerektiği için check constraint ekleyelim.

Alter table Person.Person add constraint FK_PersonID_check Check (SSN between 9999999999 and 99999999999)


---------Person.Person_Phone

--Person_Phone tablosuna SSN için foreign key constraint oluşturmamız gerekli.

Alter table Person.Person_Phone add constraint FK_Person2 Foreign key (SSN) References Person.Person(SSN)

--Phone_Number için check...

Alter table Person.Person_Phone add constraint FK_Phone_check Check (Phone_Number between 999999999 and 9999999999)

--

-------------Person.Person_Mail için Foreign key tanımlamamız gerekli

Alter table Person.Person_Mail add constraint FK_Person4 Foreign key (SSN) References Person.Person(SSN)


---Bu aşamada Database diagramınızı çizip tüm tablolar arasındaki bağlantıların oluştuğundan emin olabilirsiniz.
--Herhangi bir probleminizde daima slackten ulaşabilirsiniz. 
--Sağlıcakla, iyi çalışmalar.