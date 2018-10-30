/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las monedas
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:43:44 -0500 (dom, 06 abr 2014) $
 * $Rev: 146 $
 */
isc.defineClass("WinMonedaWindow", "WindowGridListExt");
isc.WinMonedaWindow.addProperties({
    ID: "winMonedaWindow",
    title: "Monedas",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "MonedaList",
            alternateRecordStyles: true,
            dataSource: mdl_moneda,
            autoFetchData: true,
            fields: [
                {name: "moneda_codigo",  width: '20%'},
                {name: "moneda_simbolo",  width: '20%'},
                {name: "moneda_descripcion",  width: '60%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'moneda_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "moneda_codigo") {
                    if (record.moneda_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.moneda_protected == true) {
                        isc.say('No puede eliminarse el registro debido a que es un registro del sistema y esta protegido');
                        return false;
                    } else {
                        return true;
                    }
                }
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
