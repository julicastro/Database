USE AdventureWorks2014;
USE Northwind;

-- Email

SELECT * FROM Person.EmailAddress; 

SELECT 
	EmailAddress AS 'Email Completo',
	LEFT(EmailAddress, CHARINDEX('@', EmailAddress) -1) AS 'Nombre',
	SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) as 'Dominio',
	CHARINDEX('@', EmailAddress) AS 'Posicion del @'
FROM Person.EmailAddress; 

-- Email sin .com

DECLARE @dom_internet VARCHAR(8);
SELECT @dom_internet = RIGHT(EmailAddress, LEN(EmailAddress) - CHARINDEX('.', EmailAddress) + 1) FROM Person.EmailAddress;
SELECT REPLACE(SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)), @dom_internet, '')
FROM Person.EmailAddress;

-- lo mismo 

DECLARE @dom VARCHAR(8)
SELECT @dom = RIGHT(EmailAddress, LEN(EmailAddress) - CHARINDEX('.', EmailAddress) + 1) FROM Person.EmailAddress;
SELECT REPLACE(SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)), @dom, '')
	FROM Person.EmailAddress;

/*14.Se desea enmascarar el NationalIDNumber de cada empleado, de la 
siguiente forma ###-####-##: ID, Numero, Enmascarado -> 36, 113695504, 113-6955-04 */

SELECT NationalIDNumber FROM HumanResources.Employee;
SELECT 
	CONCAT(SUBSTRING(NationalIDNumber, 1, 3) , '-' , SUBSTRING(NationalIDNumber, 4, 4) , '-' , SUBSTRING(NationalIDNumber, 7, 2))
FROM HumanResources.Employee; 

/*16. Listar la cantidad de empleados hombres y mujeres, de la siguiente forma: 
Sexo Cantidad 
Femenino 47 
Masculino 56 
Nota: Debe decir, Femenino y Masculino de la misma forma que se muestra. */

SELECT 
	CASE gender 
		WHEN 'M' 
		THEN 'Masculino' 
		ELSE 'Femenino'
	END AS 'Cantidad',
	COUNT(*) AS Genero
FROM HumanResources.Employee
GROUP BY Gender;

-- Crear funcion q devuelve una tabla. 
CREATE FUNCTION ClientesPorTipoConSaldos (
    @Tipo TINYINT
)
RETURNS @T TABLE (
    idCliente INT,
    NombreCliente VARCHAR(100),
    Saldo MONEY
)
AS
BEGIN
    INSERT INTO @T (idCliente, NombreCliente, Saldo)
    SELECT
        C.idCliente,
        C.Nombre,
        ISNULL(SUM(F.Monto), 0) AS Saldo
    FROM
        Clientes AS C
    LEFT JOIN
        Facturas AS F ON C.idCliente = F.idCliente
    WHERE
        C.Tipo = @Tipo
    GROUP BY
        C.idCliente, C.Nombre;
    RETURN;
END;

/* las funciones devuelven tabla con sentencia/s Transact-SQL */

-- crear trigger para tabla de auditorioa

CREATE TRIGGER t_AltaEmpleado
ON Empleado
AFTER INSERT 
AS
BEGIN
	IF EXISTS (SELECT 1 FROM INSERTED)
		BEGIN
			DECLARE @Codigo INT;
			DECLARE @NombreCompleto VARCHAR(50);

			SELECT @Codigo = Codigo,
				   @NombreCompleto = CONCAT(Nombre, ' ', Apellido)
			FROM INSERTED; 
			
			DECLARE @usuario_actual VARCHAR(128);
			SET @usuario_actual = SUSER_SNAME();

			INSERT INTO Auditoria(Tabla, Operacion, Codigo, Fecha, Detalle, Usuario)
				VALUES ('Empleado', 'A', 'Codigo', GETDATE(), CONCAT('Alta de Emplado ', @NombreCompleto), @usuario_actual);
			COMMIT TRANSACTION; 
		END
	ELSE
		BEGIN
			ROLLBACK TRANSACTION; 
			THROW 50000, 'No se pudo insertar Empleado', 1;
		END

END;

select SUSER_SNAME(); -- muestra el usuario actual logeado. 

-- SP con valor de salida
CREATE OR ALTER PROCEDURE sp_CantCulture
(
	@cantidad INT OUTPUT
)
AS
BEGIN
	SELECT @cantidad = COUNT(*) FROM Production.Culture;
END; 

DECLARE @resultado INT;
EXEC sp_CantCulture @resultado OUT;
SELECT @resultado AS 'Total de Culturas';

SELECT * FROM Production.Culture;

