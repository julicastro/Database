USE AdventureWorks2014;
USE Northwind;

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
		IF @Provincia = 'Chaco'
		BEGIN
			UPDATE EmpleadoChaco
			SET ec.nombre = i.nombre
			FROM EmpleadoChaco ec
			JOIN INSERTED i 
			ON i.id = ec.id
			WHERE i.provincia = 'Chaco';
		END
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