CREATE DATABASE IF NOT EXISTS bd1_ejercicio_3_agregacion;
USE bd1_ejercicio_3_agregacion;

CREATE TABLE Almacen
		(Nro INT(5) PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Responsable VARCHAR(50) NOT NULL);
        
CREATE TABLE Articulo
		(CodArt INT(5) PRIMARY KEY,
        Descripcion VARCHAR(225) NOT NULL,
        Precio DOUBLE);

CREATE TABLE Material
		(CodMat INT(5) PRIMARY KEY,
        Descripcion VARCHAR(225) NOT NULL);
        
CREATE TABLE Proveedor
		(CodProv INT(5) PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Domicilio VARCHAR(50) NOT NULL,
        CodCiudad INT(5) NOT NULL,
        FOREIGN KEY (CodCiudad) REFERENCES Ciudad(CodCiudad));
        
CREATE TABLE Ciudad
		(CodCiudad INT(5) PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL);
        
CREATE TABLE Contiene
		(Cod_Contiene INT(5) PRIMARY KEY AUTO_INCREMENT,
        Nro INT(5) NOT NULL,
        CodArt INT(5) NOT NULL,
        FOREIGN KEY (Nro) REFERENCES Almacen(Nro),
        FOREIGN KEY (CodArt) REFERENCES Articulo(CodArt));
        
CREATE TABLE Compuesto_por
		(Cod_Composicion INT(3) PRIMARY KEY AUTO_INCREMENT,
        CodArt INT(5) NOT NULL,
        CodMat INT(5) NOT NULL,
        FOREIGN KEY (CodArt) REFERENCES Articulo(CodArt),
        FOREIGN KEY (CodMat) REFERENCES Material(CodMat)
        );
        
CREATE TABLE Provisto_por
		(Cod_Provisto INT(3) PRIMARY KEY AUTO_INCREMENT,
        CodMat INT(5) NOT NULL,
        CodProv INT(5) NOT NULL,
        FOREIGN KEY (CodMat) REFERENCES Material(CodMat),
        FOREIGN KEY (CodProv) REFERENCES Proveedor(CodProv)
        );
        
INSERT INTO Almacen (Nro, Nombre, Responsable)
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

        
#1) Indicar la cantidad de proveedores que comienzan con la letra L
SELECT COUNT(*) AS Cantidad_Provedores, p.Nombre 
		FROM Proveedor p 
		WHERE p.Nombre LIKE "L%";

#2) Listar el promedio de precios de los artículos por cada almacén (nombre). 
# (POR CADA ALMACEN = GROUP BY ALMACEN)
SELECT ROUND(AVG(ar.Precio), 2) AS "Precio Promedio", al.Nombre
		FROM articulo ar 
        JOIN contiene co ON ar.CodArt = co.CodArt
        JOIN almacen al ON co.Nro = al.Nro
        GROUP BY al.Nro;
        
#3) Listar la descripción de artículos compuestos por al menos 2 materiales. 
# (NECESITO UN COUNT DE MATERIALES YA Q TENGO Q APLICAR CONDICION CON HAVING COUNT)
SELECT ar.CodArt AS "Codigo Articulo", ar.Descripcion, COUNT(ma.CodMat) AS "Cantidad de Materiales"
		FROM articulo ar
        JOIN COMPUESTO_POR cp ON ar.CodArt = cp.CodArt
        JOIN material ma ON cp.CodMat = ma.CodMat
        GROUP BY ar.CodArt
        HAVING COUNT(ma.CodMat) >= 2;

#4) Listar cantidad de materiales que provee cada proveedor y el código, nombre y domicilio del proveedor
SELECT COUNT(ma.CodMat) AS "Cantidad de Materiales", pr.CodProv AS "Codigo Proveedor", pr.Nombre, pr.Domicilio
		FROM Proveedor pr
        LEFT JOIN PROVISTO_POR pp ON pr.CodProv = pp.CodProv
        LEFT JOIN material ma ON pp.CodMat = ma.CodMat
        GROUP BY pr.CodProv; 

#5) Cuál es el precio máximo de los artículos que estan compuestos por materiales que proveen los proveedores de la ciudad de La Plata.
SELECT ar.Descripcion AS "Articulo", ar.precio AS "Precio Maximo", pv.Nombre AS Provedor, ci.Nombre AS Ciudad
		FROM articulo ar
        JOIN COMPUESTO_POR cp ON ar.CodArt = cp.CodArt
        JOIN material ma ON cp.CodMat = ma.CodMat
        JOIN PROVISTO_POR pp ON ma.CodMat = pp.CodMat
        JOIN proveedor pv ON pp.CodProv = pv.CodProv
        JOIN ciudad ci ON pv.CodCiudad = ci.CodCiudad
        WHERE ci.Nombre = 'La Plata'
        ORDER BY ar.precio DESC 
        LIMIT 1;

#6) Listar los nombres de aquellos proveedores que no proveen ningún material
SELECT pv.nombre
		FROM proveedor pv 
        LEFT JOIN PROVISTO_POR pp ON pv.CodProv = pp.CodProv
        WHERE pp.CodMat IS NULL; 
        
SELECT P.NOMBRE NOMBRE_PROV
		FROM PROVEEDOR P 
        LEFT JOIN PROVISTO_POR PP ON 
		P.CodProv= PP.CodProv
		GROUP BY P.CodProv
		HAVING COUNT(PP.CodMat) = 0;