CREATE DATABASE IF NOT EXISTS  bd1_ejercicio_2_multitabla;
USE bd1_ejercicio_2_multitabla;

CREATE TABLE ALMACEN(
Nro INT(5) PRIMARY KEY,
Responsable VARCHAR(50) NOT NULL);

CREATE TABLE ARTICULO(
CodArt INT(5) PRIMARY KEY,
Descripcion VARCHAR (50) NOT NULL,
Precio DOUBLE);

CREATE TABLE MATERIAL(
CodMat INT(6) PRIMARY KEY,
Descripcion VARCHAR(100) NOT NULL);

CREATE TABLE CIUDAD(
CodCiudad INT(2) PRIMARY KEY, 
Nombre VARCHAR(100) NOT NULL);

CREATE TABLE PROVEEDOR(
CodProv INT(5) PRIMARY KEY,
Nombre VARCHAR(20) NOT NULL,
Domicilio VARCHAR(100),
CodCiudad INT(2) NOT NULL,
FOREIGN KEY (CodCiudad) REFERENCES Ciudad (CodCiudad));

CREATE TABLE CONTIENE(
Cod_Contiene INT(3) PRIMARY KEY AUTO_INCREMENT,
Nro INT(5) NOT NULL,
CodArt INT(5) NOT NULL,
FOREIGN KEY (Nro) REFERENCES ALMACEN (Nro),
FOREIGN KEY (CodArt) REFERENCES ARTICULO (CodArt));

CREATE TABLE COMPUESTO_POR(
Cod_Composicion INT(3) PRIMARY KEY AUTO_INCREMENT,
CodArt INT(5) NOT NULL,
CodMat INT(6) NOT NULL,
FOREIGN KEY (CodArt) REFERENCES ARTICULO (CodArt),
FOREIGN KEY (CodMat) REFERENCES MATERIAL (CodMat));

CREATE TABLE PROVISTO_POR(
Cod_Provisto INT(3) PRIMARY KEY AUTO_INCREMENT,
CodMat INT(6) NOT NULL,
CodProv INT(5) NOT NULL,
FOREIGN KEY (CodMat) REFERENCES MATERIAL (CodMat),
FOREIGN KEY (CodProv) REFERENCES PROVEEDOR (CodProv));

INSERT INTO ALMACEN (Nro, Responsable)
VALUES (001, 'Alfredo'),
(002, 'Esteban'),
(003, 'Juan'),
(004, 'Roberto');

INSERT INTO ARTICULO (CodArt, Descripcion, Precio)
VALUES (001, 'Pan', 130.70),
(002, 'Facturas', 300.00),
(003, 'Cheese Cake', 450.87),
(004, 'Pasta Frola', 278.90);

INSERT INTO MATERIAL (CodMat, Descripcion)
VALUES (001, 'Aceite'),
(002, 'Harina'),
(003, 'Levadura'),
(004, 'Huevo'),
(005, 'Azucar'),
(006, 'Sal'),
(007, 'Agua');

INSERT INTO CIUDAD(CodCiudad, Nombre)
VALUES (1, 'La Plata'),
(2, 'Capital Federal'),
(3, 'Ramos Mejia'),
(4, 'La Matanza');

INSERT INTO PROVEEDOR (CodProv, Nombre, Domicilio, CodCiudad)
VALUES(1, 'Arcor', 'Ayacucho 1234', 1),
(2, 'Molinos', 'Yatay 456', 4),
(3, 'Ledesma', 'Mario Bravo 987', 1),
(4, 'Marolio', 'Potosi 098', 2),
(5, 'Glaciar', 'Sarmiento 555', 3);

INSERT INTO CONTIENE (Nro, CodArt)
VALUES (001, 001),
(001, 002),
(001, 003),
(001, 004),
(002, 003),
(002, 004),
(003, 001),
(004, 002);

INSERT INTO COMPUESTO_POR (CodArt, CodMat)
VALUES(001, 001),
(001, 002),
(001, 003),
(002, 002),
(002, 005),
(002, 007),
(003, 001),
(003, 002),
(003, 006),
(004, 007);

INSERT INTO PROVISTO_POR(CodMat, CodProv)
VALUES (001, 1),
(002, 3),
(003, 5),
(004, 4),
(005, 2),
(006, 2),
(007, 5);

#1) Listar nombre de todos los proveedores y de su ciudad
SELECT p.Nombre, c.nombre AS Ciudad 
		FROM proveedor p 
			LEFT JOIN ciudad c ON p.CodCiudad = c.CodCiudad;

