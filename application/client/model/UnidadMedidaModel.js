/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:53:42 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_unidadmedida",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "unidad_medida_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "unidad_medida_descripcion", title: "Descripcion", required: true},
        {name: "unidad_medida_siglas", title: "Siglas", required: true},
        {name: "unidad_medida_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_unidadmedida._getBooleanFieldValue(v);
            }, required: true},
        {name: "unidad_medida_tipo", title: "Tipo", valueMap: {"P":"Peso", "V":"Volumen", "L":"Longitud","T":"Tiempo"}, required: true},
        {name: "unidad_medida_default", title: 'Default', type: 'boolean', getFieldValue: function(r, v, f, fn) {
            return mdl_unidadmedida._getBooleanFieldValue(v);
        }, required: true},
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
    fetchDataURL: glb_dataUrl + 'unidadMedidaController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'unidadMedidaController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'unidadMedidaController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'unidadMedidaController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});