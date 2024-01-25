USE AdventureWorks2014;

/*
	Temas: 
		- Insert /Delete /Update 
		- Inner Join / Left Join / Right Join / Full Join / Cross Join 
		- Exists / In / not exists / not in 
		- Group by / Having 
*/

/* 1. Listar los nombres de los productos y el nombre del modelo que 
posee asignado. Solo listar aquellos que tengan asignado algún modelo. */

SELECT pp.Name AS Producto, pm.Name AS Modelo 
	FROM Production.Product pp
	JOIN Production.ProductModel pm 
	ON pp.ProductModelID = pm.ProductModelID
	WHERE pp.ProductModelID IS NOT NULL;

/* 2. Mostrar “todos” los productos junto con el modelo que tenga 
asignado. En el caso que no tenga asignado ningún modelo, 
mostrar su nulidad. */

SELECT pp.Name AS 'Producto', pm.Name AS 'Modelo'
FROM Production.Product pp
	LEFT JOIN Production.ProductModel AS pm
	ON pp.ProductModelID=pm.ProductModelID;

/* 3. Ídem Ejercicio2, pero en lugar de mostrar nulidad, mostrar la 
palabra “Sin Modelo” para indicar que el producto no posee un 
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
posean asignados 2 o más productos. */

SELECT pp.ProductModelID, pm.Name, COUNT(pp.ProductID) AS 'Cantidad de Productos'
	FROM Production.Product pp
	JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pp.ProductModelID, pm.Name
	HAVING COUNT(*) > 2;

/* 6. Contar la cantidad de Productos que poseen asignado cada 
modelo valido, es decir, que se encuentre cargado en la tabla 
de modelos. Realizar este ejercicio de 3 formas posibles: 
“exists” / “in” / “inner join”. */

-- INNER JOIN
SELECT pm.ProductModelID AS 'Modelo Valido ID', COUNT(*) AS 'Cantidad de Productos'
	FROM Production.Product pp
	JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pm.ProductModelID;

-- IN
SELECT pp.ProductModelID AS 'Modelo Valido ID', COUNT(*) AS 'Cantidad de Productos'
	FROM Production.Product pp
	WHERE pp.ProductModelID IN (SELECT pm.ProductModelID 
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
la cantidad de productos asignados. Si algún modelo no posee 
asignado ningún producto, se quiere visualizar 0 (cero). */

SELECT pm.Name, COUNT(pp.ProductID) AS 'Cantidad de Productos Asignados'
	FROM Production.Product pp
	RIGHT JOIN Production.ProductModel AS pm
	ON pp.ProductModelID = pm.ProductModelID
	GROUP BY pp.ProductModelID, pm.Name;

/* 8. Se quiere visualizar, el nombre del producto, el nombre 
modelo que posee asignado, la ilustración que posee asignada 
y la fecha de última modificación de dicha ilustración y el 
diagrama que tiene asignado la ilustración. Solo nos interesan 
los productos que cuesten más de $150 y que posean algún 
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

/* 9. Mostrar aquellas culturas que no están asignadas a ningún 
producto/modelo.(Production.ProductModelProductDescriptionCulture)*/

SELECT Name AS 'Cultura' 
FROM Production.Culture
WHERE CultureID NOT IN
	(SELECT CultureID
	FROM Production.ProductModelProductDescriptionCulture);

/* 10. Agregar a la base de datos el tipo de contacto “Ejecutivo de 
Cuentas” (Person.ContactType)*/
INSERT INTO Person.ContactType (Name) 
VALUES ('Ejecutivo de Cuentas');

/* 11. Agregar la cultura llamada “nn” – “Cultura Moderna”. */




12. Cambiar la fecha de modificación de las culturas Spanish, 
French y Thai para indicar que fueron modificadas hoy. 
13. En la tabla Production.CultureHis agregar todas las culturas 
que fueron modificadas hoy. (Insert/Select). 
14. Al contacto con ID 10 colocarle como nombre “Juan Perez”. 
15. Agregar la moneda “Peso Argentino” con el código “PAR” 
(Sales.Currency) 
16. ¿Qué sucede si tratamos de eliminar el código ARS 
correspondiente al Peso Argentino? ¿Por qué? 
17. Realice los borrados necesarios para que nos permita eliminar 
el registro de la moneda con código ARS. 
18. Eliminar aquellas culturas que no estén asignadas a ningún 
producto (Production.ProductModelProductDescriptionCulture)*/