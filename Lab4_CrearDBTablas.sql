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
-- CREATE SCHEMA Discos; 

/* 4. Se desea crear el siguiente modelo relacional. Recordar que se deben crear 
cada una de las tablas involucradas y de sus relaciones.*/

CREATE TABLE Discos.Artista( 
	artno smallint NOT NULL, 
	nombre varchar(50) NULL, 
	clasificacion char(1) NULL, 
	bio text NULL, 
	foto image null, 
	CONSTRAINT PK_Artista PRIMARY KEY CLUSTERED (artno) 
);

CREATE TABLE Discos.Concierto(
	artno smallint not null,
	fecha datetime not null,
	ciudad varchar(25) not null,
	CONSTRAINT PK_Concierto PRIMARY KEY CLUSTERED (fecha), 
	CONSTRAINT FK_Concierto_Artista FOREIGN KEY (artno) REFERENCES Discos.Artista(artno)
);

CREATE TABLE Discos.Album (
	titulo VARCHAR(50) not null,
	artno smallint not null,
	itemno smallint not null,
	CONSTRAINT PK_Album PRIMARY KEY CLUSTERED (itemno), 
	CONSTRAINT FK_Album_Artista FOREIGN KEY (artno) REFERENCES Discos.Artista(artno)
);

CREATE TABLE Discos.Stock (
    itemno smallint not null,
    tipo char(1) null,
    precio decimal(5, 2) null,
    cantidad int null,
    CONSTRAINT PK_Stock PRIMARY KEY CLUSTERED (itemno), 
    CONSTRAINT FK_Stock_Album FOREIGN KEY (itemno) REFERENCES Discos.Artista(artno)
);

CREATE TABLE Discos.Orden(
	itemno smallint not null,
	timestamp timestamp null,
	CONSTRAINT PK_Orden PRIMARY KEY CLUSTERED (itemno), 
    CONSTRAINT FK_Orden_Stock FOREIGN KEY (itemno) REFERENCES Discos.Artista(artno)
)

/* 6. Realizar los siguientes cambios en el modelo: 
6.1. Cambiar el tamaño de campo ciudad en la tabla ciudad para que sea de 
30 en lugar de 25. 
6.2. En la tabla de Stock, colocar el precio con un valor por defecto en 0 
(cero). 
6.3. En la tabla de álbumes el nombre del título no puede ser nulo. */

