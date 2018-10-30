/**
 * Clase especifica para la definicion de la ventana para la edicion de las pruebas genericas
 * Esta forma presenta un requerimiento especial y este se debe a que los campos
 * apppruebas_marca_menor y apppruebas_marca_mayor son de tipo mutable , ya que estos dependiendo
 * de la categoria de prueba tienen una mascara o expresion regular diferente para el input.
 *
 * Por ende se requiere que :
 * 1) A la primera vez que se agregue , en el caso que no se haya editado previamente la unica manera
 *  de interceptar la lectura del registro de clasificacion de prueba es en el DataArrived.
 *  CORREGIDO AL PONERSE COMO SINCRONICA EL DATASOURCE DE PRUEBAS.
 *
 *  09/02/2016 - Se ha preferido el metodo de dataArrived tambien es util al editarse por primera vez
 *      solo aqui podemos leer el dato que corresponde.
 *      El metodo de poner sincronica no es aceptable para el ajax y el xhr.
 *
 * 2) Para el caso de modo editar es suficiente el override de postSetFieldsToEdit()  al editarse
 * cuando no es la primera vez ya que en ese punto todos los datos estan cargados y nada llegaria por el lado de dataArrived.
 *
 * 3) Como es obvio el changed de la clasificacion de prueba tambien modificara el status de los campos
 *
 * 4) Despues de la primera vez que se obtiene el resultset en cualquier caso sea editar o agregar
 * el punto 2) es suficiente.
 *
 * Otro caso es el de los valores del viento para la pruenba , ya que estos solo pueden ingresarse
 * si la prueba no es multiple o combinada, al igual que el caso anterior dependiendo de eso los campos
 * deben ser inicializaos , pero dado que aqui solo se requiere modificar el estado de los camos
 * y no la mascara de input dependiendo del campo de prueba multiple y de la accion a tomar osea sea edit o add
 * ,solo se requiere trabajar el setEditMode() y obviamente el changed() del campo que indica si la prueba es multiple o
 * no.
 *
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:49:13 -0500 (mar, 24 jun 2014) $
 * $Rev: 250 $
 */
