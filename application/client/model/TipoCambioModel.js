/**
 * Definicion del modelo para la conversion de unidades de medida.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.defineClass("RestDataSourceTipoCambio", "RestDataSourceExt");

isc.RestDataSourceTipoCambio.create({
    ID: "mdl_tipocambio",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "tipo_cambio_id", primaryKey: "true", required: true},
        {name: "moneda_codigo_origen", title:'Moneda Origen',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        {name: "moneda_codigo_destino", title:'Moneda Destino',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        {name: "tipo_cambio_fecha_desde", title:'Desde',type: 'date', required: true},
        {name: "tipo_cambio_fecha_hasta", title:'Hasta',type: 'date', required: true},
        {
            name: "tipo_cambio_tasa_compra", title:'Compra',required: true,type: 'double', format: "0.0000",
            validators: [{type: 'floatRange', min: 0.0001, max: 5.00}, {type: "floatPrecision", precision: 4}]
        },
        {
            name: "tipo_cambio_tasa_venta", title:'Venta',required: true,type: 'double', format: "0.0000",
            validators: [{type: 'floatRange', min: 0.0001, max: 5.00}, {type: "floatPrecision", precision: 4}]
        },
        // Campos join
        {name: "moneda_descripcion_o",title:'Moneda Origen'},
        {name: "moneda_descripcion_d", title:'Moneda Destino'}
    ],
    fetchDataURL: glb_dataUrl + 'tipoCambioController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoCambioController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoCambioController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoCambioController?op=del&libid=SmartClient'
});