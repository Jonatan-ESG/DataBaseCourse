-- FOR TRIGGERS
SELECT * FROM inv.encabezado_operacion

SELECT * FROM inv.detalle_operacion
GO

SELECT * FROM inv.producto
WHERE producto_id = 12
GO

CREATE TRIGGER trg_actualizacion_precio_producto
ON inv.producto
FOR UPDATE
AS
BEGIN
    UPDATE do
    SET precio_unitario = i.precio_unitario_entrega
    FROM inv.detalle_operacion do
    JOIN inserted i ON do.producto_id = i.producto_id
END
GO

UPDATE inv.producto
SET precio_unitario_entrega = 9.50
WHERE producto_id = 12
