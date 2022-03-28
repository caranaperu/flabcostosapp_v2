/**
 * Definicion del modelo para las monedas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:53:42 -0500 (dom, 06 abr 2014) $
 */
isc.defineClass("RestDataSourceMoneda", "RestDataSourceExt");

isc.RestDataSourceMoneda.create({
    ID: "mdl_moneda",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "moneda_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "moneda_descripcion", title: "Descripcion", required: true},
        {name: "moneda_simbolo", title: "Siglas", required: true},
        {name: "moneda_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_moneda._getBooleanFieldValue(v);
            }, required: true}

    ],
    fetchDataURL: glb_dataUrl + 'monedaController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'monedaController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'monedaController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'monedaController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});