isc.defineClass("RestDataSourceTipoAplicacionEntries", "RestDataSourceExt");

isc.RestDataSourceTipoAplicacionEntries.create({
    /**
     * Definicion del modelo para los ingresos de cada entrada de valor para cada tipo de costo global valido
     * desde una determinada fecha.
     *
     * @version 1.00
     * @since 17-MAY-2021
     * @Author: Carlos Arana Reategui
     */
    ID: "mdl_taplicacion_entries",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "taplicacion_entries_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {name: "taplicacion_entries_descripcion", title: "Descripcion", required: true},
        {name: "taplicacion_codigo", title: 'Tipo Aplicacion', foreignKey: "mdl_taplicacion.taplicacion_codigo", required: true},
    ],
    fetchDataURL: glb_dataUrl + 'tipoAplicacionEntriesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoAplicacionEntriesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoAplicacionEntriesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoAplicacionEntriesController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
            dataProtocol: "postParams"
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        }
    ]
});