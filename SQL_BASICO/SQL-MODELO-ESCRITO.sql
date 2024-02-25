#2 Se desea conocer cuantos productos y de cuantas categorias distintas provee cada proveedor
SELECT prv.nombre, COUNT(DISTINCT prd.COD_PROVEEDOR), COUNT(DISTINCT prd.COD_CATEGORIA)
	FROM provedor prv 
    JOIN producto prd 
    ON prv.COD_PRODUCTO = prd.COD_PRODUCTO
    JOIN categoria cat 
    ON prd.COD_CATEGORIA = cat.COD_CATEGORIA
    GROUP BY(prv.COD_PROVEEDOR);
                        
# 3. Informar la cantidad y el importe de productos vendidos por cada categoria
SELECT COUNT(fd.COD_PRODCUTO) AS Cantidad, (prd.PU * Cantidad) AS Importe
	FROM factura_detalle fd
    JOIN producto prd 
    ON fd.COD_PRODUCTO = prd.COD_PRODUCTO
    JOIN categoria ct 
    ON prd.COD_CATEGORIA = ct.COD_CATEGORIA
    GROUP BY prd.COD_CATEGORIA;
    
# 4. Listar los codigos de los productos q distribuye el provedor con el codigo 1001 y no los provea el 1005
SELECT prd.COD_PRODUCTO, prd.CPD_PROVEEDOR 
	FROM producto prd 
    WHERE prd.COD_PROVEDOR IN (SELECT pvd.COD_PROVEEDOR
						FROM provedor pvd
                        WHERE prd.COD_PROVEDOR = 1001
                        AND prd.COD_PROVEDOR NOT IN (SELECT pvd.COD_PROVEEDOR
												FROM provedor pvd
                                                WHERE prd.COD_PROVEDOR = 1005));

# 5. Hallas los codigos y nombres de los proveedores q proveen al menos un producto con alguna categoria 
-- el cual el precio es mayor a $800
SELECT pvd.COD_PROVEEDOR, pvd.nombre
	FROM proveedor pvd
    JOIN producto prd
    ON pvd.COD_PROVEEDOR = prd.COD_PROVEEDOR
    WHERE prd.PU > 800 
    AND prd.COD_CATEGORIA IN (SELECT COD_CATEGORIA 
						FROM categoria);
                        

SELECT PROV.COD_PROVEEDOR, PROV.nombre
	FROM PROVEEDOR PROV
	WHERE PROV.COD_PROV IN (SELECT P.COD_PROV 
					FROM PRODUCTO P 
					JOIN CATEGORIA C 
					ON C.COD_PRODUCTO = P.COD_PRODUCTO 
					WHERE P.IMPORTE > 800);
