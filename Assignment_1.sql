


CREATE DATABASE CManufacturer;
USE CManufacturer


CREATE TABLE Product (
  ProductID int,
  ProductName varchar(50),
  Quantity int,
  PRIMARY KEY (ProductID)
);


--
-- Table structure for table 'Component'
--

CREATE TABLE Component (
  ComponentID int,
  ComponentName varchar(50),
  Description nvarchar(50),
  Quantity_comp int,
  PRIMARY KEY (ComponentID)
);


--
-- Table structure for table 'Supplier'
--

CREATE TABLE Supplier (
  SupplierID int,
  SupplierName varchar(50),
  IsActive bit,
  PRIMARY KEY (SupplierID)
);


--
-- Table structure for table 'ProdComp'
--

CREATE TABLE ProdComp (
  ProductID int,
  ComponentID int,
  FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
  FOREIGN KEY (ComponentID) REFERENCES Component (ComponentID),
  PRIMARY KEY (ProductID, ComponentID),
  Quantity_comp int
);


--
-- Table structure for table 'SuppComp'
--

CREATE TABLE SuppComp (
  ComponentID int NOT NULL,
  SupplierID int NOT NULL,
  PRIMARY KEY (ComponentID, SupplierID),
  FOREIGN KEY (SupplierID) REFERENCES  Supplier (SupplierID),
  FOREIGN KEY (ComponentID) REFERENCES Component (ComponentID),
  OrderDate date NOT NULL,
  Quantity int
);

