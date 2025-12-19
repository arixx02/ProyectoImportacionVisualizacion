USE pruebaTecnica;
GO

CREATE SCHEMA vistas;
GO

---- EJERCICIO 1
CREATE OR ALTER VIEW vistas.primero AS
	WITH estudiantes2023 AS (
		SELECT 
			i.idpadreinstitucion,
			CASE WHEN e.genero=1 THEN 'M' ELSE 'H' END AS genero, --suponiendo que 1 es mujer
			e.paisorigen,
			e.paisprocedencia,
			COUNT(*) AS totalEstudiantes,
			DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
		FROM institucion i
		JOIN estudianteInformado e 
			ON e.idinstitucion = i.idinstitucion
		WHERE e.anioinformado = 2023 AND i.idpadreinstitucion IS NOT NULL
		GROUP BY i.idpadreinstitucion, genero, e.paisorigen, e.paisprocedencia
	)
	SELECT 
		e.idpadreinstitucion,
		e.genero,
		CAST(e.paisorigen AS VARCHAR(MAX)) AS paisorigen, --castear como texto asi powerBI no hace la suma
		CAST(e.paisprocedencia AS VARCHAR(MAX)) AS paisprocedencia,
		e.totalEstudiantes
	FROM estudiantes2023 e
	WHERE ranking <= 10
GO

CREATE OR ALTER VIEW vistas.primeroB AS
	WITH estudiantesNivel AS (
		SELECT 
			i.idpadreinstitucion, 
			CASE WHEN e.genero=1 THEN 'M' ELSE 'H' END AS genero,
			e.paisorigen,
			e.paisprocedencia,
			u.nivel AS nivel, 
			COUNT(*) AS totalEstudiantes
		FROM institucion i
		JOIN estudianteInformado e ON e.idinstitucion=i.idinstitucion
		JOIN titulo t ON e.idtitulo=t.idtitulo
		JOIN tipoTitulo u ON u.idtipotitulo=t.idtipotitulo
		WHERE e.anioinformado=2023 AND i.idpadreinstitucion IS NOT NULL
		GROUP BY 
			i.idpadreinstitucion, 
			e.genero,
			e.paisorigen,
			e.paisprocedencia,
			u.nivel
	)
	SELECT 
		idpadreinstitucion,
		genero,
		CAST(paisorigen AS VARCHAR(MAX)) AS paisorigen,
		CAST(paisprocedencia AS VARCHAR(MAX)) AS paisprocedencia,
		[E] AS totalPregrado, 
		[G] AS totalGrado, 
		[P] AS totalPosgrado
	FROM estudiantesNivel
	PIVOT (
		MAX(totalEstudiantes) FOR nivel IN ([E],[G],[P])
	) AS pvt;
GO

--EJERCICIO 2
CREATE OR ALTER VIEW vistas.segundo AS 
	WITH estudiantes2023 AS (
		SELECT i.idpadreinstitucion, COUNT(*) AS totalEstudiantes
		FROM institucion i
		JOIN estudianteInformado e ON i.idinstitucion = e.idinstitucion
		WHERE e.anioinformado = 2023 AND i.idpadreinstitucion IS NOT NULL
		GROUP BY i.idpadreinstitucion
	),
	estudiantesRegulares AS (
		SELECT i.idpadreinstitucion, COUNT(*) AS cantidadRegulares
		FROM institucion i
		JOIN (
			SELECT m.id_persona, m.idinstitucion
			FROM materiaAprobadaDesaprobada m
			WHERE aprobado = 1 AND YEAR(m.fechaaprobacion) = 2023
			GROUP BY m.id_persona, m.idinstitucion
			HAVING COUNT(*) >= 2
		) a ON i.idinstitucion = a.idinstitucion
		WHERE i.idpadreinstitucion IS NOT NULL
		GROUP BY i.idpadreinstitucion
	),
	rango AS(
		SELECT
			e.idpadreinstitucion,
			CAST(ISNULL(r.cantidadRegulares, 0) AS DECIMAL(10,3)) / NULLIF(e.totalEstudiantes,0) AS porcentaje,
			DENSE_RANK() OVER (ORDER BY CAST(ISNULL(r.cantidadRegulares, 0) AS DECIMAL(10,3)) / NULLIF(e.totalEstudiantes,0) DESC) AS ranking
		FROM estudiantes2023 e
		JOIN estudiantesRegulares r ON e.idpadreinstitucion = r.idpadreinstitucion
	)
	SELECT
		r.idpadreinstitucion,
		r.porcentaje
	FROM rango r
	WHERE r.ranking<=3;
