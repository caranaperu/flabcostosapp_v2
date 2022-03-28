/**
 * Definicion del modelo para los items de la relacion producto-Procesos
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui
 */
isc.defineClass("RestDataSourceProductoProcesosDetalle", "RestDataSourceExt");

isc.RestDataSourceProductoProcesosDetalle.create({
    ID: "mdl_producto_procesos_detalle",
    fields: [
        {name: "producto_procesos_detalle_id", primaryKey: "true", required: true},
        {name: "producto_procesos_id", foreignKey: "mdl_producto_procesos.producto_procesos_id", required: true},
        {name: "procesos_codigo", foreignKey: "mdl_procesos.procesos_id", title:'Proceso',required: true},
        {
            name: "producto_procesos_detalle_porcentaje", title: 'Porcentaje', required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 0.00,
                max: 100.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        // Campos join
        {name: "procesos_descripcion", title: 'Procesos'}
    ],
    fetchDataURL: glb_dataUrl + 'productoProcesosDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'productoProcesosDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'productoProcesosDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'productoProcesosDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});