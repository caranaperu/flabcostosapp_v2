/**
 * Definicion del modelo para las empresas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.RestDataSource.create({
    ID: "mdl_empresa",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    disableQueuing: true,
    fields: [
        {name: "empresa_id", title: "id", canEdit: "false", primaryKey: true,required: false},
        {name: "empresa_razon_social", title: "Razon Social", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText},{type: "lengthRange", max: 200}]
        },
        {name: "empresa_ruc", title: "R.U.C", mask: '###########', required: true,validators: [{type: "lengthRange", min: 11, max : 11}]},
        {name: "empresa_direccion", title: "Direccion", required: true,
            validators: [{type: "lengthRange", max: 200}]
        },
        {name: "empresa_correo", title: "Correo", validators: [{type: "regexp", expression: glb_RE_email},{type: "lengthRange", max: 100}]},
        {name: "empresa_telefonos", title: "Telefonos",validators: [{type: "lengthRange", max: 60}]},
        {name: "empresa_fax", title: "Fax", mask:glb_MSK_phone, validators: [{type: "lengthRange", min: 7, max : 10}]},
        {name: "tipo_empresa_codigo", required: true,  foreignKey: "mdl_tipo_producto.tipo_empresa_codigo"},
        // virtual
        {name: "tipo_empresa_descripcion", title: 'Tipo Empresa'}

    ],
    fetchDataURL: glb_dataUrl + 'empresaController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'empresaController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'empresaController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'empresaController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"}
    ]
});