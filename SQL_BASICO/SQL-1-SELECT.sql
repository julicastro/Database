CREATE DATABASE IF NOT EXISTS  bd1_ejercicio_1_select;
USE bd1_ejercicio_1_select;

CREATE TABLE IF NOT exists fabricante (
		codigo int(10) PRIMARY KEY NOT NULL, 
        nombre varchar(30) NOT NULL
);

CREATE TABLE IF NOT exists producto (
	codigo int(10) PRIMARY KEY NOT NULL,
    nombre varchar(100) NOT NULL,
    precio double NOT NULL,
    codigo_fabricante int(10) NOT NULL,
    FOREIGN KEY (codigo_fabricante) REFERENCES fabricante(codigo)
);

INSERT into fabricante (codigo, nombre) values 
    (1, "Adidas"), 
    (2, "Nike"),
    (3, "Puma");
    
INSERT into fabricante (codigo, nombre) values 
    (4, "Fender"), 
    (5, "Gibson");
    
INSERT into fabricante (codigo, nombre) values 
    (7, ""), 
    (8, "");

INSERT into producto (codigo, nombre, precio, codigo_fabricante) values 
    (1, "producto1", 2000.000, 2), 
    (2, "producto2", 2020.000, 3),
    (3, "producto3", 1570.000, 2),
    (4, "producto4", 1350.000, 1),
    (5, "producto5", 1146.000, 3),
    (6, "producto6", 5222.000, 1);
    
INSERT into producto (codigo, nombre, precio, codigo_fabricante) values 
    (7, "productoESA", 2000.000, 2), 
    (8, "productoESA2", 1570.000, 2),
	(9, "producto2ESA", 1570.000, 2);  
    
UPDATE producto SET nombre = "Almendra" WHERE codigo = 4;
UPDATE producto SET nombre = "Alaska" WHERE codigo = 8;
    
#1) LISTAR NOMBRES Y PRECIOS DE TODOS LOS PRODUCTOS
SELECT nombre, precio FROM producto;

#2) LISTA TODAS LAS COLUMNAS DE LA TABLA PRODUCTO 
SELECT * FROM producto;
SELECT * FROM fabricante;

#3) Lista el nombre de los productos, el precio en euros y el precio en dólares estadounidenses (USD).
SELECT p.nombre, CAST(p.precio / 117 AS DECIMAL(20,2)) AS precio_dolar, CAST(p.precio / 122 AS DECIMAL(20,2)) AS precio_euro FROM producto p;
SELECT p.nombre, p.precio / 117 AS precio_dolar, p.precio / 122 AS precio_euro FROM producto p;
SELECT NOMBRE, PRECIO as PRECIO_ARS, TRUNCATE((PRECIO/117), 2) AS PRECIO_USD, TRUNCATE((PRECIO/122), 2) AS PRECIO_EUROS FROM PRODUCTO;

#4) Lista los nombres y los precios de todos los productos de la tabla producto, que terminen con las letras ESA.
SELECT p.nombre, p.precio FROM producto p WHERE p.nombre LIKE '%ESA';

#5) Lista los nombres y los precios de todos los productos de la tabla producto, que comiencen con A.
SELECT p.nombre, p.precio FROM producto p WHERE p.nombre LIKE 'A%';

#6) Lista el nombre de todos los fabricantes en una columna, y en otra columna obtenga en mayúsculas los dos primeros caracteres del nombre del fabricante. 
SELECT f.nombre AS fabricantes, UPPER(left(f.nombre, 2)) AS iniciales FROM fabricante f;
-- opcion 1: UPPER(SUBSTRING(nombre, 1, 2)) AS ABREV, 
-- opcion 2: UPPER(LEFT(nombre, 2)) AS ABREV_LEFT, 
-- opcion 3: SUBSTRING(UPPER(NOMBRE), 1, 2) AS OPCION3

#7) Lista los nombres y los precios de todos los productos de la tabla producto, redondeando el valor del precio.
SELECT p.nombre, ROUND(p.precio, 4) AS precio_redondo FROM producto p;

#8) Lista los nombres y los precios de todos los productos de la tabla producto, truncando el valor del precio para mostrarlo sin ninguna cifra decimal.
SELECT p.nombre, TRUNCATE(p.precio, 0) AS precio_sin_decimal FROM producto p;

#9) Lista el código de los fabricantes que tienen productos en la tabla producto. 
SELECT DISTINCT codigo_fabricante FROM producto;
# se usa para obtener valores distintos. 

#10) Lista los nombres de los fabricantes ordenados de forma ascendente 
SELECT nombre FROM fabricante ORDER BY nombre; #ASC

