/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los tipos de record.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-01 16:53:51 -0500 (mar, 01 jul 2014) $
 * $Rev: 301 $
 */
isc.defineClass("WinRecordsTipoWindow", "WindowGridListExt");
isc.WinRecordsTipoWindow.addProperties({
    ID: "winRecordsTipoWindow",
    title: "Tipo de Records",
    width: 550, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "RecordsTipoList",
            alternateRecordStyles: true,
            dataSource: mdl_records_tipo,
            autoFetchData: true,
            fields: [
                {name: "records_tipo_codigo", title: "Codigo", width: '15%'},
                {name: "records_tipo_descripcion", title: "Descripcion", width: '40%'},
                {name: "records_tipo_abreviatura", title: "Abreviatura", width: '12%'}
            ],
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "records_tipo_codigo") {
                    if (record.records_tipo_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.records_tipo_protected == true) {
                        isc.say('No puede eliminarse el registro debido a que es un regisro del sistema y esta protegido');
                        return false;
                    } else {
                        return true;
                    }
                }
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'records_tipo_protected_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
