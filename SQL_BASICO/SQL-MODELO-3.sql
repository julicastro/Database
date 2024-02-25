
# 1. Listar cada Deporte con cantidad de equipos y jugadores totales actuales.

SELECT de.CodDeporte, de.nombre, COUNT(eq.idEquipo) AS cantidad_equipo, COUNT(ju.idJugador) 
		FROM deporte de
        JOIN equipo eq 
        ON de.CodDeporte = eq.CodDeporte
        JOIN jugador ju
        ON eq.idEquipo = ju.idEquipo
        GROUP BY de.codDeporte;
        
# 2. Encontar para todos los equipos (nombre) que hicieron podio (de primer a
# tercer lugar), los torneos en los que sucedió. Listar equipo, torneo y posición. 

SELECT *
		FROM posicion po
        JOIN equipo eq 
        ON po.idEquipo = eq.idEquipo
        JOIN torneo tr
        ON eq.idTorneo = tr.IdTorneo
        WHERE po.idPosicion IN (1, 2, 3);

# 5. Determinar los socios (DNI y nombre) que practican algún deporte y no son
# jugadores de ningún equipo.

SELECT so.dni, so.nombre
		FROM socio so
		WHERE so.dni IN (SELECT pr.dni
					FROM practica pr)
                    AND so.dni NOT IN (SELECT ju.dni
									FROM jugador ju);

# 6. Determinar los jugadores que practican todos los deportes ofrecidos en el club.

SELECT *
		FROM jugadores ju
        JOIN practica pr
        ON ju.dni = pr.dni
        GROUP BY ju.dni
        HAVING COUNT(pr.codDeporte) = (SELECT COUNT(*) FROM deporte);
        
# 7. Lista de torneos en los que se participó en los últimos 3 años por cada deporte.
SELECT tr.idTorneo
		FROM torneo tr
        WHERE tr.idTorneo IN (SELECT po.idTorneo
							FROM posicion po
                            JOIN equipo eq
                            ON po.idEquipo = eq.idEquipo
                            JOIN deporte de 
                            ON eq.codDeporte = de.codDeporte
                            WHERE tr.año > (tr.año-3)
                            GROUP BY de.codDeporte
                            );
        
# 8. Listar los torneos con la mayor cantidad de equipos.
select t.*
		from torneo t join posicion p on t.idTorneo = p.idTorneo
		group by p.idTorneo 
		having count(*) = (select count(*) as cantidadDeEquipos
		from posicion pos
		 group by pos.idTorneo
		 order by cantidadDeEquipos desc
		 limit 1);
				
# 9.istar los Socios que juegan en equipos con categoría "Profesional”
SELECT * 
		FROM socio so
        JOIN practica pr
        ON so.dni = pr.dni
        JOIN equipo eq
        ON pr.codDeporte = eq.codDeporte
        WHERE eq.categoria = 'Profesional';

# 10. Se quiere premiar con dinero a todos los jugadores que entraron al podio
# en los torneos del verano pasado, para ello necesitamos saber la máxima
# posición obtenida por cada uno.

SELECT ju.idJugador, MAX(po.posicion)
		from jugador ju
		join posicion po
        on ju.idEquipo = po.idEquipo
        where po.fecha between '2022-01-02' and '2022-05-05'
		group by ju.idJugador;
        
		

        

        
	
        
