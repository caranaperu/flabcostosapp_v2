/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los yipos de insumos.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinPresentacionWindow", "WindowGridListExt");
isc.WinPresentacionWindow.addProperties({
    ID: "winPresentacionWindow",
    title: "Presentaciones",
    width: 600, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "PresentacionList",
            alternateRecordStyles: true,
            dataSource: mdl_presentacion,
            autoFetchData: true,
            fields: [
                {name: "tpresentacion_codigo", title: "Codigo", width: '15%'},
                {name: "tpresentacion_descripcion", title: "Nombre", width: '45%'},
                {
                    name: "tpresentacion_cantidad_costo",align: 'right',
                    width: '20%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                },
                {
                    name: "unidad_medida_descripcion_costo",
                    width: '20%'
                },
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'tpresentacion_descripcion',
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.tpresentacion_protected === true) {
                        return "font-weight:bold; color:red;";
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.tpresentacion_protected == true) {
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
