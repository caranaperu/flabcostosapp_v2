/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los paises.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinUMConversionWindow", "WindowGridListExt");
isc.WinUMConversionWindow.addProperties({
    ID: "winUMConversionWindow",
    title: "Conversion de Unidades de Medida",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "UMConversionList",
            alternateRecordStyles: true,
            dataSource: mdl_umconversion,
            fetchOperation: 'fetchJoined',
            autoFetchData: true,
            fields: [
                {name: "unidad_medida_descripcion_o",  width: '40%'},
                {name: "unidad_medida_descripcion_d", width: '40%'},
                {name: "unidad_medida_conversion_factor", width: '20%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'unidad_medida_origen'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
