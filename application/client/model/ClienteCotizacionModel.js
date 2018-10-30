/**
 * Definicion del modelo para los clientes/empresas que pueden seleccionarse dentro de
 * una cotizacion.
 *
 * Solo se acepta querys no se graba a traves de este modelo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */

isc.RestDataSource.create({
    ID: "mdl_cliente_cotizacion",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {name: "cliente_id", title: "Id",primaryKey: "true"},
        {name: "cliente_razon_social", title: "Razon Social"},
        {name: "tipo_cliente_codigo"}
    ],
    fetchDataURL: glb_dataUrl + 'clienteController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
    ]
});