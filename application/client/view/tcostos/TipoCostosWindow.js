/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los tipos de costos.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoCostosWindow", "WindowGridListExt");
isc.WinTipoCostosWindow.addProperties({
    ID: "winTipoCostosWindow",
    title: "Tipo Costos",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoCostosList",
            alternateRecordStyles: true,
            dataSource: mdl_tcostos,
            autoFetchData: true,
            fields: [
                {name: "tcostos_codigo",  width: '25%'},
                {name: "tcostos_descripcion",  width: '50%'},
                {name: "tcostos_indirecto",  width: '25%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'tcostos_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.tcostos_protected === true) {
                    return "font-weight:bold; color:red;";
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.tcostos_protected == true) {
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
