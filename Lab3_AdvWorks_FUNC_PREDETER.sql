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

SELECT ROUND(385.86, 1) AS 'Numero Redondeado'; -- LA MAS ADECUADA
SELECT ROUND(CONVERT(DOUBLE PRECISION, 385.86),1)  AS 'Numero Redondeado';

/* 5. Realizar una consulta permita saber cu�nto es el mes actual al cuadrado. Por 
ejemplo, si estamos en Junio, ser�a 6 a la 2 */

SELECT POWER(MONTH(GETDATE()), 2) AS 'Mes al cuadrado';

/* 6. Devolver cu�l es el usuario que se encuentra conectado a la base de datos */
SELECT SYSTEM_USER;

/* 7. Realizar una consulta que permita conocer la edad de cada empleado 
(Ayuda: HumanResources.Employee) */

SELECT DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS 'Edad'
	FROM HumanResources.Employee e;

/* 8. Realizar una consulta que retorne la longitud de cada apellido de los 
Contactos, ordenados por apellido. En el caso que se repita el apellido 
devolver �nicamente uno de ellos. Por ejemplo, Apellido, Longitud ->
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
que hayan sido modificados en los �ltimos 9 a�os.*/

SELECT FirstName AS 'Nombre',LastName AS 'Apellido'
FROM Person.Person
WHERE DATEDIFF(YEAR, ModifiedDate, getDate()) <= 9;

/* 11.Se quiere obtener los emails de todos los contactos, pero en may�scula. */

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

/* 13. Devolver los �ltimos 3 d�gitos del NationalIDNumber de cada empleado*/ 

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

/* 15. Listar la direcci�n de cada empleado �supervisor� que haya nacido hace m�s 
de 30 a�os. Listar todos los datos en may�scula. Los datos a visualizar son: 
nombre y apellido del empleado, direcci�n y ciudad. */
