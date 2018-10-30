/**
 * Definicion del modelo para los insumos reducido el numero de campos
 * util para los select list de reportes.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.defineClass("RestDataSourceInsumosCostos", "RestDataSourceExt");

isc.RestDataSourceInsumo.create({
    ID: "mdl_insumo_costos_historico_report",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "insumo_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {
            name: "insumo_tipo",
            required: true
        },
        {
            name: "insumo_codigo",
            title: "Codigo",
            required: true
        },
        {
            name: "insumo_descripcion",
            title: "Descripcion",
            required: true
        },
        {
            name: "empresa_id",
            foreignKey: "mdl_empresa.empresa_id",
            required: true
        }
    ],
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'insumoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'insumoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'insumoController?op=del&libid=SmartClient'
});