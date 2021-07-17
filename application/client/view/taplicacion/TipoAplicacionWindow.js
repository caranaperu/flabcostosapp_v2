/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los yipos de Aplicacion.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoAplicacionWindow", "WindowGridListExt");
isc.WinTipoAplicacionWindow.addProperties({
    ID: "winTipoAplicacionWindow",
    title: "Tipo Aplicacion",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoAplicacionList",
            alternateRecordStyles: true,
            dataSource: mdl_taplicacion,
            autoFetchData: true,
            fields: [
                {name: "taplicacion_codigo", title: "Codigo", width: '25%'},
                {name: "taplicacion_descripcion", title: "Descripcion", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'taplicacion_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
