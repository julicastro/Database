USE AdventureWorks2014;

/* 1. Crear la base de datos MusicaDB a trav�s del siguiente script: */

CREATE DATABASE MusicaDB 
ON PRIMARY
(
	NAME = 'Musica',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Musica.mdf',
	SIZE = 4096KB,
	MAXSIZE = 20480KB,
	FILEGROWTH= 1024KB
)
LOG ON
(
	NAME = 'Musica_log',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Musica_log_ldf',
	SIZE = 2048KB,
	MAXSIZE = 10240KB,
	FILEGROWTH= 10%
)

SELECT * FROM sys.databases WHERE name = 'MusicaDB';

/*2. Responder la siguientes preguntas verificando c�mo ha quedado la base de 
datos creada: 
2.1. �Qu� se ha definido como pol�tica de retenci�n de log? 
2.2. �Se crear�n estad�sticas autom�ticamente? 
2.3. �Ser� compatible con una base de datos de SQL Server 2000? 
2.4. �Cu�l es el juego de caracteres que se utilizar� y qu� significa?*/
-- RESPONDIDO EN EL WORD

/* 3. Crear el esquema discos. */
CREATE SCHEMA Discos; 

/* 4. Se desea crear el siguiente modelo relacional. Recordar que se deben crear 
cada una de las tablas involucradas y de sus relaciones.*/

