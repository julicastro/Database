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

SELECT ROUND(385.86, 1) AS 'Numero Redondeado'; -- LA MAS ADECUADA
SELECT ROUND(CONVERT(DOUBLE PRECISION, 385.86),1)  AS 'Numero Redondeado';

/* 5. Realizar una consulta permita saber cuánto es el mes actual al cuadrado. Por 
ejemplo, si estamos en Junio, sería 6 a la 2 */

SELECT POWER(MONTH(GETDATE()), 2) AS 'Mes al cuadrado';

/* 6. Devolver cuál es el usuario que se encuentra conectado a la base de datos */
SELECT SYSTEM_USER;

/* 7. Realizar una consulta que permita conocer la edad de cada empleado 
(Ayuda: HumanResources.Employee) */
SELECT DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS 'Edad'
	FROM HumanResources.Employee e;

/* 8. Realizar una consulta que retorne la longitud de cada apellido de los 
Contactos, ordenados por apellido. En el caso que se repita el apellido 
devolver únicamente uno de ellos. Por ejemplo, Apellido, Longitud ->
Abel, 4*/


SELECT DISTINCT p.LastName AS 'Apellido', LEN(p.LastName) AS 'Longitud'
	FROM Person.Person p
	ORDER BY p.LastName ASC;

/* 9. Realizar una consulta que permita encontrar el apellido con mayor longitud. */

SELECT MAX(LEN(p.LastName)) AS 'Mayor Longitud'
	FROM Person.Person p;

SELECT DISTINCT LastName AS 'Apellido'
FROM Person.Person
WHERE LEN(LastName)=(
	SELECT MAX(LEN(LastName))
	FROM Person.Person 
);

SELECT TOP 1 LastName AS 'Apellido', LEN(LastName) AS 'Mayor Longitud'
FROM Person.Person
ORDER BY LEN(LastName) DESC;

/* 10.Realizar una consulta que devuelva los nombres y apellidos de los contactos 
que hayan sido modificados en los últimos 3 años.*/