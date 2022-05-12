USE A01044772_Project
GO

/*B1*/

SELECT od.OrderID, od.Quantity, od.ProductID, p.ReorderLevel, p.SupplierID
FROM OrderDetails AS od
JOIN Products AS p ON p.ProductID = od.ProductID
WHERE Quantity BETWEEN 65 AND 70
ORDER BY od.OrderID

/*B2*/

SELECT p.ProductID, p.ProductName, p.EnglishName, p.UnitPrice
FROM Products AS p
WHERE p.UnitPrice < 8.00
ORDER BY ProductID

/*B3*/

SELECT c.CustomerID, c.CompanyName, c.Country, c.Phone
FROM Customers AS c
WHERE c.Country = 'Canada' OR c.Country =  'USA'
ORDER BY c.CustomerID

/*B4*/

SELECT p.SupplierID, s.Name, p.ProductName, p.ReorderLevel, p.UnitsInStock  
FROM Products AS p
JOIN Suppliers AS s ON s.SupplierID = p.SupplierID
WHERE p.ReorderLevel = p.UnitsInStock
ORDER BY s.SupplierID

/*B5*/

SELECT o.OrderID, c.CompanyName, c.ContactName, CONVERT(VARCHAR, o.ShippedDate, 107) AS ShippedDate, DATEDIFF(yy, o.ShippedDate, '2009-01-01') AS ElapsedYears
FROM Orders AS o
JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.ShippedDate >= '1994-01-01'
ORDER BY o.OrderID


/*B6*/

SELECT o.OrderID, p.ProductName, c.CompanyName,  CONVERT(VARCHAR, o.OrderDate, 107) AS OrderDate, CONVERT(VARCHAR, DATEADD(day, 10, o.ShippedDate), 107) AS NewShippedDate, (od.Quantity* p.UnitPrice ) AS OrderCost 
FROM Orders AS o
JOIN Customers AS c ON C.CustomerID = o.CustomerID
JOIN OrderDetails AS od ON od.OrderID = o.OrderID
JOIN Products AS p ON p.ProductID = od.ProductID
WHERE o.OrderDate BETWEEN '1992-01-01' AND '1992-03-30'
AND (od.Quantity* p.UnitPrice ) > 1500
ORDER BY o.OrderID

/*B7*/

SELECT o.OrderID, od.UnitPrice, od.Quantity
FROM Orders AS o
JOIN OrderDetails AS od ON o.OrderID = od.OrderID
WHERE o.ShipCity = 'Vancouver'
ORDER BY o.OrderID

/*B8*/

SELECT c.CustomerID, c.CompanyName, c.Fax, o.OrderID, o.OrderDate
FROM Customers AS c 
JOIN Orders AS o ON c.CustomerID = o.CustomerID
WHERE o.ShippedDate IS NULL
ORDER BY C.CustomerID, o.OrderDate

/*B9*/

SELECT p.ProductID, p.ProductName, p.QuantityPerUnit, p.UnitPrice
FROM Products AS p
WHERE p.ProductName LIKE '%choc%' OR p.ProductName LIKE '%tofu%'
ORDER BY p.ProductID


/*B10*/
DROP TABLE IF EXISTS temporary_table

SELECT SUBSTRING(p.ProductName, 1, 1) AS ProductName, COUNT(p.ProductName ) AS Total
INTO temporary_table
FROM Products AS p 
GROUP BY SUBSTRING(p.ProductName, 1, 1) 

SELECT *
FROM temporary_table
WHERE Total >= 3

/*C1*/
DROP VIEW IF EXISTS dbo.vw_supplier_items
GO
CREATE VIEW dbo.vw_supplier_items
AS
SELECT s.SupplierID, s.Name, p.ProductID, p.ProductName
FROM Suppliers AS s
JOIN Products AS p ON s.SupplierID = p.SupplierID
GO

SELECT * 
FROM dbo.vw_supplier_items
ORDER BY Name, ProductID


