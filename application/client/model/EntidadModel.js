/**
 * Definicion del modelo para las jefaturas municipales
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.RestDataSource.create({
    ID: "mdl_entidad",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "entidad_id", title: "id", canEdit: "false", primaryKey: true,required: false},
        {name: "entidad_razon_social", title: "Razon Social", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText},{type: "lengthRange", max: 200}]
        },
        {name: "entidad_ruc", title: "R.U.C", mask: '###########', required: true,validators: [{type: "lengthRange", min: 11, max : 11}]},
        {name: "entidad_direccion", title: "Direccion", required: true,
            validators: [{type: "lengthRange", max: 200}]
        },
        {name: "entidad_correo", title: "Correo", validators: [{type: "regexp", expression: glb_RE_email},{type: "lengthRange", max: 100}]},
        {name: "entidad_telefonos", title: "Telefonos",validators: [{type: "lengthRange", max: 60}]},
        {name: "entidad_fax", title: "Fax", mask:glb_MSK_phone, validators: [{type: "lengthRange", min: 7, max : 10}]}
    ],
    fetchDataURL: glb_dataUrl + 'entidadController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'entidadController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'entidadController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'entidadController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"}
    ]
});