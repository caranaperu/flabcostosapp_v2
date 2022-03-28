/**
 * Definicion del modelo para los insumos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.defineClass("RestDataSourceProducto", "RestDataSourceExt");

isc.RestDataSourceProducto.create({
    ID: "mdl_producto",
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
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "taplicacion_entries_id",
            foreignKey: "mdl_taplicacion_entries.taplicacion_entries_id",
            required: true
        },
        {   name: "tpresentacion_codigo",
            title: "Codigo Presentacion",
            foreignKey: "mdl_presentacion.tpresentacion_codigo",
            required: true
        },
        {
            name: "insumo_merma",
            title: 'Merma',
            required: true,
            validators: [{
                type: 'floatRange',
                min: 0.0001,
                max: 100000.00
            }, {
                type: "floatPrecision",
                precision: 4
            }]
        },
        {
            name: "insumo_precio_mercado",
            title: 'Precio Mercado',
            required: true,
            validators: [{
                type: 'floatRange',
                min: 0.0000,
                max: 100000.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {
            name: "moneda_codigo_costo",
            title: 'Moneda Costo',
            foreignKey: "mdl_moneda.moneda_codigo",
            required: true
        },
        // campos join
        {
            name: "taplicacion_entries_descripcion",
            title: 'Modo Aplicacion'
        },
        {
            name: "tpresentacion_descripcion",
            title: 'Presentacion'
        },
        {
            name: "moneda_descripcion",
            title: "Moneda Costo"
        },
        {name: "moneda_simbolo"},
        {
            name: "insumo_costo",
            title: 'Costo'
        }

    ],
    fetchDataURL: glb_dataUrl + 'productoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'productoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'productoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'productoController?op=del&libid=SmartClient'
});