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
    CONSTRAINT FK_Stock_Album FOREIGN KEY (itemno) REFERENCES Discos.Album(itemno)
);

CREATE TABLE Discos.Orden(
	itemno smallint not null,
	timestamp timestamp null,
	CONSTRAINT PK_Orden PRIMARY KEY CLUSTERED (itemno), 
    CONSTRAINT FK_Orden_Stock FOREIGN KEY (itemno) REFERENCES Discos.Stock(itemno)
)


/* 6. Realizar los siguientes cambios en el modelo: */
/* 6.1. Cambiar el tamaño de campo ciudad en la tabla ciudad para que sea de 
30 en lugar de 25. */

ALTER TABLE Discos.Concierto
	ALTER COLUMN ciudad varchar(30);

/* 6.2. En la tabla de Stock, colocar el precio con un valor por defecto en 0 
(cero). */

ALTER TABLE Discos.Stock
	ADD CONSTRAINT df_precio
	DEFAULT 0 FOR precio;

/* obtener todos los datos de la columna de una tabla */ 
SELECT *
	FROM sys.columns
	WHERE object_id = OBJECT_ID('Discos.Stock');

/* 6.3. En la tabla de álbumes el nombre del título no puede ser nulo. */
ALTER TABLE Discos.Album
	ALTER COLUMN titulo varchar(50) not null;

/* 7. Agregar los siguientes registros dentro de la base de datos creada: 
- 3 artistas 
- 2 conciertos por cada uno de los artistas en diferentes fechas y ciudades 
- 2 álbumes por cada uno de los artistas 
- Stock sólo de 2 álbumes de diferentes artistas */

INSERT INTO Discos.Artista (artno, nombre, clasificacion, bio, foto) VALUES (1, 'Juan Carlos', 'R', 'Es un fenomeno', null);
INSERT INTO Discos.Artista (artno, nombre, clasificacion, bio, foto) VALUES (2, 'Lionel Messi', 'H', 'Un maestro total', null);
INSERT INTO Discos.Artista (artno, nombre, clasificacion, bio, foto) VALUES (3, 'Carol Sanchez', 'P', 'Na es tremendo', null);

INSERT INTO Discos.Concierto (artno, fecha, ciudad)
VALUES 
    (1, '2024-07-15', 'Haedo'),
    (1, '2024-08-20', 'Morón'),
    (2, '2024-09-10', 'Castelar'),
    (2, '2024-10-05', 'Ituzaingó'),
    (3, '2024-11-15', 'Ramos Mejía'),
    (3, '2024-12-02', 'San Justo');

INSERT INTO Discos.Album (titulo, artno, itemno)
VALUES 
    ('Álbum1_Artista1', 1, 1),
    ('Álbum2_Artista1', 1, 2),
    ('Álbum1_Artista2', 2, 3),
    ('Álbum2_Artista2', 2, 4),
    ('Álbum1_Artista3', 3, 5),
    ('Álbum2_Artista3', 3, 6);

INSERT INTO Discos.Stock (itemno, tipo, precio, cantidad)
VALUES 
    (1, 'A', 10.99, 50),
    (2, 'B', 15.99, 30),
    (3, 'C', 12.99, 40),
    (4, 'D', 18.99, 20),
    (5, 'E', 14.99, 45),
    (6, 'F', 20.99, 25);
