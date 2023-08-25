/*
Conversión de Unidades Automática en Operaciones

Escenario: Queremos que las cantidades ingresadas en las operaciones se conviertan automáticamente a la unidad de medida principal del producto si se utilizan unidades distintas.

Solución: Utilizaremos un FOR trigger para realizar la conversión de unidades antes de insertar los detalles de operación.
*/
CREATE TRIGGER tr_conversion_unidades_operacion
ON inv.detalle_operacion
FOR INSERT
AS
BEGIN
    -- Convertir cantidades a unidad de medida principal
    UPDATE i
    SET cantidad = i.cantidad * c.factor
    FROM INSERTED i
    JOIN inv.producto p ON i.producto_id = p.producto_id
    JOIN inv.conversion c ON i.um_id = c.um_origen_id AND p.um_recepcion_id = c.um_destino_id;
END
GO

/*
Explicación: Este FOR trigger se activa después de una inserción en la tabla inv.detalle_operacion. Cuando se inserta un nuevo detalle de operación, 
el trigger busca la conversión correspondiente en la tabla inv.conversion para convertir la cantidad a la unidad de medida principal del producto antes de insertarla.
*/

/*
Validación de Stock Máximo en Recepciones

Escenario: Queremos evitar que se reciba más stock del permitido cuando se realiza una recepción de productos.

Solución: Utilizaremos un FOR trigger para validar el stock máximo antes de insertar el detalle de la recepción.
*/
CREATE TRIGGER tr_validacion_stock_maximo_recepcion
ON inv.detalle_operacion
FOR INSERT
AS
BEGIN
    -- Validar stock máximo antes de insertar el detalle de recepción
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN inv.producto p ON i.producto_id = p.producto_id
        WHERE p.stock + i.cantidad > p.stock_maximo
    )
    BEGIN
        RAISERROR('El stock máximo sería superado. No es posible recibir más unidades.', 16, 1) 
    END
    ELSE
    BEGIN
        -- Insertar el detalle de recepción
        INSERT INTO inv.detalle_operacion (encabezado_operacion_id, producto_id, um_id, cantidad, precio_unitario)
        SELECT i.encabezado_operacion_id, i.producto_id, i.um_id, i.cantidad, i.precio_unitario
        FROM INSERTED i;
    END;
END
GO

/*
Explicación: Este FOR trigger se activa después de una inserción en la tabla inv.detalle_operacion. Verifica si la cantidad a recibir supera el 
stock máximo permitido para cualquier producto. Si es así, se genera un error. Si el stock no se supera, se realiza la inserción normalmente.
*/