/*C2*/
DROP VIEW IF EXISTS dbo.vw_employee_info
GO

CREATE VIEW dbo.vw_employee_info
AS
SELECT e.EmployeeID, e.LastName, e.FirstName, e.BirthDate
FROM Employees AS e
GO

SELECT EmployeeID, (FirstName + ' ' + LastName) AS Name, BirthDate
FROM dbo.vw_employee_info
WHERE EmployeeID IN ( 3, 6, 9 )
GO


/*C3*/

UPDATE Customers 
SET Fax = 'Unknown'
WHERE Fax IS NULL

SELECT *
FROM Customers 
WHERE Fax = 'Unknown'

/*C4*/

DROP VIEW IF EXISTS vw_order_cost
GO
CREATE VIEW vw_order_cost
AS 
SELECT o.OrderID, o.OrderDate, p.ProductID, c.CompanyName, (od.Quantity * od.UnitPrice ) AS OrderCost
FROM Orders AS o 
JOIN OrderDetails AS od on o.OrderID = od.OrderID
JOIN Customers AS c ON o.CustomerID = c.CustomerID
JOIN Products AS p ON od.ProductID = P.ProductID
GO

SELECT *
FROM vw_order_cost
WHERE orderID BETWEEN 10100 AND 10200
ORDER BY ProductID

/*C5*/

/*INSERT INTO Suppliers
		(SupplierID, Name)
	VALUES
		(16, 'Supplier P')
GO
*/
SELECT *
FROM Suppliers

/*C6*/

/*UPDATE Products
SET UnitPrice = UnitPrice * 0.15 + UnitPrice
WHERE UnitPrice < 5
*/
SELECT UnitPrice
FROM Products
WHERE UnitPrice < 5

/*C7*/

DROP VIEW IF EXISTS vw_orders 
GO

CREATE VIEW vw_orders 
AS
SELECT o.OrderID, c.CustomerID, c.CompanyName, c.City, c.Country, o.ShippedDate
FROM Orders AS o
JOIN Customers AS c ON o.CustomerID = c.CustomerID
GO
SELECT *
FROM vw_orders
WHERE ShippedDate BETWEEN '1993-01-01' AND '1993-01-31'
ORDER BY CompanyName, Country

/*D1*/

DROP PROCEDURE IF EXISTS #sp_emp_info
GO

/*D1*/

DROP PROCEDURE IF EXISTS #sp_emp_info
GO

CREATE PROCEDURE #sp_emp_info @employee INT
AS

SELECT e.EmployeeID, e.LastName, e.FirstName, e.Phone
FROM Employees AS e
WHERE e.EmployeeID = @employee
GO

EXEC dbo.#sp_emp_info 7

/*D2*/

DROP PROCEDURE IF EXISTS #sp_orders_by_dates 
GO
CREATE PROCEDURE #sp_orders_by_dates @start DATE, @end DATE
AS

SELECT o.OrderID, c.CustomerID, c.CompanyName, s.CompanyName, o.ShippedDate
FROM Customers AS c
JOIN Orders AS o ON c.CustomerID = o.CustomerID
JOIN Shippers AS s ON o.ShipperID = s.ShipperID
WHERE o.ShippedDate BETWEEN @start AND @end

GO

EXEC #sp_orders_by_dates '1991-01-01', '1991-12-31'


/*D3*/





DROP PROCEDURE IF EXISTS #sp_products
GO

CREATE PROCEDURE #sp_products @key VARCHAR(15), @month VARCHAR(15), @year INT

AS

SELECT p.ProductName, p.UnitPrice, p.UnitsInStock, s.Name
FROM Products AS p
JOIN Suppliers AS s ON p.SupplierID = s.SupplierID
JOIN OrderDetails AS od ON p.ProductID = od.ProductID
JOIN Orders AS o ON od.OrderID = o.OrderID
WHERE p.ProductName LIKE @key AND DATENAME(month, o.ShippedDate)  = @month AND DATENAME(year, o.ShippedDate) = @year

