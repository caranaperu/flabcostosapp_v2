/**
 * Definicion del modelo para las monedas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:53:42 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_tipocliente",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    //cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "tipo_cliente_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "tipo_cliente_descripcion", title: "Descripcion", required: true},
        {name: "tipo_cliente_protected", hidden:true,defaultValue: false}
    ],
    fetchDataURL: glb_dataUrl + 'tipoClienteController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoClienteController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoClienteController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoClienteController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});