isc.defineClass("WinAppPruebasForm", "WindowBasicFormExt");
isc.WinAppPruebasForm.addProperties({
    ID: "winAppPruebasForm",
    title: "Mantenimiento de Genericas de Pruebas",
    width: 560,
    height: 440,
    joinKeyFieldName: 'apppruebas_codigo',
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formAppPruebas",
            numCols: 2,
            colWidths: ["150", "*"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_apppruebas,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['apppruebas_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'apppruebas_descripcion', // campos viruales
            _pruebas_clasificacion_descripcion: undefined,
            _unidad_medida_codigo: undefined,
            fields: [{
                name: "apppruebas_codigo",
                type: "text",
                showPending: true,
                width: 110,
                mask: ">AAAAAAAAAAAA"
            }, {
                name: "apppruebas_descripcion",
                showPending: true,
                length: 150,
                width: 220
            }, {
                name: "pruebas_clasificacion_codigo",
                editorType: "comboBoxExt",
                showPending: true,
                length: 50,
                width: 180,
                valueField: "pruebas_clasificacion_codigo",
                displayField: "pruebas_clasificacion_descripcion",
                pickListFields: [{
                    name: "pruebas_clasificacion_codigo",
                    width: '20%'
                }, {
                    name: "pruebas_clasificacion_descripcion",
                    width: '80%'
                }],
                pickListWidth: 240,
                optionDataSource: mdl_pruebas_clasificacion,
                optionOperationId: 'fetchJoined',
                textMatchStyle: 'substring',
                initialSort: [{property: 'pruebas_clasificacion_descripcion'}],

                /**
                 * Si cambia el estado de este campo se actualiza los estados de los campos de marca
                 * ya que la mascara o experesion regular para inputarlos varia segun la clasisificacion
                 * de la prueba.
                 */
                changed: function (form, item, value) {
                    var record = item.getSelectedRecord();
                    formAppPruebas._pruebas_clasificacion_descripcion = record.pruebas_clasificacion_descripcion;
                    formAppPruebas._setMarcasFieldStatus(record, true);
                    formAppPruebas._setPruebasDependantsStatus(record);
                },
                /**
                 * Aqui basicamnete deberia pasar una sola vez y es la primera vez que se abre un registro
                 * de la forma, en ese caso al llegar postSetFieldsToEdit es muy probable que el registro
                 * aun no este cargado y no podamos inicializar los datos que corresponden a  la clasificacion
                 * de las pruebas.
                 * WARNING: Esto solo esta verificado con un numero de registros pequeño el cual es el caso en este momento ,
                 * debe validarse que pasa cuando son una gran cantidad de datos y llega paginado , esaria el selectedRecord cargado
                 * o este metodo seria llamado multiples veces?
                 *
                 * @since  09/02/2016
                 */
                dataArrived: function (startRow, endRow, data)
                {
                    var record = formAppPruebas.getItem('pruebas_clasificacion_codigo').getSelectedRecord();
                    // En el caso que se agregue un registro este record todavia no exisira.
                    if (record) {
                        formAppPruebas._pruebas_clasificacion_descripcion = record.pruebas_clasificacion_descripcion;
                        formAppPruebas._setPruebasDependantsStatus(record);
                        formAppPruebas._setMarcasFieldStatus(record, false);
                    }
                }
            }, {
                name: "apppruebas_multiple",
                showPending: true,
                defaultValue: false,
                changed: function (form, item, value) {
                    var record = formAppPruebas.getItem('pruebas_clasificacion_codigo').getSelectedRecord();
                    formAppPruebas._setPruebasDependantsStatus(record);
                }
            }, {
                name: 'apppruebas_separator',
                defaultValue: "Limites",
                type: "section",
                width: "*",
                canCollapse: false,
                align: 'center',
                itemIds: ["apppruebas_marca_menor", "apppruebas_marca_mayor", "apppruebas_verifica_viento", "apppruebas_viento_limite_normal", "apppruebas_viento_limite_multiple"]
            }, {
                name: "apppruebas_marca_menor",
                showPending: true,
                textAlign: 'right',
                length: 12,
                width: 80,
                validators: [{
                    type: "regexp",
                    expression: '^$',
                    errorMessage: 'Formato de la Marca invalido para la prueba'
                }, {
                    type: "marcaMenorCheck", // Valida que la marca menor no sea mayor que la final
                    // dado que en este momento se tratan como string normalizamos y comparamos
                    condition: function (item, validator, value) {
                        formAppPruebas.clearFieldErrors('apppruebas_marca_mayor', true);
                        var testMenor = formAppPruebas.getValue('apppruebas_marca_menor');
                        var testMayor = formAppPruebas.getValue('apppruebas_marca_mayor');
                        testMenor = isc.AtlUtils.getMarcaNormalizada(testMenor, formAppPruebas._unidad_medida_codigo, false, 0);
                        testMayor = isc.AtlUtils.getMarcaNormalizada(testMayor, formAppPruebas._unidad_medida_codigo, false, 0);

                        if (parseInt(testMenor) >= parseInt(testMayor)) {
                            validator.errorMessage = 'No puede ser mayor que la Marca Mayor';
                            return false;
                        }
                        return true;
                    }
                }]
            }, {
                name: "apppruebas_marca_mayor",
                showPending: true,
                textAlign: 'right',
                length: 12,
                width: 80,
                validators: [{
                        type: "regexp",
                        expression: '^$',
                        errorMessage: 'Formato de la Marca invalido para la prueba'
                    }, {
                        type: "marcaMayorCheck", // Valida que la marca mayor no sea menor o igual que la inicial
                        // dado que en este momento se tratan como string normalizamos y comparamos
                        condition: function (item, validator, value) {
                            formAppPruebas.clearFieldErrors('apppruebas_marca_menor', true);
                            var testMenor = formAppPruebas.getValue('apppruebas_marca_menor');
                            var testMayor = formAppPruebas.getValue('apppruebas_marca_mayor');
                            testMenor = isc.AtlUtils.getMarcaNormalizada(testMenor, formAppPruebas._unidad_medida_codigo, false, 0);
                            testMayor = isc.AtlUtils.getMarcaNormalizada(testMayor, formAppPruebas._unidad_medida_codigo, false, 0);

                            if (parseInt(testMayor) <= parseInt(testMenor)) {
                                validator.errorMessage = 'No puede ser menor que la Marca Menor';
                                return false;
                            }
                            return true;
                        }
                    }

                ]
            }, {
                name: 'apppruebas_factor_manual',
                showPending: true,
                defaultValue: "0.00",
                width: 60,
                textAlign: 'right'
            }, {
                name: "apppruebas_verifica_viento",
                defaultValue: false,
                redrawOnChange: true, // Si hay cambios se afecta su campo relacionado donde se coloca
                // la velocidad del viento.
                changed: function (f, it, val) {
                    // si se cambia de estado al checkbox de verificacion de viento se acivan o desactivan
                    // los controles de input de viento de acuerdo al estado de este campo. Siempre se blanquearan los valores.
                    var record = formAppPruebas.getItem('pruebas_clasificacion_codigo').getSelectedRecord();
                    formAppPruebas._setPruebasDependantsStatus(record);
                }
            }, {
                name: "apppruebas_viento_individual",
                showPending: true,
                defaultValue: false,
                redrawOnChange: true
            }, {
                name: "apppruebas_viento_limite_normal",
                showPending: true,
                width: 60,
                textAlign: 'right',
                validators: [{
                    type: "requiredIf",
                    expression: "formAppPruebas.getValue('apppruebas_verifica_viento') == true",
                    errorMessage: "Por favor indique el viento limite normal permitido"
                }]
            }, {
                name: "apppruebas_viento_limite_multiple",
                showPending: true,
                width: 60,
                textAlign: 'right'
            }, {
                name: 'apppruebas_nro_atletas',
                showPending: true,
                defaultValue: "1",
                width: 60,
                textAlign: 'right'
            }],
            isAllowedToSave: function (values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.pruebas_protected == true) {
                    isc.say('No puede actualizarse el registro  debido a que es un registro del sistema y esta protegido');
                    return false;
                }
                else {
                    return true;
                }
            },
            /**
             * @override
             * Se aprovecha que setEditMode es llamado despues de cargarse la forma para setear los estado
             * de los campos de viento, el tratamiento para los campos de marcas no pueden hacerse aqui
             * por motivos explicados en la clase.
             */
            setEditMode: function (mode) {
                this.Super("setEditMode", arguments);
                if (mode == 'add') {
                    // En modo agregar el checkbox de viento se habilita para su uso y los campos
                    // para los valores del viento se dejan inabilitados hasta que se encienda el checkbox de viento.
                    //formAppPruebas._setPruebasDependantsStatus(true, false);
                    formAppPruebas._setPruebasDependantsStatus(null);
                }
            },
            /**
             * Se hace el override para aprovechar en setear sobre todo los campos de marcas , cada vez
             * que se va a editar un registro este metodo es llamado y aprovecho para hacerlo para cada edit.
             * Dado que esto depende solo del campo de clasificacion y no del modo de edicion se realiza aqui y no en setEditMode.
             */
            postSetFieldsToEdit: function () {
                var record = this.getValues();
                formAppPruebas._pruebas_clasificacion_descripcion = record.pruebas_clasificacion_descripcion;

                // IMPORTANTE:
                // Esto fuerza la lectura de la lista del combo asociado a la clasificacion de pruebas.
                record = formAppPruebas.getItem('pruebas_clasificacion_codigo').getSelectedRecord();
                if (record) {
                    formAppPruebas._setPruebasDependantsStatus(record);
                    formAppPruebas._setMarcasFieldStatus(record, false);
                }
            },
            postSaveData: function (mode,record) {
                record.pruebas_clasificacion_descripcion = formAppPruebas._pruebas_clasificacion_descripcion;
            },
            /**
             * Maneja los distintos estados de los campos que dependen directamente del tipo de prueba
             * tales como el viento, factor manual , nro atletas (solo las de velocidad requieren esto por ejemplo).
             *              *
             * @param {Record} record con el registro de la prueba generica actual seleccionada.
             *
             */
            _setPruebasDependantsStatus: function (record) {
                if (record) {

                    var haveViento = formAppPruebas.getValue('apppruebas_verifica_viento');
                    var esCombinada = formAppPruebas.getValue('apppruebas_multiple');
                    // Si la prueba es basada en tiempo o metros (saltos , lanzamientos)
                    // permitimos ingresar el viento y sus limites de lo contrario  los campos no seran visibles.
                    if ((record.unidad_medida_tipo == 'T' || record.unidad_medida_tipo == 'M') && esCombinada == false) {
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_verifica_viento'), true, false, false);
                        if (haveViento == false) {
                            formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_individual'), false, true, true);
                            formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_normal'), false, true, true);
                            formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_multiple'), false, true, true);
                        }
                        else {
                            formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_individual'), true, false, false);
                            formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_normal'), true, false, false);
                            formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_multiple'), true, false, false);
                        }
                    }
                    else {
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_verifica_viento'), false, true, true);
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_individual'), false, true, true);
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_normal'), false, true, true);
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_multiple'), false, true, true);
                    }

                    // Si la prueba es basada en tiempo el factor de correccion manual y el numero de atletas pueden ser
                    // indicados , pero siempre que no se indique como prueba combinada.
                    if (record.unidad_medida_tipo == 'T' && esCombinada == false) {
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_factor_manual'), true, false, false);
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_nro_atletas'), true, false, false);
                    }
                    else {
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_factor_manual'), false, true, true);
                        formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_nro_atletas'), false, true, true);
                    }

                }
                else {
                    // Si el registro no esta deinido , blanqueamos todo.
                    formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_factor_manual'), false, true, true);
                    formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_verifica_viento'), false, true, true);
                    formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_individual'), false, true, true);
                    formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_normal'), false, true, true);
                    formAppPruebas._setFieldStatus(formAppPruebas.getItem('apppruebas_viento_limite_multiple'), false, true, true);
                    formAppPruebas.getItem('apppruebas_nro_atletas').setValue('1');
                }
            },
            /**
             * Es llamada para setear el formato de input para la marca mayor y marca menor , asi mismo limpia los campos
             * de ser requerido.
             *
             * @param {object} record ,, con el registro de la prueba generica
             * @param {boolean} clearFields , true si los campos de marca menor y mayor deben ser limpiados y activados
             */
            _setMarcasFieldStatus: function (record, clearFields) {
                var itMarcaMenor = formAppPruebas.getItem('apppruebas_marca_menor');
                var itMarcaMayor = formAppPruebas.getItem('apppruebas_marca_mayor'); // Si existe un record procesamos
                if (record) {
                    // De acuerdo al registro de clasificacion de pruebas
                    // se asigna la expresion regulr a usar.
                    itMarcaMenor.validators[0].expression = record.unidad_medida_regex_e;
                    itMarcaMayor.validators[0].expression = record.unidad_medida_regex_e;
                    formAppPruebas._unidad_medida_codigo = record.unidad_medida_codigo;
                    // Si los campos deben ser blanqueados se procede.
                    if (clearFields == true) {
                        formAppPruebas._setFieldStatus(itMarcaMenor, true, false, true);
                        formAppPruebas._setFieldStatus(itMarcaMayor, true, false, true);
                    }
                }
                else {
                    itMarcaMenor.validators[0].expression = '^$';
                    itMarcaMayor.validators[0].expression = '^$';
                }

            },
            /**
             * Funcion de soporte para limpiar un campo , sus errores y activarlo o desactivarlo.
             * @param {FormItem} campo de la forma
             * @param {boolean} enable true para activar , false para desactivar.
             * @param {boolean} hide true para esconder , false para mostrar.
             * @param {boolean} clear true para limpiar , false para dejar como esta.
             */
            _setFieldStatus: function (field, enable, hide, clear) {

                if (clear) {
                    field.setValue(undefined);
                }
                field.clearErrors();
                if (enable == false) {
                    field.disable();
                }
                else {
                    field.enable();
                }

                if (hide) {
                    field.hide();
                }
                else {
                    field.show();
                }
            }
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});