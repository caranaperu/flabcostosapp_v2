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
isc.defineClass("AtletasResultadosGraphWindow", "Window");
isc.AtletasResultadosGraphWindow.addProperties({
    ID: 'atletasResultadosGraphWindow',
    canDragResize: true,
    showFooter: false,
    autoSize: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '700',
    height: '400',
    title: 'Resultados Atletas - Grafico',
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
                        formGraphAtletasResultados.focusInItem('apppruebas_codigo');
                        formButtons.getMember(1).setDisabled(true);
                        formGraphAtletasResultados.clearValues();
                        formGraphAtletasResultados.setAtletasCodigoDisabledState(1, 5, true);
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
                        var atleta_num;
                        var url = '';
                        if (formGraphAtletasResultados.getValue('report_type') != true) {
                            url = '/atletismo/application/client/view/graphics/AtletasResultadosGraphOutput.php';
                        } else {
                            url = '/atletismo/application/client/view/graphics/AtletasResultadosTopNGraphOutput.php';
                        }

                        url += '?apppruebas_codigo=' + formGraphAtletasResultados.getValue('apppruebas_codigo');
                        url += '&atletas_sexo=' + formGraphAtletasResultados.getValue('atletas_sexo');
                        url += '&fecha_desde=' + formGraphAtletasResultados.getValue('fecha_desde').toSerializeableDate().substring(0, 10);
                        url += '&fecha_hasta=' + formGraphAtletasResultados.getValue('fecha_hasta').toSerializeableDate().substring(0, 10);
                        url += '&incluye_manuales=' + formGraphAtletasResultados.getValue('incluye_manuales');
                        url += '&incluye_observadas=' + formGraphAtletasResultados.getValue('incluye_observadas');
                        url += '&categorias_desde=' + formGraphAtletasResultados.getValue('categorias_desde');
                        url += '&categorias_hasta=' + formGraphAtletasResultados.getValue('categorias_hasta');
                        for (var i = 1; i <= 5; i++) {
                            atleta_num = 'atletas_codigo_0' + i;
                            if (formGraphAtletasResultados.getValue(atleta_num)) {
                                url += '&' + atleta_num + '=' + formGraphAtletasResultados.getValue(atleta_num);
                            }
                        }
                        // solo para topN
                        if (formGraphAtletasResultados.getValue('report_type') == true) {
                            url += '&n_records=' + formGraphAtletasResultados.getValue('n_records');
                        }
                        // llama vista que genera datos.
                        graphAtletasResultadosPane.setContentsURL(url);
                    }
                })
            ]
        });

        var formGraphAtletasResultados = isc.DynamicFormExt.create({
            ID: "formGraphAtletasResultados",
            numCols: 4,
            fixedColWidths: true,
            padding: 5,
            autoSize: true,
            fields: [
                {name: "report_type", title: 'Tipo TopN', type: "checkbox",
                    changed: function (form, item, value) {
                        if (value == false) {
                            form.getItem('n_records').setDisabled(true);
                            form.clearFieldErrors('n_records', true);
                            form.setValue('n_records', '');
                        } else {
                            form.getItem('n_records').setDisabled(false);
                            form.setValue('n_records', '10');
                        }
                        // Se habilita ingreso al primer ateta , se limpian los demas y se desabilitan.
                        formGraphAtletasResultados.getItem('atletas_codigo_01').setDisabled(false);
                        formGraphAtletasResultados.clearAtletasCodigo(1, 5);
                        formGraphAtletasResultados.setAtletasCodigoDisabledState(2, 5, true);

                    }},
                {name: "n_records", title: '#Registros', type: "integer", length: 2, width: 50,
                    validators: [{
                            type: "requiredIf",
                            expression: "formGraphAtletasResultados.getValue('report_type') == true",
                            errorMessage: "Por favor indique el numero de resultados maximos"
                        }],
                    endRow: true},
                {name: "apppruebas_codigo", title: 'prueba', editorType: "comboBoxExt", length: 50, width: "200", required: true, endRow: true,
                    valueField: "apppruebas_codigo", displayField: "apppruebas_descripcion",
                    pickListFields: [{name: "apppruebas_codigo", width: '30%'}, {name: "apppruebas_descripcion", width: '80%'}],
                    pickListWidth: 280,
                    optionOperationId: 'fetchJoined',
                    optionDataSource: mdl_apppruebas,
                    textMatchStyle: 'substring',
                    sortField: "apppruebas_descripcion",
                    changed: function (form, item, value) {
                        // si la prueba es cambiada debe limpiarse los atletas elegidos y ademas
                        // dejar enabled solo el ingreso al primero de ellos.
                        var record = item.getSelectedRecord();
                        if (record) {
                            formGraphAtletasResultados.getItem('atletas_codigo_01').setDisabled(false);
                        } else {
                            formGraphAtletasResultados.getItem('atletas_codigo_01').setDisabled(true);

                        }
                        formGraphAtletasResultados.clearAtletasCodigo(1, 5);
                        formGraphAtletasResultados.setAtletasCodigoDisabledState(2, 5, true);
                    }
                },
                {name: "atletas_sexo", title: 'sexo', valueMap: ["M", "F"], defaultValue: 'M', required: true, width: 60, endRow: true,
                    changed: function (form, item, value) {
                        // si el sexo para la prueba  es cambiada debe limpiarse los atletas elegidos y ademas
                        // dejar enabled solo el ingreso al primero de ellos.
                        formGraphAtletasResultados.getItem('atletas_codigo_01').setDisabled(false);
                        formGraphAtletasResultados.clearAtletasCodigo(1, 5);
                        formGraphAtletasResultados.setAtletasCodigoDisabledState(2, 5, true);
                    }},
                {name: "categorias_desde", title: 'Categorias Desde', editorType: "comboBoxExt", length: 50, width: "100",
                    valueField: "categorias_codigo", displayField: "categorias_descripcion",
                    pickListFields: [{name: "categorias_codigo", width: '20%'}, {name: "categorias_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    optionOperationId: 'fetchWithPesos',
                    defaultValue: 'MAY',
                    optionDataSource: mdl_categorias_pesos,
                    validators: [
                        // Valida que la categoria inicial no sea mayor que la final
                        {type: "categoriaMenorCheck",
                            // Valida que la marca menor no sea mayor que la final
                            // dado que en este momento se tratan como string normalizamos y comparamos
                            condition: function (item, validator, value) {
                                var record_desde = item.getSelectedRecord();
                                var record_hasta = formGraphAtletasResultados.getItem('categorias_hasta').getSelectedRecord();
                                if (!record_desde) {
                                    validator.errorMessage = 'Defina desde que categoria';
                                    return false;
                                } else if (record_desde && record_hasta) {
                                    formGraphAtletasResultados.clearFieldErrors('categorias_hasta', true);
                                    var testMenor = record_desde.appcat_peso;
                                    var testMayor = record_hasta.appcat_peso;
                                    if (parseInt(testMenor) > parseInt(testMayor)) {
                                        validator.errorMessage = 'No puede ser mayor que la Categoria Hasta';
                                        return false;
                                    }
                                }
                                return true;
                            }
                        }
                    ]
                },
                {name: "categorias_hasta", title: 'Hasta', editorType: "comboBoxExt", length: 50, width: "100", endRow: true,
                    valueField: "categorias_codigo", displayField: "categorias_descripcion",
                    pickListFields: [{name: "categorias_codigo", width: '20%'}, {name: "categorias_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    optionOperationId: 'fetchWithPesos',
                    defaultValue: 'MAY',
                    optionDataSource: mdl_categorias_pesos,
                    validators: [
                        // Valida que la categoria final no sea menor que la inicial
                        {type: "categoriaMayorCheck",
                            // Valida que la marca menor no sea mayor que la final
                            // dado que en este momento se tratan como string normalizamos y comparamos
                            condition: function (item, validator, value) {
                                var record_hasta = item.getSelectedRecord();
                                var record_desde = formGraphAtletasResultados.getItem('categorias_desde').getSelectedRecord();
                                if (!record_hasta) {
                                    validator.errorMessage = 'Defina hasta que categoria';
                                    return false;
                                } else if (record_desde && record_hasta) {
                                    formGraphAtletasResultados.clearFieldErrors('categorias_desde', true);
                                    var testMenor = record_desde.appcat_peso;
                                    var testMayor = record_hasta.appcat_peso;
                                    if (parseInt(testMenor) > parseInt(testMayor)) {
                                        validator.errorMessage = 'No puede ser menor que la Categoria Desde';
                                        return false;
                                    }
                                }
                                return true;
                            }
                        }
                    ]
                },
                {name: "fecha_desde", title: 'Fechas Desde', type: "date",
                    validators: [
                        {type: "fechaMenorCheck",
                            // Valida que la decha menor no sea mayor que la final
                            condition: function (item, validator, value) {
                                var fecha_hasta = formGraphAtletasResultados.getValue('fecha_hasta');
                                var fecha_desde = value;

                                formGraphAtletasResultados.clearFieldErrors('fecha_hasta', true);

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
                                var fecha_desde = formGraphAtletasResultados.getValue('fecha_desde');
                                var fecha_hasta = value;

                                formGraphAtletasResultados.clearFieldErrors('fecha_desde', true);

                                if (fecha_desde > fecha_hasta) {
                                    validator.errorMessage = 'No puede ser menor que la fecha inicial';
                                    return false;
                                }
                                return true;
                            }
                        }
                    ]
                },
                {name: "atletas_codigo_01", title: 'Atleta 1', editorType: "comboBoxExt", length: 50, colSpan: '4', width: "*", endRow: true,
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    pickListFields: [{name: "atletas_codigo", width: '30%'}, {name: "atletas_nombre_completo", width: '80%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    required: true,
                    disabled: false,
                    optionOperationId: 'fetchForListByPrueba',
                    optionDataSource: mdl_atletas,
                    textMatchStyle: 'substring',
                    sortField: "atletas_nombre_completo",
                    changed: function (form, item, value) {
                        var record = item.getSelectedRecord();
                        if (record) {
                            // solo se abre el siguiente input si es un reporte topn
                            if (formGraphAtletasResultados.getValue('report_type') == true) {
                                formGraphAtletasResultados.getItem('atletas_codigo_02').setDisabled(false);
                            }
                        } else {
                            formGraphAtletasResultados.clearAtletasCodigo(2, 5);
                            formGraphAtletasResultados.setAtletasCodigoDisabledState(2, 5, true);
                        }
                    },
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la prueba y sexo seleccionados
                     */
                    getPickListFilterCriteria: function () {
                        return formGraphAtletasResultados.getPickListFilterCriteriaForAtletasCodigo(this);
                    }
                },
                {name: "atletas_codigo_02", title: 'Atleta 2', editorType: "comboBoxExt", length: 50, colSpan: '4', width: "*", endRow: true,
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    pickListFields: [{name: "atletas_codigo", width: '30%'}, {name: "atletas_nombre_completo", width: '80%'}],
                    pickListWidth: 350,
                    completeOnTab: true,
                    disabled: true,
                    optionOperationId: 'fetchForListByPrueba',
                    optionDataSource: mdl_atletas,
                    textMatchStyle: 'substring',
                    sortField: "atletas_nombre_completo",
                    changed: function (form, item, value) {
                        var record = item.getSelectedRecord();
                        if (record) {
                            formGraphAtletasResultados.getItem('atletas_codigo_03').setDisabled(false);
                        } else {
                            formGraphAtletasResultados.clearAtletasCodigo(3, 5);
                            formGraphAtletasResultados.setAtletasCodigoDisabledState(3, 5, true);
                        }
                    },
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la prueba y sexo seleccionados
                     */
                    getPickListFilterCriteria: function () {
                        return formGraphAtletasResultados.getPickListFilterCriteriaForAtletasCodigo(this);
                    }
                },
                {name: "atletas_codigo_03", title: 'Atleta 3', editorType: "comboBoxExt", length: 50, colSpan: '4', width: "*", endRow: true,
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    pickListFields: [{name: "atletas_codigo", width: '30%'}, {name: "atletas_nombre_completo", width: '80%'}],
                    pickListWidth: 350,
                    completeOnTab: true,
                    disabled: true,
                    optionOperationId: 'fetchForListByPrueba',
                    optionDataSource: mdl_atletas,
                    textMatchStyle: 'substring',
                    sortField: "atletas_nombre_completo",
                    changed: function (form, item, value) {
                        var record = item.getSelectedRecord();
                        if (record) {
                            formGraphAtletasResultados.getItem('atletas_codigo_04').setDisabled(false);
                        } else {
                            formGraphAtletasResultados.clearAtletasCodigo(4, 5);
                            formGraphAtletasResultados.setAtletasCodigoDisabledState(4, 5, true);
                        }
                    },
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la prueba y sexo seleccionados
                     */
                    getPickListFilterCriteria: function () {
                        return formGraphAtletasResultados.getPickListFilterCriteriaForAtletasCodigo(this);
                    }
                },
                {name: "atletas_codigo_04", title: 'Atleta 4', editorType: "comboBoxExt", length: 50, colSpan: '4', width: "*", endRow: true,
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    pickListFields: [{name: "atletas_codigo", width: '30%'}, {name: "atletas_nombre_completo", width: '80%'}],
                    pickListWidth: 350,
                    completeOnTab: true,
                    disabled: true,
                    optionOperationId: 'fetchForListByPrueba',
                    optionDataSource: mdl_atletas,
                    textMatchStyle: 'substring',
                    sortField: "atletas_nombre_completo",
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la prueba y sexo seleccionados
                     */
                    getPickListFilterCriteria: function () {
                        return formGraphAtletasResultados.getPickListFilterCriteriaForAtletasCodigo(this);
                    }
                },
                {name: "atletas_codigo_05", title: 'Atleta 5', editorType: "comboBoxExt", length: 50, colSpan: '4', width: "*", endRow: true,
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    pickListFields: [{name: "atletas_codigo", width: '30%'}, {name: "atletas_nombre_completo", width: '80%'}],
                    pickListWidth: 350,
                    completeOnTab: true,
                    disabled: true,
                    optionOperationId: 'fetchForListByPrueba',
                    editorProperties: {
                        optionDataSource: mdl_atletas,
                        minimumSearchLength: 3,
                        textMatchStyle: 'substring',
                        sortField: "atletas_nombre_completo"
                    },
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la prueba y sexo seleccionados
                     */
                    getPickListFilterCriteria: function () {
                        return formGraphAtletasResultados.getPickListFilterCriteriaForAtletasCodigo(this);
                    }
                },
                {name: "incluye_manuales", title: 'Resultados Manuales', defaultValue: true, type: 'boolean', length: 50},
                {name: "incluye_observadas", title: 'Resultados Observados', defaultValue: true, type: 'boolean', length: 50, endRow: true}
            ],
            itemChanged: function () {
                formButtons.getMember(1).setDisabled(!formGraphAtletasResultados.valuesAreValid(false));
            },
            /**
             * Se hace el override ya que este campo requiere que solo obtenga las pruebas
             * que dependen de la de la categoria y el sexo del atleta,el primero proviene
             * de la competencia y el segundo del atleta.
             */
            getPickListFilterCriteriaForAtletasCodigo: function (item) {
                // Recogo primero el filtro si existe uno y luego le agrego
                // la categoria y el sexo.
                var filter = item.Super("getPickListFilterCriteria", arguments);
                if (filter == null) {
                    filter = {};
                }

                filter = {_constructor: "AdvancedCriteria",
                    operator: "and", criteria: [
                        {fieldName: "pruebas_generica_codigo", operator: "equals", value: formGraphAtletasResultados.getValue('apppruebas_codigo')},
                        {fieldName: 'atletas_sexo', operator: 'equals', value: formGraphAtletasResultados.getValue('atletas_sexo')}
                    ]};
                return filter;
            },
            /**
             * SOPORTE PARA EVITAR CODIGO REPETITIVO.
             */
            setAtletasCodigoDisabledState: function (from, to, disabled) {
                for (var i = from; i <= to; i++) {
                    var atleta_num = 'atletas_codigo_0' + i;
                    formGraphAtletasResultados.getItem(atleta_num).setDisabled(disabled);
                }
            },
            clearAtletasCodigo: function (from, to) {
                for (var i = from; i <= to; i++) {
                    var atleta_num = 'atletas_codigo_0' + i;
                    formGraphAtletasResultados.getItem(atleta_num).clearValue();
                }
            }
            // , cellBorder: 1
        });



        /**
         * Parte visual
         */
        var htmlPane = isc.HTMLPane.create({
            ID: "graphAtletasResultadosPane",
            showEdges: true,
            contentsURL: "",
            contentsType: "page"
        })

        var sections = isc.SectionStack.create({
            autoSize: true,
            border: "1px solid blue",
            showExpandControls: false,
            sections: [
                {title: "Filtro", expanded: true, items: [formGraphAtletasResultados, formButtons], ID: 'SectionFiltroAtletasResultados'},
                {title: "Grafico", expanded: false, canCollapse: true, items: [graphAtletasResultadosPane], ID: 'SectionGraficoAtletasResultados'}
            ],
            collapseSection: function (sections, callback) {
                this.Super('collapseSection', arguments);
                // Se cambia el tamaño del contenido de la seccion de acuerdo sea la seccion de filtro o
                // la seccion de graficos.
                if (sections.name == 'SectionFiltroAtletasResultados') {
                    atletasResultadosGraphWindow.resizeTo(820, 560);
                } else {
                    atletasResultadosGraphWindow.resizeTo(700, 400);
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
                        atletasResultadosGraphWindow.hide();
                    }
                })
            ]
        });

        this.addItem(sections);
        this.addItem(exitButton);
    }
});
