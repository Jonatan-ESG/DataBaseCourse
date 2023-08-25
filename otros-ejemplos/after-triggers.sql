/*
Registro de Cambios Automático en Operaciones

Escenario: Queremos que cada vez que se realiza una operación, se registren automáticamente los cambios en una tabla de historial inv.operacion_historial.

Solución: Utilizaremos un AFTER trigger para registrar automáticamente los detalles de la operación en la tabla de historial.
*/
CREATE TRIGGER tr_registro_cambios_operacion
ON inv.detalle_operacion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Crear tabla
    -- Insertar detalles de operación en la tabla de historial
    INSERT INTO inv.operacion_historial (detalle_operacion_id, tipo_operacion, accion, fecha_registro)
    SELECT i.detalle_operacion_id, 
           CASE WHEN i.cantidad IS NOT NULL THEN 'UPDATE'
                WHEN d.producto_id IS NOT NULL THEN 'DELETE'
                ELSE 'INSERT' END AS tipo_operacion,
           CASE WHEN i.cantidad IS NOT NULL THEN 'Actualización'
                WHEN d.producto_id IS NOT NULL THEN 'Eliminación'
                ELSE 'Inserción' END AS accion,
           GETDATE() AS fecha_registro
    FROM INSERTED i
    FULL OUTER JOIN DELETED d ON i.detalle_operacion_id = d.detalle_operacion_id;
END
GO
/*
Explicación: Este AFTER trigger se activa después de una inserción, actualización o eliminación en la tabla inv.detalle_operacion. Captura los detalles de la operación
 y determina si se trata de una inserción, actualización o eliminación. Luego, registra estos cambios en la tabla de historial inv.operacion_historial.
*/

/*
Actualización de Precios Automática en Cambio de Unidad de Medida Principal

Escenario: Queremos que cada vez que se cambia la unidad de medida principal de un producto en la tabla inv.producto, se actualicen automáticamente 
los precios en las operaciones anteriores que involucran ese producto.

Solución: Utilizaremos un AFTER trigger para actualizar automáticamente los precios después de que se realice un cambio de unidad de medida principal.
*/

CREATE TRIGGER tr_actualizacion_precios_um_principal
ON inv.producto
AFTER UPDATE
AS
BEGIN
    -- Crear agregar factor anterior
    -- Actualizar precios en operaciones anteriores después de cambiar la UM principal
    UPDATE dop
    SET precio_unitario = d.precio_unitario_entrega * (c.factor / c.factor_anterior)
    FROM inv.detalle_operacion dop
    JOIN deleted d ON dop.producto_id = d.producto_id
    JOIN inserted i ON dop.producto_id = i.producto_id
    JOIN inv.conversion c ON d.um_recepcion_id = c.um_origen_id AND i.um_recepcion_id = c.um_destino_id;
END
GO


/*
Explicación: Este AFTER trigger se activa después de una actualización en la columna um_recepcion_id de la tabla inv.producto. Cuando se cambia la unidad de medida 
principal de un producto, el trigger busca las operaciones anteriores en la tabla inv.detalle_operacion que involucran ese producto y actualiza sus precios unitarios 
en función de la conversión de unidades.
*/