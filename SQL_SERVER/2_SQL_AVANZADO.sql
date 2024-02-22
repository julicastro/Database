USE AdventureWorks2014;

/*
	Temas: 
		- Insert /Delete /Update 
		- Inner Join / Left Join / Right Join / Full Join / Cross Join 
		- Exists / In / not exists / not in 
		- Group by / Having 
*/

/* 1. Listar los nombres de los productos y el nombre del modelo que 
posee asignado. Solo listar aquellos que tengan asignado alg�n modelo. */

SELECT pp.Name AS Producto, pm.Name AS Modelo 
	FROM Production.Product pp
	JOIN Production.ProductModel pm 
	ON pp.ProductModelID = pm.ProductModelID
	WHERE pp.ProductModelID IS NOT NULL;

/* 2. Mostrar �todos� los productos junto con el modelo que tenga 
asignado. En el caso que no tenga asignado ning�n modelo, 
mostrar su nulidad. */

SELECT pp.Name AS 'Producto', pm.Name AS 'Modelo'
FROM Production.Product pp
	LEFT JOIN Production.ProductModel AS pm
	ON pp.ProductModelID=pm.ProductModelID;

/* 3. �dem Ejercicio2, pero en lugar de mostrar nulidad, mostrar la 
palabra �Sin Modelo� para indicar que el producto no posee un 
modelo asignado. */

SELECT pp.Name AS 'Producto', 
CASE
	WHEN pm.Name IS NULL THEN 'Sin Modelo'
	ELSE pm.Name
END
AS 'Modelo'
FROM Production.Product pp
	LEFT JOIN Production.ProductModel AS pm
	ON pp.ProductModelID=pm.ProductModelID;

/* 4. Contar la cantidad de Productos que poseen asignado cada 
uno de los modelos. (cada modelo tiene una cantidad de productos asignada. 
se debe mostrar esa cantidad y a q modelo pertenece ) */

SELECT pp.ProductModelID, pm.Name, COUNT(pp.ProductID) AS 'Cantidad de Productos'
	FROM Production.Product pp
	JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pp.ProductModelID, pm.Name;

/* 5. Contar la cantidad de Productos que poseen asignado cada 
modelo, pero mostrar solo aquellos modelos que 
posean asignados 2 o m�s productos. */

SELECT pp.ProductModelID, pm.Name, COUNT(pp.ProductID) AS 'Cantidad de Productos'
	FROM Production.Product pp
	JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pp.ProductModelID, pm.Name
	HAVING COUNT(*) > 2;

/* 6. Contar la cantidad de Productos que poseen asignado cada 
modelo valido, es decir, que se encuentre cargado en la tabla 
de modelos. Realizar este ejercicio de 3 formas posibles: 
�exists� / �in� / �inner join�. */

-- INNER JOIN
SELECT pm.ProductModelID AS 'Modelo Valido ID', COUNT(*) AS 'Cantidad de Productos'
	FROM Production.Product pp
	JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pm.ProductModelID;

-- IN
SELECT pp.ProductModelID AS 'Modelo Valido ID', COUNT(*) AS 'Cantidad de Productos'
	FROM Production.Product pp
	WHERE pp.ProductModelID IN 
		(SELECT pm.ProductModelID 
		FROM Production.ProductModel pm
		)
	GROUP BY pp.ProductModelID;

-- EXISTS
SELECT pp.ProductModelID AS 'Modelo Valido ID', COUNT(*) AS 'Cantidad de Productos'
	FROM Production.Product pp
	WHERE EXISTS (SELECT pm.ProductModelID 
					FROM Production.ProductModel pm
					WHERE pp.ProductModelID = pm.ProductModelID
					)
	GROUP BY pp.ProductModelID;

/* 7. Contar cuantos productos poseen asignado cada uno de los 
modelos, es decir, se quiere visualizar el nombre del modelo y 
la cantidad de productos asignados. Si alg�n modelo no posee 
asignado ning�n producto, se quiere visualizar 0 (cero). */

SELECT pm.Name, COUNT(pp.ProductID) AS 'Cantidad de Productos Asignados'
	FROM Production.Product pp
	RIGHT JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pp.ProductModelID, pm.Name;

/* 8. Se quiere visualizar, el nombre del producto, el nombre 
modelo que posee asignado, la ilustraci�n que posee asignada 
y la fecha de �ltima modificaci�n de dicha ilustraci�n y el 
diagrama que tiene asignado la ilustraci�n. Solo nos interesan 
los productos que cuesten m�s de $150 y que posean alg�n 
color asignado.*/

