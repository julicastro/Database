USE AdventureWorks2014;

-- 1- Listar los c�digos y descripciones de todos los productos (Ayuda: Production.Product) 

SELECT pp.ProductID AS 'Codigo', pd.Description AS 'Descripcion'  
	FROM Production.Product pp
		JOIN Production.ProductModel pm
		ON pp.ProductModelID = pm.ProductModelID
		JOIN Production.ProductModelProductDescriptionCulture pmd
		ON pm.ProductModelID = pmd.ProductModelID
		JOIN Production.ProductDescription pd
		ON pmd.ProductDescriptionID = pd.ProductDescriptionID;

-- 2- Listar los datos de la subcategor�a n�mero 17 (Ayuda: Production.ProductSubCategory) 

SELECT ps.* 
	FROM Production.ProductSubCategory ps
		WHERE ProductSubcategoryID = 17;

-- 3- Listar los productos cuya descripci�n comience con D (Ayuda: like �D%�) 
SELECT pp.ProductID AS 'Codigo', pd.Description AS 'Descripcion'  
	FROM Production.Product pp
		JOIN Production.ProductModel pm
		ON pp.ProductModelID = pm.ProductModelID
		JOIN Production.ProductModelProductDescriptionCulture pmd
		ON pm.ProductModelID = pmd.ProductModelID
		JOIN Production.ProductDescription pd
		ON pmd.ProductDescriptionID = pd.ProductDescriptionID
			WHERE pd.Description LIKE 'D%';

-- 4- Listar las descripciones de los productos cuyo n�mero finalice con 8 (Ayuda: ProductNumber like �%8�)

SELECT pp.ProductID AS 'Codigo', PP.ProductNumber AS 'Numero'  
	FROM Production.Product pp
		WHERE PP.ProductNumber LIKE '%8';

-- 5- Listar aquellos productos que posean un color asignado. Se deber�n excluir todos aquellos que no posean ning�n valor (Ayuda: is not null)
SELECT * 
	FROM Production.Product pp
		WHERE pp.Color IS NOT NULL; 

-- 6- Listar el c�digo y descripci�n de los productos de color Black (Negro) y que posean el nivel de stock en 500. (Ayuda: SafetyStockLevel = 500) 
SELECT pp.ProductID, pp.Color, pp.SafetyStockLevel 
	FROM Production.Product pp
		JOIN Production.ProductModel pm
		ON pp.ProductModelID = pm.ProductModelID
		JOIN Production.ProductModelProductDescriptionCulture pmd
		ON pm.ProductModelID = pmd.ProductModelID
		JOIN Production.ProductDescription pd
		ON pmd.ProductDescriptionID = pd.ProductDescriptionID
			WHERE pp.Color = 'Black'
			AND pp.SafetyStockLevel = 500;

-- 7- Listar los productos que sean de color Black (Negro) � Silver (Plateado). 
SELECT pp.ProductID, pp.Color 
	FROM Production.Product pp
		WHERE pp.Color = 'Black' OR pp.Color = 'Silver'; 

-- 8- Listar los diferentes colores que posean asignados los productos. S�lo se deben listar los colores. (Ayuda: distinct) 
SELECT DISTINCT pp.Color
	FROM Production.Product pp
		WHERE pp.Color IS NOT NULL;

-- 9- Contar la cantidad de categor�as que se encuentren cargadas en la base. (Ayuda: count) 
SELECT COUNT(pc.ProductCategoryID) 
	FROM Production.ProductCategory pc;

-- 10- Contar la cantidad de subcategor�as que posee asignada la categor�a 2. 
SELECT COUNT(ps.ProductSubcategoryID) 
	FROM Production.ProductCategory pc
	JOIN Production.ProductSubcategory ps
	ON pc.ProductCategoryID = ps.ProductCategoryID
		WHERE pc.ProductCategoryID = 2;

SELECT COUNT(*) AS 'Subcategorias de la Categoria 2'
	FROM Production.ProductSubcategory
		WHERE ProductCategoryID=2;

-- 11- Listar la cantidad de productos que existan por cada uno de los colores. 
SELECT DISTINCT Color, COUNT(*) AS Productos
	FROM Production.Product
		WHERE Color IS NOT NULL
			GROUP BY Color;

-- 12- Sumar todos los niveles de stocks aceptables que deben existir para los productos con color Black. (Ayuda: sum) 
SELECT SUM(pp.SafetyStockLevel) AS 'Total'
	FROM Production.Product pp
		WHERE pp.Color = 'Black';

