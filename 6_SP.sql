USE AdventureWorks2014;

/* 1- p_InsCulture(id,name,date): Este sp debe permitir dar de alta un nuevo 
registro en la tabla Production.Culture. Los tipos de datos de los parámetros 
deben corresponderse con la tabla. Para ayudarse, se podrá ejecutar el 
procedimiento sp_help“<esquema.objeto>”. */

sp_help 'Production.Culture';

CREATE OR ALTER PROCEDURE p_InsCulture 
	@p_id NCHAR(12),
	@p_name NVARCHAR(100)
AS
	BEGIN TRY
		BEGIN TRANSACTION 
			DECLARE @p_date  DATETIME
			SET @p_date =GETDATE()
			INSERT INTO Production.Culture (CultureID, Name, ModifiedDate) VALUES (@p_id, @p_name, @p_date);
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRANSACTION;
	END CATCH
GO

EXEC p_InsCulture 'xT3s', 'Sup1er SmalUl';
GO
select * from Production.Culture;

/* 2- p_SelCuture(id): Este sp devolverá el registro completo según el id 
enviado. */

ALTER PROCEDURE p_SelCuture
	@p_id NCHAR(12)
AS 
BEGIN TRY
	IF  @p_id IS NOT NULL AND @p_id IN (SELECT CultureID FROM Production.Culture)
		SELECT * FROM Production.Culture WHERE CultureID = @p_id;
	ELSE 
		THROW 50000, 'Registro no encontrado', 1;
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS ERROR;
END CATCH

EXEC p_SelCuture '6';

/* 3- p_DelCulture(id): Este sp debe borrar el id enviado por parámetro de la 
tabla Production.Culture.*/

ALTER PROCEDURE p_DelCulture
	@p_id NCHAR(12)
AS
BEGIN TRY
	BEGIN TRANSACTION
	IF @p_id IS NOT NULL AND @p_id IN (SELECT CultureId FROM Production.Culture)
		BEGIN
			DELETE FROM Production.Culture WHERE CultureID = @p_id;
		END
	ELSE 
		THROW 50000, 'Registro no encontrado', 1;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS ERROR;
	ROLLBACK TRANSACTION;
END CATCH

EXEC p_DelCulture 'xs';

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
registros en Culture. El resultado deberá colocarlo en una variable de salida. */

ALTER PROCEDURE sp_CantCulture
    @cant_out INT OUTPUT -- ESTE ES UN PARAMETRO DE SALIDA
AS
BEGIN
	SELECT @cant_out = COUNT(CultureID) FROM Production.Culture;
END;

DECLARE @cantidadSalida INT;
EXECUTE sp_CantCulture @cant_out = @cantidadSalida OUT;
SELECT @cantidadSalida AS 'Cantidad Total';

/*6- sp_CultureAsignadas : Realizar un sp que devuelva solamente las 
Culture’s que estén siendo utilizadas en las tablas (Verificar qué tabla/s la 
están referenciando). Sólo debemos devolver id y nombre de la Cultura.*/

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

/*7- p_ValCulture(id,name,date,operación, valida out): Este sp permitirá 
validar los datos enviados por parámetro. En el caso que el registro sea 
válido devolverá un 1 en el parámetro de salida valida ó 0 en caso contrario. 
El parámetro operación puede ser “U” (Update), “I” (Insert) ó “D” (Delete). 
Lo que se debe validar es:
- Si se está insertando no se podrá agregar un registro con un id 
existente, ya que arrojará un error.
- Tampoco se puede agregar dos registros Cultura con el mismo Name, 
ya que el campo Name es un unique index.
- Ninguno de los campos debería estar vacío.
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
				PRINT 'No se encontró una cultura con ese ID'
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
				PRINT 'No se encontró una cultura con ese ID'
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
2, este debe emitir todos los datos en sus parámetros de salida. ¿Cómo se 
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

/* 9- Realizar una modificación al sp p_InsCulture para que valide los registros 
ingresados. Por lo cual, deberá invocar al sp p_ValCulture. Sólo se insertará 
si la validación es correcta.*/ 

