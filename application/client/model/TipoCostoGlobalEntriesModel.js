isc.defineClass("RestDataSourceTipoCostoGlobalEntries", "RestDataSourceExt");

isc.RestDataSourceTipoCostoGlobalEntries.create({
    /**
     * Definicion del modelo para los ingresos de cada entrada de valor para cada tipo de costo global valido
     * desde una determinada fecha.
     *
     * @version 1.00
     * @since 17-MAY-2021
     * @Author: Carlos Arana Reategui
     */
    ID: "mdl_tcosto_global_entries",
    fields: [
        {
            name: "tcosto_global_entries_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {
            name: "tcosto_global_entries_fecha_desde",
            title: "Fecha Desde",
            type: 'date',
            align: 'left',
            required: true
        },
        {
            name: "tcosto_global_codigo",
            title: "Tipo Costo Global",
            foreignKey: "mdl_tcosto_global.tcosto_global_codigo",
            required: true
        },
        {
            name: "tcosto_global_entries_valor",
            title: "Valor",
            required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 1.00,
                max: 1000000000.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {name: "moneda_codigo", title: 'Codigo', foreignKey: "mdl_moneda.moneda_codigo", required: true},
        // Solo visualizacion
        {name: "moneda_descripcion", title: "Descripcion"},
        {
            name: "tcosto_global_descripcion",
            title: "Tipo Costo Global"
        }
    ],
    fetchDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
            dataProtocol: "postParams"
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        }
    ]
});