#11) Lista los nombres de los fabricantes ordenados de forma descendente 
SELECT nombre FROM fabricante ORDER BY nombre DESC;

#12) Lista los nombres de los productos ordenados en primer lugar por el nombre de forma ascendente y en segundo lugar por el precio de forma descendente.
SELECT p.nombre, p.precio FROM producto p ORDER BY p.nombre, p.precio DESC;

#13) Devuelve una lista con las 5 primeras filas de la tabla fabricante. SELECT *
SELECT * FROM fabricante LIMIT 5;

#14) Lista el nombre y el precio del producto más barato. (Utilice solamente las cláusulas ORDER BY y LIMIT 1)
SELECT p.nombre, p.precio FROM producto p ORDER BY p.precio ASC LIMIT 1;

#15) Lista el nombre y el precio del producto más caro. (Utilice solamente las cláusulas ORDER BY y LIMIT 1)
SELECT p.nombre, p.precio FROM producto p ORDER BY p.precio DESC LIMIT 1;

#16) Lista el nombre de todos los productos del fabricante cuyo código de fabricante es igual a 2.
SELECT p.nombre, p.codigo_fabricante FROM producto p WHERE codigo_fabricante = 2;

#17) Lista el nombre de los productos que tienen un precio menor o igual a 1€. 
SELECT p.nombre, p.precio / 122 AS precio_euro FROM producto p WHERE (p.precio / 122) <= 1;

#18) Lista todos los productos que tengan un precio entre 1€ y 3€. Sin utilizar el operador BETWEEN.
SELECT p.nombre, p.precio / 122 AS precio_euro FROM producto p WHERE (p.precio / 122) <= 1 AND (p.precio / 122) <= 3;

#19) Lista todos los productos que tengan un precio entre 1€ y 3€. Utilizando el operador BETWEEN.
SELECT p.nombre, p.precio / 122 AS precio_euro FROM producto p WHERE (p.precio / 122) BETWEEN 1 AND 3;

#20) Lista todos los productos que tengan un precio mayor que 2€ y que el código de fabricante sea igual a 004.
SELECT * FROM producto p WHERE (p.precio / 122) <= 2 AND p.codigo_fabricante > 2;

#21) Lista todos los productos donde el código de fabricante sea 1, 3 o 5. Sin utilizar el operador IN.
SELECT * FROM producto p WHERE p.codigo_fabricante = 1 OR p.codigo_fabricante = 3 OR p.codigo_fabricante = 5;

#22) Lista todos los productos donde el código de fabricante sea 1, 3 o 5. Utilizando el operador IN.
SELECT * FROM producto p WHERE p.codigo_fabricante IN (1,3,5);

#23) Lista el nombre y el precio de los productos en céntimos (Habrá que multiplicar por 100 el valor del precio). Cree un alias para la columna que contiene el precio que se llame céntimos.
SELECT p.nombre, (p.precio * 100) AS centimos FROM producto p;

#24) Lista los nombres de los fabricantes cuyo nombre empiece por la letra L 
SELECT f.nombre FROM fabricante f WHERE f.nombre LIKE 'P%';

#25) Lista los nombres de los fabricantes cuyo nombre termine por la vocal O. 
SELECT f.nombre FROM fabricante f WHERE f.nombre LIKE '%N';

#26) Lista los nombres de los fabricantes cuyo nombre contenga el carácter H. 
SELECT f.nombre FROM fabricante f WHERE f.nombre LIKE '%N%';

#27) Lista los códigos de los fabricantes cuyo nombre este vacio 
SELECT f.codigo FROM fabricante f WHERE f.nombre IS NULL;

#28) Devuelve una lista con el nombre de todos los productos que contienen la cadena 'Mayo' en el nombre.
SELECT p.nombre FROM producto p WHERE p.nombre LIKE '%ESA%';

#29) Devuelve una lista con el nombre de todos los productos que contienen la cadena 'Ket' en el nombre y tienen un precio inferior a 200(ARS).
SELECT p.nombre FROM producto p WHERE p.nombre LIKE '%ESA%' AND precio < 1600;

#30) Lista el nombre y el precio de todos los productos que tengan un precio mayor o igual a 180ARS. Ordene el resultado en primer lugar por el precio (en orden descendente) y en segundo lugar por el nombre (en orden ascendente)
SELECT p.nombre, p.precio FROM producto p WHERE precio < 180 ORDER BY p.precio DESC, p.nombre; #ASC

#DROP DATABASE IF EXISTS bd1_unlam;