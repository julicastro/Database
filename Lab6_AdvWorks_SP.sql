USE AdventureWorks2014;

/* 1- p_InsCulture(id,name,date): Este sp debe permitir dar de alta un nuevo 
registro en la tabla Production.Culture. Los tipos de datos de los par�metros 
deben corresponderse con la tabla. Para ayudarse, se podr� ejecutar el 
procedimiento sp_help�<esquema.objeto>�. */

sp_help 'Production.Culture';

CREATE PROCEDURE p_InsCulture 
	@p_id NCHAR(12),
	@p_name NVARCHAR(100)
AS
BEGIN
	DECLARE @p_date  DATETIME
		SET @p_date =GETDATE()

	IF @p_id IS NOT NULL AND @p_name IS NOT NULL AND @p_date IS NOT NULL
		INSERT INTO Production.Culture (CultureID, Name, ModifiedDate) VALUES (@p_id, @p_name, @p_date);
	ELSE 
		THROW 50000, 'Algun parametro est� incompleto', 1;
END;

EXEC p_InsCulture 'xs', 'Super Small';

select * from Production.Culture;

/* 2- p_SelCuture(id): Este sp devolver� el registro completo seg�n el id 
enviado. */

ALTER PROCEDURE p_SelCuture
	@p_id NCHAR(12)
AS 
BEGIN
	IF  @p_id IS NOT NULL AND @p_id IN (SELECT CultureID FROM Production.Culture)
		SELECT * FROM Production.Culture WHERE CultureID = @p_id;
	ELSE 
		THROW 50000, 'Error', 1;
END; 

EXEC p_SelCuture 'ar';

/* 3- p_DelCulture(id): Este sp debe borrar el id enviado por par�metro de la 
tabla Production.Culture.*/

ALTER PROCEDURE p_DelCulture
	@p_id NCHAR(12)
AS
BEGIN
	IF @p_id IS NOT NULL AND @p_id IN (SELECT CultureId FROM Production.Culture)
		BEGIN
			DELETE FROM Production.Culture WHERE CultureID = @p_id;
		END
	ELSE 
		THROW 50000, 'ID no encontrado', 1;
END;

EXEC p_DelCulture 'ar';

/* 4- p_UpdCulture(id): Dado un id debe permitirme cambiar el campo name 
del registro. */

CREATE PROCEDURE p_UpdCulture
	@p_id NCHAR(12), -- PARAMETRO OBLIGATORIO
	@p_name NVARCHAR(100) -- PARAMETRO OBLIGATORIO
AS
BEGIN
	UPDATE Production.Culture SET Name = @p_name WHERE CultureID = @p_id; 
END;

EXEC p_UpdCulture 'ar', 'Messilandia';

/* 5- sp_CantCulture (cant out): Realizar un sp que devuelva la cantidad de 
registros en Culture. El resultado deber� colocarlo en una variable de salida. */

ALTER PROCEDURE sp_CantCulture
    @cant_out INT OUTPUT -- ESTE ES UN PARAMETRO DE SALIDA
AS
BEGIN
	SELECT @cant_out = COUNT(CultureID) FROM Production.Culture;
END;

DECLARE @cantidadSalida INT;
EXECUTE sp_CantCulture @cant_out = @cantidadSalida OUTPUT;
SELECT @cantidadSalida AS 'Cantidad Total';

/*6- sp_CultureAsignadas : Realizar un sp que devuelva solamente las 
Culture�s que est�n siendo utilizadas en las tablas (Verificar qu� tabla/s la 
est�n referenciando). S�lo debemos devolver id y nombre de la Cultura.*/

-- SABER TABLAS REFERENCIADAS: 
BEGIN 
	SELECT 
		fk.name AS 'Nombre de la Clave Externa',
		tp.name AS 'Tabla Principal',
		ref.name AS 'Tabla Referenciada'
	FROM 
		sys.foreign_keys AS fk
	JOIN 
		sys.tables AS tp ON fk.parent_object_id = tp.object_id
	JOIN 
		sys.tables AS ref ON fk.referenced_object_id = ref.object_id
	WHERE 
		ref.name = 'Culture' -- Nombre de la tabla referenciada (Production.Culture)
	ORDER BY 
		tp.name, 
		fk.name;
END;

SELECT * FROM Production.ProductModelProductDescriptionCulture;

CREATE PROCEDURE sp_CultureAsignadas
	@p_id NCHAR(12) OUTPUT,
	@p_name NVARCHAR(100) OUTPUT
