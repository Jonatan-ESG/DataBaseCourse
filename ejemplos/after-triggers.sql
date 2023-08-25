-- AFTER TRIGGERS
SELECT * FROM system_logs.logs_insercion

SELECT * FROM inv.categoria

INSERT INTO inv.categoria (categoria)
VALUES ('Categoria 1 para Video'), ('Categoria 2 para Video'),  ('Categoria 3 para Video')
GO

CREATE TRIGGER trg_insercion_categoria
ON inv.categoria
AFTER INSERT
AS
BEGIN
    INSERT INTO system_logs.logs_insercion (registro)
    SELECT 
        CONCAT('Se agregó una nueva categoría con el ID: ', inserted.categoria_id, ' y la descripción: ', inserted.categoria) AS registro
    FROM inserted
END
GO

DELETE FROM inv.categoria
WHERE categoria_id = 18
GO

CREATE TABLE system_logs.logs_eliminacion (
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registro VARCHAR(MAX)
)
GO

CREATE TRIGGER trg_eliminacion_categoria
ON inv.categoria
AFTER DELETE
AS
BEGIN
    INSERT INTO system_logs.logs_eliminacion (registro)
    SELECT 
        CONCAT('Se eliminó la categoría con el ID: ', deleted.categoria_id, ' y la descripción: ', deleted.categoria) AS registro
    FROM deleted
END
GO

DELETE FROM inv.categoria
WHERE categoria_id > 15
GO

SELECT * FROM system_logs.logs_insercion
UNION
SELECT * FROM system_logs.logs_eliminacion
GO


CREATE TABLE system_logs.logs_actualizacion (
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registro VARCHAR(MAX)
)
GO

CREATE TRIGGER trg_actualizacion_categoria
ON inv.categoria
AFTER UPDATE
AS 
BEGIN
    INSERT INTO system_logs.logs_actualizacion (registro)
    SELECT 
        CONCAT('Se actualizó la categoría con el ID: ', d.categoria_id, ' tenía una descripción de: ', d.categoria, ' y ahora es de: ', i.categoria) AS registro
    FROM deleted d
    JOIN inserted i on d.categoria_id = i.categoria_id
END

SELECT * FROM inv.categoria

UPDATE inv.categoria
SET categoria = 'Detergente Multiusos'
WHERE categoria_id = 13

SELECT * FROM system_logs.logs_actualizacion