/**
 * Definicion del modelo para los tipos de insumo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_tinsumo",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
   // cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "tinsumo_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "tinsumo_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "tinsumo_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
            return mdl_tinsumo._getBooleanFieldValue(v);
        }, required: true}
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
    fetchDataURL: glb_dataUrl + 'tipoInsumoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoInsumoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoInsumoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoInsumoController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});