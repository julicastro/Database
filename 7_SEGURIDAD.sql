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
