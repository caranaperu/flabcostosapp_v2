/**
 * Definicion del modelo para la cabecera de la relacion tipo aplicacion - Procesos
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
isc.defineClass("RestDataSourceTipoAplicacionProcesos", "RestDataSourceExt");

isc.RestDataSourceTipoAplicacionProcesos.create({
    ID: "mdl_taplicacion_procesos",
    fields: [
        {name: "taplicacion_procesos_id", primaryKey: "true", required: true},
        {name: "taplicacion_codigo",title: 'Modo de Aplicacion',foreignKey: "mdl_taplicacion.taplicacion_codigo", required: true},
        {name: "taplicacion_procesos_fecha_desde",title:'Fecha Desde',type: 'date',required: true},
        // Campos join
        {name: "taplicacion_descripcion",title:'Descripcion'}
    ],
    fetchDataURL: glb_dataUrl + 'tipoAplicacionProcesosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoAplicacionProcesosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoAplicacionProcesosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoAplicacionProcesosController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});