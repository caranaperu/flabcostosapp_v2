
isc.RestDataSource.create({
    /**
     * Definicion del modelo para los ingresos de insumos y posterior calculo de su
     * factor de ajustes.
     *
     *
     * @version 1.00
     * @since 1.00
     * $Author: aranape $
     * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
     */
    ID: "mdl_insumo_entries",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "insumo_entries_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {
            name: "insumo_entries_fecha",
            title:"Fecha Ingreso",
            type: 'date',
            align: 'left'
        },
        {
            name: "insumo_id",
            title: "Insumo",
            foreignKey: "mdl_insumo.insumo_id",
            required: true
        },
        {
            name: "insumo_entries_qty",
            title: "#Kilos",
            required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 1.00,
                max: 99999999.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {
            name: "insumo_entries_value",
            title: "Concentracion",
            required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 1.00,
                max: 100.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {
            name: "insumo_descripcion",
            title: "Insumo"
        }
    ],
    fetchDataURL: glb_dataUrl + 'insumoEntriesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'insumoEntriesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'insumoEntriesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'insumoEntriesController?op=del&libid=SmartClient',
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