-- Actualizar tabla principal en casos de update view
/*  
SELECT id, nombre, provincia FROM EmpleadosChaco 
UNION 
SELECT id, nombre, provincia FROM EmpleadosFormosa.
*/

CREATE TRIGGER 
ON EmpleadosFormosaChaco
INSTEAD OF UPDATE
	IF EXISTS (SELECT 1 FROM INSERTED)
	BEGIN 
		DECLARE @Provincia VARCHAR(25);
		SELECT @Provincia = provincia FROM INSERTED; 
		IF @Provincia = 'Formosa'
		BEGIN
			UPDATE EmpleadosFormosa
			SET ef.nombre = i.nombre
			FROM EmpleadosFormosa ef
			JOIN INSERTED i 
			ON i.id = ef.id
			WHERE i.provincia = 'Formosa';
		END
		-- ELSE ERROR + ROLLBACK 
		IF @Provincia = 'Chaco'
		BEGIN
			UPDATE EmpleadoChaco
			SET ec.nombre = i.nombre
			FROM EmpleadoChaco ec
			JOIN INSERTED i 
			ON i.id = ec.id
			WHERE i.provincia = 'Chaco';
		END
		-- ELSE ERROR + ROLLBACK 
	END
	ELSE 
	BEGIN			
		ROLLBACK TRANSACTION;
		THROW 50000, 'Error', 1;
	END
GO

-- Otro ejemplo 
CREATE TRIGGER TR_U_Person
ON dbo.Person
INSTEAD OF UPDATE
AS
	UPDATE dbo.Customers
	SET    CustomerName = I.PersonName , CustomerAddress = I.PersonAddress
	FROM   dbo.Customers C
		   INNER JOIN Inserted I ON C.CustomerCode = I.PersonCode;
 
	UPDATE dbo.Providers
	SET    ProviderName = I.PersonName , ProviderAddress = I.PersonAddress
	FROM   dbo.Providers P
		   INNER JOIN Inserted I ON P.ProviderCode = I.PersonCode;
GO

-- En SQL Server, el nivel de aislamiento READ UNCOMMITTED permite acceder a los datos sin ningún tipo de bloqueo.

/* Declare un cursos para la tabla Production.Product q muestre x pantalla
el valor de los registros ProductID, Name, ProductNumber */

DECLARE @ProductID INT, @Name NVARCHAR(255), @ProductNumber NVARCHAR(25);

DECLARE product_cursor CURSOR FOR 
    SELECT ProductID, Name, ProductNumber 
    FROM Production.Product;

OPEN product_cursor;

FETCH NEXT FROM product_cursor INTO @ProductID, @Name, @ProductNumber;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'ProductID: ' + CAST(@ProductID AS NVARCHAR(10)) + ', Name: ' + @Name + ', ProductNumber: ' + @ProductNumber;

    FETCH NEXT FROM product_cursor INTO @ProductID, @Name, @ProductNumber;
END

CLOSE product_cursor;
DEALLOCATE product_cursor;

-- obtener la edad de cada empleado: 

SELECT 
    Nombre,
    FechaNacimiento,
    DATEDIFF(YEAR, FechaNacimiento, GETDATE()) AS Edad
FROM 
    Empleados;

-- MUY IMPORTANTE USAR DATEDIF. 

/* normalizar: 
si se realizan consultas unicamente por un solo campo como x ejemplo apellido,
se puede agregarla a este campo un indice no agrupado. NON-CLUSTERED. pero las 
filas de la tabla no se ordenan físicamente según el orden de ese índice.
 un tipo de índice en el que las filas de la tabla no se almacenan en el mismo orden que el índice.
*/

-- CREACION DE BASE DE DATOS.
CREATE DATABASE PruebaDb
ON 
(
	NAME = 'Prueba_data', -- nombre logico
	FILENAME = 'C://files/msql_server/data/prueba.mdf', -- nombre fisico
	SIZE = 5MB,
	MAXSIZE = 20MB,
	FILEGROWTH = 10%
)
LOG ON
(
	NAME = 'Prueba_log',
	FILENAME = 'C://files/msql_server/data/prueba.ldf',
	SIZE = 5MB,
	MAXSIZE = 20MB,
	FILEGROWTH = 10%
)

-- Agregar restriccion a tabla

ALTER TABLE tabla ADD CONSTRAINT birthday CHECK (birthday >= '1900-05-05');

SELECT 
    EmailAddress AS Email,
    LEFT(EmailAddress, CHARINDEX('@', EmailAddress) - 1) AS Nombre,
	SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) as 'DOM',
    CHARINDEX('@', EmailAddress) AS PosicionArroba
