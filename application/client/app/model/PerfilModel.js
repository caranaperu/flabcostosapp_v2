/**
 * Definicion del modelo De la clasificacion de documentos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.RestDataSource.create({
    ID: "mdl_perfil",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    //  requestProperties:  {params:{sys_systemcode:glb_systemident}},
  //  cacheAllData : true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "perfil_id", title: "ID", primaryKey: "true", canEdit: "false", required: true},
        {name: "sys_systemcode", title: "Cod.Sistema", canEdit: "false", required: true},
        {name: "perfil_codigo", title: "Codigo", canEdit: "true", required: true},
        {name: "perfil_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        }
    ],
    fetchDataURL: glb_dataUrl + 'perfilController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'perfilController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'perfilController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'perfilController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"}
    ]
});