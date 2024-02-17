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

-- crear trigger para tabla de auditorioa



