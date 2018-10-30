/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los paises.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinCiudadesWindow", "WindowGridListExt");
isc.WinCiudadesWindow.addProperties({
    ID: "winCiudadesWindow",
    title: "Ciudades",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CiudadesList",
            alternateRecordStyles: true,
            dataSource: mdl_ciudades,
            autoFetchData: true,
            fields: [
                {name: "paises_codigo", title: "Pais", width: '12%'},
                {name: "ciudades_codigo", title: "Codigo", width: '13%'},
                {name: "ciudades_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'ciudades_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
