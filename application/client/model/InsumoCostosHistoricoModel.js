/**
 * Definicion del modelo para la lista del hoistorico de costos de un determinado producto.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */

isc.RestDataSource.create({
    ID: "mdl_insumo_costos_historico",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "insumo_history_id",
            primaryKey: true
        },
        {
            name: "insumo_codigo",
            title: "Codigo"
        },
        {
            name: "insumo_descripcion",
            title: "Descripcion"
        },
        {
            name: "insumo_history_fecha",
            title: "Fecha"
        },
        {
            name: "tinsumo_descripcion",
            title: "T.Insumo"
        },
        {
            name: "tcostos_descripcion",
            title: "T.Costo"
        },
        {
            name: "unidad_medida_descripcion",
            title: 'U.Medida'
        },
        {
            name: "insumo_merma",
            title: 'Merma'
        },
        {
            name: "insumo_costo",
            title: 'Costo'
        },
        {
            name: "insumo_precio_mercado",
            title: 'Precio Mercado'
        },
        {
            name: "moneda_costo_descripcion",
            title: 'Moneda Costo'
        }

    ],
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'insumoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'insumoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'insumoController?op=del&libid=SmartClient'
});