-- 13- Calcular el promedio de stock que se debe tener de todos los productos cuyo c�digo se encuentre entre el 316 y 320. (Ayuda: avg)
SELECT AVG(pp.SafetyStockLevel) AS 'Promedio'
	FROM Production.Product pp
		WHERE pp.ProductID BETWEEN 316 AND 320;

-- 14- Listar el nombre del producto y descripci�n de la subcategor�a que posea asignada. (Ayuda: inner join)
SELECT pp.Name, ps.Name
	FROM Production.Product pp
	INNER JOIN Production.ProductSubcategory ps
	ON pp.ProductSubcategoryID = ps.ProductSubcategoryID;

-- 15- Listar todas las categor�as que poseen asignado al menos una subcategor�a. Se deber�n excluir aquellas que no posean ninguna.
SELECT pc.Name AS 'Categoria'
	FROM Production.ProductCategory AS pc
		WHERE EXISTS
			(SELECT 1
				FROM Production.ProductSubcategory AS ps
					WHERE pc.ProductCategoryID = ps.ProductCategoryID);

-- 16- Listar el c�digo y descripci�n de los productos que posean fotos asignadas. (Ayuda: Production.ProductPhoto)
SELECT pp.ProductID AS 'Codigo', pd.Description AS 'Descripcion'
		FROM Production.Product pp
		JOIN Production.ProductModel pm
		ON pp.ProductModelID = pm.ProductModelID
		JOIN Production.ProductModelProductDescriptionCulture pmd
		ON pm.ProductModelID = pmd.ProductModelID
		JOIN Production.ProductDescription pd
		ON pmd.ProductDescriptionID = pd.ProductDescriptionID
		WHERE EXISTS
			(SELECT 1
				FROM Production.ProductProductPhoto AS pf
					WHERE pp.ProductID = pf.ProductID);

-- 17- Listar la cantidad de productos que existan por cada una de las Clases (Ayuda: campo Class)
SELECT Class, COUNT(*) AS 'Cantidad de Productos'
	FROM Production.Product
		WHERE Class IS NOT NULL
			GROUP BY Class;

-- 18- Listar la descripci�n de los productos y su respectivo color. 
-- S�lo nos interesa caracterizar al color con los valores: Black, Silver u Otro. 
-- Por lo cual si no es ni silver ni black se debe indicar Otro. (Ayuda: utilizar case).

SELECT pd.Description, 
	CASE pp.Color
		WHEN 'Black' THEN 'Black'
		WHEN 'Silver' THEN 'Silver'
		ELSE 'Otro'	
	END 
	AS 'Color'
	FROM Production.ProductDescription AS pd
		JOIN Production.ProductModelProductDescriptionCulture AS pmd
		ON pd.ProductDescriptionID = pmd.ProductDescriptionID
		JOIN Production.ProductModel AS pm
		ON pmd.ProductModelID = pm.ProductModelID
		JOIN Production.Product AS pp
		ON pm.ProductModelID = pp.ProductModelID
			GROUP BY pd.Description, pp.Color;	

-- 19- Listar el nombre de la categor�a, el nombre de la subcategor�a y la descripci�n del producto. (Ayuda: join) 
SELECT pd.Description AS 'Descripcion', pc.Name, ps.Name  
	FROM Production.Product pp
		JOIN Production.ProductModel pm
		ON pp.ProductModelID = pm.ProductModelID
		JOIN Production.ProductModelProductDescriptionCulture pmd
		ON pm.ProductModelID = pmd.ProductModelID
		JOIN Production.ProductDescription pd
		ON pmd.ProductDescriptionID = pd.ProductDescriptionID
		JOIN Production.ProductSubcategory ps 
		ON pp.ProductSubcategoryID = ps.ProductSubcategoryID
		JOIN Production.ProductCategory pc 
		ON ps.ProductCategoryID = pc.ProductCategoryID;

-- 20- Listar la cantidad de subcategor�as que posean asignado los productos. (Ayuda: distinct).
SELECT DISTINCT COUNT(*) AS 'Total'
	FROM Production.ProductSubcategory ps 
		WHERE EXISTS (SELECT 1
						FROM Production.Product pp
							WHERE pp.ProductSubcategoryID = ps.ProductSubcategoryID);

SELECT COUNT(DISTINCT ProductSubcategoryID) AS 'SubCategorias'
	FROM Production.Product
		WHERE ProductSubcategoryID IS NOT NULL;