/**
 * Definicion del modelo para las presentaciones de prodiucto,
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 */
isc.RestDataSource.create({
    ID: "mdl_ffarmaceutica",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
   // cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "ffarmaceutica_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "ffarmaceutica_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "ffarmaceutica_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
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
    fetchDataURL: glb_dataUrl + 'formaFarmaceuticaController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'formaFarmaceuticaController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'formaFarmaceuticaController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'formaFarmaceuticaController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});