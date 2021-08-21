/**
 * Definicion del modelo para los sub procesos
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
isc.RestDataSource.create({
    ID: "mdl_subprocesos",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "subprocesos_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "subprocesos_descripcion", title: "Descripcion", required: true}

    ],
    fetchDataURL: glb_dataUrl + 'subProcesosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'subProcesosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'subProcesosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'subProcesosController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});