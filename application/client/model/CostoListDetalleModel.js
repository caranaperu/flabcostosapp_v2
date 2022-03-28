/**
 * Definicion del modelo para los items de la costoList
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.defineClass("RestDataSourceCostosListDetalle", "RestDataSourceExt");

isc.RestDataSourceCostosListDetalle.create({
    ID: "mdl_costos_list_detalle",
    fields: [
        {name: "costos_list_detalle_id", primaryKey: "true", required: true},
        {name: "costos_list_id", foreignKey: "mdl_costos_list.costo_list_id", required: true},
        {name: "insumo_id"},
        {name: "costos_list_detalle_qty_presentacion",title: 'Presentacion'},
        {name: "unidad_medida_siglas",title: 'U.M'},
        {name: "insumo_descripcion",title: 'Producto'},
        {name: "taplicacion_entries_descripcion",title: 'Modo Aplicacion'},
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