/**
 * Definicion del modelo para la lista de quien usa un determinado insumo/producto
 * como componente.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */

isc.defineClass("RestDataSourceInsumoUsedBy", "RestDataSourceExt");

isc.RestDataSourceInsumoUsedBy.create({
    ID: "mdl_insumo_used_by",
    fields: [
        {
            name: "insumo_id",
            primaryKey: true
        },
        {
            name: "insumo_codigo",
            title: "Codigo"
        },
        {
            name: "insumo_descripcion",
            title: "Descripcion"
        }
    ],
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient'
});