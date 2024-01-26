USE AdventureWorks2014;

-- 1. Realizar una consulta que permita devolver la fecha y hora actual
SELECT CONVERT(date, GETDATE(), 103) AS 'Fecha Actual', 
	   FORMAT(GETDATE(), 'HH:mm:ss')  AS 'Hora Actual';

-- 2. Realizar una consulta que permita devolver únicamente el año y mes actual: 
SELECT FORMAT(GETDATE(), 'yyyy') AS 'Año Actual', FORMAT(GETDATE(), 'MM') AS 'Mes Actual';
SELECT YEAR(getDate()) AS 'Año', MONTH(getDate()) AS 'Mes', DAY(getDate()) AS 'Día';

/* 3. Realizar una consulta que permita saber cuántos días faltan para el día de la 
primavera (21-Sep) */

SELECT DATEDIFF(DAY, GETDATE(), '2024-09-21') AS 'Faltan para la primavera';

/*4. Realizar una consulta que permita redondear el número 385,86 con 
únicamente 1 decimal.*/


