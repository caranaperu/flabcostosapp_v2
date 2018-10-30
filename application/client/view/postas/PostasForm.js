/**
 * Clase especifica para la definicion para la edicion de postas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 03:00:37 -0500 (mar, 24 jun 2014) $
 * $Rev: 238 $
 */
isc.defineClass("WinPostasForm", "WindowBasicFormExt");
isc.WinPostasForm.addProperties({
    ID: "winPostasForm",
    title: "Mantenimiento de Postas",
    width: 560,
    height: 160,
    useDeleteButton: true,
    joinKeyFields: [{
        fieldName: 'postas_id',
        fieldValue: ''
    }],
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formPostas",
            numCols: 2,
            colWidths: ["150",
                        "340"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_postas,
            formMode: 'add', // parametro de inicializacion
            openFormMode: 'add',
            saveButton: this.getFormButton('save'),
            deleteButton: this.getFormButton('delete'),
            focusInEditFld: 'postas_id',
            fields: [
                {
                    name: "postas_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    required: false,
                    length: 50,
                    width: 180,
                    valueField: "postas_id",
                    displayField: "postas_descripcion",
                    redrawOnChange: true,
                    pickListFields: [
                        {
                            name: "postas_id",
                            width: '20%'
                        },
                        {
                            name: "postas_descripcion",
                            width: '80%'
                        }],
                    pickListWidth: 240,
                    // optionOperationId: 'fetchJoined',
                    optionDataSource: mdl_postas,
                    textMatchStyle: 'substring',
                    initialSort: [{property: 'postas_descripcion'}],
                    specialValues: {'': "Agregar Posta"},
                    separateSpecialValues: true,
                    getPickListFilterCriteria: function () {
                        // Recogo primero el filtro si existe uno y luego le agrego
                        // id de la posta
                        var filter = this.Super("getPickListFilterCriteria", arguments);
                        if (filter == null) {
                            filter = {};
                        }

                        if (filter.postas_descripcion) {
                            filter = {
                                _constructor: "AdvancedCriteria",
                                operator: "and",
                                criteria: [
                                    {
                                        fieldName: "postas_descripcion",
                                        operator: "iContains",
                                        value: filter.postas_descripcion
                                    },
                                    {
                                        fieldName: 'competencias_pruebas_id',
                                        operator: 'equals',
                                        value: formPostas.competencias_pruebas_id
                                    }]
                            };
                        } else {
                            filter = {
                                _constructor: "AdvancedCriteria",
                                operator: "and",
                                criteria: [{
                                    fieldName: 'competencias_pruebas_id',
                                    operator: 'equals',
                                    value: formPostas.competencias_pruebas_id
                                }]
                            };
                        }
                        return filter;
                    },
                    changed: function (form, item, value) {
                        if (value) {
                            // Seteamos el join key field directo ya que esta forma no sigue el
                            // flujo standard que maneja DefaultController
                            winPostasForm.joinKeyFields[0].fieldValue = value;

                            formPostas.editRecord(item.getSelectedRecord());

                            postasGridContainer.enable();
                            formPostas.setEditMode('edit');

                            g_postasdetalle.cancelEditing();
                            var searchCriteria = g_postasdetalle.getCriteria();
                            if (searchCriteria === null) {
                                searchCriteria = {};
                            }
                            isc.addProperties(searchCriteria, {postas_id: value});
                            g_postasdetalle.fetchData(searchCriteria);
                        } else {
                            formPostas._prepareToAdd();
                        }
                        formPostas.clearErrors(true);
                    },
                    validators: [{
                        type: "requiredIf",
                        expression: "if (value) {return true;} else {return false;}"
                    }]
                },
                {
                    name: "postas_descripcion",
                    title: "Descripcion",
                    length: 150,
                    width: "220",
                    showIf: "values.postas_id === undefined"
                }
            ],
            preSaveData: function (formMode, record) {
                record.competencias_pruebas_id = formPostas.competencias_pruebas_id;
            },
            postSetFieldsToEdit: function () {
                if (this.formMode == 'add') {
                    postasGridContainer.enable();
                }
            },
            /**
             * IMPORTANTE: esto se requiere en esta forma y no en otras ya que el delete se hace en la misma
             * forma y no en una grilla .
             * Cuando esto sucede el DefaultController invoca el removeData deldataSource y en este caso
             * solo pasa los campos llave , en la implementacion la operacion de remove requiere versionId
             * por el servidor.
             *
             * @see DynamicFormExt::getAditionalPropertiesForOperation
             */
            getAditionalPropertiesForOperation: function (operation) {
                var params = null;
                if (operation == 'remove') {
                    params = {'params': {'versionId': formPostas.getItem('postas_id').getSelectedRecord().versionId}};
                }
                return params;
            },
            _prepareToAdd: function () {
                winPostasForm.joinKeyFields[0].fieldValue = null;
                formPostas.editNewRecord();
                //formPostas.formMode = 'add';
                formPostas.setEditMode('add');

                g_postasdetalle.cancelEditing();
                g_postasdetalle.setData([]);
                postasGridContainer.disable();
            }
        });
    },
    showWithMode: function (mode) {
        this.Super('showWithMode', arguments);
        if (mode === 'add') {
            formPostas._prepareToAdd();
        }
    },
    canShowTheDetailGrid: function (mode) {
        return true;
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    isRequiredReadDetailGridData: function () {
        // Si es multiple se requiere releer , de lo ocntraio no es necesario.
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            ID: 'postasGridContainer',
            //   shrinkElementOnHide: true,
            height: 160,
            sectionTitle: 'Atletas que la componen',
            //     showIf:"postasForm.getValue('postas_id') !== undefined,alert(1)",
            gridProperties: {
                ID: 'g_postasdetalle',
                fetchOperation: 'fetchJoined', // solicitado un resultset con el join a atletas resuelto por eficiencia
                dataSource: 'mdl_postasdetalle',
                initialSort: [{property: 'postas_detalle_id'}],
                sortField: 'postas_detalle_id',
                autoFetchData: false,
                fields: [
                    // En este caso observese que no hay option datasource , y que la operacion es fetchJoined, eta tecnica
                    // hace que el servidor traiga los nombres del atleta joined con la tabla principal , pero aun asi
                    // el combo pagina y lee paginadamente , para esto usa la definicion del modelo que le indica que
                    // hay un foreign key a los atletas.
                    {
                        name: "atletas_codigo",
                        editorType: "comboBoxExt",
                        showPending: true,
                        valueField: "atletas_codigo",
                        displayField: "atletas_nombre_completo",
                        pickListWidth: 360,
                        endRow: true,
                        pickListFields: [
                            {
                                name: "atletas_codigo",
                                width: '20%'
                            },
                            {
                                name: "atletas_nombre_completo",
                                width: '80%'
                            }
                        ],
                        completeOnTab: true,
                        //width: 250,
                        optionOperationId: 'fetchForListByPosta',
                        editorProperties: {
                            // Aqui es la mejor posicion del optionDataSource en cualquiera de los otros lados
                            // en pickListProperties o afuera funciona de distinta manera.
                            optionDataSource: mdl_atletas_list,
                            minimumSearchLength: 3,
                            autoFetchData: false,
                            textMatchStyle: 'substring',
                            sortField: "atletas_nombre_completo",
                            getPickListFilterCriteria: function () {
                                // Recogo primero el filtro si existe uno y luego le agrego
                                // id de la posta
                                var filter = this.Super("getPickListFilterCriteria", arguments);
                                if (filter == null) {
                                    filter = {};
                                }
                                // Si existe un filtro ya pre digitado lo pongo en la criteria , de lo contrario
                                // todos los del sexo indicado.
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
                                                fieldName: 'postas_id',
                                                operator: 'equals',
                                                value: formPostas.getValue('postas_id')
                                            }]
                                    };
                                } else {
                                    filter = {
                                        _constructor: "AdvancedCriteria",
                                        operator: "and",
                                        criteria: [{
                                            fieldName: 'postas_id',
                                            operator: 'equals',
                                            value: formPostas.getValue('postas_id')
                                        }]
                                    };
                                }
                                return filter;
                            }
                        }
                    }
                ],
                editComplete: function (rowNum, colNum, newValues, oldValues, editCompletionEvent, dsResponse) {
                    // Actualizamos el registro GRBADO no puedo usar setEditValue porque asumiria que el regisro recien grabado
                    // difiere de lo editado y lo tomaria como pendiente de grabar.d
                    // Tampoco puedo usar el record basado en el rowNum ya que si la lista esta ordenada al reposicionarse los registros
                    // el rownum sera el que equivale al actual orden y no realmente al editado.
                    // En otras palabras este evento es llamado despues de grabar correctamente Y ORDENAR SI HAY UN ORDER EN LA GRILLA
                    // Para resolver esto actualizamos la data del response la cual luego sera usada por el framework SmartClient para actualizar el registro visual.
                    //
                    var oldValue = null;
                    // El valor anterior por si acaso oldValues no este definido.
                    if (oldValues) {
                        oldValue = oldValues.atletas_nombre_completo;
                    }
                    //
                    // el registro es null si se ha eliminado
                    // Si los valores no han cambiado es generalmente que viene de un delete
                    if (dsResponse.data[0] && newValues.atletas_nombre_completo != oldValue) {
                        if (newValues.atletas_nombre_completo) {
                            dsResponse.data[0].atletas_nombre_completo = newValues.atletas_nombre_completo;
                        } else {
                            dsResponse.data[0].atletas_nombre_completo = oldValue;
                        }
                    }
                    // IMPORTANTE: Esto es en realidad es un bug de SmartClient ya que luego de una operacion con los datos
                    // pierde el order by , por lo tanto siempre lo reseteamos al orden de la prueba.
                    g_postasdetalle.setSort([{property: 'postas_detalle_id'}]);
                }
            }
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});