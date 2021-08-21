/**
 * Definicion del modelo para las monedas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:53:42 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_tipoempresa",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "tipo_empresa_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "tipo_empresa_descripcion", title: "Descripcion", required: true}
    ],
    fetchDataURL: glb_dataUrl + 'tipoEmpresaController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoEmpresaController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoEmpresaController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoEmpresaController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});