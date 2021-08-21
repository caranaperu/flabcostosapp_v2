/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las genericas de pruebas
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:47:59 -0500 (mar, 25 mar 2014) $
 * $Rev: 112 $
 */
isc.defineClass("WinAppPruebasWindow", "WindowGridListExt");
isc.WinAppPruebasWindow.addProperties({
    ID: "winAppPruebasWindow",
    title: "Mantenimiento de Genericas De Pruebas",
    width: 760, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "AppPruebasList",
            alternateRecordStyles: true,
            dataSource: mdl_apppruebas,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {name: "apppruebas_codigo", width: '15%'},
                {name: "apppruebas_descripcion", width: '40%'},
                {name: "pruebas_clasificacion_descripcion", width: '45%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'apppruebas_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "apppruebas_codigo") {
                    if (record.apppruebas_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.apppruebas_protected == true) {
                        isc.say('No puede eliminarse el registro debido a que es un regisro del sistema y esta protegido');
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
