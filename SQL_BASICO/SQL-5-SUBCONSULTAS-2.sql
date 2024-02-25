CREATE SCHEMA IF NOT EXISTS bd1_ejercicio_5_subconsultas_2;
USE bd1_ejercicio_5_subconsultas_2; 

create table Localidad
(IDlocalidad int (20) primary key,
descripcion varchar (30) not null);

create table Plato
(idPlato int (20) primary key auto_increment,
descricipcion varchar (50) not null,
precio int (10) not null);

create table Cliente
(idCliente int (10) primary key,
nombre varchar (20) not null,
apellido varchar (20),
calle varchar (30) ,
nro int (5),
idlocalidad int (20) not null,
foreign key (idlocalidad) references localidad (idlocalidad));

create table pedidoEncabezado 
(idPedido int (10) primary key auto_increment,
idCliente int (10) not null,
fecha date,
foreign key (idCliente) references Cliente (idCliente));

create table pedidoDetalle 
(idDetalle int (10) primary key auto_increment,
idPedido int(10) not null,
idPlato int(20) not null,
cantidad int(5) not null,
foreign key (idPlato) references Plato (idPlato),
foreign key (idPedido) references pedidoEncabezado (idpedido));

INSERT INTO LOCALIDAD (IDlocalidad, descripcion) VALUES 
(1, 'Haedo'),
(2, 'Ramos Mejia'),
(3, 'San Justo'),
(4, 'Villa Luzuriaga'),
(5, 'Castelar'),
(6, 'Caseros');

INSERT INTO CLIENTE(idCliente, nombre, apellido, calle, nro, idLocalidad) VALUES
(1, 'Julian', 'Castro', 'Suiapcha',505 ,1),
(2, 'Lionel', 'Messi', 'Iberlucea', 454, 1),
(3, 'Gio', 'Lo Celso', 'San Lorenzo',121 ,2),
(4, 'Lean', 'Paredes', 'Uruguay',905 ,4),
(5, 'Carlos', 'Gonzalez', 'Esmeralda',664 ,3);

# QUERY PARA EJECUTR CONSIGNA 10. (Eliminar para ejecutar la 9)
INSERT INTO CLIENTE(idCliente, nombre, apellido, calle, nro, idLocalidad) VALUES
(6, 'Jesus', 'Perez', 'Concordia', 666,3),
(7, 'Jorge', 'Martinez', 'Rivadavia',877 ,4);

INSERT INTO PLATO (idPlato, descricipcion, precio) VALUES
(1,'Fideos', 2000),
(2,'Pizza', 5500),
(3,'Milanesa', 1500),
(4,'Hamburguesa', 500),
(5,'Asado', 8000),
(6,'Pollo', 4505),
(7,'Cerdo', 3215);

INSERT INTO pedidoEncabezado (idPedido, idCliente, fecha) VALUES
(1, 1, '2022-02-01'),
(2, 2, '2022-05-21'),
(3, 2, '2022-02-01'),
(4, 4, '2022-02-01'),
(5, 7, '2022-02-01'),
(6, 3, '2022-02-01'),
(7, 5, '2022-02-01'),
(8, 6, '2022-02-01');

UPDATE pedidoEncabezado SET fecha = '2022-02-08' WHERE idPedido = 8;
UPDATE pedidoEncabezado SET fecha = '2022-02-11' WHERE idPedido = 7;
UPDATE pedidoEncabezado SET fecha = '2022-04-20' WHERE idPedido = 6;
UPDATE pedidoEncabezado SET fecha = '2022-02-12' WHERE idPedido = 5;
UPDATE pedidoEncabezado SET fecha = '2022-02-11' WHERE idPedido = 4;
UPDATE pedidoEncabezado SET fecha = '2022-03-28' WHERE idPedido = 3;
select * from pedidoEncabezado;

INSERT INTO pedidoDetalle (idPedido, idPlato, cantidad) VALUES
(1, 1, 2),
(1, 2, 1),
(1, 3, 3),
(1, 4, 5),
(1, 5, 6),
(2, 2, 2),
(4, 3, 2),
(4, 4, 6),
(6, 4, 8),
(8, 1, 5),
(6, 5, 3),
(2, 2, 1),
(7, 4, 1);

# 2- Obtener los datos de todos los clientes, ordenados por Localidad, Nombre y Apellido
SELECT * 
		FROM cliente c
        JOIN localidad l 
        ON c.idLocalidad = l.idLocalidad
        ORDER BY l.idLocalidad, c.nombre, c.apellido;

# 3- Informar: número de Pedido, Cantidad de Platos Distintos, Cantidad de unidades total, Importe 
SELECT pd.idPedido AS nro_pedido, count(DISTINCT pd.idPlato) as platos_distintos, SUM(pd.cantidad) as unidades, SUM(pl.precio * pd.cantidad) AS total
		FROM pedidoDetalle pd
        JOIN plato pl 
        ON pd.idPlato = pl.idPlato
        GROUP BY pd.idPedido;

# 4- Mostrar un detalle de los clientes que han realizado pedidos en el mes de Febrero y no realizaron ningún pedido en el mes de Mayo
SELECT c.idCliente, c.nombre
		FROM cliente c
        WHERE c.idCliente IN (SELECT pe.idCliente 
						FROM pedidoEncabezado pe
                        WHERE pe.fecha BETWEEN '2022-02-01' AND '2022-02-28'
                        AND c.idCliente NOT IN (SELECT pe.idCliente 
										FROM pedidoEncabezado pe
                                        WHERE pe.fecha BETWEEN '2022-05-01' AND '2022-05-31'));

# 5- Informar el nombre del plato mas barato de la carta
SELECT MIN(p.precio), p.descricipcion
		FROM plato p;

# 6- informar los datos completos de los clientes, la fecha de última compra y el total gastado. Deben informarse la totalidad de los clientes existentes. 
SELECT c.idCliente, c.nombre, c.apellido, MAX(pe.fecha) AS ULTIMA_FECHA, SUM(pd.cantidad * p.precio) AS pago_total
		FROM cliente c
        JOIN pedidoEncabezado pe
        ON c.idCliente = pe.idCliente
        JOIN pedidodetalle pd
        ON pe.idPedido = pd.idPedido
        JOIN plato p
        ON pd.idPlato = p.idPlato
        GROUP BY  c.idCliente; # sin el group by NO me muestra TODOS los detalles de TODOS los clientes.

# 7- Informar los platos que han sido comprados por mas de un cliente
SELECT p.idPlato, p.descricipcion
		FROM plato p
        JOIN pedidodetalle pd
        ON p.idPlato = pd.idPlato
        JOIN pedidoEncabezado pe
        ON pe.idPedido = pd.idPedido
        GROUP BY p.idPlato
        HAVING COUNT(p.idPlato) > 1;
        
# 8- Mostrar los clientes que han pedido todos los platos del menú 
SELECT c.nombre 
		FROM cliente c
        JOIN pedidoEncabezado pe 
        ON c.idCliente = pe.idCliente
        JOIN pedidoDetalle pd
        ON pe.idPedido = pd.idPedido
        GROUP BY c.idCliente
        HAVING COUNT(c.idCliente) = (SELECT COUNT(*) FROM plato);

# 9- Informar la descripción y precio de los platos que no han sido comprados por ningún cliente.
SELECT DISTINCT p.descricipcion, p.precio 
		FROM plato p 
        JOIN pedidoDetalle pd 
		WHERE NOT EXISTS (SELECT pd.idPlato
					FROM pedidoDetalle pd
                    WHERE pd.idPlato = p.idPlato);