FROM 
    Person.EmailAddress;

-- Crear PRC con error detallado

CREATE OR ALTER PROCEDURE EliminarProductos
	@p_product int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		IF @p_product IS NOT NULL AND @p_product IN (SELECT ProductID FROM Production.Product)
			DELETE FROM Production.Product WHERE ProductID = @p_product
		ELSE
			THROW 50000, 'ID no encontrado', 1;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = 'Número: ' + CAST(ERROR_NUMBER() AS NVARCHAR) + 
                            ', Descripción: ' + ERROR_MESSAGE() + 
                            ', Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '') + 
                            ', Número de línea: ' + CAST(ERROR_LINE() AS NVARCHAR);
        THROW 50000, @ErrorMessage, 1;
	END CATCH
END

EXEC EliminarProductos 1;

-- Trigger para no eliminar mas de 1 empleado

CREATE OR ALTER TRIGGER EliminarProducto3
ON Production.Product
FOR DELETE
AS
BEGIN
	IF (SELECT COUNT(*) FROM DELETED ) > 1
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50000, 'No se puede borrar mas de un Empleado', 1;
	END
END


/*7- p_ValCulture(id,name,date,operación, valida out): Este sp permitirá 
validar los datos enviados por parámetro. En el caso que el registro sea 
válido devolverá un 1 en el parámetro de salida valida ó 0 en caso contrario. 
El parámetro operación puede ser “U” (Update), “I” (Insert) ó “D” (Delete). 
Lo que se debe validar es:
- Si se está insertando no se podrá agregar un registro con un id 
existente, ya que arrojará un error.
- Tampoco se puede agregar dos registros Cultura con el mismo Name, 
ya que el campo Name es un unique index.
- Ninguno de los campos debería estar vacío.
- La fecha ingresada no puede ser menor a la fecha actual.
*/

CREATE OR ALTER PROCEDURE p_ValCultureInsert 
    @p_id NCHAR(12),
    @p_name NVARCHAR(100),
    @p_date DATE = NULL,
    @p_operacion CHAR(1)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		IF @p_date IS NULL
			SET @p_date = GETDATE();

		IF @p_date > GETDATE()
			THROW 50000, 'La fecha no puede ser mayor a la actual', 1;

		IF @p_operacion <> 'I' AND @p_operacion <> 'U' AND @p_operacion <> 'D'
			THROW 50000, 'La operación debe ser I, U o D', 1;

		IF @p_id IS NULL or @p_name IS NULL or @p_date IS NULL or @p_operacion IS NULL
			THROW 50000, 'No se permiten campos nulos', 1;

		IF @p_operacion = 'I'
		BEGIN
			IF EXISTS (SELECT 1 FROM Production.Culture WHERE CultureID = @p_id) or EXISTS (SELECT 1 FROM Production.Culture WHERE Name = @p_name) 
				THROW 50000, 'Ya existe esa cultura', 1;
			ELSE
				INSERT INTO Production.Culture (CultureID, Name, ModifiedDate) VALUES (@p_id, @p_name, @p_date);
		END
		COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION; 
		DECLARE @err VARCHAR(4000)
		SET @err = CONCAT(
			'Descripcion: ' , ERROR_MESSAGE() ,
			'. Linea: ' , ERROR_LINE() ,
			'. Numero: ' , CAST(ERROR_NUMBER() AS VARCHAR) ,
			'. Procedure: ' , ISNULL(ERROR_PROCEDURE(), 'No aplica')
		);
		THROW 50000, @err, 1;
	END CATCH
END;

DECLARE @v_date DATE;
SET @v_date = GETDATE();
EXEC p_ValCultureInsert 'dada', '44', @v_date, 'I';

SELECT * FROM Production.Culture;

/* EJEMPLO DE CURSOR */ 

DECLARE @ID INT;
DECLARE @Nombre NVARCHAR(50);
DECLARE @Apellido NVARCHAR(50);

DECLARE empleado_cursor CURSOR FOR
SELECT ID, Nombre, Apellido
FROM Empleados;

OPEN empleado_cursor;

FETCH NEXT FROM empleado_cursor INTO @ID, @Nombre, @Apellido;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Aquí puedes realizar las operaciones que desees con los valores de las columnas del registro actual
    PRINT 'ID: ' + CAST(@ID AS NVARCHAR(10)) + ', Nombre: ' + @Nombre + ', Apellido: ' + @Apellido;

    FETCH NEXT FROM empleado_cursor INTO @ID, @Nombre, @Apellido;
END