SELECT pp.Name AS 'Nombre Producto', pp.ListPrice, pm.Name AS 'Modelo Asignado', il.* 
	FROM Production.Product pp
	JOIN Production.ProductModel pm
	ON pp.ProductModelID = pm.ProductModelID
	JOIN Production.ProductModelIllustration mi
	ON pm.ProductModelID = mi.ProductModelID
	JOIN Production.Illustration il
	ON mi.IllustrationID = il.IllustrationID
	WHERE pp.ProductID IN 
			(SELECT ProductID 
			FROM Production.Product 
			WHERE Color IS NOT NULL
			AND ListPrice >= 150);

/* 9. Mostrar aquellas culturas que no est�n asignadas a ning�n 
producto/modelo.(Production.ProductModelProductDescriptionCulture)*/

SELECT Name AS 'Cultura' 
	FROM Production.Culture
	WHERE CultureID NOT IN
		(SELECT CultureID
		FROM Production.ProductModelProductDescriptionCulture);

/* 10. Agregar a la base de datos el tipo de contacto �Ejecutivo de 
Cuentas� (Person.ContactType)*/
INSERT INTO Person.ContactType (Name) 
VALUES ('Ejecutivo de Cuentas');

/* 11. Agregar la cultura llamada �nn� � �Cultura Moderna�. */
INSERT INTO Production.Culture (CultureID, Name) 
VALUES ('mm', 'Cultura Moderna');

/* 12. Cambiar la fecha de modificaci�n de las culturas Spanish, 
French y Thai para indicar que fueron modificadas hoy. */

UPDATE Production.Culture 
	SET ModifiedDate = GETDATE()
	WHERE CultureID IN ('es', 'fr', 'th');

/* 13. En la tabla Production.CultureHis agregar todas las culturas 
que fueron modificadas hoy. (Insert/Select). */

CREATE TABLE Production.CultureHis (
    CultureID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(225),
    ModifiedDate DATE
);
-- cree la tabla xq no existia
INSERT INTO Production.CultureHis (CultureID, Name, ModifiedDate)
SELECT CultureID, Name, ModifiedDate
FROM Production.Culture pc
WHERE CONVERT(DATE, pc.ModifiedDate) = CONVERT(DATE, GETDATE());
SELECT * FROM Production.CultureHis;
/* convert convierte el pc.ModifiedDate al tipo Date q es el tipo de la tabla.
este pregunta si es igual a la conversion del getDate() al tipo Date. Como este
se convierte a Date, solo se va a tomar la fecha y no la hora. estableciendo x detras
la hora 00.00.00. X lo q se agregaran a la tabla los de la fecha de hoy desde las 0hs.*/

/* 14. Al contacto con ID 10 colocarle como nombre �Juan Perez�. */
UPDATE Production.Product
SET Name='Juan'
WHERE ProductID=4;

/* 15. Agregar la moneda �Peso Argentino� con el c�digo �PAR� 
(Sales.Currency) */

INSERT INTO Sales.Currency (CurrencyCode, Name)
VALUES ('PAR', 'Peso Argentino');

/* 16. �Qu� sucede si tratamos de eliminar el c�digo ARS 
correspondiente al Peso Argentino? �Por qu�? */

DELETE FROM Sales.Currency WHERE CurrencyCode = 'ARS';
/* The DELETE statement conflicted with the REFERENCE constraint "FK_CountryRegionCurrency_Currency_CurrencyCode". 
The conflict occurred in database "AdventureWorks2014", table "Sales.CountryRegionCurrency", column 'CurrencyCode'. */

/* 17. Realice los borrados necesarios para que nos permita eliminar 
el registro de la moneda con c�digo ARS. */

DELETE FROM Sales.CurrencyRate
WHERE FromCurrencyCode='ARS'
	OR ToCurrencyCode='ARS';

DELETE FROM Sales.CountryRegionCurrency
WHERE CurrencyCode='ARS';

DELETE FROM Sales.Currency
WHERE CurrencyCode='ARS';

/* 18. Eliminar aquellas culturas que no est�n asignadas a ning�n 
producto (Production.ProductModelProductDescriptionCulture) */

DELETE FROM Production.Culture
	   WHERE CultureID NOT IN
	   (SELECT CultureID
	   FROM Production.ProductModelProductDescriptionCulture);