/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los yipos de insumos.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoInsumoWindow", "WindowGridListExt");
isc.WinTipoInsumoWindow.addProperties({
    ID: "winTipoInsumoWindow",
    title: "Tipo Insumo",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoInsumoList",
            alternateRecordStyles: true,
            dataSource: mdl_tinsumo,
            autoFetchData: true,
            fields: [
                {name: "tinsumo_codigo", title: "Codigo", width: '25%'},
                {name: "tinsumo_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'tinsumo_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.tinsumo_protected === true) {
                        return "font-weight:bold; color:red;";
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.tinsumo_protected == true) {
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
