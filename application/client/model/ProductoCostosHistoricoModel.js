/**
 * Definicion del modelo para obtener la lista de costos historicos asociados a un producto
 * usado para efectos de presentacion o consulta.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_producto_costos_historico",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
   // dropExtraFields: true,
    fields: [
        {name: "costos_list_detalle_id", primaryKey: "true", required: true},
        {name: "costos_list_fecha", type: "datetime", title:"Fecha Calculo"},
        {name: "costos_list_descripcion",title:"Descripcion"},
        {name: "moneda_descripcion",title: 'Moneda'},
        {name: "costos_list_detalle_costo_base",title: 'Costo Base',type: 'float'},
        {name: "costos_list_detalle_costo_agregado",title: 'Costo Agregado',type: 'float'},
        {name: "costos_list_detalle_costo_total",title: 'Costo Total',type: 'float'},

    ],
    fetchDataURL: glb_dataUrl + 'costosListDetalleController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]
});