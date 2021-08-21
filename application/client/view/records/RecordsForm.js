/**
 * Clase especifica para la definicion de la ventana para la edicion y creacion de los records mundiales,
 * nacionales,etc-
 *
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-16 00:10:26 -0500 (mié, 16 jul 2014) $
 * $Rev: 313 $
 */
isc.defineClass("WinRecordsForm", "WindowBasicFormExt");
isc.WinRecordsForm.addProperties({
    ID: "winRecordsForm",
    title: "Mantenimiento de Records",
    autoSize: false,
    width: '600',
    height: '230',
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formRecords",
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_records,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['records_id',
                        'records_tipo_codigo',
                        'apppruebas_codigo',
                        'atletas_codigo',
                        'atletas_resultados_id',
                        'categorias_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'records_tipo_codigo',
            fields: [
                {
                    name: "records_tipo_codigo",
                    editorType: "comboBoxExt",
                    length: 50,
                    width: "200",
                    valueField: "records_tipo_codigo",
                    displayField: "records_tipo_descripcion",
                    pickListFields: [
                        {
                            name: "records_tipo_descripcion",
                            width: '70%'
                        },
                        {name: "records_tipo_abreviatura"}
                    ],
                    pickListWidth: 250,
                    completeOnTab: true,
                    // vital para indicar el opertion id , si se usa en otro lugar recarga por gusto.
                    optionOperationId: 'fetch',
                    optionDataSource: mdl_records_tipo,
                    autoFetchData: true,
                    textMatchStyle: 'substring',
                    sortField: "records_tipo_descripcion"
                },
                {
                    name: "apppruebas_codigo",
                    title: 'Prueba',
                    editorType: "comboBoxExt",
                    length: 50,
                    width: "200",
                    valueField: "apppruebas_codigo",
                    displayField: "apppruebas_descripcion",
                    pickListFields: [
                        {name: "apppruebas_descripcion"}
                    ],
                    pickListWidth: 250,
                    completeOnTab: true,
                    optionOperationId: 'fetchDescriptions',
                    optionDataSource: mdl_apppruebas_description,
                    autoFetchData: false,
                    textMatchStyle: 'substring',
                    sortField: "apppruebas_descripcion",
                    changed: function (form, item, value) {
                        // si la prueba es cambiada debe limpiarse el atleta ,competencia y
                        // categorias elegidas.
                        var record = item.getSelectedRecord();
                        formRecords._setFieldStatus('atletas_codigo', (record ? false : true), true);
                        formRecords._setFieldStatus('atletas_resultados_id', true, true);
                        formRecords._setFieldStatus('categorias_codigo', true, true);
                    }
                },
                {
                    name: "atletas_codigo",
                    title: 'Atleta',
                    editorType: "comboBoxExt",
                    length: 50,
                    width: "250",
                    disabled: true,
                    valueField: "atletas_codigo",
                    displayField: "atletas_nombre_completo",
                    pickListFields: [
                        {
                            name: "atletas_codigo",
                            width: '20%'
                        },
                        {
                            name: "atletas_nombre_completo",
                            width: '80%'
                        }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    optionOperationId: 'fetchForListByPruebaGenerica',
                    optionDataSource: mdl_atletas,
                    autoFetchData: false,
                    textMatchStyle: 'substring',
                    sortField: "atletas_nombre_completo",
                    // ESto para que no lea autmaticamente ya que al editar requerimos hacer el fetch directamente
                    // ya que las pruebas dependen de la categoria y sexo.
                    fetchMissingValues: false,
                    changed: function (form, item, value) {
                        // si el codigo del atleta es cambiado  la competencia y
                        // categorias elegidas deben ser apagadas.
                        var record = item.getSelectedRecord();
                        formRecords._setFieldStatus('atletas_resultados_id', (record ? false : true), true);
                        formRecords._setFieldStatus('categorias_codigo', true, true);

                    },
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la categoria y el sexo del atleta,el primero proviene
                     * de la competencia y el segundo del atleta.
                     */
                    getPickListFilterCriteria: function () {
                        // Recogo primero el filtro si existe uno y luego le agrego
                        // la categoria y el sexo.
                        var filter = this.Super("getPickListFilterCriteria", arguments);
                        if (filter == null) {
                            filter = {};
                        }


                        // Esta es una optimizacion realizada para que en mode edit solo lea un especifico registro.
                        // YA QUE AHORA NO SE PUEDE EDITAR EL CODIGO DE PRUEBA AL EDITARSE!!! , DE LO CONTRARIO DEBERIA
                        // LEERSE SIEMPRE TODO.
                        //
                        // Si existe un filtro ya pre digitado lo pongo en la criteria , de lo contrario
                        // todos los posibles para la competencia indicada.
                        if (filter.atletas_nombre_completo) {
                            filter = {
                                _constructor: "AdvancedCriteria",
                                operator: "and",
                                criteria: [
                                    {
                                        fieldName: "atletas_nombre_completo",
                                        operator: "iContains",
                                        value: filter.atletas_nombre_completo
                                    },
                                    {
                                        fieldName: "apppruebas_codigo",
                                        operator: "equals",
                                        value: formRecords.getValue('apppruebas_codigo')
                                    }
                                ]
                            };
                        } else { // CASO NO EXISTE NADA DIGITADO.
                            // En modo edit buscamos en gorma exacta el codigo
                            if (formRecords.formMode == 'edit') {

                                var curRecord = formRecords.getValues();

                                // Si el record es de postas buscamos al atleta basado en el resultado ya que el codigo para las postas es unico
                                // y se repite en todos los resultados.
                                if (curRecord.postas_id) {
                                    filter = {
                                        _constructor: "AdvancedCriteria",
                                        operator: "and",
                                        criteria: [
                                            {
                                                fieldName: "atletas_resultados_id",
                                                operator: "equals",
                                                value: curRecord.atletas_resultados_id
                                            }
                                        ]
                                    };
                                } else {
                                    filter = {
                                        _constructor: "AdvancedCriteria",
                                        operator: "and",
                                        criteria: [
                                            {
                                                fieldName: "atletas_codigo",
                                                operator: "equals",
                                                value: formRecords.getValue('atletas_codigo')
                                            },
                                            {
                                                fieldName: "apppruebas_codigo",
                                                operator: "equals",
                                                value: formRecords.getValue('apppruebas_codigo')
                                            }
                                        ]
                                    };
                                }
                            } else {
                                // De lo contrario buscamos todas las posibles.
                                filter = {
                                    _constructor: "AdvancedCriteria",
                                    operator: "and",
                                    criteria: [
                                        //   {fieldName: "atletas_nombre_completo", operator: "iContains", value: filter.atletas_nombre_completo},
                                        {
                                            fieldName: "apppruebas_codigo",
                                            operator: "equals",
                                            value: formRecords.getValue('apppruebas_codigo')
                                        }
                                    ]
                                };
                            }
                        }
                        console.log(filter);
                        return filter;
                    }
                },
                {
                    name: "atletas_resultados_id",
                    title: 'Competencia/Marca',
                    editorType: "comboBoxExt",
                    length: 50,
                    width: "450",
                    disabled: true,
                    valueField: "atletas_resultados_id",
                    displayField: "competencias_descripcion",
                    pickListFields: [
                        {
                            name: 'Resultado',
                            formatCellValue: function (value, record, rownum, colnum) {
                                if (record) {
                                    var fvalue = record.numb_resultado;
                                    if (record.ciudades_altura == true) {
                                        fvalue += '(A)'
                                    }
                                    fvalue += ', V:' + record.competencias_pruebas_viento;
                                    return fvalue;
                                } else {
                                    return '';
                                }

                            },
                            width: 100
                        },
                        {
                            name: "competencias_pruebas_fecha",
                            width: '60'
                        },
                        {
                            name: "categorias_codigo",
                            width: '70'
                        },
                        {
                            name: 'Lugar',
                            formatCellValue: function (value, record, rownum, colnum) {
                                if (record) {
                                    return record.competencias_descripcion + '/' + record.paises_descripcion + '/' + record.ciudades_descripcion;
                                } else {
                                    return '';
                                }

                            }
                        }
                    ],
                    pickListWidth: 500,
                    formatOnBlur: true,
                    optionDataSource: mdl_atletaspruebas_resultados_for_records,
                    textMatchStyle: 'substring',
                    sortField: "competencias_pruebas_fecha",
                    autoFetchData: false,
                    formatValue: function (value, record, form, item) {

                        // closure para mejor lectura
                        var _doFormat = function (lugar, resultado, enAltura, viento, categoria) {
                            var fvalue = 'Marca: ' + resultado;
                            if (enAltura == true) {
                                fvalue += '(A)'
                            }
                            fvalue += ', V:' + viento;
                            fvalue += ', Cat: ' + categoria;
                            fvalue += ', ' + lugar;

                            return fvalue;
                        }
                        // caso edit
                        // En este caso usamos el parametro record que contiene los datos del registro a editar
                        // y alli estan todos los valores necesarios a pintar.
                        // Si es un modo add los valores los extraemos del registro leido por el combo.
                        if (formRecords.formMode == 'edit') {
                            return _doFormat(record.lugar, record.atletas_resultados_resultado, record.ciudades_altura, record.competencias_pruebas_viento, record.categorias_codigo);
                        } else {
                            // Si existe un registro ya seleccionado , partmos de alli
                            var recordFinal = item.getSelectedRecord();
                            if (recordFinal) {
                                return _doFormat(recordFinal.competencias_descripcion + '/' + recordFinal.paises_descripcion + '/' + recordFinal.ciudades_descripcion,
                                    recordFinal.numb_resultado, recordFinal.ciudades_altura, recordFinal.competencias_pruebas_viento, recordFinal.categorias_codigo);
                            } else {
                                return value;
                            }
                        }

                    },
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la categoria y el sexo del atleta,el primero proviene
                     * de la competencia y el segundo del atleta.
                     */
                    getPickListFilterCriteria: function () {
                        // Recogo primero el filtro si existe uno y luego le agrego
                        // la categoria y el sexo.
                        var filter = this.Super("getPickListFilterCriteria", arguments);
                        if (filter == null) {
                            filter = {};
                        }
                        // Esta es una optimizacion realizada para que en mode edit solo lea un especifico registro.
                        // YA QUE AHORA NO SE PUEDE EDITAR EL CODIGO DE PRUEBA AL EDITARSE!!! , DE LO CONTRARIO DEBERIA
                        // LEERSE SIEMPRE TODO.
                        //
                        // Si existe un filtro ya pre digitado lo pongo en la criteria , de lo contrario
                        // todos los posibles para la competencia indicada.
                        if (filter.competencias_descripcion) {
                            filter = {
                                _constructor: "AdvancedCriteria",
                                operator: "and",
                                criteria: [
                                    {
                                        fieldName: "competencias_descripcion",
                                        operator: "iContains",
                                        value: filter.competencias_descripcion
                                    },
                                    {
                                        fieldName: "apppruebas_codigo",
                                        operator: "equals",
                                        value: formRecords.getValue('apppruebas_codigo')
                                    },
                                    {
                                        fieldName: "atletas_codigo",
                                        operator: "equals",
                                        value: formRecords.getValue('atletas_codigo')
                                    }
                                ]
                            };
                        } else { // CASO NO EXISTE NADA DIGITADO.
                            // En modo edit buscamos en gorma exacta el codigo
                            if (formRecords.formMode == 'edit') {
                                filter = {
                                    _constructor: "AdvancedCriteria",
                                    operator: "and",
                                    criteria: [
                                        {
                                            fieldName: "atletas_resultados_id",
                                            operator: "equals",
                                            value: formRecords.getValue('atletas_resultados_id')
                                        }
                                    ]
                                };
                            } else {
                                // De lo contrario buscamos todas las posibles.
                                filter = {
                                    _constructor: "AdvancedCriteria",
                                    operator: "and",
                                    criteria: [
                                        //   {fieldName: "atletas_nombre_completo", operator: "iContains", value: filter.atletas_nombre_completo},
                                        {
                                            fieldName: "apppruebas_codigo",
                                            operator: "equals",
                                            value: formRecords.getValue('apppruebas_codigo')
                                        },
                                        {
                                            fieldName: "atletas_codigo",
                                            operator: "equals",
                                            value: formRecords.getValue('atletas_codigo')
                                        }
                                    ]
                                };
                            }
                        }
                        console.log(filter);
                        return filter;
                    },
                    changed: function (form, item, value) {
                        // si el codigo del atleta es cambiado  la competencia y
                        // categorias elegidas deben ser apagadas.
                        var record = item.getSelectedRecord();
                        if (record) {
                            formRecords._setFieldStatus('categorias_codigo', false, false);
                            formRecords.getItem('categorias_codigo').setValue(record.categorias_codigo);

                        } else {
                            formRecords._setFieldStatus('categorias_codigo', true, true);
                        }
                    }
                },
                {
                    name: "categorias_codigo",
                    editorType: "comboBoxExt",
                    length: 50,
                    width: "100",
                    valueField: "categorias_codigo",
                    displayField: "categorias_descripcion",
                    pickListFields: [
                        {
                            name: "categorias_codigo",
                            width: '20%'
                        },
                        {
                            name: "categorias_descripcion",
                            width: '80%'
                        }],
                    pickListWidth: 240,
                    optionDataSource: mdl_categorias,
                    autoFetchData: false
                },
                {
                    name: "records_id",
                    visible: false
                }
            ],
            /**
             * Override para aprovecha que solo en modo add se blanqueen todas las variables de cache y el estado
             * de los campos a su modo inicial o default.
             *
             * @param {string} mode 'add' o 'edit'
             */
            setEditMode: function (mode) {
                this.Super("setEditMode", arguments);
                if (mode == 'add') {
                    formRecords.getItem('atletas_codigo').setDisabled(true);
                    formRecords.getItem('atletas_resultados_id').setDisabled(true);
                    formRecords.getItem('categorias_codigo').setDisabled(true);
                }
            },
            isPostOperationDataRefreshMainListRequired: function (operationType) {
                return true;
            },
            editSelectedData: function (component) {
                var record = component.getSelectedRecord();
                this.Super('editSelectedData', arguments);


                // Aqui forzamos solo a leer un registro justo el que corresponde a la prueba
                // de este registro.
                // Para que esto funcione ok es necesario que el combo de pruebas indique
                //      fetchMissingValues: false,
                //      autoFetchData: false
                // De tal manera que se anulen lecturas no deseadas.
                winRecordsForm.fetchFieldRecord('atletas_codigo',
                    {"atletas_codigo": record.atletas_codigo});
            },
            /*******************************************************************
             *
             * FUNCIONES DE SOPORTE PARA LA FORMA
             */
            /**
             * Funcion de soporte para limpiar un campo , sus errores y activarlo o desactivarlo.
             * @param {fieldName} nombre del campo de la forma
             * @param {boolean} disable true para desactivar , false para activar.
             * @param {boolean} clear true para limpiar campo, false no tocarlo.
             */
            _setFieldStatus: function (fieldName, disable, clear) {
                if (clear) {
                    formRecords.getItem(fieldName).clearValue();
                }
                formRecords.getItem(fieldName).setDisabled(disable);
                formRecords.clearFieldErrors(fieldName, true);
            }
            //  , cellBorder: 1
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});