/**
 * Definicion del modelo para los procesos
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
isc.defineClass("RestDataSourceProcesos", "RestDataSourceExt");

isc.RestDataSourceProcesos.create({
    ID: "mdl_procesos",
    fields: [
        {name: "procesos_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "procesos_descripcion", title: "Descripcion", required: true}

    ],
    fetchDataURL: glb_dataUrl + 'procesosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'procesosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'procesosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'procesosController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});