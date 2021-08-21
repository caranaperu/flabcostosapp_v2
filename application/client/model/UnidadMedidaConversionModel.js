/**
 * Definicion del modelo para la conversion de unidades de medida.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_umconversion",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "unidad_medida_conversion_id", primaryKey: "true", required: true},
        {name: "unidad_medida_origen", title:'U.M Origen',foreignKey: "mdl_unidadmedida.unidad_medida_codigo", required: true},
        {name: "unidad_medida_destino",title:'U.M Destino',foreignKey: "mdl_unidadmedida.unidad_medida_codigo", required: true},
        {
            name: "unidad_medida_conversion_factor", title:'Factor',required: true,type: 'double',format: "0.0000",
            validators: [{type: 'floatRange', min: 0.0001, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        // Campos join
        {name: "unidad_medida_descripcion_o",title:'U.Medida Origen'},
        {name: "unidad_medida_descripcion_d", title:'U.Medida Destino'}
    ],
    fetchDataURL: glb_dataUrl + 'unidadMedidaConversionController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'unidadMedidaConversionController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'unidadMedidaConversionController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'unidadMedidaConversionController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});