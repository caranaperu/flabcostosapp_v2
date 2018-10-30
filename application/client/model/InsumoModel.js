/**
 * Definicion del modelo para los insumos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.defineClass("RestDataSourceInsumo", "RestDataSourceExt");

isc.RestDataSourceInsumo.create({
    ID: "mdl_insumo",
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
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "empresa_id",
            foreignKey: "mdl_empresa.empresa_id",
            required: true
        },
        {
            name: "tcostos_codigo",
            title: "Tipo Costos",
            foreignKey: "mdl_tcostos.tcostos_codigo",
            required: true
        },
        {
            name: "tinsumo_codigo",
            title: "Tipo Insumo",
            foreignKey: "mdl_tinsumo.tinsumo_codigo",
            required: true
        },
        {
            name: "unidad_medida_codigo_ingreso",
            title: 'Unidad Ingreso',
            foreignKey: "mdl_unidadmedida.unidad_medida_codigo",
            required: true
        },
        {
            name: "unidad_medida_codigo_costo",
            title: 'Unidad Costo',
            foreignKey: "mdl_unidadmedida.unidad_medida_codigo",
            required: true
        },
        {
            name: "insumo_merma",
            title: 'Merma',
            required: true,
            validators: [{
                type: 'floatRange',
                min: 0.0000,
                max: 100000.00
            }, {
                type: "floatPrecision",
                precision: 4
            }]
        },
        {
            name: "insumo_costo",
            title: 'Costo',
            required: true,
            validators: [{
                type: 'floatRange',
                min: 0.0000,
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
            name: "tcostos_descripcion",
            title: "Tipo Costos"
        },
        {
            name: "tcostos_indirecto",
            title: "Indirecto",
            type: 'boolean',
            getFieldValue: function(r, v, f, fn) {
                return mdl_insumo._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "tinsumo_descripcion",
            title: "Tipo Insumo"
        },
        {
            name: "unidad_medida_descripcion_ingreso",
            title: "Unidad Ingreso"
        },
        {
            name: "unidad_medida_descripcion_costo",
            title: "Unidad Costo"
        },
        {
            name: "moneda_descripcion",
            title: "Moneda Costo"
        },
        {name: "moneda_simbolo"}

    ],
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'insumoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'insumoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'insumoController?op=del&libid=SmartClient'
});