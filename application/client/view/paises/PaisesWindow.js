/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los paises.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-29 21:13:31 -0500 (dom, 29 jun 2014) $
 * $Rev: 278 $
 */
isc.defineClass("WinPaisesWindow", "WindowGridListExt");
isc.WinPaisesWindow.addProperties({
    ID: "winPaisesWindow",
    title: "Paises",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "PaisesList",
            alternateRecordStyles: true,
            dataSource: mdl_paises,
            autoFetchData: true,
            fields: [
                {name: "paises_codigo", title: "Codigo", width: '25%'},
                {name: "paises_descripcion", title: "Nombre", width: '55%'},
                {name: "regiones_codigo", title: "Region", width: '20%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'paises_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.paises_entidad === true) {
                    return "font-weight:bold; color:red;";
                }
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
