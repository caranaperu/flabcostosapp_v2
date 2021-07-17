/**
 * Definicion del modelo para los items de la relacion tipo aplicacion-Procesos
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui
 */
isc.RestDataSource.create({
    ID: "mdl_taplicacion_procesos_detalle",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "taplicacion_procesos_detalle_id", primaryKey: "true", required: true},
        {name: "taplicacion_procesos_id", foreignKey: "mdl_producto_procesos.taplicacion_procesos_id", required: true},
        {name: "procesos_codigo", foreignKey: "mdl_procesos.procesos_id", title:'Proceso',required: true},
        {
            name: "taplicacion_procesos_detalle_porcentaje", title: 'Porcentaje', required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 0.01,
                max: 100.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        // Campos join
        {name: "procesos_descripcion", title: 'Procesos'}
    ],
    fetchDataURL: glb_dataUrl + 'tipoAplicacionProcesosDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoAplicacionProcesosDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoAplicacionProcesosDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoAplicacionProcesosDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});