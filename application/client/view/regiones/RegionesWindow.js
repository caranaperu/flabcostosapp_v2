/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las regiones atleticas
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinRegionesWindow", "WindowGridListExt");
isc.WinRegionesWindow.addProperties({
    ID: "winRegionesWindow",
    title: "Regiones",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "RegionesList",
            alternateRecordStyles: true,
            dataSource: mdl_regiones,
            autoFetchData: true,
            fields: [
                {name: "regiones_codigo", title: "Codigo", width: '25%'},
                {name: "regiones_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'regiones_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
