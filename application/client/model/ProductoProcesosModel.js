/**
 * Definicion del modelo para la cabecera de la relacion producto - Procesos
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
isc.defineClass("RestDataSourceCotizacion", "RestDataSourceExt");


isc.RestDataSourceCotizacion.create({
    ID: "mdl_producto_procesos",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "producto_procesos_id", primaryKey: "true", required: true},
        {name: "insumo_id",title: 'Producto',foreignKey: "mdl_insumo.insumo_id", required: true},
        {name: "producto_procesos_fecha_desde",title:'Fecha Desde',type: 'date',required: true},
        // Campos join
        {name: "insumo_descripcion",title:'Producto'}
    ],
    fetchDataURL: glb_dataUrl + 'productoProcesosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'productoProcesosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'productoProcesosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'productoProcesosController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});