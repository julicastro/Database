CREATE SCHEMA IF NOT EXISTS bd1_modelo_6;
USE bd1_modelo_6;

CREATE TABLE especialidad (
	idEsp INT(5) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
CREATE TABLE medico (
	legajo INT (5) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
	telefono INT(10) NOT NULL,
    valorConsulta DOUBLE NOT NULL,
    idEsp INT (5) NOT NULL,
    FOREIGN KEY (idEsp) REFERENCES especialidad(idEsp)
);
CREATE TABLE localidad (
	idLocalidad INT(5) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
CREATE TABLE paciente (
	legajo INT(5) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
	telefono INT(10) NOT NULL,
    idLocalidad INT(5) NOT NULL,
    FOREIGN KEY (idLocalidad) REFERENCES localidad(idLocalidad)
);
CREATE TABLE consulta (
	id INT(5) PRIMARY KEY,
    legajoMedico INT (5) NOT NULL,
    legajoPaciente INT (5) NOT NULL,
    fecha DATE NOT NULL,
    nroConsultorio INT(5) NOT NULL,
    FOREIGN KEY (legajoMedico) REFERENCES medico(legajo),
    FOREIGN KEY (legajoPaciente) REFERENCES paciente(legajo)
);

INSERT INTO ESPECIALIDAD (idEsp, descripcion) VALUES 
(1, 'General'),
(2, 'Endocrinología'),
(3, 'Oftalmología'),
(4, 'Ortopedista'),
(5, 'Cirugía');

INSERT INTO LOCALIDAD (idLocalidad, descripcion) VALUES 
(1, 'Haedo'),
(2, 'Ramos Mejia'),
(3, 'San Justo'),
(4, 'Villa Luzuriaga'),
(5, 'Castelar'),
(9, 'Caseros');

INSERT INTO PACIENTE(legajo, nombre, apellido, telefono, idLocalidad) VALUES
(1, 'Julian', 'Castro', 12345678, 1),
(2, 'Lionel', 'Messi', 12345678, 1),
(3, 'Gio', 'Lo Celso', 12345678, 9),
(4, 'Lean', 'Paredes', 12345678, 4),
(5, 'Carlos', 'Gonzalez', 12345678, 5),
(6, 'Jesus', 'Perez', 12345678, 2),
(7, 'Jorge', 'Martinez', 12345678, 2);

INSERT INTO MEDICO (legajo, nombre, apellido, telefono, valorConsulta, idEsp) VALUES
(1, 'Gonzalo', 'Rodriguez', 6548752, 2000.0, 1),
(2, 'Marcelo', 'Rodriguez', 6548752, 4500.30, 4),
(3, 'Pepe', 'Robinho', 6548752, 2020.21, 4),
(4, 'Juancito', 'Carlos', 6548752, 210.0, 2),
(5, 'Patricio', 'Gomez', 6548752, 1500.10, 2),
(6, 'Maria', 'Perez', 6548752, 2440.0, 1);

INSERT INTO CONSULTA (id, legajoMedico, legajoPaciente, fecha, nroConsultorio) VALUES
(1, 3, 3, '2022-03-11', 12),
(2, 1, 6, '2022-03-25', 3),
(3, 4, 2, '2022-01-06', 11),
(4, 2, 4, '2022-03-24', 2),
(5, 2, 3, '2022-08-12', 9),
(6, 1, 2, '2022-03-09', 4),
(7, 1, 2, '2022-01-11', 1);

#1 Escribir el script de creación de tabla de Paciente con sus restricciones
# ya está hecho :)

#2 Obtener los datos de todos los pacientes, ordenados por localidad y legajo
SELECT * FROM paciente p
		ORDER BY p.idLocalidad, p.legajo;

#3 Para cada paciente, informar la cantidad de consultas, y el valor máximo de consulta abonado
SELECT count(co.legajoPaciente) AS cantidad_consultas, pa.nombre AS "Nombre paciente", me.valorConsulta AS valor_maximo_abonado
		FROM consulta co 
        JOIN paciente pa 
        ON co.legajoPaciente = pa.legajo
		JOIN medico me ON co.legajoMedico = me.legajo
        GROUP BY co.legajoPaciente;

# 4 informar: Legajo, Nombre y apellido del paciente, Legajo del médico, nombre y apellido del médico, fecha de consulta, importe, comisión de la clínica (10% del # importe abonado por consulta) y nro de consultorio, de todas las consultas registradas en el desde el 2019
SELECT pa.legajo, pa.nombre, pa.apellido, me.legajo as legajo_medico, me.apellido, co.fecha, me.valorConsulta, (me.valorConsulta * 10)/100 as comision_clinica, co.nroConsultorio
		FROM consulta co 
        JOIN paciente pa 
        ON co.legajoPaciente = pa.legajo
        JOIN medico me 
        ON co.legajoMedico = me.legajo
        WHERE co.fecha IN (SELECT co.fecha 
							FROM consulta co 
                            WHERE fecha BETWEEN '2022-03-01' AND '2022-03-31');
        
#5  Escribir el script para agregar el siguiente paciente: B8, Juan, Perez,01154545454, 9
INSERT INTO PACIENTE(legajo, nombre, apellido, telefono, idLocalidad) VALUES
(8, 'Juan', 'Perez', 123456, 5);

#6 Considera que podría tener algún inconveniente al insertar el registro del punto anterior? Justifique su respuesta.
# es INT y le estoy pasando el caracter "B"

#7 Modificar el valor de la consulta del médico 555, por 1690
UPDATE medico me
SET valorConsulta = 1690
WHERE me.legajo = 1;

#8. Informar los médicos que tienen el mayor valor de consulta
SELECT me.nombre, me.valorConsulta
		FROM medico me
        WHERE me.valorConsulta = (SELECT MAX(valorConsulta) FROM medico);

#9 Mostrar los datos de los pacientes que han realizado alguna consulta "General" pero nunca han consultado a un Ortopedista
SELECT pa.nombre, pa.legajo 
		FROM paciente pa 
        JOIN consulta co
        ON co.legajoPaciente = pa.legajo
        WHERE pa.legajo IN (SELECT me.legajo 
						FROM medico me 
						JOIN especialidad es
						ON me.idEsp = es.idEsp
						WHERE es.descripcion = 'General'
						AND pa.legajo NOT IN (SELECT me.legajo 
											FROM medico me 
											JOIN especialidad es
											ON me.idEsp = es.idEsp
											WHERE es.descripcion = 'Ortopedista'));

#10 Mostrar los datos de los pacientes que se han atenido por todos los médicos
SELECT *
		FROM paciente pa 
        JOIN consulta co 
        ON pa.legajo = co.legajoPaciente
        GROUP BY pa.legajo
        HAVING COUNT(*) = (SELECT COUNT(*) FROM medico);

#11 nformar los datos de los pacientes que se han atendido mas de una vez por el mismo médico
SELECT pa.nombre, COUNT(co.legajoMedico) AS cantidades_atendidas
		FROM paciente pa
        JOIN consulta co
        ON pa.legajo = co.legajoPaciente
        GROUP BY pa.legajo
        HAVING COUNT(co.legajoMedico) > 1;


        

