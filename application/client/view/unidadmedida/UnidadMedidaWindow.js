/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las unidades de medida.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:43:44 -0500 (dom, 06 abr 2014) $
 * $Rev: 146 $
 */
isc.defineClass("WinUnidadMedidaWindow", "WindowGridListExt");
isc.WinUnidadMedidaWindow.addProperties({
    ID: "winUnidadMedidaWindow",
    title: "Unidades de Medida",
    width: 520, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "UnidadMedidaList",
            alternateRecordStyles: true,
            dataSource: mdl_unidadmedida,
            autoFetchData: true,
            fields: [
                {name: "unidad_medida_codigo",  width: '15%'},
                {name: "unidad_medida_siglas",  width: '20%'},
                {name: "unidad_medida_descripcion", width: '45%'},
                {name: "unidad_medida_tipo", width: '10%'},
                {name: "unidad_medida_default", width: '10%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'unidad_medida_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.unidad_medida_protected === true) {
                    return "font-weight:bold; color:red;";
                }
            },
            isAllowedToDelete2: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.unidad_medida_protected == true) {
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