AS
BEGIN 
	SELECT @p_id = c.CultureID 
	FROM Production.Culture c
	WHERE c.CultureID IN (SELECT CultureID FROM Production.ProductModelProductDescriptionCulture);
	SELECT @p_name = NAME
	FROM Production.Culture c
	WHERE c.CultureID = @p_id;
END; 

DECLARE @id NCHAR(12), @nombre NVARCHAR(100);
EXECUTE sp_CultureAsignadas @p_id = @id OUTPUT, @p_name = @nombre OUTPUT;
SELECT @id AS 'ID Referenciado', @nombre AS 'Nombre Referenciado';

ALTER PROCEDURE sp_CultureAsignadas
AS
SELECT P.CultureID,P.Name 
FROM Production.Culture P
WHERE EXISTS(
	SELECT 1
	FROM Production.ProductModelProductDescriptionCulture PM
	WHERE P.CultureID=PM.CultureID
);
EXECUTE sp_CultureAsignadas;

/*7- p_ValCulture(id,name,date,operaci�n, valida out): Este sp permitir� 
validar los datos enviados por par�metro. En el caso que el registro sea 
v�lido devolver� un 1 en el par�metro de salida valida � 0 en caso contrario. 
El par�metro operaci�n puede ser �U� (Update), �I� (Insert) � �D� (Delete). 
Lo que se debe validar es:
- Si se est� insertando no se podr� agregar un registro con un id 
existente, ya que arrojar� un error.
- Tampoco se puede agregar dos registros Cultura con el mismo Name, 
ya que el campo Name es un unique index.
- Ninguno de los campos deber�a estar vac�o.
- La fecha ingresada no puede ser menor a la fecha actual.
*/

ALTER PROCEDURE p_ValCulture 
    @p_id NCHAR(12),
    @p_name NVARCHAR(100),
    @p_date DATE = NULL,
    @p_operacion CHAR(1),
    @p_valida SMALLINT OUTPUT
AS
BEGIN

	IF @p_date IS NULL
		SET @p_date = GETDATE();

	IF @p_date > GETDATE()
	BEGIN
		SET @p_valida = 0;
		PRINT 'Operacion Invalida'
		RETURN;
	END

	IF @p_operacion <> 'I' AND @p_operacion <> 'U' AND @p_operacion <> 'D'
	BEGIN
		SET @p_valida = 0;
		PRINT 'Operacion Invalida'
		RETURN;
	END

	IF @p_id IS NULL or @p_name IS NULL or @p_date IS NULL or @p_operacion IS NULL
		BEGIN
		SET @p_valida = 0;
		PRINT 'No se permiten campos vacios'
		RETURN;
	END

	IF @p_operacion = 'I'
		BEGIN
			IF EXISTS (SELECT 1 FROM Production.Culture WHERE CultureID = @p_id) 
			or EXISTS (SELECT 1 FROM Production.Culture WHERE Name = @p_id) 
			BEGIN
				SET @p_valida = 0;
				PRINT 'Ya existe Cultura con ese ID o Nombre'
				RETURN;
			END
			INSERT INTO Production.Culture (CultureID, Name, ModifiedDate)
			VALUES (@p_id, @p_name, @p_date);
			SET @p_valida = 1;
		END

	IF @p_operacion = 'U'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Production.Culture WHERE CultureID = @p_id) 
			BEGIN
				SET @p_valida = 0;
				PRINT 'No se encontr� una cultura con ese ID'
				RETURN;
			END
			IF EXISTS (SELECT 1 FROM Production.Culture c WHERE c.Name = @p_name) 
			BEGIN
				SET @p_valida = 0;
				PRINT 'Ya existe Cultura Nombre'
				RETURN;
			END 
			UPDATE Production.Culture SET Name = @p_name, ModifiedDate = @p_date
			WHERE CultureID = @p_id;
			SET @p_valida = 1;
		END

	IF @p_operacion = 'D'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Production.Culture WHERE CultureID = @p_id) 
			BEGIN
				SET @p_valida = 0;
				PRINT 'No se encontr� una cultura con ese ID'
				RETURN;
			END
			DELETE FROM Production.Culture WHERE CultureID = @p_id;
			SET @p_valida = 1;
		END
END;

DECLARE @v_date DATE, @v_valida SMALLINT;
SET @v_date = GETDATE();
EXEC p_ValCulture 'sex', 'asdasd2322', @v_date, 'D', @v_valida OUTPUT;
SELECT @v_valida AS Resultado;

SELECT * FROM Production.Culture;

