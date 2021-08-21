
isc.RestDataSource.create({
    /**
     * Definicion de la lista de ingresos para el calculo del factor de ajuste
     * asociados a un insumo.
     *
     * Solo se acepta querys no se graba a traves de este modelo.
     *
     * @version 1.00
     * @since 1.00
     * $Author: aranape $
     * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
     */
    ID: "mdl_insumo_entries_assoc",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "insumo_entries_fecha",
            title:"Fecha Ingreso",
            type: 'date',
            align: 'left'
        },
        {
            name: "insumo_entries_qty",
            title: "#Kilos",
            type: 'double',
            format: "0.00",
        },
        {
            name: "insumo_entries_value",
            title: "Concentracion",
            type: 'double',
            format: "0.00",
        },
        {
            name: "insumo_factor_ajuste",
            title: "Factor Ajuste",
            type: 'double',
            format: "0.00"
        }
    ],
    fetchDataURL: glb_dataUrl + 'insumoEntriesController?op=fetch&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        }
    ]
});