/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de valor para cada tipo de costo global valido
 * desde una determinada fecha.
 *
 * @version 1.00
 * @since 1.00
 */
isc.defineClass("WinTipoCostoGlobalEntriesWindow", "WindowGridListExt");
isc.WinTipoCostoGlobalEntriesWindow.addProperties({
    ID: "winTipoCostoGlobalEntriesWindow",
    title: "Movimiento de Tipo de Costo Globales",
    width: 840,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoCostoGlobalEntriesList",
            alternateRecordStyles: true,
            dataSource: mdl_tcosto_global_entries,
            fetchOperation: 'fetchJoined',
            autoFetchData: true,
            fields: [
                {
                    name: "tcosto_global_entries_fecha_desde",
                    width: '10%',
                    //filterOperator: "equals"
                    filterEditorProperties: {
                        operator: "greaterOrEqual",
                        editorType: 'date'
                    }
                },
                {name: "tcosto_global_descripcion", width: '30%'},
                {name: "moneda_descripcion", width: '10%'},
                {
                    name: "tcosto_global_entries_valor", align: 'right', width: '8%',
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
            sortField : 'tcosto_global_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
