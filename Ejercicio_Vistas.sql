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

ALTER VIEW v_pedidos
AS
	SELECT o.OrderID AS nro, o.ExtendedPrice AS total
	FROM [Order Details Extended] o;

SELECT * FROM v_pedidos;

/* Ejer2:Crear una vista con los totales de flete x Pais */