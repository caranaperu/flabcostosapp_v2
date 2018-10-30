/**
 * Definicion del modelo para la lista de sistemas que componen la aplicacion.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_sistemas",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    autoCacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "sys_systemcode", primaryKey: "true"},
        {name: "sistema_descripcion"},
        {name: "activo"}
    ],
    fetchDataURL: glb_dataUrl + 'sistemasController?op=fetch&libid=SmartClient&sys_systemcode=' + glb_systemident,
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]});