/**
 * Definicion del modelo para la cabecera de la cotizacion
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.defineClass("RestDataSourceCotizacion", "RestDataSourceExt");


isc.RestDataSourceCotizacion.create({
    ID: "mdl_cotizacion",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "cotizacion_id", primaryKey: "true", required: true},
        {name: "empresa_id",foreignKey: "mdl_empresa.empresa_id", required: true},
        {name: "cliente_id",title:'Cliente', required: true},
        {name: "cotizacion_numero",title:'Nro.', required: true},
        {name: "moneda_codigo",title:'Moneda',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        {name: "cotizacion_fecha",title:'Fecha',type: 'date',required: true},
        {name: "cotizacion_es_cliente_real", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
            return mdl_cotizacion._getBooleanFieldValue(v);
        }, required: true},
        {name: "cotizacion_cerrada", title: 'Cerrada ?', type: 'boolean', getFieldValue: function(r, v, f, fn) {
            return mdl_cotizacion._getBooleanFieldValue(v);
        }, required: true},
        // Campos join
        {name: "cliente_razon_social",title:'Cliente'},
        {name: "moneda_descripcion", title:'Moneda'}
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'cotizacionController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'cotizacionController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'cotizacionController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'cotizacionController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});