ALTER PROCEDURE p_InsCulture (
	@p_id NCHAR(12),
	@p_name NVARCHAR(100),
	@p_date DATE = NULL
) AS
BEGIN
	
	DECLARE @v_date DATE, @v_valida SMALLINT;
	SET @v_date = GETDATE();
	EXECUTE p_ValCulture @p_id, @p_name, @p_date, 'I', @v_valida OUTPUT;
	IF @v_valida = 1
		BEGIN
			PRINT('Operacion realizada con éxito');
			SELECT *  FROM Production.Culture WHERE CultureID = @p_id;
		END 
	ELSE
		BEGIN
			THROW 50000, 'Error', 1;
		END
END;

EXEC p_InsCulture 'x1s', 'Super Small Bros';


/*10-Idem con el sp p_UpdCulture. Validar los datos a actualizar. */ 

ALTER PROCEDURE p_UpdCulture
	@p_id NCHAR(12),
	@p_name NVARCHAR(100),
	@p_date DATE = NULL
AS
BEGIN

	DECLARE @v_date DATE, @v_valida SMALLINT;
	SET @v_date = GETDATE();
	EXECUTE p_ValCulture @p_id, @p_name, @p_date, 'U', @v_valida OUTPUT;
	IF @v_valida = 1
		BEGIN
			PRINT('Operacion realizada con éxito');
			SELECT *  FROM Production.Culture WHERE CultureID = @p_id;
		END 
	ELSE
		THROW 50000, 'Error', 1;
END; 

EXEC p_UpdCulture 'ar', 'Papita';

/* 11-En p_DelCulture se deberá modificar para que valide que no posea registros 
relacionados en la tabla que lo referencia. Investigar cuál es la tabla 
referenciada e incluir esta validación. Si se está utilizando, emitir un 
mensaje que no se podrá eliminar. */

ALTER PROCEDURE p_DelCulture
	@p_id NCHAR(12)
AS
BEGIN
	DECLARE @v_referencias SMALLINT;
	SELECT @v_referencias = COUNT(c.CultureID)
			FROM Production.Culture c
			WHERE c.CultureID = @p_id 
			AND c.CultureID IN (SELECT CultureID FROM Production.ProductModelProductDescriptionCulture);
	IF @v_referencias >= 1
		THROW 50000, 'La PK se encuentra referenciada en otra tabla', 1;
	ELSE 
		BEGIN 
			DECLARE @v_valida SMALLINT;
				EXECUTE p_ValCulture @p_id, 'deleted_object', NULL, 'D', @v_valida OUTPUT;
				IF @v_valida = 1
					PRINT ('Se elimino la Cultura con id = ' + CAST(@p_id AS VARCHAR));
		END
END;

EXEC p_DelCulture 'x1s';

select * from Production.Culture;

/* 12-p_CrearCultureHis: Realizar un sp que permita crear la siguiente tabla 
histórica de Cultura. Si existe deberá eliminarse. Ejecutar el procedimiento 
para que se pueda crear:
CREATE TABLE Production.CultureHis( 
CultureID nchar(6) NOT NULL,
Name [dbo].[Name] NOT NULL,
ModifiedDate datetime NOT NULL CONSTRAINT
DF_CultureHis_ModifiedDate DEFAULT (getdate()), 
CONSTRAINT PK_CultureHis_IDDate PRIMARY KEY CLUSTERED (CultureID,
ModifiedDate)
)
- ¿Qué tipo de datos posee asignado el campo Name?
- ¿Qué sucede si no se inserta el campo ModifiedDate?
*/

CREATE OR ALTER PROCEDURE p_CrearCultureHis 
AS
BEGIN TRY
	BEGIN TRANSACTION
		IF OBJECT_ID('Production.CultureHis') IS NOT NULL
			BEGIN
				DROP TABLE Production.CultureHis;
				PRINT 'La tabla Production.CultureHis ha sido eliminada.';
			END
		ELSE
			BEGIN
				CREATE TABLE Production.CultureHis( 
					CultureID nchar(6) NOT NULL,
					Name [dbo].[Name] NOT NULL,
					ModifiedDate datetime NOT NULL CONSTRAINT
					DF_CultureHis_ModifiedDate DEFAULT (getdate()), 
					CONSTRAINT PK_CultureHis_IDDate PRIMARY KEY CLUSTERED (CultureID, ModifiedDate)
				)
				PRINT 'La tabla Production.CultureHis ha sido creada';
			END

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS ERROR;
	ROLLBACK TRANSACTION;
