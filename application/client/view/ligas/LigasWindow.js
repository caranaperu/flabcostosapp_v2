/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las ligas.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinLigasWindow", "WindowGridListExt");
isc.WinLigasWindow.addProperties({
    ID: "winLigasWindow",
    title: "Ligas",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "LigasList",
            alternateRecordStyles: true,
            dataSource: mdl_ligas,
            autoFetchData: true,
            fields: [
                {name: "ligas_codigo", title: "Codigo", width: '25%'},
                {name: "ligas_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'ligas_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
