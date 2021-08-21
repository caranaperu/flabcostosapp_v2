/**
 * Clase que prepara la informacion previa a emitir el reporte de resultados
 * de atletas individualmente o comparados, luego de preparar la data
 * llama a una ventana externa que emitira los graficos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-05-05 20:23:49 -0500 (lun, 05 may 2014) $
 * $Rev: 177 $
 */
isc.defineClass("RecordsGraphWindow", "Window");
isc.RecordsGraphWindow.addProperties({
    ID: 'recordsGraphWindow',
    canDragResize: true,
    showFooter: false,
    autoSize: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '700',
    height: '275',
    title: 'Records - Grafico',
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
                        formGraphRecords.focusInItem('apppruebas_codigo');
                        formButtons.getMember(1).setDisabled(true);
                        formGraphRecords.clearValues();
                    }
                }),
                isc.Button.create({
                    ID: "btnDoGraph" + this.ID,
                    title: 'graficar',
                    width: '100',
                    autoDraw: false,
                    disabled: true,
                    click: function () {
                        sections.expandSection(1);
                        // prepara la llamada
                        var url = '/atletismo/application/client/view/graphics/RecordsGraphOutput.php';


                        url += '?apppruebas_codigo=' + formGraphRecords.getValue('apppruebas_codigo');
                        url += '&atletas_sexo=' + formGraphRecords.getValue('atletas_sexo');
                        url += '&fecha_desde=' + formGraphRecords.getValue('fecha_desde').toSerializeableDate().substring(0, 10);
                        url += '&fecha_hasta=' + formGraphRecords.getValue('fecha_hasta').toSerializeableDate().substring(0, 10);
                        url += '&incluye_manuales=' + formGraphRecords.getValue('incluye_manuales');
                        url += '&incluye_altura=' + formGraphRecords.getValue('incluye_altura');
                        url += '&categorias_codigo=' + formGraphRecords.getValue('categorias_codigo');
                        url += '&records_tipo_codigo=' + formGraphRecords.getValue('records_tipo_codigo');
                        // llama vista que genera datos.
                        graphRecordsPane.setContentsURL(url);
                    }
                })
            ]
        });

        var formGraphRecords = isc.DynamicFormExt.create({
            ID: "formGraphRecords",
            numCols: 4,
            fixedColWidths: true,
            padding: 5,
            autoSize: true,
            fields: [
                //  {name: "n_records", title: '#Registros', type: "integer", length: 2, width: 50, endRow: true},
                {name: "records_tipo_codigo", title: 'Tipo Record', editorType: "comboBoxExt", length: 50, width: "200", required: true, endRow: true,
                    valueField: "records_tipo_codigo", displayField: "records_tipo_descripcion",
                    pickListFields: [{name: "records_tipo_codigo", width: '30%'}, {name: "records_tipo_descripcion", width: '80%'}],
                    pickListWidth: 280,
                    optionOperationId: 'fetchJoined',
                    optionDataSource: mdl_records_tipo,
                    textMatchStyle: 'substring',
                    sortField: "records_tipo_descripcion"
                },
                {name: "apppruebas_codigo", title: 'prueba', editorType: "comboBoxExt", length: 50, width: "200", required: true, endRow: true,
                    valueField: "apppruebas_codigo", displayField: "apppruebas_descripcion",
                    pickListFields: [{name: "apppruebas_codigo", width: '30%'}, {name: "apppruebas_descripcion", width: '80%'}],
                    pickListWidth: 280,
                    optionOperationId: 'fetchJoined',
                    optionDataSource: mdl_apppruebas,
                    textMatchStyle: 'substring',
                    sortField: "apppruebas_descripcion"
                },
                {name: "atletas_sexo", title: 'sexo', valueMap: ["M", "F"], defaultValue: 'M', required: true, width: 60, endRow: true},
                {name: "categorias_codigo", title: 'Categoria', editorType: "comboBoxExt", length: 50, width: "100", endRow: true,
                    valueField: "categorias_codigo", displayField: "categorias_descripcion",
                    pickListFields: [{name: "categorias_codigo", width: '20%'}, {name: "categorias_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    optionOperationId: 'fetchWithPesos',
                    defaultValue: 'MAY',
                    optionDataSource: mdl_categorias_pesos
                },
                {name: "fecha_desde", title: 'Fechas Desde', type: "date",
                    validators: [
                        {type: "fechaMenorCheck",
                            // Valida que la decha menor no sea mayor que la final
                            condition: function (item, validator, value) {
                                var fecha_hasta = formGraphRecords.getValue('fecha_hasta');
                                var fecha_desde = value;

                                formGraphRecords.clearFieldErrors('fecha_hasta', true);

                                if (fecha_desde > fecha_hasta) {
                                    validator.errorMessage = 'No puede ser mayor que la fecha final';
                                    return false;
                                }
                                return true;
                            }
                        }
                    ]
                },
                {name: "fecha_hasta", title: 'Hasta', type: "date", endRow: true,
                    validators: [
                        {type: "fechaMayorCheck",
                            // Valida que la fecha mayor no sea menor que la inicial.
                            condition: function (item, validator, value) {
                                var fecha_desde = formGraphRecords.getValue('fecha_desde');
                                var fecha_hasta = value;

                                formGraphRecords.clearFieldErrors('fecha_desde', true);

                                if (fecha_desde > fecha_hasta) {
                                    validator.errorMessage = 'No puede ser menor que la fecha inicial';
                                    return false;
                                }
                                return true;
                            }
                        }
                    ]
                },
                {name: "incluye_manuales", title: 'Resultados Manuales', defaultValue: true, type: 'boolean', length: 50},
                {name: "incluye_altura", title: 'Resultados en Altura', defaultValue: true, type: 'boolean', length: 50, endRow: true}
            ],
            itemChanged: function () {
                formButtons.getMember(1).setDisabled(!formGraphRecords.valuesAreValid(false));
            },
            // , cellBorder: 1
        });



        /**
         * Parte visual
         */
        var htmlPane = isc.HTMLPane.create({
            ID: "graphRecordsPane",
            showEdges: true,
            contentsURL: "",
            contentsType: "page"
        })

        var sections = isc.SectionStack.create({
            autoSize: true,
            border: "1px solid blue",
            showExpandControls: false,
            sections: [
                {title: "Filtro", expanded: true, items: [formGraphRecords, formButtons], ID: 'SectionFiltroRecords'},
                {title: "Grafico", expanded: false, canCollapse: true, items: [graphRecordsPane], ID: 'SectionGraficoRecords'}
            ],
            collapseSection: function (sections, callback) {
                this.Super('collapseSection', arguments);
                // Se cambia el tamaño del contenido de la seccion de acuerdo sea la seccion de filtro o
                // la seccion de graficos.
                if (sections.name == 'SectionFiltroRecords') {
                    recordsGraphWindow.resizeTo(820, 560);
                } else {
                    recordsGraphWindow.resizeTo(700, 275);
                }
            }
        });

        var exitButton = isc.HStack.create({
            height: 22,
            layoutAlign: "center", padding: 0, autoDraw: false,
            align: 'center',
            members: [isc.Button.create({
                    ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function () {
                        recordsGraphWindow.hide();
                    }
                })
            ]
        });

        this.addItem(sections);
        this.addItem(exitButton);
    }
});
