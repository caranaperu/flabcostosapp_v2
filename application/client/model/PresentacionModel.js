/**
 * Definicion del modelo para las presentaciones de prodiucto,
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 */
isc.RestDataSource.create({
    ID: "mdl_presentacion",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
   // cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "tpresentacion_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "tpresentacion_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "tpresentacion_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
            return mdl_presentacion._getBooleanFieldValue(v);
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
    fetchDataURL: glb_dataUrl + 'presentacionController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'presentacionController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'presentacionController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'presentacionController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});