CLOSE empleado_cursor;
DEALLOCATE empleado_cursor;

/* 15-p_GenerarProductoxColor(): Generar un procedimiento que divida los 
productos según el color que poseen. Los mismos deben ser insertados en 
diferentes tablas según el color del producto. Por ejemplo, las tablas podrían 
ser Product_Black, Product_Silver, etc… Estas tablas deben ser generadas 
dinámicamente según los colores que existan en los productos, es decir, si 
genero un nuevo producto con un nuevo color, al ejecutar el procedimiento 
debe generar dicho color. Cada vez que se ejecute este procedimiento se 
recrearán las tablas de colores. Los productos que no posean color 
asignados, no se tendrán en cuenta para la generación de tablas y no se 
insertarán en ninguna tabla de color. */

CREATE OR ALTER PROCEDURE p_GenerarProductoxColor
AS
BEGIN
	DECLARE @v_color VARCHAR(25);
	DECLARE @v_sql VARCHAR(MAX);
	DECLARE color_cursor CURSOR FOR SELECT DISTINCT Color FROM [Production].[Product] WHERE Color IS NOT NULL;

	OPEN color_cursor;
	FETCH NEXT FROM color_cursor INTO @v_color; 
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @v_sql = 'IF EXISTS(SELECT 1 FROM sys.tables WHERE name = ''Product_'+@v_color+''')
						DROP TABLE ''Product_'+@v_color+';'
						EXEC sp_executesql @v_sql;
		SET @v_sql = 'CREATE TABLE ''Product_'+@v_color+' (id int PRIMARY KEY, name VARCHAR(25))' 
						EXEC sp_executesql @v_sql;
		SET @v_sql = 'INSERT INTO ''Product_'+@v_color+' SELECT ProductID, name FROM [Production].[Product] WHERE color = '+@v_color+';'
		FETCH NEXT FROM color_cursor INTO @v_color;
	END
	CLOSE color_cursor;
	DEALLOCATE color_cursor;  
END

USE AdventureWorks2014;
USE master;
GO
/* sql_seg
1. Crear el usuario sql_seg.
2. El usuario será de Seguridad Informática y podrá sólo realizar asignaciones 
de logins y usuarios de todas las bases de datos.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- Create login sql_1 with password='123'
- Drop login sql_1 */

CREATE LOGIN sql_seg2 WITH PASSWORD='1234';
GO
CREATE USER sql_seg3 FOR LOGIN sql_seg3; 
GO 
ALTER SERVER ROLE securityadmin ADD MEMBER sql_seg3
GO

/* sql_seg
1. Crear el usuario sql_seg.
2. El usuario será de Seguridad Informática y podrá sólo realizar asignaciones 
de logins y usuarios de todas las bases de datos.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- Create login sql_1 with password='123'
- Drop login sql_1 */

/* sql_consulta
1. Crear el usuario sql_consulta. El mismo debe tener como base de datos 
por defecto AdventureWorks.
2. No hará falta que cambie la password al ingresar, sino que la password será 
predeterminada.
3. Asignarle que sólo pueda leer la información de todas las tablas contenidas 
dentro de la base de datos AdventureWorks.
4. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- Delete from Person.Contact where contactID=1
*/

-- Crear el inicio de sesión para el usuario sql_consulta
CREATE LOGIN sql_consulta WITH PASSWORD = '1234';
GO

-- Asignar la base de datos AdventureWorks como la base de datos por defecto
ALTER LOGIN sql_consulta WITH DEFAULT_DATABASE = AdventureWorks2014;
GO

-- Crear el usuario en la base de datos AdventureWorks
USE AdventureWorks2014;
GO
CREATE USER sql_consulta FOR LOGIN sql_consulta;
GO

DENY SELECT, INSERT, UPDATE, DELETE ON sql_personas TO sql_personas;
GO

-- Conceder permisos SELECT en todas las tablas de AdventureWorks al usuario sql_consulta
GRANT SELECT ON SCHEMA::dbo TO sql_consulta;
GO

SELECT TOP 10 * FROM Person.Person;
DELETE FROM Person.Person WHERE BusinessEntityID = 1;

/* sql_personas
1. Crear el usuario sql_personas.
2. Este usuario sólo podrá consultar las tablas de esquema Person y no podrá 
consultar ninguna otra tabla.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- Select * from Production.Culture */

CREATE LOGIN sql_personas WITH PASSWORD = '1234';
GO
ALTER LOGIN sql_personas WITH DEFAULT_DATABASE = AdventureWorks2014;
GO
USE AdventureWorks2014;
GO
CREATE USER sql_personas FOR LOGIN sql_personas;
GO
DENY SELECT, INSERT, UPDATE, DELETE ON sql_personas TO sql_personas;
GO
GRANT SELECT ON SCHEMA::Person TO sql_personas;
GO

/* sql_dba
1. Crear el usuario sql_dba. Utilizará las políticas de claves de Windows 
Policies.
2. El usuario será dba de todas las bases de datos contenidas dentro de la 
instancia de SQLServer.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- alter database adventureworks set offline
- alter database adventureworks set online
Nota: Refrescar la base de datos para verificar las opciones de offline y 
online. */

CREATE LOGIN sql_dba FROM WINDOWS;
CREATE USER sql_dba FOR LOGIN sql_dba;
ALTER ROLE db_owner ADD MEMBER sql_dba;

/* sql_oper
4. Crear el usuario sql_oper. Utilizará las políticas de claves de Windows 
Policies.
5. El usuario será de operaciones y podrá realizar ejecución de procesos y 
además recuperar y backupear base de datos.
6. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- BACKUP DATABASE AdventureWorks TO DISK='C:\AdventureWorks.bak'
- BACKUP DATABASE Model TO DISK='C:\Model.bak'*/

CREATE LOGIN sql_oper FROM WINDOWS;
CREATE USER sql_oper FOR LOGIN sql_oper; 
ALTER ROLE db_backupoperator ADD MEMBER sql_oper

/*sql_app1…3
1. Crear los usuarios sql_app1..3. No expirará su password.
2. Los usuario serán de la aplicación y sólo deberá poder ejecutar los stored 
procedures de la base de datos Adventureworks
3. Dado que tenemos varios usuarios con los mismos permisos, crear un nuevo 
role llamado rol_exec y asignar este role a cada usuario.
4. Loguearse con dichos usuarios y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- exec uspGetBillOfMaterials 765,'20000901'
*/

CREATE LOGIN sql_app1 WITH PASSWORD = 'Pa$$w0rd';
CREATE USER sql_app1 FOR LOGIN sql_app1; 
ALTER LOGIN sql_app1 WITH DEFAULT_DATABASE = AdventureWorks2014;
GO
CREATE LOGIN sql_app2 WITH PASSWORD = 'Pa$$w0rd';
CREATE USER sql_app2 FOR LOGIN sql_app2; 
ALTER LOGIN sql_app2 WITH DEFAULT_DATABASE = AdventureWorks2014;
GO
CREATE LOGIN sql_app3 WITH PASSWORD ='Pa$$w0rd';
CREATE USER sql_app3 FOR LOGIN sql_app3; 
ALTER LOGIN sql_app3 WITH DEFAULT_DATABASE = AdventureWorks2014;
GO

CREATE ROLE rol_execution;
GRANT EXECUTE TO rol_execution;

EXEC sp_addrolemember 'rol_execution', 'sql_app1';
EXEC sp_addrolemember 'rol_execution', 'sql_app2';
EXEC sp_addrolemember 'rol_execution', 'sql_app3';

ALTER LOGIN [sql_app1] WITH CHECK_EXPIRATION=OFF;
ALTER LOGIN [sql_app2] WITH CHECK_EXPIRATION=OFF;
ALTER LOGIN [sql_app3] WITH CHECK_EXPIRATION=OFF;

/* sql_imple
1. Crear el usuario sql_imple.
2. El usuario sólo se encargará de implementar los scripts en la base de datos. 
Es decir, realizará la creación de todos los objetos o modificación de los 
existentes, pero no podrá ver los datos.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para 
verificar los permisos:
- Select top 10 * from Person.Contact
- create table test (campo1 int)
- drop table test
- create procedure sp_test as select 1
- drop procedure sp_test */

CREATE LOGIN sql_imple WITH PASSWORD = '1234';
CREATE USER sql_imple FOR LOGIN sql_imple; 
ALTER ROLE db_ddladmin ADD MEMBER sql_imple;
EXEC sp_addrolemember 'db_ddladmin', 'sql_imple';

/*14.Se desea enmascarar el NationalIDNumbre de cada empleado, de la 
siguiente forma ###-####-##: ID, Numero, Enmascarado -> 36, 113695504, 113-6955-04 */

SELECT e.BusinessEntityID AS 'ID', e.NationalIDNumber AS 'Numero',
CONCAT(SUBSTRING(e.NationalIDNumber, 1, 3), '-', SUBSTRING(e.NationalIDNumber, 4, 4), '-', SUBSTRING(e.NationalIDNumber, 8, 2))
FROM HumanResources.Employee e;
