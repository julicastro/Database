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
que hayan sido modificados en los últimos 9 años.*/

SELECT FirstName AS 'Nombre',LastName AS 'Apellido'
FROM Person.Person
WHERE DATEDIFF(YEAR, ModifiedDate, getDate()) <= 9;

/* 11.Se quiere obtener los emails de todos los contactos, pero en mayúscula. */

SELECT pp.FirstName, UPPER(ea.EmailAddress)
	FROM Person.Person pp
	JOIN Person.EmailAddress ea
	ON pp.BusinessEntityID = ea.BusinessEntityID;

/*12.Realizar una consulta que permita particionar el mail de cada contacto, 
obteniendo lo siguiente: IDContacto email nombre Dominio ->
1 juanp@ibm.com juanp ibm */

SELECT pp.BusinessEntityID, ea.EmailAddress,
	SUBSTRING(ea.EmailAddress, 1, CHARINDEX('@', ea.EmailAddress) -1) AS 'nombre',
	SUBSTRING(ea.EmailAddress, CHARINDEX('@', ea.EmailAddress) + 1, LEN(ea.EmailAddress)- CHARINDEX('@', ea.EmailAddress)) AS 'Dominio'
	FROM Person.Person pp
	JOIN Person.EmailAddress ea
	ON pp.BusinessEntityID = ea.BusinessEntityID;

SELECT pp.BusinessEntityID, ea.EmailAddress,
	SUBSTRING(ea.EmailAddress, 1, CHARINDEX('@', ea.EmailAddress) -1) AS 'nombre',
	REPLACE(SUBSTRING(ea.EmailAddress, CHARINDEX('@', ea.EmailAddress) + 1, LEN(ea.EmailAddress)- CHARINDEX('@', ea.EmailAddress)), '.com', '') AS 'Dominio'
	FROM Person.Person pp
	JOIN Person.EmailAddress ea
	ON pp.BusinessEntityID = ea.BusinessEntityID;

/* 13. Devolver los últimos 3 dígitos del NationalIDNumber de cada empleado*/ 

SELECT RIGHT(e.NationalIDNumber, 3) AS 'Ultimos 3 Digitos'
FROM HumanResources.Employee e;

/*14.Se desea enmascarar el NationalIDNumbre de cada empleado, de la 
siguiente forma ###-####-##: ID, Numero, Enmascarado -> 36, 113695504, 113-6955-04 */

SELECT e.BusinessEntityID AS 'ID', e.NationalIDNumber AS 'Numero',
CONCAT(SUBSTRING(e.NationalIDNumber, 1, 3), '-', SUBSTRING(e.NationalIDNumber, 4, 4), '-', SUBSTRING(e.NationalIDNumber, 8, 2))
FROM HumanResources.Employee e;

SELECT NationalIDNumber AS 'Telefono',
	CASE LEN(NationalIDNumber) WHEN 9 
		THEN
			CONCAT(SUBSTRING(e.NationalIDNumber, 1, 3), '-', SUBSTRING(e.NationalIDNumber, 4, 4) , '-', SUBSTRING(e.NationalIDNumber, 8, 2))
		ELSE
			SUBSTRING(NationalIDNumber,1,3) + '-' +
			SUBSTRING(NationalIDNumber,4,LEN(NationalIDNumber))	
	END	AS 'Enmascarado' 
	FROM HumanResources.Employee e;	

/* 15. Listar la dirección de cada empleado “supervisor” que haya nacido hace más 
de 30 años. Listar todos los datos en mayúscula. Los datos a visualizar son: 
nombre y apellido del empleado, dirección y ciudad. */
