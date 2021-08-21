/**
 * Definicion del modelo para los clientes
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("RestDataSourceCliente", "RestDataSourceExt");

isc.RestDataSourceCliente.create({
    ID: "mdl_cliente",
    jsonPrefix: '',
    jsonSuffix: '',
    dataFormat: "json",
  //  disableQueuing: true,
    fields: [
        {name: "cliente_id", title: "id", canEdit: "false", primaryKey: true,required: false},
        {name: "empresa_id", title: "Empresa",foreignKey: "mdl_empresa.empresa_id"},
        {name: "cliente_razon_social", title: "Razon Social", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText},{type: "lengthRange", max: 200}]
        },
        {name: "cliente_ruc", title: "R.U.C", mask: '###########', required: true,validators: [{type: "lengthRange", min: 11, max : 11}]},
        {name: "cliente_direccion", title: "Direccion", required: true,
            validators: [{type: "lengthRange", max: 200}]
        },
        {name: "cliente_correo", title: "Correo", validators: [{type: "regexp", expression: glb_RE_email},{type: "lengthRange", max: 100}]},
        {name: "cliente_telefonos", title: "Telefonos",validators: [{type: "lengthRange", max: 60}]},
        {name: "cliente_fax", title: "Fax", mask:glb_MSK_phone, validators: [{type: "lengthRange", min: 7, max : 10}]},
        {name: "tipo_cliente_codigo", required: true,  foreignKey: "mdl_tipo_cliente.tipo_cliente_codigo"},
        // virtual
        {name: "tipo_cliente_descripcion", title: 'Tipo Cliente'}

    ],
    fetchDataURL: glb_dataUrl + 'clienteController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'clienteController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'clienteController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'clienteController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"}
    ]
});