/* 8- p_SelCulture2(id out, name out, date out): A diferencia del sp del punto 
2, este debe emitir todos los datos en sus par�metros de salida. �C�mo se 
debe realizar la llamada del sp para testear este sp? */

CREATE OR ALTER PROCEDURE p_SelCuture2
    @p_id NCHAR(12) OUTPUT,
	@id_out NCHAR(12) OUTPUT,
    @name_out NVARCHAR(100) OUTPUT,
    @date_out DATE = NULL OUTPUT
AS 
BEGIN
	IF  @p_id IS NOT NULL AND @p_id IN (SELECT CultureID FROM Production.Culture)
		BEGIN 
			SELECT @id_out = c.CultureID, @name_out = c.Name, @date_out = c.ModifiedDate
			FROM Production.Culture c WHERE CultureID = @p_id;
		END
	ELSE 
		THROW 50000, 'Error', 1;
END; 

DECLARE @id NCHAR(12), @nombre NVARCHAR(100), @fecha DATE;
EXEC p_SelCuture2 'ar', @id_out = @id OUTPUT, @name_out = @nombre OUTPUT, @date_out = @fecha OUTPUT;
SELECT @id AS ID, @nombre AS Nombre, @fecha AS Fecha;

SELECT * FROM Production.Culture;

/* 9- Realizar una modificaci�n al sp p_InsCulture para que valide los registros 
ingresados. Por lo cual, deber� invocar al sp p_ValCulture. S�lo se insertar� 
si la validaci�n es correcta.*/ 




/*10-Idem con el sp p_UpdCulture. Validar los datos a actualizar.
11-En p_DelCulture se deber� modificar para que valide que no posea registros 
relacionados en la tabla que lo referencia. Investigar cu�l es la tabla 
referenciada e incluir esta validaci�n. Si se est� utilizando, emitir un 
mensaje que no se podr� eliminar.
12-p_CrearCultureHis: Realizar un sp que permita crear la siguiente tabla 
hist�rica de Cultura. Si existe deber� eliminarse. Ejecutar el procedimiento 
para que se pueda crear:
CREATE TABLE Production.CultureHis( 
CultureID nchar(6) NOT NULL,
Name [dbo].[Name] NOT NULL,
ModifiedDate datetime NOT NULL CONSTRAINT
DF_CultureHis_ModifiedDate DEFAULT (getdate()), 
CONSTRAINT PK_CultureHis_IDDate PRIMARY KEY CLUSTERED (CultureID,
ModifiedDate)
)
- �Qu� tipo de datos posee asignado el campo Name?
- �Qu� sucede si no se inserta el campo ModifiedDate?
13-Dada la tabla hist�rica creada en el punto 12, se desea modificar el 
procedimiento p_UpdCulture creado en el punto 4. La modificaci�n consiste 
en que cada vez que se cambia alg�n valor de la tabla Culture se desea 
enviar el registro anterior a una tabla hist�rica. De esta forma, en la tabla 
Culture siempre tendremos el �ltimo registro y en la tabla CutureHis cada 
una de las modificaciones realizadas.
14-p_UserTables(opcional esquema): Realizar un procedimiento que liste 
las tablas que hayan sido creadas dentro de la base de datos con su 
nombre, esquema y fecha de creaci�n. En el caso que se ingrese por 
par�metro el esquema, entonces mostrar �nicamente dichas tablas, de lo 
contrario, mostrar todos los esquemas de la base.
15-p_GenerarProductoxColor(): Generar un procedimiento que divida los 
productos seg�n el color que poseen. Los mismos deben ser insertados en 
diferentes tablas seg�n el color del producto. Por ejemplo, las tablas podr�an 
ser Product_Black, Product_Silver, etc� Estas tablas deben ser generadas 
din�micamente seg�n los colores que existan en los productos, es decir, si 
genero un nuevo producto con un nuevo color, al ejecutar el procedimiento 
debe generar dicho color. Cada vez que se ejecute este procedimiento se 
recrear�n las tablas de colores. Los productos que no posean color 
asignados, no se tendr�n en cuenta para la generaci�n de tablas y no se 
insertar�n en ninguna tabla de color.
16-p_UltimoProducto(param): Realizar un procedimiento que devuelva en 
sus par�metros (output), el �ltimo producto ingresado.
17-p_TotalVentas(fecha): Realizar un procedimiento que devuelva el total 
facturado en un d�a dado. El procedimiento, simplemente debe devolver el 
total monetario de lo facturado (Sales) */