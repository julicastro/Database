USE AdventureWorks2014;

-- 1. Realizar una consulta que permita devolver la fecha y hora actual
SELECT CONVERT(date, GETDATE(), 103) AS 'Fecha Actual', 
	   FORMAT(GETDATE(), 'HH:mm:ss')  AS 'Hora Actual';

-- 2. Realizar una consulta que permita devolver �nicamente el a�o y mes actual: 
SELECT FORMAT(GETDATE(), 'yyyy') AS 'A�o Actual', FORMAT(GETDATE(), 'MM') AS 'Mes Actual';
SELECT YEAR(getDate()) AS 'A�o', MONTH(getDate()) AS 'Mes', DAY(getDate()) AS 'D�a';

/* 3. Realizar una consulta que permita saber cu�ntos d�as faltan para el d�a de la 
primavera (21-Sep) */

SELECT DATEDIFF(DAY, GETDATE(), '2024-09-21') AS 'Faltan para la primavera';

/*4. Realizar una consulta que permita redondear el n�mero 385,86 con 
�nicamente 1 decimal.*/


