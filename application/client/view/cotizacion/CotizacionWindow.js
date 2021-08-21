/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las cotizaciones.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinCotizacionWindow", "WindowGridListExt");
isc.WinCotizacionWindow.addProperties({
    ID: "winCotizacionWindow",
    title: "Cotizaciones",
    width: 800,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CotizacionList",
            alternateRecordStyles: true,
            showRecordComponents: true,
            showRecordComponentsByCell: true,
            recordComponentPoolingMode: "recycle",
            dataSource: mdl_cotizacion,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "cotizacion_numero",
                    width: '10%',
                    filterOperator: "equals"
                },
                {
                    name: "cotizacion_fecha",
                    width: '10%',
                    filterOperator: "equals"
                },
                {
                    name: "moneda_descripcion",
                    width: '30%'
                },
                {
                    name: "cliente_razon_social",
                    width: '35%'
                },
                {
                    name: "cotizacion_cerrada",
                    width: '10%'
                },
                {
                    name: "I",
                    width: '5%',
                    align:'center'
                }
            ],
            createRecordComponent : function (record, colNum) {
                var fieldName = this.getFieldName(colNum);

                if (fieldName == "I" && record.cotizacion_cerrada == true) {
                    return isc.ImgButton.create({
                        showDown: false,
                        showRollOver: false,
                        layoutAlign: "center",
                        src: "[ISOMORPHIC]/../assets/images/print.png",
                        prompt: "Imprimir",
                        height: 16,
                        width: 16,
                        grid: this,
                        click : function () {
                            isc.ask('Desea imprimir la cotizacion Nro: '+record.cotizacion_numero+' <BR>Desea Continuar ?',
                                function (val) {
                                    var reportWindow;
                                    if (val == true) {
                                        //item.setValue(oldValue);
                                        var url = glb_reportServerUrl + '/flow.html?_flowId=viewReportFlow&standAlone=false&decorate=no&_flowId=viewReportFlow' +
                                            '&ParentFolderUri=/reports/dblabs&&viewAsDashboardFrame=false';

                                        url += '&reportUnit=/reports/dblabs/cotizaciones_rpt&output=pdf';
                                        url += '&p_cotizacion_id=' + record.cotizacion_id;
                                        // user y password
                                        url += '&j_username=' + glb_reportServerUser;
                                        url += '&j_password=' + glb_reportServerPsw;

                                        reportWindow = isc.ReportsOutputWindow.getInstance(url);
                                        reportWindow.show();
                                    }
                                });
                        }
                    });
                } else {
                    return null;
                }
            },
            updateRecordComponent: function(record, colNum, component,sameRow) {
                var fieldName = this.getFieldName(colNum);

                if (fieldName == "I" && record.cotizacion_cerrada == true) {
                    component.src = "[ISOMORPHIC]/../assets/images/print.png";
                } else {
                    component.src = "";
                }
                return component;
            },
            initialCriteria: {
                _constructor: "AdvancedCriteria",
                operator: "and",
                criteria: [{
                    fieldName: 'empresa_id',
                    value: glb_empresaId,
                    operator: 'equals'
                }]
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI
                    if (record.cotizacion_cerrada == true) {
                        isc.say('No puede eliminarse una cotizacion cerrada');
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
            AutoFitWidthApproach: 'both'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
