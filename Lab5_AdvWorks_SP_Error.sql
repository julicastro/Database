USE AdventureWorks2014;

/* 1- p_InsertaDatos(): Realizar un sp que permita insertar números pares del 
2 al 20 en una tabla con el nombre dbo.NumeroPar (nro smallint), excepto 
los números 10 y 16. La tabla debe ser creada fuera del procedimiento.
Controlar los errores que pudieran sucederse. */

CREATE TABLE dbo.NumeroPar(
	nro smallint
)

IF OBJECT_ID('p_InsertaDatos', 'P') IS NOT NULL -- P = tipo de objeto. en este caso procedure 
    DROP PROCEDURE p_InsertaDatos;
GO

CREATE PROCEDURE p_InsertaDatos
AS
BEGIN
    BEGIN TRY
        DELETE FROM dbo.NumeroPar;
        DECLARE @Numero INT = 2;
        WHILE @Numero <= 20
        BEGIN
            IF @Numero NOT IN (10, 16)
                INSERT INTO dbo.NumeroPar (nro) VALUES (@Numero);
            SET @Numero = @Numero + 2;
        END
        PRINT 'Datos insertados correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

EXEC p_InsertaDatos;

SELECT * FROM dbo.NumeroPar;

/* 2- p_InsertaDatos2(nro): Realiza un sp que inserte a la tabla 
dbo.NumeroPar el número ingresado por parámetro, pero sólo se deberá 
insertar si el número es par. De lo contrario lanzar una excepción. */

DROP PROCEDURE p_InsertaDatos2;

CREATE PROCEDURE p_InsertaDatos2
	@p_numero smallint
AS 
BEGIN 
	BEGIN TRY
		IF @p_numero % 2 = 0 AND @p_numero NOT IN (SELECT nro FROM dbo.NumeroPar)
			BEGIN 
				INSERT INTO dbo.NumeroPar (nro) VALUES (@p_numero);	
				PRINT 'El numero ' + CAST(@p_numero as VARCHAR) + ' se insertó correctamente';
			END
		ELSE 
			PRINT 'El numero no es par o ya existe';
	END TRY
	BEGIN CATCH
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH
END; 

EXEC p_InsertaDatos2 24;

SELECT * FROM dbo.NumeroPar;

/* 3- p_MuestraNroPares(): Realizar un sp que devuelva los registros 
insertados en los ítems anteriores. En el caso de que la tabla esté vacía 
lanzar una excepción indicando dicho error. */
