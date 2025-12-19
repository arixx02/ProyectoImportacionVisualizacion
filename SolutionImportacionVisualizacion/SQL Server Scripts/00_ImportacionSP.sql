USE master;
GO

DROP DATABASE IF EXISTS pruebaTecnica;
GO

CREATE DATABASE proyecto;
GO

USE proyecto;
GO

CREATE SCHEMA importacion;
GO 

CREATE OR ALTER PROCEDURE importacion.importaciones
AS
BEGIN
	CREATE TABLE importacion.#estudianteTemp (
		id_subida VARCHAR(50),
		genero VARCHAR(10),
		cue VARCHAR(50),
		horas VARCHAR(50),
		instpadre VARCHAR(50),
		instmadre VARCHAR(50),
		paisorigen VARCHAR(50),
		paisprocedencia VARCHAR(50),
		fechaingresopais VARCHAR(50),
		paistituloanterior VARCHAR(50),
		idinstitucion VARCHAR(50),
		idtitulo VARCHAR(50),
		anioingreso VARCHAR(10),
		formaingreso VARCHAR(50),
		fechaegreso VARCHAR(50),
		idinstitucioningreso VARCHAR(50),
		idinstitucionegreso VARCHAR(50),
		codigoprocedencia VARCHAR(50),
		anioinformado VARCHAR(10),
		tienecud VARCHAR(10),
		id_persona VARCHAR(50)
	);


	CREATE TABLE [dbo].[estudianteInformado] (
		[idinstitucion] INT,
		[genero] SMALLINT,
		[idtitulo] INT,
		[paisorigen] INT,
		[paisprocedencia] INT,
		[anioingreso] INT, 
		[anioinformado] INT,
		[fechaegreso] DATE,
		[id_persona] VARCHAR(50)
	);

	BULK INSERT importacion.#estudianteTemp
	FROM 'RutaArchivo\a1_anon.csv'
	WITH (
		FIELDTERMINATOR = ';',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2,  
		TABLOCK
	);

	INSERT INTO dbo.estudianteInformado (idinstitucion, genero,idtitulo, paisorigen, paisprocedencia, anioingreso, anioinformado, fechaegreso, id_persona)
	SELECT
		TRY_CONVERT(INT,idinstitucion),
		TRY_CONVERT(SMALLINT,genero),
		TRY_CONVERT(INT,idtitulo),
		TRY_CONVERT(INT, paisorigen),
		TRY_CONVERT(INT, paisprocedencia),
		TRY_CONVERT(INT, anioingreso),
		TRY_CONVERT(INT, anioinformado),
		TRY_CONVERT(DATE, fechaegreso, 103),  -- 103 = dd/mm/yyyy
		id_persona
	FROM importacion.#estudianteTemp;

	SELECT COUNT(*) AS filasEstudiantesTemp FROM importacion.#estudianteTemp;
	SELECT COUNT(*) AS filasEstudiantesImportadas FROM estudianteInformado;

	CREATE TABLE [dbo].[materiaAprobadaDesaprobada] (
		[idinstitucion] INT,
		[idtitulo] INT,
		[fechaaprobacion] DATE,
		[aprobado] BIT,
		[codigomateria] VARCHAR(MAX),
		[nombremateria] NVARCHAR(MAX),
		[cargahoraria] INT,
		[formaaprobacion] INT,
		[id_persona] VARCHAR(50)
	)

	CREATE TABLE importacion.#materiasTemp (
		id_subida VARCHAR(50),
		idinstitucion VARCHAR(50),
		idtitulo VARCHAR(50),
		fechaaprobacion VARCHAR(20),
		aprobado VARCHAR(5),
		codigomateria VARCHAR(MAX),
		nombremateria NVARCHAR(MAX) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
		cargahoraria VARCHAR(MAX),
		formaaprobacion VARCHAR(50),
		aniocursada VARCHAR(10),
		libroactas VARCHAR(50),
		numeroactas VARCHAR(50),
		renglon VARCHAR(50),
		expediente VARCHAR(50),
		anioinformado VARCHAR(10),
		id_persona VARCHAR(50)
	);

	BULK INSERT importacion.#materiasTemp
	FROM 'RutaArchivo\a2_anon_arreglado.csv'
	WITH (
		CODEPAGE = '65001',   
		FIELDTERMINATOR = ';',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2,  
		TABLOCK
	);

	INSERT INTO dbo.materiaAprobadaDesaprobada (
		idinstitucion, 
		idtitulo, 
		fechaaprobacion, 
		aprobado, 
		codigomateria, 
		nombremateria, 
		cargahoraria, 
		formaaprobacion, 
		id_persona
	)
	SELECT
		TRY_CONVERT(INT, idinstitucion),
		TRY_CONVERT(INT, idtitulo),
		TRY_CONVERT(DATE, fechaaprobacion, 103),  -- 103 = dd/mm/yyyy
		CASE WHEN aprobado='1' THEN 1 ELSE 0 END,
		codigomateria,
		nombremateria,
		TRY_CONVERT(INT, cargahoraria),
		TRY_CONVERT(INT, formaaprobacion),
		id_persona
	FROM importacion.#materiasTemp;

	SELECT COUNT(*) AS filasMateriasTemp FROM importacion.#materiasTemp;
	SELECT COUNT(*) AS filasMateriasImportadas FROM materiaAprobadaDesaprobada;

	CREATE TABLE [dbo].[institucion] (
		idinstitucion INT NOT NULL,
		nombre_corto NVARCHAR(101),
		tipo VARCHAR(71),
		idpadreinstitucion VARCHAR(30),
		regimen VARCHAR(30),
		vigencia_hasta INT
	);


	CREATE TABLE importacion.#institucionTemp (
		idinstitucion VARCHAR(50),
		cuit VARCHAR(MAX),
		nombre VARCHAR(MAX),
		nombre_corto NVARCHAR(MAX),
		tipo VARCHAR(MAX),
		jurisdiccion VARCHAR(MAX),
		sigla VARCHAR(MAX),
		idpadreinstitucion VARCHAR(MAX),
		casillacorreo VARCHAR(MAX),
		clasificacion VARCHAR(MAX),
		regimen VARCHAR(MAX),
		observaciones VARCHAR(MAX),
		esuniversidad VARCHAR(MAX),
		modiuniversidad VARCHAR(MAX),
		email VARCHAR(MAX),
		web VARCHAR(MAX),
		cue VARCHAR(MAX),
		facebook VARCHAR(MAX),
		twitter VARCHAR(MAX),
		vigencia_hasta VARCHAR(MAX),
		solo_guia VARCHAR(MAX),
		nivelcpres VARCHAR(MAX),
		en_cpres VARCHAR(MAX),
		idnivel VARCHAR(MAX),
		en_sicer VARCHAR(MAX),
		prefijo VARCHAR(MAX),
		telefono1 VARCHAR(MAX),
		telefono2 VARCHAR(MAX)
	);

	BULK INSERT importacion.#institucionTemp
	FROM 'RutaArchivo\institución.csv'
	WITH (
		CODEPAGE = '65001',
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2,
		TABLOCK
	);

	INSERT INTO dbo.institucion (
		idinstitucion,
		nombre_corto,
		tipo,
		idpadreinstitucion,
		regimen,
		vigencia_hasta
	)
	SELECT
		TRY_CONVERT(INT, idinstitucion),
		NULLIF(REPLACE(nombre_corto,'"',''),''),
		NULLIF(REPLACE(tipo,'"',''),''),
		NULLIF(REPLACE(idpadreinstitucion,'"',''),''),
		NULLIF(REPLACE(regimen,'"',''),''),
		TRY_CONVERT(INT, vigencia_hasta)
	FROM importacion.#institucionTemp
	WHERE TRY_CONVERT(INT, idinstitucion) IS NOT NULL;

	SELECT COUNT(*) AS filasInstitucionTemp FROM importacion.#institucionTemp;
	SELECT COUNT(*) AS filasInstitucionImportadas FROM institucion;

	CREATE TABLE [dbo].[tipoTitulo] (
		idtipotitulo VARCHAR(200) NOT NULL UNIQUE,
		nombre NVARCHAR(60),
		nivel CHAR(1)
	);

	CREATE TABLE importacion.#tipoTituloTemp (
		idtipotitulo VARCHAR(200),
		nombre NVARCHAR(MAX),
		nivel VARCHAR(5),
		minanios VARCHAR(10),
		maxanios VARCHAR(10),
		esuniversidad VARCHAR(5),
		modiuniversidad VARCHAR(5),
		compatible VARCHAR(10)
	);
	
	BULK INSERT importacion.#tipoTituloTemp
	FROM 'RutaArchivo\tipotitulo.csv'  
	WITH (
		CODEPAGE = '65001',
		FIELDTERMINATOR = ',',   
		ROWTERMINATOR = '\n',    
		FIRSTROW = 2,           
		TABLOCK
	);
	
	
	INSERT INTO dbo.tipoTitulo (idtipotitulo, nombre, nivel)
	SELECT REPLACE(idtipotitulo,'"',''), REPLACE(nombre,'"',''), REPLACE(nivel,'"','')
	FROM importacion.#tipoTituloTemp;

	SELECT COUNT(*) AS filasTipoTituloTemp FROM importacion.#tipoTituloTemp;
	SELECT COUNT(*) AS filasTipoTituloImportadas FROM tipoTitulo;

	CREATE TABLE [dbo].[titulo] ( 
		idtitulo INT NOT NULL UNIQUE, 
		nombre NVARCHAR(MAX), 
		idtipotitulo VARCHAR(200) 
	)

	CREATE TABLE importacion.#tituloTemp (
		idtitulo VARCHAR(20),
		nombre NVARCHAR(MAX),
		idtipotitulo VARCHAR(200),
		idarea VARCHAR(500),
		idcarrera VARCHAR(50),
		tipotitulofijo VARCHAR(100),
		idtitulopresencial VARCHAR(100),
		fecha VARCHAR(20),
		esuniversidad VARCHAR(100),
		modiuniversidad VARCHAR(100),
		idterminal VARCHAR(100),
		idsubterminal VARCHAR(100),
		id_orientaciondiniece VARCHAR(100),
		anio_art_43 VARCHAR(100),
		resolucion_art_43 VARCHAR(50),
		en_sicer VARCHAR(100)
	);

	BULK INSERT importacion.#tituloTemp
	FROM 'RutaArchivo\titulo.csv'  
	WITH (
		CODEPAGE = '65001',
		FIELDTERMINATOR = ',',   
		ROWTERMINATOR = '\n',    
		FIRSTROW = 2,            
		TABLOCK
	);


	INSERT INTO dbo.titulo (idtitulo, nombre, idtipotitulo)
	SELECT
		TRY_CONVERT(INT, idtitulo),
		NULLIF(REPLACE(nombre,'"',''),''),
		REPLACE(idtipotitulo,'"','')
	FROM importacion.#tituloTemp
	WHERE TRY_CONVERT(INT, idtitulo) IS NOT NULL;

	SELECT COUNT(*) AS filasTituloTemp FROM importacion.#tituloTemp;
	SELECT COUNT(*) AS filasTituloImportadas FROM titulo;
END
GO