/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los niveles de los entrenadores.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:17:30 -0500 (mar, 25 mar 2014) $
 * $Rev: 116 $
 */
isc.defineClass("WinEntrenadoresNivelWindow", "WindowGridListExt");
isc.WinEntrenadoresNivelWindow.addProperties({
    ID: "winEntrenadoresNivelWindow",
    title: "Entrenadores-Niveles",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "EntrenadoresNivelList",
            alternateRecordStyles: true,
            dataSource: mdl_entrenadores_nivel,
            autoFetchData: true,
            fields: [
                {name: "entrenadores_nivel_codigo", title: "Codigo", width: '25%'},
                {name: "entrenadores_nivel_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'entrenadores_nivel_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "entrenadores_nivel_codigo") {
                    if (record.entrenadores_nivel_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.entrenadores_nivel_protected == true) {
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