END CATCH

SELECT * FROM Production.CultureHis;

EXECUTE p_CrearCultureHis;

/* sirve para saber q tabla usa determinada FK */ 
SELECT t.name AS TableName
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.name = 'PK_CultureHis_IDDate';

-- ¿Qué sucede si no se inserta el campo ModifiedDate?
/* Si no se inserta un valor para el campo ModifiedDate, se aplicará la restricción DEFAULT (getdate()). 
Esto significa que si no se proporciona un valor explícito para ModifiedDate durante una operación de inserción, 
se utilizará automáticamente la fecha y hora actuales como valor predeterminado.

-- ¿Qué tipo de datos posee asignado el campo Name?
/* Sí, la definición Name [dbo].[Name] en la creación de la tabla Production.CultureHis indica que el 
campo Name en esta tabla es del mismo tipo que el campo Name en la tabla dbo.Name. Esta sintaxis es comúnmente 
utilizada cuando se desea hacer referencia a un tipo de datos definido previamente en la base de datos. 
Name [dbo].[Name] indica que el campo Name en la tabla Production.CultureHis utilizará el mismo tipo de datos definido en 
la tabla dbo.Name. Esto promueve la consistencia en la base de datos y facilita la administración de los tipos de datos personalizados.*/

/* 13-Dada la tabla histórica creada en el punto 12, se desea modificar el 
procedimiento p_UpdCulture creado en el punto 4. La modificación consiste 
en que cada vez que se cambia algún valor de la tabla Culture se desea 
enviar el registro anterior a una tabla histórica. De esta forma, en la tabla 
Culture siempre tendremos el último registro y en la tabla CutureHis cada 
una de las modificaciones realizadas. */ */

CREATE OR ALTER FUNCTION f_validarUpdate(
	@p_id NCHAR(12), 
	@p_name NVARCHAR(100),
	@p_date DATE = NULL
)
	RETURNS SMALLINT
AS 
BEGIN 
	DECLARE @v_result SMALLINT;
	IF @p_date IS NULL
		SET @p_date = GETDATE();
	IF @p_id IS NULL OR @p_name IS NULL OR @p_date > GETDATE()
       SET @v_result = 0;
	ELSE 
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Production.Culture WHERE CultureID = @p_id) 
			BEGIN
				SET @v_result = 0;
			END
			IF EXISTS (SELECT 1 FROM Production.Culture c WHERE c.Name = @p_name) 
			BEGIN
				SET @v_result = 0;
			END 
			SET @v_result = 1;
		END
	RETURN @v_result;
END; 

CREATE OR ALTER PROCEDURE p_UpdCulture
	@p_id NCHAR(12), 
	@p_name NVARCHAR(100),
	@p_date DATE = NULL
AS
BEGIN
	DECLARE @is_ok SMALLINT;
	IF @p_date IS NULL
		SET @p_date = GETDATE();
	SELECT @is_ok = dbo.f_validarUpdate (@p_id, @p_name, @p_date);
	IF @is_ok = 1
		BEGIN TRY
			BEGIN TRANSACTION

				INSERT INTO Production.CultureHis (CultureID, Name, ModifiedDate)
				SELECT CultureID, Name, ModifiedDate 
				FROM Production.Culture 
				WHERE CultureID = @p_id;

				UPDATE Production.Culture 
				SET Name = @p_name, ModifiedDate = @p_date  
				WHERE CultureID = @p_id; 

			COMMIT TRANSACTION; 
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE() MENSAJE
			ROLLBACK TRANSACTION
		END CATCH
	ELSE 
		THROW 50000, 'Error en los parametros insertados', 1;
END;

EXEC p_UpdCulture 'ar', 'florianopolis';

