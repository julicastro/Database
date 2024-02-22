USE AdventureWorks2014;
USE Northwind;

/* Crear, ver, modificar, eliminar */

CREATE VIEW v_importe 
AS
	SELECT (s.precio) AS 'Importe Total', ar.nombre AS 'Artista'
	FROM Discos.Stock s
	JOIN Discos.Album a 
	ON s.itemno = a.itemno
	JOIN Discos.Artista ar
	ON ar.artno = a.artno;

ALTER VIEW v_importe
AS
	SELECT (s.tipo) AS 'Tipo', ar.nombre AS 'Artista'
	FROM Discos.Stock s
	JOIN Discos.Album a 
	ON s.itemno = a.itemno
	JOIN Discos.Artista ar
	ON ar.artno = a.artno;

Alter view v_importe
WITH ENCRYPTION
AS 
	SELECT (s.precio) AS 'Importe Total', ar.nombre AS 'Artista'
	FROM Discos.Stock s
	JOIN Discos.Album a 
	ON s.itemno = a.itemno
	JOIN Discos.Artista ar
	ON ar.artno = a.artno;

DROP VIEW v_importe;
select * from v_importe; 

/* Permisos a las vistas */

GRANT SELECT ON v_importe 
TO username; 
GRANT SELECT ON v_importe
TO role;

/* Ej1: Crear una vista de los pedidos(nro y total) de argentina. */

CREATE VIEW PedidosArgentina
AS
SELECT o.OrderID,
sum(od.quantity*od.unitPrice) as Total
FROM orders o
JOIN [Order Details] od on od.OrderID=o.OrderID
JOIN customers c on c.CustomerID=o.CustomerID
WHERE c.Country='Argentina'
GROUP BY o.OrderID

SELECT * FROM PedidosArgentina;

/* Ejer2:Crear una vista con los totales de flete x Pais */
CREATE VIEW v_totales
AS
	SELECT c.Country, SUM(o.Freight) AS flete
	FROM Orders o
	JOIN Customers c
	ON o.CustomerID = c.CustomerID
	GROUP BY c.Country;

select * from v_totales;

/* Ejer3 :Crear una vista con los productos ( nombres y cantidades
en el año 1998 */

CREATE VIEW v_productos
AS	
	SELECT p.productName,sum(od.quantity) as Cantidad
	FROM products p
	JOIN [Order Details] od on od.productid=p.ProductID
	JOIN Orders o on o.OrderID=od.OrderID
	WHERE year(o.orderdate)=1998
	GROUP BY p.ProductName;

	select * from v_productos;

/* Ejer5:Crear una vista con las categorias , los proveedores y sus
productos */

CREATE VIEW v_productos_categorias
AS	
	SELECT c.CategoryName, s.CompanyName, 
	p.ProductName
	FROM Categories as c
	JOIN products as p on p.CategoryID=c.CategoryID
	JOIN Suppliers as s on s.SupplierID=p.SupplierID;

	select * from v_productos_categorias;

/* Ejer6:Crear una vista con los empleados, sus importes totales
de los pedidos en 1996 */

CREATE VIEW v_empleados
AS
SELECT e.LastName AS empleados,
	SUM(od.Quantity*od.UnitPrice) AS 'Importes totales'
	FROM Employees e
	JOIN Orders o
	ON e.EmployeeID = o.EmployeeID
	JOIN [Order Details] od 
	ON o.OrderID = od.OrderID
	WHERE YEAR(o.OrderDate) = 1996
	GROUP BY e.LastName;

SELECT * FROM v_empleados;
