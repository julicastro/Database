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
