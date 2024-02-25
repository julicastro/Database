CREATE SCHEMA IF NOT EXISTS bd1_practica_3;
USE bd1_practica_3;

CREATE TABLE Producto (
		id_producto INT (5) PRIMARY KEY,
        descripcion VARCHAR(50) NOT NULL,
        estado VARCHAR(50) NOT NULL,
        id_proveedor INT(5) NOT NULL,
        FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
        );

CREATE TABLE Proveedor (
		id_proveedor INT(5) PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        cuit INT(10)
        );
        
CREATE TABLE Cliente (
		id_cliente INT(5) PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL
        );

CREATE TABLE Vendedor (
		id_empleado INT(5) PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR(50) NOT NULL,
        dni INT(10) NOT NULL
        );
        
CREATE TABLE Venta (
		nro_factura INT(10) PRIMARY KEY AUTO_INCREMENT,
        id_cliente INT(5) NOT NULL,
        fecha DATE NOT NULL,
        id_empleado INT(5) NOT NULL,
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
        FOREIGN KEY (id_empleado) REFERENCES vendedor(id_empleado)
        );
        
CREATE TABLE Detalle_venta (
        nro_detalle INT(10) PRIMARY KEY,
        nro_factura INT(10),
        id_producto INT (5) NOT NULL,
        cantidad INT(5) NOT NULL,
        precio_unitario DOUBLE,
        FOREIGN KEY (nro_factura) REFERENCES Venta (nro_factura),
        FOREIGN KEY (id_producto) REFERENCES Producto (id_producto)
        );
        
INSERT INTO Producto (id_producto, descripcion, estado, id_proveedor) VALUES
		(1, "Almendra", "Nuevo", 1),
        (2, "Queso", "Casi Nuevo", 3),
        (3, "Papa", "Usado", 1),
        (4, "Messi", "Nuevo", 2),
        (5, "Cebolla", "Usado", 2),
        (6, "Banana", "Nuevo", 3);
	
INSERT INTO Proveedor (id_proveedor, nombre, cuit) VALUES
		(1, "Carlos", 1321456),
        (2, "Matias", 1545616),
        (3, "Alfredo", 2376456);
		
INSERT INTO Cliente (id_cliente, nombre) VALUES
		(1, "Maria"),
        (2, "Jorge"),
        (3, "Gabriel"),
        (4, "Pepe"),
        (5, "Cristiano"),
        (6, "Neymar");
        
INSERT INTO Vendedor (id_empleado, nombre, apellido, dni) VALUES
		(1, "Julian", "Castro", 39347169),
        (2, "Lionel", "Messi", 6664664),
        (3, "Marcelo", "Brasilero", 32132154),
        (4, "Lionel", "Scaloni", 3214587),
        (5, "Gonzalo", "Montiel", 65498736),
        (6, "Ramiero", "Funesmori", 12345678);
        
INSERT INTO Venta (nro_factura, id_cliente, fecha, id_empleado) VALUES
		(1, 6, '2016-12-07', 2),
        (2, 3, '2014-05-02', 1),
        (3, 1, '2013-11-01', 1),
        (4, 1, '2012-03-25', 1),
        (5, 2, '2017-08-02', 2),
        (6, 2, '2018-01-10', 3),
        (7, 4, '2020-03-22', 3);
        
INSERT INTO Detalle_venta (nro_detalle, nro_factura, id_producto, cantidad, precio_unitario) VALUES 
		(1, 7, 6, 12, 504.52),
        (2, 5, 5, 12, 300.00),
        (3, 6, 5, 12, 24.52),
        (4, 3, 3, 12, 45.84),
        (5, 4, 3, 12, 880.66),
        (6, 2, 2, 12, 496.21),
        (7, 1, 1, 12, 505.10);
        
 
# 1. Listar la cantidad de productos que tiene la empresa.
SELECT COUNT(*) AS Cantidad_Producto FROM producto pr;

# 2. Listar la descripción de productos en estado 'Usado' que tiene la empresa.

# 3. Listar los productos que nunca fueron vendidos.
# 4. Listar la cantidad total de unidades que fueron vendidas de cada producto (descripción).
# 5. Listar el nombre de cada vendedor y la cantidad de ventas realizadas en el año 2015.
# 6. Listar el monto total vendido por cada cliente (nombre)
# 7. Listar la descripción de aquellos productos en estado ‘sin stock’ que se hayan vendido en el mes de Enero de 2015

		