GO

--EJERCICIO 3 
CREATE OR ALTER VIEW vistas.tercero AS
	WITH estudiantes2023 AS (
		SELECT i.idpadreinstitucion, COUNT(*) AS totalEstudiantes2023
		FROM institucion i
		JOIN estudianteInformado e ON i.idinstitucion = e.idinstitucion
		WHERE e.anioinformado = 2023 AND i.idpadreinstitucion IS NOT NULL
		GROUP BY i.idpadreinstitucion
	),
	totalMateriasAprobadas AS (
		SELECT i.idpadreinstitucion, COUNT(*) AS totalAprobadas2023
		FROM institucion i
		JOIN materiaAprobadaDesaprobada m ON m.idinstitucion=i.idinstitucion
		WHERE YEAR(m.fechaaprobacion)=2023 AND m.aprobado=1 AND i.idpadreinstitucion IS NOT NULL
		GROUP BY i.idpadreinstitucion
	)
	SELECT e.idpadreinstitucion, CAST(t.totalAprobadas2023 AS DECIMAL(10,3))/e.totalEstudiantes2023 AS promedio_aprobadas
	FROM estudiantes2023 e
	JOIN totalMateriasAprobadas t ON t.idpadreinstitucion=e.idpadreinstitucion;
GO

--EJERCICIO 4
CREATE OR ALTER VIEW vistas.cuarto AS
	WITH totalEstudiantesCarrera AS(
		SELECT
			t.idtitulo, 
			t.nombre, 
			COUNT(*) AS totalEstudiantes,
			DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as ranking
		FROM estudianteInformado e
		JOIN titulo t ON t.idtitulo=e.idtitulo
		WHERE e.anioinformado=2023
		GROUP BY t.idtitulo, t.nombre
	)
	SELECT t.idtitulo, t.nombre, t.totalEstudiantes
	FROM totalEstudiantesCarrera t
	WHERE t.ranking<=5
GO

--EJERCICIO 5
CREATE OR ALTER VIEW vistas.quinto AS 
	WITH totalAprobados AS (
		SELECT 
			t.idtitulo, 
			t.nombre, 
			COUNT(*) AS aprobados,
			DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
		FROM estudianteInformado e
		JOIN titulo t ON t.idtitulo=e.idtitulo
		WHERE e.fechaegreso IS NOT NULL
		GROUP BY t.idtitulo, t.nombre
	)
	SELECT t.idtitulo, t.nombre, t.aprobados
	FROM totalAprobados t
	WHERE ranking<=10
GO

--EJERCICIO 6
CREATE OR ALTER VIEW vistas.sexto AS 
	WITH porcentajes AS (
		SELECT 
			t.idtitulo,
			t.nombre,
			CAST(COUNT(CASE WHEN e.fechaegreso IS NOT NULL THEN 1 END) AS DECIMAL(10,3)) 
				/ COUNT(*) AS porcentajeAprobados,
			DENSE_RANK() OVER (
				ORDER BY CAST(COUNT(CASE WHEN e.fechaegreso IS NOT NULL THEN 1 END) AS DECIMAL(10,3)) 
				/ NULLIF(COUNT(*),0) DESC
			) AS ranking
		FROM estudianteInformado e
		JOIN titulo t ON t.idtitulo = e.idtitulo
		GROUP BY t.idtitulo, t.nombre
	)
	SELECT idtitulo, nombre, porcentajeAprobados
	FROM porcentajes
	WHERE ranking <= 10;
GO

--EJERCICIO 7
CREATE OR ALTER VIEW vistas.septimo AS 
	WITH inscriptosEstatal2023 AS (
		SELECT 
			t.idtitulo, 
			t.nombre,
			COUNT(*) AS totalInscriptos2023
		FROM titulo t
		JOIN estudianteInformado e 
			ON e.idtitulo = t.idtitulo
		JOIN institucion i 
			ON e.idinstitucion = i.idinstitucion
		WHERE e.anioingreso = 2023
		  AND i.regimen = 'PU'
		GROUP BY t.idtitulo, t.nombre
	),
	rango AS (
		SELECT *,
			   DENSE_RANK() OVER (ORDER BY totalInscriptos2023 DESC) AS ranking
		FROM inscriptosEstatal2023 
	)
	SELECT idtitulo, nombre, totalInscriptos2023
	FROM rango
	WHERE ranking <= 10;
GO



