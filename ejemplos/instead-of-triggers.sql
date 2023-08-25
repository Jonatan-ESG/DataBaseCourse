-- INSTEAD OF

CREATE TABLE system_logs.producto_registro_cambios (
    producto_id INT NOT NULL,
    codigo_de_barras VARCHAR(20) NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion VARCHAR(300),
    categoria_id INT,
    marca_id INT,
    tipo_producto_id INT,
    um_recepcion_id INT,
    um_entrega_id INT,
    precio_unitario_entrega DECIMAL(10, 2),
    stock INT,
    stock_minimo INT,
    stock_maximo INT,
    servicio BIT,
    disponible_en_pos BIT,
    url_de_imagen VARCHAR(200),
    url_de_miniatura_de_imagen VARCHAR(200),
    ultima_fecha_vigente DATETIME NOT NULL
)
GO

CREATE TRIGGER trg_actualizacion_producto
ON inv.producto
INSTEAD OF UPDATE
AS
BEGIN
    -- Almacenar los valores anteriores en la tabla de registro de cambios (DELETED)
    INSERT INTO system_logs.producto_registro_cambios
    SELECT 
        *,
        GETDATE() AS ultima_fecha_vigente
    FROM deleted

    -- Realizar la actualización solicitada (INSERTED)
    UPDATE p
    SET 
        p.codigo_de_barras = i.codigo_de_barras,
        p.nombre_producto = i.nombre_producto,
        p.descripcion = i.descripcion,
        p.categoria_id = i.categoria_id,
        p.marca_id = i.marca_id,
        p.tipo_producto_id = i.tipo_producto_id,
        p.um_recepcion_id = i.um_recepcion_id,
        p.um_entrega_id = i.um_entrega_id,
        p.precio_unitario_entrega = i.precio_unitario_entrega,
        p.stock = i.stock,
        p.stock_minimo = i.stock_minimo,
        p.stock_maximo = i.stock_maximo,
        p.servicio = i.servicio,
        p.disponible_en_pos = i.disponible_en_pos,
        p.url_de_imagen = i.url_de_imagen,
        p.url_de_miniatura_de_imagen = i.url_de_miniatura_de_imagen
    FROM inv.producto p
    JOIN inserted i ON p.producto_id = i.producto_id

END
GO

SELECT * FROM inv.producto
WHERE producto_id = 12

UPDATE inv.producto
SET stock_minimo = 100, stock_maximo = 1000
WHERE producto_id = 12

SELECT * FROM system_logs.producto_registro_cambios

SELECT * FROM inv.detalle_operacion