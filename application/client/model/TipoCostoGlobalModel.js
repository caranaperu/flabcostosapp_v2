/**
 * Definicion del modelo para las monedas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:53:42 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_tcosto_global",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    cacheAllData: false, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "tcosto_global_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "tcosto_global_descripcion", title: "Descripcion", required: true},
        {name: "tcosto_global_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_tcosto_global._getBooleanFieldValue(v);
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
    fetchDataURL: glb_dataUrl + 'tipoCostoGlobalController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoCostoGlobalController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoCostoGlobalController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoCostoGlobalController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});