SELECT * FROM Production.CultureHis
SELECT * FROM Production.Culture;

/* 14-p_UserTables(opcional esquema): Realizar un procedimiento que liste 
las tablas que hayan sido creadas dentro de la base de datos con su 
nombre, esquema y fecha de creación. En el caso que se ingrese por 
parámetro el esquema, entonces mostrar únicamente dichas tablas, de lo 
contrario, mostrar todos los esquemas de la base. */

CREATE OR ALTER PROCEDURE p_UserTables (
	@SchemaName NVARCHAR(128) = NULL
)
AS 
BEGIN
	IF @SchemaName IS NULL
		BEGIN
			SELECT 
			t.name AS Nombre_Tabla,
			s.name AS Esquema,
			t.create_date AS Fecha_Creacion
			FROM 
				sys.tables t
			INNER JOIN 
				sys.schemas s ON t.schema_id = s.schema_id
			ORDER BY 
				t.create_date DESC;
		END
	ELSE
		BEGIN
			SELECT 
			t.name AS Nombre_Tabla,
			s.name AS Esquema,
			t.create_date AS Fecha_Creacion
			FROM 
				sys.tables t
			INNER JOIN 
				sys.schemas s ON t.schema_id = s.schema_id
			WHERE s.name = @SchemaName
			ORDER BY 
				t.create_date DESC;
		END
END; 

EXEC p_UserTables 'Discos';

/* 15-p_GenerarProductoxColor(): Generar un procedimiento que divida los 
productos según el color que poseen. Los mismos deben ser insertados en 
diferentes tablas según el color del producto. Por ejemplo, las tablas podrían 
ser Product_Black, Product_Silver, etc… Estas tablas deben ser generadas 
dinámicamente según los colores que existan en los productos, es decir, si 
genero un nuevo producto con un nuevo color, al ejecutar el procedimiento 
debe generar dicho color. Cada vez que se ejecute este procedimiento se 
recrearán las tablas de colores. Los productos que no posean color 
asignados, no se tendrán en cuenta para la generación de tablas y no se 
insertarán en ninguna tabla de color. */

/* pato */

alter procedure p_GenerarProductoxColor
as 
begin try
	begin transaction
	DECLARE @color nvarchar(15);
	DECLARE @sql NVARCHAR(MAX);

	declare  curColor cursor for  select distinct  Color from [Production].[Product] where Color is not null
	open curColor
	
	fetch next from curColor into @color
	while (@@FETCH_STATUS =0)
	BEGIN
		SET @sql = 'IF EXISTS ( SELECT 1 FROM sys.tables WHERE NAME  = ''Product_'+@color+''' )
						DROP TABLE [Production].[Product_'+@color+'];';
			EXEC sp_executesql @sql;

            SET @sql = 'CREATE TABLE [Production].[Product_'+@color+'] (' +
                       '    ProductId INT PRIMARY KEY,' +
                       '    name NVARCHAR(50)); ' ;
			EXEC sp_executesql @sql;

             SET @sql= 'INSERT INTO [Production].[Product_'+@color+'] ' +
                       'SELECT ProductID, name ' +
                       'FROM [Production].[Product] WHERE Color = ''' + @color + ''';';
            EXEC sp_executesql @sql;
		 
		fetch next from curColor into @color
		
	end 
	close curColor
	deallocate curColor

	commit transaction
END try
begin catch

	close curColor
	deallocate curColor
	SELECT ERROR_LINE(),ERROR_PROCEDURE(), ERROR_MESSAGE() MENSAJE
	rollback transaction
end catch


 SELECT 1 FROM sys.tables WHERE NAME  = 'Product_Black'

execute p_GenerarProductoxColor

drop table [Product].[Product_@color]


/* gpt */

CREATE OR ALTER PROCEDURE p_GenerarProductoxColor
AS
BEGIN
    -- Variables
    DECLARE @sql NVARCHAR(MAX);
    
    -- Crear una tabla temporal para almacenar los colores únicos de los productos
    IF OBJECT_ID('tempdb..#Colores') IS NOT NULL
        DROP TABLE #Colores;
    CREATE TABLE #Colores (Color NVARCHAR(50));
    
    -- Insertar los colores únicos de los productos en la tabla temporal
    INSERT INTO #Colores (Color)
    SELECT DISTINCT Color
    FROM Production.Product
    WHERE Color IS NOT NULL;

    -- Iterar sobre los colores y generar tablas dinámicas
    DECLARE @Color NVARCHAR(50);
    DECLARE color_cursor CURSOR FOR
    SELECT Color FROM #Colores;
    
    OPEN color_cursor;
    FETCH NEXT FROM color_cursor INTO @Color;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'IF OBJECT_ID(''Production.Product_' + REPLACE(@Color, ' ', '_') + ''') IS NOT NULL
                        DROP TABLE Production.Product_' + REPLACE(@Color, ' ', '_') + ';
                    SELECT * INTO Production.Product_' + REPLACE(@Color, ' ', '_') + '
                    FROM Production.Product
                    WHERE Color = ''' + @Color + ''';';
                    
        EXEC sp_executesql @sql;
        
        FETCH NEXT FROM color_cursor INTO @Color;
    END
    
    CLOSE color_cursor;
    DEALLOCATE color_cursor;
