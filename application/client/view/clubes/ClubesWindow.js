/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los clubes
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinClubesWindow", "WindowGridListExt");
isc.WinClubesWindow.addProperties({
    ID: "winClubesWindow",
    title: "Clubes",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ClubesList",
            alternateRecordStyles: true,
            dataSource: mdl_clubes,
            autoFetchData: true,
            fields: [
                {name: "clubes_codigo", title: "Codigo", width: '25%'},
                {name: "clubes_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'clubes_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
