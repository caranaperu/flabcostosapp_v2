/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los tipos de pruebas.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:40:54 -0500 (mar, 25 mar 2014) $
 * $Rev: 106 $
 */
isc.defineClass("WinPruebasTipoWindow", "WindowGridListExt");
isc.WinPruebasTipoWindow.addProperties({
    ID: "winPruebasTipoWindow",
    title: "Tipos de Prueba",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "PruebasTipoList",
            alternateRecordStyles: true,
            dataSource: mdl_pruebas_tipo,
            autoFetchData: true,
            fields: [
                {name: "pruebas_tipo_codigo", title: "Codigo", width: '25%'},
                {name: "pruebas_tipo_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'pruebas_tipo_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