END;

EXEC p_GenerarProductoxColor; 



/* DECLARE color_cursor CURSOR FOR SELECT Color FROM #Colores;: 
Esta instrucción declara un cursor llamado color_cursor que se utilizará para iterar sobre los resultados 
de la consulta SELECT Color FROM #Colores. Un cursor es un objeto que permite recorrer fila por fila un 
conjunto de resultados devuelto por una consulta.

OPEN color_cursor;:
Esta instrucción abre el cursor, lo que significa que está listo para empezar a procesar las filas devueltas
por la consulta subyacente.

FETCH NEXT FROM color_cursor INTO @Color;: 
Esta instrucción recupera la siguiente fila del cursor y almacena el valor de la columna Color en la variable 
@Color. FETCH NEXT se utiliza para avanzar al siguiente registro del cursor.

WHILE @@FETCH_STATUS = 0: 
Esta es una estructura de control de flujo que ejecuta el código contenido en su bloque mientras @@FETCH_STATUS 
sea igual a 0. @@FETCH_STATUS es una variable de sistema que indica el estado de la última operación FETCH. Si 
el estado es 0, significa que se recuperó una fila correctamente y el bucle debe continuar.

CLOSE color_cursor;:
Esta instrucción cierra el cursor después de que se ha completado el procesamiento de todas las filas.

DEALLOCATE color_cursor;:
Esta instrucción libera los recursos asociados con el cursor, eliminando el cursor de la memoria.

En resumen, estas instrucciones se utilizan juntas para recorrer iterativamente las filas devueltas por la
consulta y realizar alguna acción con cada fila, como almacenar los valores en una variable o procesarlos 
de alguna otra manera. */


/* 16-p_UltimoProducto(param): Realizar un procedimiento que devuelva en 
sus parámetros (output), el último producto ingresado. */

CREATE OR ALTER PROCEDURE p_UltimoProducto(
	@p_product INT OUTPUT
)
AS
BEGIN
	SET @p_product = (SELECT TOP 1 ProductID FROM Production.Product ORDER BY ProductID DESC);
END; 

DECLARE @var INT;
EXEC p_UltimoProducto @var OUTPUT;
SELECT * FROM Production.Product WHERE ProductID = @var;

/* 17-p_TotalVentas(fecha): Realizar un procedimiento que devuelva el total 
facturado en un día dado. El procedimiento, simplemente debe devolver el 
total monetario de lo facturado (Sales) */

create procedure p_TotalVentas
@date datetime, @resultado money output
as 
begin try
	select @resultado=sum(TotalDue) from [Sales].[SalesOrderHeader]
	where OrderDate =@date

	if @resultado is null 
		set @resultado =0;
end try
begin catch
	select ERROR_MESSAGE() mensaje
end catch


declare @resultado money
execute p_TotalVentas '2011-05-31' , @resultado output
print @resultado