GO

EXEC #sp_products '%tofu%', 'December', 1992


/*D4*/

DROP PROCEDURE IF EXISTS #sp_unit_prices 
GO

CREATE PROCEDURE #sp_unit_prices @price1 MONEY, @price2 MONEY
AS 
SELECT p.ProductID, p.ProductName, p.EnglishName, p.UnitPrice
FROM Products AS p
WHERE p.UnitPrice BETWEEN @price1 AND @price2
GO

EXEC #sp_unit_prices 5.50, 8.00

/*D5*/

DROP PROCEDURE IF EXISTS #sp_customer_city
GO

CREATE PROCEDURE #sp_customer_city @city NVARCHAR(15)
AS 

SELECT c.CustomerID, c.CompanyName, c.Address, c.City, c.Phone
FROM Customers AS c
WHERE c.City = @city
GO

EXEC #sp_customer_city 'Paris'
/*D6*/

DROP PROCEDURE IF EXISTS #sp_reorder_qty
GO

CREATE PROCEDURE #sp_reorder_qty @numb INT
AS
SELECT p.ProductID, p.ProductName, s.Name, p.UnitsInStock, p.ReorderLevel
FROM Products AS p
JOIN Suppliers AS s ON p.SupplierID = s.SupplierID
WHERE p.UnitsInStock- p.ReorderLevel < 9
GO

EXEC #sp_reorder_qty 9



/*D7*/ 

DROP PROCEDURE IF EXISTS #sp_shipping_date
GO

CREATE PROCEDURE #sp_shipping_date @date DATE
AS

SELECT o.OrderID, c.CompanyName AS CustomerName, s.CompanyName AS ShipperName, o.OrderDate, o.ShippedDate
FROM Orders AS o
JOIN Customers AS c ON o.CustomerID = c.CustomerID
JOIN Shippers AS s ON o.ShipperID = s.ShipperID
WHERE DATEADD(d, 10, o.OrderDate) = @date
GO

EXEC #sp_shipping_date '1993-11-29' 

/*D8*/

DROP PROCEDURE IF EXISTS #sp_del_inactive_cust
GO

CREATE PROCEDURE #sp_del_inactive_cust 
AS

DELETE FROM Customers
FROM Orders AS o
RIGHT JOIN Customers AS c ON o.CustomerID = c.CustomerID
WHERE O.OrderID IS NULL

GO

--EXEC #sp_del_inactive_cust


GO
SELECT * 
FROM Orders AS o
RIGHT JOIN Customers AS c ON o.CustomerID = c.CustomerID
WHERE O.OrderID IS NULL
GO

/*D9*/
DROP TRIGGER IF EXISTS tr_check_qty
GO

CREATE TRIGGER tr_check_qty
ON OrderDetails
AFTER UPDATE
AS
IF EXISTS (SELECT od.Quantity, p.UnitsInStock
   FROM OrderDetails AS od
   INNER JOIN Products AS p ON p.ProductID = od.ProductID
   WHERE od.Quantity < p.UnitsInStock 
    )

BEGIN
RAISERROR ('The Quantity Amount is greater than the units in the Product available!', 16, 1)
ROLLBACK TRANSACTION
RETURN 
END
GO

/*UPDATE OrderDetails
SET Quantity = 40
WHERE OrderID = 10044
AND ProductID = 77 */


/*D10*/

DROP TRIGGER IF EXISTS tr_insert_shippers
GO
CREATE TRIGGER tr_insert_shippers ON Shippers 
INSTEAD OF INSERT
AS

IF EXISTS ( SELECT * FROM Shippers 
    INNER JOIN INSERTED AS i on i.CompanyName = Shippers.CompanyName )
BEGIN
    ROLLBACK 
	RAISERROR ('Duplicate Data', 16, 1);
END
GO

/*INSERT Shippers
VALUES ( 4, 'Federal Shipping' )*/