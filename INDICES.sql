USE AdventureWorks2014;

-- Crea un �ndice en una tabla. se permiten valores duplicados:
CREATE INDEX index_name
ON table_name (column1, column2, ...);
-- Crea un �ndice �nico en una tabla. Los valores duplicados no est�npermitidos:
CREATE UNIQUE INDEX index_name
ON table_name (column1, column2, ...);
-- Create a single nonclustered index
CREATE UNIQUE NONCLUSTERED INDEX IX_NC_PresidentNumber
ON dbo.Presidents (PresidentNumber) 
-- specify table and column name


CREATE TABLE empTest1 ( 
	empId INT, 
	empNombre VARCHAR(1000));

/* vemos q no tiene ningun indice xq indid es = */
SELECT OBJECT_NAME(i.id) AS Tabla, i.name AS iName, i.indid AS iId
FROM sysindexes i
GO

INSERT INTO empTest1 VALUES(4, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(6, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(1, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(3, REPLICATE ('a', 1000))
GO

/* el select devuelve en el mismo orden insertado */
select * from empTest1;

/* Cada tabla tiene asociada unas p�ginas determinadas para almacenar los datos, para 
saber, que p�ginas tiene asociadas a una tabla, tenemos el siguiente script: */

DBCC TRACEON(3604)-- imprimir la salida en la ventana de consulta
GO
DECLARE @DBID Int, @TableID Int
SELECT @DBID = DB_ID(), @TableID = OBJECT_ID('empTest1')
DBCC ind(@DBID, @TableID, -1)--El comando lista todas las p�ginas que se asignan a un �ndice
GO

/* Seg�n la informaci�n devuelta, no tenemos ninguna p�gina que guarde informaci�n 
de �ndices. Con el PagePID podemos ver que informaci�n tiene almacenada la p�gina. 
Para esto ejecutamos el script: */

DBCC TRACEON (3604)
GO
Declare @DBID Int
Select @DBID = db_id()
DBCC page(@DBID, 1, 9653, 3)
GO

/* Creaci�n de un �ndice Non-Clustered */
CREATE UNIQUE NONCLUSTERED INDEX empTest1_empId
ON empTest1(empId)
GO

/* Volvamos a listar las p�ginas asociadas, mediante DBCC ind, para ver si ha habido 
alguna modificaci�n en las p�ginas asociadas a la tabla */

DBCC TRACEON (3604) 
GO
Declare @DBID Int, @TableID Int
Select @DBID = db_id(), @TableID = object_id('empTest1')
DBCC ind(@DBID, @TableID, -1)
GO

/* Aparecen dos registros nuevos. Las dos primeras p�ginas son las mismas que 
cuando no ten�amos �ndices asociados, las dos �ltimas contienen toda la informaci�n 
del �ndice. Mediante el IndexID = 2, sabemos que se trata de un �ndice Non-Clustered. 
Podemos ver el contenido de cada p�gina, como hemos anteriormente, con el 
comando DBCC page y el PagePID*/

DBCC TRACEON (3604) 
GO
Declare @DBID Int
Select @DBID = db_id()
DBCC page(@DBID, 1, 9655, 3)
GO

/* En la p�gina 9653, no hemos sufrido ninguna modificaci�n, es decir el orden de los 
datos viene dado por su inserci�n. En la p�gina 9655, encontramos la informaci�n 
ordenada por el �ndice (empId). */

INSERT INTO empTest1 VALUES(8, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(7, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(2, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(10, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(5, REPLICATE ('a', 1000))
GO
INSERT INTO empTest1 VALUES(9, REPLICATE ('a', 1000))
GO

/* A�adiremos una nueva columna, sobre la que crearemos un CLUSTERED Index. En 
una misma tabla tenemos un �ndice Clustered y Non-Clustered.
*/
ALTER TABLE empTest1 ADD EmpIndex Int IDENTITY(1,1)
GO
CREATE UNIQUE CLUSTERED INDEX clust_emp ON empTest1 (EmpIndex)
GO

/* Al crear un CLUSTERED Index, la estructura de p�ginas asociada a la tabla ha sido 
modificada, para verlo ejecutamos: */
DBCC TRACEON (3604) 
GO
Declare @DBID Int, @TableID Int
Select @DBID = db_id(), @TableID = object_id('empTest1')
DBCC ind(@DBID, @TableID, -1)
GO

/* Para ver mejor los Clustered Index, crearemos otra tabla e insertaremos registros en 
en ella. */
CREATE TABLE empTest2 (
 EmpId INT,
 EmpName VARCHAR(1000)
)
GO
INSERT INTO empTest2 VALUES (4, REPLICATE('a', 1000))
GO
INSERT INTO empTest2 VALUES (6, REPLICATE('a', 1000))
GO
INSERT INTO empTest2 VALUES (1, REPLICATE('a', 1000))
GO
INSERT INTO empTest2 VALUES (3, REPLICATE('a', 1000))
GO

/* Al no tener ning�n indice, SQL Server almacenar� los registros en el mismo orden en 
que han sido insertado. Si mostramos las p�ginas asociadas a esta tabla: */
DBCC TRACEON (3604)
GO
Declare @DBID Int, @TableID Int
Select @DBID = db_id(), @TableID = object_id('empTest2')
DBCC ind(@DBID, @TableID, -1)
GO

