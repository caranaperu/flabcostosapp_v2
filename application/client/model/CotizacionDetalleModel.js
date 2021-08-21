/**
 * Definicion del modelo para los items de la cotizacion
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_cotizaciondetalle",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
   // dropExtraFields: true,
    fields: [
        {name: "cotizacion_detalle_id", primaryKey: "true", required: true},
        {name: "cotizacion_id", foreignKey: "mdl_cotizacion.cotizacion_id", required: true},
        {name: "insumo_id", foreignKey: "mdl_insumo.insumo_id", title:'Insumo',required: true},
        {
            name: "cotizacion_detalle_cantidad", title: 'Cantidad', required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 0.00,
                max: 999999.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {
            name: "unidad_medida_codigo",
            title: 'U.Medida',
            foreignKey: "mdl_unidadmedida.unidad_medida_codigo",
            required: true
        },
        {name: "cotizacion_detalle_precio", title: 'Precio', required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 0.01
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {name: "cotizacion_detalle_total", title: 'Total', required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 0.01
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },

        // Campos join
        {name: "insumo_descripcion", title: 'Insumo'},
        {name: "unidad_medida_descripcion", title: 'U.Medida'}
    ],
    fetchDataURL: glb_dataUrl + 'cotizacionDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'cotizacionDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'cotizacionDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'cotizacionDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});