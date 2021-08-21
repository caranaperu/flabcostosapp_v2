/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las monedas
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:43:44 -0500 (dom, 06 abr 2014) $
 * $Rev: 146 $
 */
isc.defineClass("WinTipoCostoGlobalWindow", "WindowGridListExt");
isc.WinTipoCostoGlobalWindow.addProperties({
    ID: "winTipoCostoGlobalWindow",
    title: "Tipo Costos Global",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoCostoGlobalList",
            alternateRecordStyles: true,
            dataSource: mdl_tcosto_global,
            autoFetchData: true,
            fields: [
                {name: "tcosto_global_codigo",  width: '20%'},
                {name: "tcosto_global_descripcion",  width: '60%'},
                {name: "tcosto_global_protected",hidden: true}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'tcosto_global_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "tcosto_global_codigo") {
                    if (record.tcosto_global_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.tcosto_global_protected == true) {
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
