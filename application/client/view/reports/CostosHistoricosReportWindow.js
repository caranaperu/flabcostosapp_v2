/**
 * Clase que prepara la informacion previa a emitir el reporte de resultados
 * de atletas individualmente o comparados, luego de preparar la data
 * llama a una ventana externa que emitira los graficos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:06:40 -0500 (dom, 24 ene 2016) $
 * $Rev: 358 $
 */
isc.defineClass("CostosHistoricosReportWindow", "Window");
isc.CostosHistoricosReportWindow.addProperties({
    ID: 'costosHistoricosReportWindow',
    canDragResize: true,
    showFooter: false,
    autoSize: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '400',
    height: '185',
    title: 'Historico de Costos - Reporte',
    // Inicialiamos los widgets interiores
    initWidget: function () {
        this.Super("initWidget", arguments);

        // Botones principales del header
        var formButtons = isc.HStack.create({
            membersMargin: 10,
            height: 24,
            layoutAlign: "center", padding: 5, autoDraw: false,
            align: 'center',
            members: [isc.Button.create({
                    ID: "btndoClear" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Limpiar",
                    click: function () {
                        formReportCostosHistoricos.focusInItem('insumo_id');
                        formButtons.getMember(1).setDisabled(true);
                        formReportCostosHistoricos.clearValues();
                    }
                }),
                isc.Button.create({
                    ID: "btnDoReport" + this.ID,
                    title: 'Ejecutar',
                    width: '100',
                    autoDraw: false,
                    disabled: true,
                    click: function () {
                        var reportWindow;
                        // prepara la llamada
                        var url = glb_reportServerUrl + '/flow.html?_flowId=viewReportFlow&standAlone=false&decorate=no&_flowId=viewReportFlow' +
                                '&ParentFolderUri=/reports/dblabs&&viewAsDashboardFrame=false&theme=jasper_dark';

                        if (formReportCostosHistoricos.getValue('formato_xls') == false) {
                            url += '&reportUnit=/reports/dblabs/costo_insumo_rpt';
                        } else {
                            url += '&reportUnit=/reports/dblabs/costo_insumo_xls_rpt&output=xls';
                        }

                        url += '&p_insumo_id=' + formReportCostosHistoricos.getValue('insumo_id');
                        if (formReportCostosHistoricos.getValue('fecha_desde') !== undefined && formReportCostosHistoricos.getValue('fecha_desde') !== '') {
                            url += '&p_date_from=' + formReportCostosHistoricos.getValue('fecha_desde').toSerializeableDate();
                        }
                        if (formReportCostosHistoricos.getValue('fecha_hasta') !== undefined && formReportCostosHistoricos.getValue('fecha_hasta') !== '') {
                            url += '&p_date_to=' + formReportCostosHistoricos.getValue('fecha_hasta').toSerializeableDate();
                        }

                        // user y password
                        url += '&j_username=' + glb_reportServerUser;
                        url += '&j_password=' + glb_reportServerPsw;


                        reportWindow = isc.ReportsOutputWindow.getInstance(url);

                        if (formReportCostosHistoricos.getValue('formato_xls') == true) {
                            reportWindow .hide();
                        } else {
                            reportWindow.show();
                        }
                    }
                }),
                isc.Button.create({
                    ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function () {
                        costosHistoricosReportWindow.hide();
                    }
                })
            ]
        });

        var formReportCostosHistoricos = isc.DynamicFormExt.create({
            ID: "formReportCostosHistoricos",
            padding: 5,
            autoSize: true,
            fields: [
                {
                    name: "insumo_id",
                    editorType: "comboBoxExt",
                    width: 180,
                    valueField: "insumo_id",
                    displayField: "insumo_descripcion",
                    optionDataSource: mdl_insumo_costos_historico_report,
                    optionOperationId: 'fetchSimpleList',
                    pickListCriteria: {
                        _constructor: "AdvancedCriteria",
                        operator: "and",
                        criteria: [{
                            fieldName: 'empresa_id',
                            value: glb_empresaId,
                            operator: 'equals'
                        }]},
                    pickListFields: [
                        {
                            name: "insumo_codigo"
                        }, {
                            name: "insumo_descripcion"
                        }],
                    filterLocally: false,
                    pickListWidth: 420,
                    completeOnTab: true,
                    initialSort: [{property: 'insumo_descripcion'}],
                    sortField: "insumo_descripcion",
                    required: true
                },
                {name: "fecha_desde", useTextField: true,type:'date', showPickerIcon: true, width: 100,required: true,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && formReportCostosHistoricos.getValue('fecha_hasta')) {
                            if (value.getTime() > formReportCostosHistoricos.getValue('fecha_hasta').getTime()) {
                                isc.say('La fecha inicial no puede ser mayor que la final');
                                return false;
                            }
                        }
                        return true;
                    }},
                {name: "fecha_hasta", useTextField: true,type:'date', showPickerIcon: true, width: 100,required: true,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && formReportCostosHistoricos.getValue('fecha_desde')) {
                            if (value.getTime() < formReportCostosHistoricos.getValue('fecha_desde').getTime()) {
                                isc.say('La fecha final no puede ser menor que la inicial');
                                return false;
                            }
                        }
                        return true;
                    }},
                {name: "formato_xls", title: 'Para Excel', defaultValue: false, type: 'boolean', length: 50}
            ],
            itemChanged: function () {
                formButtons.getMember(1).setDisabled(!formReportCostosHistoricos.valuesAreValid(false));
            }
        });


        this.addItem(formReportCostosHistoricos);
        this.addItem(formButtons);
        formButtons.getMember(1).setDisabled(!formReportCostosHistoricos.valuesAreValid(false));
    }
});
