/**
 * Definicion del modelo para los productos que pueden seleccionarse como
 * componentes de una cotizacion.
 *
 * Solo se acepta querys no se graba a traves de este modelo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_producto_cotizacion_detalle",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "insumo_id",
            title: "Id",
            primaryKey: "true"
        },
        {
            name: "insumo_codigo",
            title: "Codigo",
        },
        {
            name: "insumo_descripcion",
            title: "Descripcion"
        },
        {name: "unidad_medida_codigo"},
        {name: "unidad_medida_descripcion"},
        {name: "moneda_simbolo"},
        {name: "precio_original",type: 'double'},
        {name: "precio_cotizar",type: 'double'},
    ],
    fetchDataURL: glb_dataUrl + 'productoController?op=fetch&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        }
    ]
});