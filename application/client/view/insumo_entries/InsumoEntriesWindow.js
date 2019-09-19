/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las importaciones del insumo para el calculo del factor de ajuste al costo
 *
 * @version 1.00
 * @since 1.00
 */
isc.defineClass("WinInsumoEntriesWindow", "WindowGridListExt");
isc.WinInsumoEntriesWindow.addProperties({
    ID: "winInsumoEntriesWindow",
    title: "Ingreso Insumos",
    width: 840,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "InsumoEntriesList",
            alternateRecordStyles: true,
            dataSource: mdl_insumo_entries,
            fetchOperation: 'fetchJoined',
            autoFetchData: true,
            fields: [
                {
                    name: "insumo_entries_fecha",
                    width: '10%',
                    filterOperator: "equals"
                },
                {name: "insumo_descripcion", width: '20%'},
                {
                    name: "insumo_entries_qty", align: 'right', width: '8%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                },
                {
                    name: "insumo_entries_value", align: 'right', width: '8%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                }
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'insumo_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
