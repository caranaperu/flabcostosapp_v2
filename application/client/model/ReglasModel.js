/**
 * Definicion del modelo para la definicion de reglas de costos entre
 * empresas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.defineClass("RestDataSourceReglas", "RestDataSourceExt");

isc.RestDataSourceReglas.create({
    ID: "mdl_reglas",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "regla_id", primaryKey: "true", required: true},
        {name: "regla_empresa_origen_id", title:'Emp.Origen',foreignKey: "mdl_empresas.empresa_id", required: true},
        {name: "regla_empresa_destino_id", title:'Emp.Destino',foreignKey: "mdl_empresas.empresa_id", required: true},
        {name: "regla_by_costo",title: "Por Costo",type: 'boolean',
            getFieldValue: function(r, v, f, fn) {
                return mdl_reglas._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "regla_porcentaje", title:'Porcentaje',required: true,type: 'double',format: "0.00",
            validators: [{type: 'floatRange', min: -99.00, max: 99.00}, {type: "floatPrecision", precision: 2}]
        },
        // Campos join
        {name: "empresa_razon_social_o",title:'Empresa Origen'},
        {name: "empresa_razon_social_d",title:'Empresa Destino'}
    ],
    fetchDataURL: glb_dataUrl + 'reglasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'reglasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'reglasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'reglasController?op=del&libid=SmartClient',

});