/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de registro de los records atleticos,
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:06:40 -0500 (dom, 24 ene 2016) $
 * $Rev: 358 $
 */
isc.defineClass("WinRecordsWindow", "WindowGridListExt");
isc.WinRecordsWindow.addProperties({
    ID: "winRecordsWindow",
    title: "Records",
    width: 900, height: 400,
    getReportURL: function () {
        return glb_dataUrl + 'reports/rptRecordsStandardController?op=listrecordsstandard&libid=SmartClient';
    },
    createGridList: function () {
        return isc.ListGrid.create({
            ID: "RecordsList",
            alternateRecordStyles: true,
            showHeaderContextMenu: true,
            dataSource: mdl_records,
            autoFetchData: true,
            dataPageSize: 10,
            // Estos 2 permiten que solo se lea lo que el tamaño de la pagina indica
            drawAheadRatio: 1,
            drawAllMaxCells: 0,
            fetchOperation: 'fetchJoined',
            fields: [
                {name: "records_tipo_codigo", type: "selectExt",
                    optionDataSource: mdl_records_tipo, valueField: 'records_tipo_codigo',
                    displayField: 'records_tipo_descripcion', pickListWidth: 200, width: 120},
                {name: "atletas_nombre_completo", title: 'atleta', width: 160},
                {name: "apppruebas_descripcion", title: 'prueba', width: 140},
                {name: "categorias_codigo", width: 40},
                //{name: "Marca",
                {name: "atletas_resultados_resultado", title: 'marca', align: 'right', width: 60},
                {name: "ciudades_altura", width: 35},
                {name: "competencias_pruebas_viento", title: 'V', decimalPad: 2, width: 30},
                {name: "competencias_pruebas_fecha", title: 'Fecha', type: 'date', filterEditorType: 'date', useTextField: true, filterOperator: 'equals',
                    filterEditorProperties: {showPickerIcon: false}, align: 'center', width: 70},
                {name: "lugar", title: "Lugar", /*
                 formatCellValue: function(value, record, rowNum, colNum, grid) {
                 if (record != null) {
                 var fvalue = record.competencias_descripcion + ' / ' + record.paises_descripcion + ' / ' + record.ciudades_descripcion;
                 return fvalue;
                 } else {
                 return value;
                 }
                 }*/
                }
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: true,
            canMultiSort: true,
            autoSize: true,
            autoFitWidthApproach: 'both',
            isPostRemoveDataRefreshMainListRequired: function (recordToDelete) {
                return true;
            }
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});
