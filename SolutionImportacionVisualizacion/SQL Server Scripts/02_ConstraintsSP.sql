USE pruebaTecnica
GO

CREATE OR ALTER PROCEDURE importacion.creacionConstraints
AS
BEGIN
	ALTER TABLE institucion
	ADD CONSTRAINT pk_institucion PRIMARY KEY (idinstitucion);

	ALTER TABLE titulo
	ADD CONSTRAINT pk_titulo PRIMARY KEY (idtitulo);

	ALTER TABLE tipoTitulo
	ADD CONSTRAINT pk_tipo PRIMARY KEY (idtipotitulo);

	ALTER TABLE estudianteInformado
	ADD CONSTRAINT fk_estudiante_titulo FOREIGN KEY (idtitulo) REFERENCES titulo(idtitulo);

	--INSERCION DE IDTIPOTITULO FALTANTES EN TIPOTITULO
	INSERT INTO dbo.tipoTitulo (idtipotitulo, nombre)
	OUTPUT inserted.idtipotitulo --MUESTRA LOS IDTIPOTITULO INSERTADOS
	SELECT DISTINCT i.idtipotitulo, 'T?tulo pendiente'
	FROM dbo.titulo i
	WHERE i.idtipotitulo NOT IN (SELECT idtipotitulo FROM dbo.tipoTitulo);

	ALTER TABLE titulo
	ADD CONSTRAINT fk_tipo_titulo FOREIGN KEY (idtipotitulo) REFERENCES tipoTitulo(idtipotitulo);

	ALTER TABLE materiaAprobadaDesaprobada
	ADD CONSTRAINT fk_materia_titulo FOREIGN KEY (idtitulo) REFERENCES titulo(idtitulo);

	ALTER TABLE materiaAprobadaDesaprobada
	ADD CONSTRAINT fk_materia_institucion FOREIGN KEY (idinstitucion) REFERENCES institucion(idinstitucion);

	ALTER TABLE estudianteInformado
	ADD CONSTRAINT fk_estudiante_institucion FOREIGN KEY (idinstitucion) REFERENCES institucion(idinstitucion);
END