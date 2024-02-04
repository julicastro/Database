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

CREATE PROCEDURE p_DelCulture
	@p_id NCHAR(12)

/* 4- p_UpdCulture(id): Dado un id debe permitirme cambiar el campo name 
del registro.
5- sp_CantCulture (cant out): Realizar un sp que devuelva la cantidad de 
registros en Culture. El resultado deber� colocarlo en una variable de salida.
6- sp_CultureAsignadas : Realizar un sp que devuelva solamente las 
Culture�s que est�n siendo utilizadas en las tablas (Verificar qu� tabla/s la 
est�n referenciando). S�lo debemos devolver id y nombre de la Cultura.
7- p_ValCulture(id,name,date,operaci�n, valida out): Este sp permitir� 
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
8- p_SelCulture2(id out, name out, date out): A diferencia del sp del punto 
2, este debe emitir todos los datos en sus par�metros de salida. �C�mo se 
debe realizar la llamada del sp para testear este sp?
9- Realizar una modificaci�n al sp p_InsCulture para que valide los registros 
ingresados. Por lo cual, deber� invocar al sp p_ValCulture. S�lo se insertar� 
si la validaci�n es correcta.
10-Idem con el sp p_UpdCulture. Validar los datos a actualizar.
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
Universidad Nacional de La Matanza 
Pr�ctica de Laboratorio
Base de Datos II SQL Server 2014
- 2 -
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