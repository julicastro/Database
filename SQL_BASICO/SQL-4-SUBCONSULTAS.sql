CREATE SCHEMA IF NOT EXISTS bd1_ejercicio_4_subconsultas;
USE bd1_ejercicio_4_subconsultas;

CREATE TABLE ALMACEN(
Nro INT(5) PRIMARY KEY,
Nombre VARCHAR(20) NOT NULL,
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

INSERT INTO ALMACEN (Nro, Nombre, Responsable)
VALUES (001, 'La Original', 'Alfredo'),
(002, 'Galpon', 'Esteban'),
(003, 'Almacen de Don Juan', 'Juan'),
(004, 'La Tiendita', 'Roberto');

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

INSERT INTO PROVEEDOR (CodProv, Nombre, Domicilio, 
CodCiudad)
VALUES(1, 'Arcor', 'Ayacucho 1234', 1),
(2, 'Molinos', 'Yatay 456', 4),
(3, 'Ledesma', 'Mario Bravo 987', 1),
(4, 'Marolio', 'Potosi 098', 2),
(5, 'Glaciar', 'Sarmiento 555', 3),
(6, 'Johnson', 'Potosi 123', 1);

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

#1) Listar los nombres de aquellos proveedores que no proveen ningún material
SELECT pr.nombre, pr.CodProv AS producto 
		FROM PROVEEDOR pr 
        WHERE pr.CodProv NOT IN (SELECT pp.CodProv 
							FROM PROVISTO_POR pp);
                            
SELECT P.CodProv
		FROM PROVEEDOR P
		WHERE NOT EXISTS (SELECT 1
						FROM PROVISTO_POR PP
						WHERE PP.CodProv = P.CodProv);
        
#2) Listar los códigos y descripción de los materiales que provea el proveedor 2 y no los provea el proveedor 5
SELECT m.CodMat, m.descripcion 
		FROM material m 
        WHERE m.CodMat IN (SELECT pp.CodMat 
						   FROM PROVISTO_POR pp 
						   WHERE pp.CodProv = 2 
                           AND m.CodMat NOT IN(SELECT pp.CodProv 
											   FROM PROVISTO_POR pp 
											   WHERE pp.CodProv != 5)); 

#3) Listar número y nombre de almacenes que contienen los artículos de descripción ‘Pan’ y los de descripción ‘Facturas’ (ambos)
SELECT COUNT(al.Nro), al.nombre 
		FROM almacen al 
		WHERE al.Nro IN (SELECT c.Nro 
						FROM CONTIENE c
                        JOIN articulo ar 
                        ON c.CodArt = ar.CodArt
                        WHERE ar.descripcion = 'Pan' 
                        AND al.Nro IN (SELECT c.Nro 
										FROM CONTIENE c
										JOIN articulo ar 
										ON c.CodArt = ar.CodArt
										WHERE ar.descripcion = 'Facturas' 
										));                             

#4) Listar la descripción de artículos compuestos por todos los materiales
SELECT ar.descripcion 
		FROM articulo ar 
        JOIN COMPUESTO_POR cp 
        ON ar.CodArt = cp.CodArt
        GROUP BY ar.CodArt
        HAVING COUNT(*) = (SELECT COUNT(*) FROM material);
        
#5) Hallar los códigos y nombres de los proveedores que proveen al menos un material que se usa en algún artículo cuyo precio es mayor a $300
SELECT p.CodProv, p.nombre 
		FROM provisto_por pp
        JOIN proveedor p
        ON pp.CodProv = p.CodProv 
        WHERE pp.CodMat IN (SELECT cp.CodMat 
							FROM compuesto_por cp
                            WHERE cp.CodArt IN (SELECT ar.CodArt 
												FROM articulo ar 
                                                WHERE ar.precio <= 300
                                                )) ORDER BY pp.codProv;              

#6) Listar la descripción de los artículos de mayor precio
SELECT ar.descripcion, ar.precio
		FROM articulo ar
        WHERE ar.precio = (SELECT MAX(precio) FROM articulo);

SELECT ar.descripcion, ar.precio
		FROM articulo ar
		ORDER BY ar.precio ASC LIMIT 2;