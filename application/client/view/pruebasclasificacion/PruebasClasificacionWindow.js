/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las clasificaciones de pruebas
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:41:53 -0500 (mar, 25 mar 2014) $
 * $Rev: 107 $
 */
isc.defineClass("WinPruebasClasificacionWindow", "WindowGridListExt");
isc.WinPruebasClasificacionWindow.addProperties({
    ID: "winPruebasClasificacionWindow",
    title: "Clasificacion dePruebas",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "PruebasClasificacionList",
            alternateRecordStyles: true,
            dataSource: mdl_pruebas_clasificacion,
            autoFetchData: true,
            fields: [
                {name: "pruebas_clasificacion_codigo", title: "Codigo", width: '12%'},
                {name: "pruebas_clasificacion_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'pruebas_clasificacion_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
