/*
Validación de Stock Mínimo en Ventas

Escenario: Queremos asegurarnos de que el stock no caiga por debajo del stock mínimo cuando se realiza una venta.

Solución: Utilizaremos un INSTEAD OF trigger para validar el stock antes de procesar la venta.
*/
CREATE TRIGGER tr_venta_validacion_stock
ON inv.detalle_operacion
INSTEAD OF INSERT
AS
BEGIN
    -- Validar stock antes de insertar el detalle de operación
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN inv.producto p ON i.producto_id = p.producto_id
        WHERE p.stock - i.cantidad < p.stock_minimo
    )
    BEGIN
        RAISERROR('No hay suficiente stock disponible para realizar la venta.', 16, 1)
    END
    ELSE
    BEGIN
        -- Insertar el detalle de operación
        INSERT INTO inv.detalle_operacion (encabezado_operacion_id, producto_id, um_id, cantidad, precio_unitario)
        SELECT i.encabezado_operacion_id, i.producto_id, i.um_id, i.cantidad, i.precio_unitario
        FROM INSERTED i;
    END
END
GO

/*
Explicación: Este trigger reemplaza la inserción directa en la tabla inv.detalle_operacion al procesar una venta. Primero, verifica si la cantidad 
solicitada en la venta haría que el stock caiga por debajo del stock mínimo para cualquier producto. Si es así, se genera un error. Si el stock es suficiente, 
se realiza la inserción normalmente.
*/

-----------------------------------------------------------------------------------------------------------------
/*
Registro de Cambios en Operaciones

Escenario: Queremos mantener un registro de cambios cada vez que se realiza una operación en la tabla inv.encabezado_operacion.

Solución: Utilizaremos un INSTEAD OF trigger para capturar los detalles de la operación antes de que se registre en la tabla.
*/
CREATE TRIGGER tr_operacion_registro_cambios
ON inv.encabezado_operacion
INSTEAD OF INSERT
AS
BEGIN
    -- Crear tabla antes
    -- Insertar detalles de la operación en la tabla de registro de cambios
    INSERT INTO inv.operacion_registro_cambios (tipo_operacion_id, fecha, codigo, tipo_documento_id, numero_de_documento, fecha_de_documento, comentario, creado_en)
    SELECT i.tipo_operacion_id, i.fecha, i.codigo, i.tipo_documento_id, i.numero_de_documento, i.fecha_de_documento, i.comentario, GETDATE()
    FROM INSERTED i;
    
    -- Insertar la operación en la tabla principal
    INSERT INTO inv.encabezado_operacion (tipo_operacion_id, fecha, codigo, tipo_documento_id, numero_de_documento, fecha_de_documento, comentario)
    SELECT tipo_operacion_id, fecha, codigo, tipo_documento_id, numero_de_documento, fecha_de_documento, comentario
    FROM INSERTED;
END;
/*
Explicación: Este trigger reemplaza la inserción directa en la tabla inv.encabezado_operacion. Primero, captura los detalles de la operación usando la tabla INSERTED 
y los inserta en una tabla de registro de cambios inv.operacion_registro_cambios. Luego, realiza la inserción normal en la tabla inv.encabezado_operacion.
*/