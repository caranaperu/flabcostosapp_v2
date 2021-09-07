/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las listas de costos.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinCostoListWindow", "WindowGridListExt");
isc.WinCostoListWindow.addProperties({
    ID: "winCostoListWindow",
    title: "Listas De Costos",
    width: 800,
    height: 400,
    getReportURL: function(record,format) {
        return CostoList.getReportURL(undefined,format);
    },
    printReport: function(url,format) {
        var reportWindow = isc.ReportsOutputWindow.getInstance(url);
        reportWindow.setTitle("Lista De Costos")
        if (format != 'XLS') {
            reportWindow.show();
        } else {
            reportWindow.hide();
        }
    },
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CostoList",
            //autoFitWidthApproach: 'both',
            alternateRecordStyles: true,
            showRecordComponents: true,
            showRecordComponentsByCell: true,
            recordComponentPoolingMode: "recycle",
            dataSource: mdl_costos_list,
            sortField: 'costos_list_fecha',
            sortDirection: "descending",
            autoFetchData: true,
            selectionType: 'single',
            fields: [
                {
                    name: "costos_list_ide",
                    hidden: true
                },
                {
                    name: "costos_list_fecha",
                    width: '15%',
                    filterEditorProperties: {
                        operator: "greaterOrEqual",
                        editorType: 'date',
                        useTextField: true
                    }

                },
                {
                    name: "costos_list_descripcion",
                    //width: '50%',
                },
                {
                    name: "costos_list_fecha_desde",
                    width: '12%',
                    filterEditorProperties: {
                        operator: "greaterOrEqual",
                        editorType: 'date',
                        useTextField: true
                    }
                },
                {
                    name: "costos_list_fecha_hasta",
                    width: '12%',
                    filterEditorProperties: {
                        operator: "greaterOrEqual",
                        editorType: 'date',
                        useTextField: true
                    }
                },
                {
                    name: "costos_list_fecha_tcambio",
                    width: '12%',
                    filterEditorProperties: {
                        operator: "greaterOrEqual",
                        editorType: 'date',
                        useTextField: true
                    }
                },
                {
                    name: "I",
                    width: '5%',
                    align: 'center'
                }
            ],
            createRecordComponent: function(record, colNum) {
                var fieldName = this.getFieldName(colNum);

                if (fieldName == "I") {
                    console.log("Paso a crear boton "+ record.costos_list_descripcion);
                    return isc.ImgButton.create({
                        showDown: false,
                        showRollOver: false,
                        layoutAlign: "center",
                        src: "[ISOMORPHIC]/../assets/images/print.png",
                        prompt: "Imprimir",
                        height: 16,
                        width: 16,
                        grid: this,
                        click: function() {
                            isc.ask('Desea imprimir la Lista : ' + record.costos_list_descripcion + ' <BR>Desea Continuar ?',
                                function(val) {
                                    if (val == true) {
                                        url = CostoList.getReportURL(record,undefined);
                                        winCostoListWindow.printReport(url,undefined);
                                    }
                                });
                        }
                    });
                } else {
                    return null;
                }
            },
            updateRecordComponent: function (record, colNum, component, recordChanged) {

                var fieldName = this.getFieldName(colNum);
                console.log("Paso a reusar boton "+record.costos_list_descripcion);
                console.log(component);

                if (fieldName == "I") {
                   CostoList.selectSingleRecord(record);

                    component.addProperties({
                        src: "[ISOMORPHIC]/../assets/images/print.png",
                        click: function() {
                            isc.ask('Desea imprimir la Lista : ' + record.costos_list_descripcion + ' <BR>Desea Continuar ?',
                                function(val) {
                                    if (val == true) {
                                        url = CostoList.getReportURL(record,undefined);
                                        winCostoListWindow.printReport(url,undefined);
                                    }
                                });
                        }
                    });
                } else {
                    return null;
                }
                return component;
            },
            getReportURL: function(record,format) {
                if (record === undefined) {
                    record = CostoList.getSelectedRecord();
                }

                var url = undefined;
                if (record) {
                    /* Para koolreport
                        var url = glb_dataUrl + 'reports/rptCostosListController?op=op_costos_list&libid=SmartClient';
                        url += '&costos_list_id=' + record.costos_list_id;
                        url += '&PARAM_toScreen=1';
                     */

                    // prepara la llamada
                    // Para jasperreports.
                    url = glb_reportServerUrl + '/flow.html?_flowId=viewReportFlow&standAlone=false&decorate=no&_flowId=viewReportFlow' +
                        '&ParentFolderUri=/SistemCostos&viewAsDashboardFrame=false&theme=jasper_dark';
                    url += '&reportUnit=/SistemCostos/cstr_CostosListReport';

                    url += '&p_costos_list_id=' + record.costos_list_id;

                    // user y password
                    url += '&j_username=' + glb_reportServerUser;
                    url += '&j_password=' + glb_reportServerPsw;

                    url += '&userLocale=es_PE';

                    if (format !== undefined) {
                        url += (format == 'XLS' ? '&output=xlsx' : '&output=pdf');
                    }
                } else {
                    isc.say("Seleccione un registro a imprimir");
                }

                return url;
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
