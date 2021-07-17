/**
 * Clase especifica para la definicion de la ventana para
 * la grilla  de la produccion de los modos de aplicacion
 *
 * @version 1.00
 * @since 1.00
 */
isc.defineClass("WinProduccionWindow", "WindowGridListExt");
isc.WinProduccionWindow.addProperties({
    ID: "winProduccionWindow",
    title: "Ingreso Produccion",
    width: 840,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ProduccionList",
            alternateRecordStyles: true,
            dataSource: mdl_produccion,
            fetchOperation: 'fetchJoined',
            autoFetchData: true,
            fields: [
                {
                    name: "produccion_id",
                    hidden: true
                },
                {
                    name: "produccion_fecha",
                    width: '10%',
                    filterEditorProperties: {
                        operator: "greaterOrEqual",
                        editorType: 'date'
                    }
                },
                {name: "taplicacion_entries_descripcion", width: '20%'},
                {
                    name: "produccion_qty", align: 'right', width: '8%',
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
            sortField: 'produccion_fecha'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
