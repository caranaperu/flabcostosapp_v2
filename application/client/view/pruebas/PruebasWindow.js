/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las pruebas atleticas.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 17:20:28 -0500 (mar, 25 mar 2014) $
 * $Rev: 131 $
 */
isc.defineClass("WinPruebasWindow", "WindowGridListExt");
isc.WinPruebasWindow.addProperties({
    ID: "winPruebasWindow",
    title: "Pruebas",
    width: 800, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "PruebasList",
            alternateRecordStyles: true,
            dataSource: mdl_pruebas,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {name: "pruebas_codigo", width: '12%'},
                {name: "pruebas_descripcion", width: '30%'},
                {name: "pruebas_clasificacion_descripcion", width: '23%'},
                {name: "categorias_descripcion", width: '23%'},
                {name: "pruebas_sexo", title: "S", width: '5%'},
                {name: "apppruebas_multiple", width: '10%', filterOperator: 'equals'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'pruebas_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "pruebas_codigo") {
                    if (record.pruebas_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                } else {
                    if (record.pruebas_sexo != 'M') {
                        return "font-weight:bold; color:#FF6699;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.pruebas_protected == true) {
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