#2) Listar los nombres de los proveedores de la ciudad de La Plata
SELECT p.nombre, c.nombre AS ciudad 
		FROM proveedor p JOIN ciudad c ON p.CodCiudad = c.CodCiudad 
			WHERE c.Nombre = "LA PLATA";

#3) Listar los números de almacenes que almacenan el artículo de descripción que empiece con P
SELECT distinct con.nro AS numero_alamacen, art.descripcion 
		FROM contiene con 
			JOIN articulo art ON con.CodArt = art.CodArt 
            WHERE art.descripcion LIKE 'P%';

#4) Listar los números de almacenes y su responsable que almacenan el artículo de descripción que empiece con P
SELECT distinct al.nro AS numero_almacen, al.responsable, art.descripcion 
		FROM almacen al 
			JOIN contiene c ON al.nro = c.nro 
			JOIN articulo art ON c.CodArt = art.CodArt 
			WHERE art.descripcion LIKE "P%";

#5) Listar los materiales (código y descripción) provistos por proveedores de la ciudad de Ramos Mejia
SELECT m.CodMat, m.descripcion, ci.nombre AS nombre_ciudad 
		FROM material m 
			JOIN PROVISTO_POR pp ON m.CodMat = pp.CodMat 
            JOIN proveedor pr ON pp.CodProv = pr.CodProv
            JOIN ciudad ci ON pr.CodCiudad = ci.CodCiudad
            WHERE ci.nombre = "RAMOS MEJIA";

#6) Listar los nombres de los proveedores que proveen materiales para artículos ubicados en almacenes que Roberto tiene a su cargo
SELECT pro.nombre, mat.Descripcion, art.Descripcion, al.responsable 
		FROM proveedor pro 
			JOIN PROVISTO_POR pp ON pro.CodProv = pp.CodProv
            JOIN material mat ON pp.CodMat = mat.CodMat
            JOIN COMPUESTO_POR cp ON mat.CodMat = cp.CodMat
            JOIN articulo art ON cp.CodArt = art.CodArt
            JOIN CONTIENE c ON art.CodArt = c.CodArt
            JOIN almacen al ON c.nro = al.nro
            WHERE al.responsable = "ROBERTO";
            
SELECT P.NOMBRE
		FROM ALMACEN A JOIN CONTIENE C ON A.NRO = C.NRO
			JOIN ARTICULO ART ON ART.CODART = C.CODART
			JOIN COMPUESTO_POR CP ON CP.CODART = ART.CODART
			JOIN MATERIAL M ON M.CODMAT = CP.CODMAT
			JOIN PROVISTO_POR PP ON PP.CODMAT = M.CODMAT
			JOIN PROVEEDOR P ON P.CODPROV=PP.CODPROV
			WHERE A.RESPONSABLE = 'Roberto';

# Contar cantidad de provedores que empiecen con la letra L
SELECT count(*) AS nombre_con_L FROM proveedor p WHERE p.nombre LIKE "L%"; 

# Listar la descripción de articulos compuestos por al menos 2 materiales
SELECT distinct ar.descripcion, count(mt.codMat) AS cantidad_materiales
FROM articulo ar 
JOIN COMPUESTO_POR cp ON ar.CodArt = cp.CodArt 
JOIN material mt ON cp.CodMat = mt.CodMat 
GROUP BY ar.CodArt, ar.descripcion
HAVING COUNT(mt.CodMat)>=2;

#Listar la cantidad de materiales q provee cada proveedor y el codigo, nombre y domicilio del provedor
SELECT count(pp.CodMat) AS cantidad_materiales_provistos, p.CodProv, p.nombre, p.domicilio
FROM proveedor p
LEFT JOIN PROVISTO_POR pp ON p.CodProv = pp.CodProv
GROUP BY pp.CodMat
HAVING COUNT(pp.CodProv) >= 1;

SELECT A.CodArt, MAX(A.Precio) Precio_Max, A.descripcion
FROM PROVEEDOR P JOIN CIUDAD C ON P.CodCiudad = 
C.CodCiudad
JOIN PROVISTO_POR PP ON P.CodProv = PP.CodProv
JOIN COMPUESTO_POR CP ON CP.CodMat = PP.CodMat
JOIN ARTICULO A ON A.CodArt = CP.CodArt
WHERE C.Nombre = 'La Plata';

select * from Articulo;





