USE AdventureWorks2014;

/* 1. Crear la base de datos MusicaDB a través del siguiente script: */

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

/*2. Responder la siguientes preguntas verificando cómo ha quedado la base de 
datos creada: 
2.1. ¿Qué se ha definido como política de retención de log? 
2.2. ¿Se crearán estadísticas automáticamente? 
2.3. ¿Será compatible con una base de datos de SQL Server 2000? 
2.4. ¿Cuál es el juego de caracteres que se utilizará y qué significa?*/
-- RESPONDIDO EN EL WORD

/* 3. Crear el esquema discos. */
CREATE SCHEMA Discos; 

/* 4. Se desea crear el siguiente modelo relacional. Recordar que se deben crear 
cada una de las tablas involucradas y de sus relaciones.*/

