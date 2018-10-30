/**
 * Clase especifica para la definicion de la ventana para la edicion y creacion de resultados de pruebas
 * para los atletas.
 *
 * Esta pantalla tiene ciertas particularidades tecnicas, ya que para obtener ciertos datos y que el workflow
 * de la pantalla funcione , se requeria que la carga del combo de pruebas fuera sincronico y ademas antes
 * de ir a la base de datos conociera los datos del filtro.
 *
 * Para resolver estos temas se ha hecho que el modelo de datos para las pruebas sea sincronico en otras
 * palabras que al ejecutar la llamada que requiere los datos de la prueba , el sistema no ejecute ninguna accion
 * hasta que esto termine, asi mismo en la ventana de la grilla principal se agrego los campos necesarios para el filtro
 * de tal forma que antes de efectuar la lectura ya conozaca esos datos.
 *
 * Esto obviamente es tambien producto que los modelos de las competencias y atletas son asincronicos y no se puede predecir
 * que a leer los datos de las pruebas , los datos de categoria y sexo ya esten cargados.
 *
 * El que el modelo de datos de las pruebas sea sincronico tambien era necesario para mostrar o no la grilla de detalle
 * del resultado , ya que se requeria saber si la prueba era multiple , para lo cual los datos de la prueba ya deberian estar
 * leidos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-29 23:52:36 -0500 (mar, 29 jul 2014) $
 * $Rev: 322 $
 * Se reviso en enero del 2016 , habiendo quitado los bugs y mejprado la performance.
 */
isc.defineClass("WinAtletasPruebasResultadosForm", "WindowBasicFormExt");
isc.WinAtletasPruebasResultadosForm.addProperties({
    ID: "winAtletasPruebasResultadosForm",
    title: "Mantenimiento de Resultados de Pruebas",
    autoSize: false,
    width: '780',
    height: '345',
    joinKeyFields: [{
        fieldName: 'competencias_pruebas_id',
        fieldValue: '',
        mapTo: 'competencias_pruebas_origen_id'
    }, {
        fieldName: 'atletas_codigo',
        fieldValue: ''
    }],
    efficientDetailGrid: false,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formAtletasPruebasResultados",
            numCols: 8,
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_atletaspruebas_resultados,
            fetchOperation: 'fetchJoined',
            formMode: this.formMode,
            // parametro de inicializacion
            keyFields: ['competencias_codigo', 'atletas_codigo', 'pruebas_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'competencias_codigo',
            // Campo virtual o de cache de datos
            _cachedData : {categorias_codigo:undefined,
                            atletas_sexo:undefined,
                            apppruebas_multiple: undefined,
                            competencias_descripcion:undefined,
                            paises_descripcion:undefined,
                            ciudades_descripcion:undefined,
                            atletas_nombre_completo:undefined,
                            pruebas_descripcion:undefined

             },
            fields: [{
                ID: "far_cb_competencias",
                name: "competencias_codigo",
                editorType: "comboBoxExt",
                showPending: true,
                length: 50,
                endRow: true,
                colSpan: '5',
                width: "*",
                valueField: "competencias_codigo",
                displayField: "competencias_descripcion",
                fetchMissingValues: true,
                pickListFields: [{
                    name: "competencias_descripcion",
                    width: '40%'
                }, {
                    name: "categorias_codigo"
                }, {
                    name: "agno"
                }, {
                    name: 'datos',
                    width: '40%',
                    formatCellValue: function (value, record) {
                        return record.competencia_tipo_descripcion + ' / ' + record.paises_descripcion + ' / ' + record.ciudades_descripcion;
                    }
                }],
                pickListWidth: 450,
                completeOnTab: true,
                textMatchStyle: 'substring',
                // vital para indicar el opertion id , si se usa en otro lugar recarga por gusto.
                optionOperationId: 'fetchJoined',
                optionDataSource: mdl_competencias,
                sortField: "competencias_descripcion",
                change: function (form, item, value, oldValue) {
                    // Si se limpiado o esta en blanco la competencia
                    if (value == null || value == undefined) {
                        // Al cambiar la competencia se limpia la prueba ya que esa depende
                        // de la categoria de prueba (may,men,etc) y el sexo del atleta
                        // Luego se procede a limpiar variables y estados de los campos asociados
                        formAtletasPruebasResultados.clearValue('pruebas_codigo');
                        formAtletasPruebasResultados.clearValue('competencias_pruebas_fecha');
                        formAtletasPruebasResultados.setValue('ciudades_altura',false);
                        formAtletasPruebasResultados._cachedData.categorias_codigo = undefined;
                        formAtletasPruebasResultados._updateMarcasFieldsStatus(null, true, true,false);
                    }
                    return true;
                },
                changed: function (form, item, value) {
                    var record = item.getSelectedRecord();
                    if (record) {
                        var newCategoria = record.categorias_codigo;
                        // Solo si la categoria ha cambiado .
                        if (formAtletasPruebasResultados._cachedData.categorias_codigo != newCategoria) {
                            // Al cambiar la competencia se limpia la prueba ya que esa depende
                            // de la categoria de prueba (may,men,etc) y el sexo del atleta
                            // Luego se procede a limpiar variables y estados de los campos asociados
                            formAtletasPruebasResultados.clearValue('pruebas_codigo');
                            formAtletasPruebasResultados._updateMarcasFieldsStatus(null, true, true,false);
                        }
                        formAtletasPruebasResultados._cachedData.competencias_descripcion = record.competencias_descripcion;
                        formAtletasPruebasResultados._cachedData.ciudades_descripcion = record.ciudades_descripcion;
                        formAtletasPruebasResultados._cachedData.paises_descripcion = record.paises_descripcion;
                        formAtletasPruebasResultados._cachedData.ciudades_alture = record.ciudades_alture;
                        formAtletasPruebasResultados._cachedData.categorias_codigo = record.categorias_codigo;

                        // LA fecha de la competencia es seteada y si la ciudad esta en altura se setean
                        formAtletasPruebasResultados.setValue('competencias_pruebas_fecha', record.competencias_fecha_inicio);
                        formAtletasPruebasResultados.setValue('ciudades_altura',record.ciudades_altura);

                    }
                }

            }, {
                ID: 'far_cb_atletas',
                name: "atletas_codigo",
                editorType: "comboBoxExt",
                showPending: true,
                length: 50,
                colSpan: '5',
                width: "*",
                endRow: true,
                valueField: "atletas_codigo",
                displayField: "atletas_nombre_completo",
                fetchMissingValues: true,
                pickListFields: [{
                    name: "atletas_codigo",
                    width: '20%'
                }, {
                    name: "atletas_nombre_completo",
                    width: '80%'
                }],
                pickListWidth: 260,
                completeOnTab: true,
                optionOperationId: 'fetchForListForResultados',
                optionDataSource: mdl_atletas,
                textMatchStyle: 'substring',
                sortField: "atletas_nombre_completo",
                change: function (form, item, value, oldValue) {
                    // Si el campo esta en blanco se limpia la prueba ya que esa depende
                    // de la categoria de prueba (may,men,etc) y el sexo del atleta
                    // Actualizamos los datos de cache de los atletas blanqueandolos asi
                    // como os asociados a la prueba.
                    if (value == null || value == undefined) {
                        formAtletasPruebasResultados.clearValue('pruebas_codigo');
                        //formAtletasPruebasResultados._setCachedAtletasVars(null);
                        formAtletasPruebasResultados._cachedData.atletas_sexo = undefined;
                        formAtletasPruebasResultados._updateMarcasFieldsStatus(null, true, true,false);
                    }
                    return true;
                },
                changed: function (form, item, value) {
                    var record = item.getSelectedRecord();

                    if (record) {                        
                        // Si el sexo ha cambiado limpiamos la prueba ya que esta asociada al sexo.
                        if (formAtletasPruebasResultados._cachedData.atletas_sexo != record.atletas_sexo) {
                            // Si limpio la prueba , limpio los inputs asociados con la misma.
                            // , esto es para el caso que varie el sexo con lo que se invalida
                            // el codigo de prueba.
                            formAtletasPruebasResultados.clearValue('pruebas_codigo');
                            formAtletasPruebasResultados._updateMarcasFieldsStatus(null, true, true,false);
                        }
                        formAtletasPruebasResultados._cachedData.atletas_sexo = record.atletas_sexo;
                        formAtletasPruebasResultados._cachedData.atletas_nombre_completo = record.atletas_nombre_completo;

                    }
                }
            }, {
                ID: 'far_cb_pruebas',
                name: "pruebas_codigo",
                editorType: "comboBoxExt",
                showPending: true,
                length: 50,
                width: "200",
                valueField: "pruebas_codigo",
                displayField: "pruebas_descripcion",
                // ESto para que no lea autmaticamente ya que al editar requerimos hacer el fetch directamente
                // ya que las pruebas dependen de la categoria y sexo.
                fetchMissingValues: false,
                autoFetchData: false,
                pickListFields: [{
                    name: "pruebas_descripcion",
                    width: '60%'
                }, {
                    name: "categorias_descripcion",
                    width: '20%'
                }, {
                    name: "pruebas_sexo",
                    width: '10%'
                }, {
                    name: "apppruebas_multiple",
                    width: '10%'
                }],
                pickListWidth: 360,
                completeOnTab: true,
                optionOperationId: 'fetchJoinedFull',
                optionDataSource: mdl_pruebas,
                minimumSearchLength: 3,
                textMatchStyle: 'substring',
                sortField: "pruebas_descripcion",
                /**
                 * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                 * que dependen de la de la categoria y el sexo del atleta,el primero proviene
                 * de la competencia y el segundo del atleta.
                 */
                getPickListFilterCriteria: function () {
                        var filter = this.pickListCriteria;
                        if (filter == null) {
                            filter = {};
                        }

                        var filterSearchExact =  (filter.filterSearchExact ? filter.filterSearchExact : false);
                        if (filterSearchExact === false) {
                            filter = this.Super("getPickListFilterCriteria", arguments);
                        }
                        if (filter == null) {
                            filter = {};
                        }
                    // Si existe una  prueba en el filtro estamos en un edit por ende solo buscamos dicha prueba
                    // esto por eficiencia y no jalamaos todo innecesariamente.
                    if ((filter.pruebas_codigo  && !filter.pruebas_descripcion) || filterSearchExact === true) {
                        filter = {
                            _constructor: "AdvancedCriteria",
                            operator: "and",
                            criteria: [{
                                fieldName: "pruebas_codigo",
                                operator: "equals",
                                value: filter.pruebas_codigo
                            }, {
                                fieldName: "categorias_codigo",
                                operator: "equals",
                                value: formAtletasPruebasResultados._cachedData.categorias_codigo
                            }, {
                                fieldName: 'pruebas_sexo',
                                operator: 'equals',
                                value: formAtletasPruebasResultados._cachedData.atletas_sexo
                            }]
                        };
                    }
                    else if (filter.pruebas_descripcion) {
                        filter = {
                            _constructor: "AdvancedCriteria",
                            operator: "and",
                            criteria: [{
                                fieldName: "pruebas_descripcion",
                                operator: "iContains",
                                value: filter.pruebas_descripcion
                            }, {
                                fieldName: "categorias_codigo",
                                operator: "equals",
                                value: formAtletasPruebasResultados._cachedData.categorias_codigo
                            }, {
                                fieldName: 'pruebas_sexo',
                                operator: 'equals',
                                value: formAtletasPruebasResultados._cachedData.atletas_sexo
                            }]
                        };

                    }
                    else {
                        filter = {
                            _constructor: "AdvancedCriteria",
                            operator: "and",
                            criteria: [{
                                fieldName: "categorias_codigo",
                                operator: "equals",
                                value: formAtletasPruebasResultados._cachedData.categorias_codigo
                            }, {
                                fieldName: 'pruebas_sexo',
                                operator: 'equals',
                                value: formAtletasPruebasResultados._cachedData.atletas_sexo
                            }]
                        };
                    }
                    return filter;
                },
                change: function (form, item, value, oldvalue) {
                    // Si el campo esta en blaco limipamos el estado de los campos
                    // asoicados y los ponemos en su default.
                    if (value == null || value == undefined) {
                        formAtletasPruebasResultados._updateMarcasFieldsStatus(null, true, true,false);
                    }

                    // Se verifica que si no estan seleccionados una competencia y un atleta no se puede seleccionar nada.
                    if (formAtletasPruebasResultados.getValue('competencias_codigo') == undefined || formAtletasPruebasResultados.getValue('atletas_codigo') == undefined) {
                        isc.say('Debe estar definida la Competencia y el Atleta para determinar la categoria y sexo de la prueba');
                        return false;
                    }

                    return true;
                },
                changed: function (form, item, value) {
                    var record = item.getSelectedRecord();
                    if (record) {
                        formAtletasPruebasResultados._cachedData.pruebas_descripcion = record.pruebas_descripcion;
                        formAtletasPruebasResultados._updateMarcasFieldsStatus(record, true, true,false);
                        formAtletasPruebasResultados._updateSeriesValues('FI');
                    }
                }

            }, {
                name: "competencias_pruebas_fecha",
                showPending: true,
                useTextField: true,
                showPickerIcon: false,
                width: 100,
                endRow: true,
                change: function (form, item, value, oldValue) {
                    // Verificamos que la fecha seleccionada este en el rango en que la competencia seleccionada
                    // se realizo.
                    var recordCompetencias = far_cb_competencias.getSelectedRecord();
                    var fechaInicio = recordCompetencias.competencias_fecha_inicio;
                    var fechaFinal = recordCompetencias.competencias_fecha_final;

                    if (value.getTime() > fechaFinal.getTime() || value.getTime() < fechaInicio.getTime()) {
                        isc.say('La fecha debe estar dentro de las fechas en que se realizo la competencia, <br>Del ' + fechaInicio.toLocaleDateString() + ' al ' + fechaFinal.toLocaleDateString());
                        return false;
                    }
                    return true;
                }
            }, {
                name: "competencias_pruebas_tipo_serie",
                type: "select",
                defaultValue: "FI",
                showPending: true,
                redrawOnChange: true,
                changed: function (form, item, value) {
                    formAtletasPruebasResultados._updateSeriesValues(value);
                }
            }, {
                name: "competencias_pruebas_nro_serie",
                showPending: true,
                width: 50,
                endRow: true,
                textAlign: 'right',
                validators: [{
                    type: "requiredIf",
                    expression: "formAtletasPruebasResultados.getValue('competencias_pruebas_tipo_serie') != 'SU' && formAtletasPruebasResultados.getValue('competencias_pruebas_tipo_serie') != 'FI'",
                    errorMessage: "Indique el nro de hit,serie,etc"
                }],
                defaultValue: 1
            }, {
                name: 'apr_resultados_separator',
                defaultValue: "Resultado",
                type: "section",
                colSpan: 8,
                width: "*",
                canCollapse: false,
                align: 'center',
                itemIds: ["atletas_resultados_resultado", "competencias_pruebas_manual", "competencias_pruebas_viento", "atletas_resultados_puesto"]
            }, {
                name: "competencias_pruebas_manual",
                showPending: true,
                defaultValue: false,
                labelAsTitle: true,
                changed: function (form, item, value) {
                    // Si es cambiado de manual a electronico o viceversa , actualizamos los campos
                    // asociados al resultado ya que el formato del input depende de este valor.
                    formAtletasPruebasResultados._updateMarcasFieldsStatus(
                    formAtletasPruebasResultados.getItem('pruebas_codigo').getSelectedRecord(), true, false,false);
                }
            }, {
                name: "atletas_resultados_resultado",
                showPending: true,
                length: 12,
                width: '90',
                textAlign: 'right',
                validators: [{
                    type: "regexp",
                    expression: '^$'
                }, {
                    type: "custom",
                    // Valida que la marca menor no sea mayor que la final
                    // dado que en este momento se tratan como string normalizamos y comparamos
                    condition: function (item, validator, value) {
                        var pruebasRecord = formAtletasPruebasResultados.getItem('pruebas_codigo').getSelectedRecord();
                        if (pruebasRecord) {

                            // Para efectos de validacion es irrelevante si son manuales o electronicas , asumimos todas electronicas.
                            var minValue = isc.AtlUtils.getMarcaNormalizada(
                                pruebasRecord.apppruebas_marca_menor, pruebasRecord.unidad_medida_codigo, false, 0);
                            var maxValue = isc.AtlUtils.getMarcaNormalizada(
                                pruebasRecord.apppruebas_marca_mayor, pruebasRecord.unidad_medida_codigo, false, 0);
                            var valueTest = isc.AtlUtils.getMarcaNormalizada(
                                value, pruebasRecord.unidad_medida_codigo, false, 0);
                            if (parseInt(valueTest) < minValue || parseInt(
                                valueTest) > maxValue) {
                                    validator.errorMessage = 'EL resultado esta fuera del rango permitido de ' + pruebasRecord.apppruebas_marca_menor + ' hasta ' + pruebasRecord.apppruebas_marca_mayor;
                                    return false;
                            }
                        }
                        return true;
                    }
                }

                ]
            }, {
                name: "competencias_pruebas_viento",
                showPending: true,
                length: 12,
                width: '50',
                textAlign: 'right'

            }, {
                name: "atletas_resultados_puesto",
                showPending: true,
                endRow: true,
                length: 3,
                width: '50',
                textAlign: 'right',
                defaultValue: 0
            }, {
                name: 'apr_obs_separator',
                defaultValue: "Observaciones",
                type: "section",
                colSpan: 8,
                width: "*",
                canCollapse: false,
                align: 'center',
                itemIds: ["ciudades_altura",
                "competencias_pruebas_anemometro", "competencias_pruebas_material_reglamentario", "competencias_pruebas_observaciones"]
            }, {
                name: "ciudades_altura",
                type: 'staticText',
                defaultValue: false,
                // depende de la ciudad,
                formatValue: function (value, record, form, item) {
                    if (value !== true) {
                        return 'No';
                    }
                    else {
                        return '<b style = "color:#FF6699;">Si</b>';
                    }
                }
            }, {
                name: "competencias_pruebas_anemometro",
                showPending: true,
                width: '50',
                defaultValue: true,
                labelAsTitle: true,
                changed: function (form, item, value) {
                    formAtletasPruebasResultados._setupViento(value);
                }
            }, {
                name: "competencias_pruebas_material_reglamentario",
                showPending: true,
                width: '50',
                defaultValue: true,
                labelAsTitle: true,
                endRow: true
            }, {
                name: "competencias_pruebas_observaciones",
                showPending: true,
                colSpan: '8',
                width: '*',
                endRow: true
            }, {
                name: "competencias_pruebas_origen_combinada",
                visible: false,
                defaultValue: false
            },
            // Para join con detalles , no es visible
            {
                name: "competencias_pruebas_id",
                visible: false
            }],
            isAllowedToEdit: function(record) {
                if (record)  {
                    if (record.postas_id) {
                        isc.warn('No es posible modificar postas por aqui , ir a mantenimiento de competencias');
                        return false;
                    }
                    return true;
                } else {
                    return false;
                }
            },
            isAllowedToSave: function(values,oldValues) {
                if (oldValues && oldValues.postas_id) {
                    isc.warn('No es posible modificar o agregar resultados de postas aqui , ir a mantenimiento de competencias');
                    return false;
                }
                return true;
            },
            preSaveData: function(mode,currentValues) {
                // Si es prueba multiple ponemos cero para cumplir con las reglas
                // del servidor que este valor debe existir
                if (mode == 'add' && formAtletasPruebasResultados._cachedData.apppruebas_multiple == true) {
                    formAtletasPruebasResultados.getItem('atletas_resultados_resultado').setValue(0);
                }
            },
            /**
             * Override para aprovecar que todas los datos modificados en esta pantalla que estan representados
             * en la lista que llama a esta se actualizen.
             *
             * @param {String} 'add' agregar , 'edit' update.
             * @param {Object} record El registro recien grabado.
             */
            postSaveData: function (mode,record) {
               
                //var record_values;
                // Copiamos al registro los valores que son parte de este pero no de la forma.
                record.competencias_descripcion  = formAtletasPruebasResultados._cachedData.competencias_descripcion;
                record.paises_descripcion = formAtletasPruebasResultados._cachedData.paises_descripcion;
                record.ciudades_descripcion = formAtletasPruebasResultados._cachedData.ciudades_descripcion;
                record.categorias_codigo = formAtletasPruebasResultados._cachedData.categorias_codigo;
                record.atletas_nombre_completo = formAtletasPruebasResultados._cachedData.atletas_nombre_completo;
                record.atletas_sexo = formAtletasPruebasResultados._cachedData.atletas_sexo;
                record.pruebas_descripcion = formAtletasPruebasResultados._cachedData.pruebas_descripcion;
                record.apppruebas_multiple = formAtletasPruebasResultados._cachedData.apppruebas_multiple;
                // Campos ensamblados del registro.
                // Observaciones
                if (record.ciudades_altura == true || formAtletasPruebasResultados.getValue('competencias_pruebas_manual') == true || 
                    formAtletasPruebasResultados.getValue('competencias_pruebas_anemometro') == false ||
                    formAtletasPruebasResultados.getValue('competencias_pruebas_material_reglamentario') == false) {
                    record.obs = true;
                } else {
                    record.obs = false;
                }

                // Serie
                var tipo_serie = formAtletasPruebasResultados.getValue('competencias_pruebas_tipo_serie');
                if (tipo_serie == 'SU' || tipo_serie == 'FI') {
                    record.serie = tipo_serie;
                }
                else {
                    record.serie = tipo_serie + "-" + formAtletasPruebasResultados.getValue('competencias_pruebas_nro_serie');
                }
            },
            /**
             * Override para aprovecha que solo en modo add se blanqueen todas las variables de cache y el estado
             * de los campos a su modo inicial o default.
             *
             * @param {string} mode 'add' o 'edit'
             */
            setEditMode: function (mode) {
                this.Super("setEditMode", arguments);
                if (mode == 'add') {
                    // Empezamos con los valores del filtro de pruebas indefinidos
                    formAtletasPruebasResultados._cachedData.categorias_codigo = undefined;
                    formAtletasPruebasResultados._cachedData.atletas_sexo = undefined;

                    // Se ponen los defaults al nuevo registro
                    formAtletasPruebasResultados._updateMarcasFieldsStatus(null, null, null,false);
                    formAtletasPruebasResultados._updateSeriesValues('FI');
                }
                else {
                    formAtletasPruebasResultados._updateSeriesValues(formAtletasPruebasResultados.getItem('competencias_pruebas_tipo_serie').getValue());
                    formAtletasPruebasResultados._setupViento(formAtletasPruebasResultados.getValue('competencias_pruebas_anemometro'));
                }
            },
            /**
             * IMPORTANTE: Este override es viatal en este caso ya que es el unico punto
             * donde se puede interceptar previo a que los datos de pantalla sean leidos
             * ya que el controlador al abrir esta forma al EDITAR un campo recoge de la grilla
             * el registro a editar usando este metodo.
             *
             * Esto se requiere para :
             * 1) preparar los datos para el filtro de las pruebas antes que la pantalla se actualize y garantizar
             * que la criteria para el combo de pruebas pueda filtrar correctamente.
             * El problema es que como las pruebas a filtrar depeneden de los capos de categoria y sexo del atleta
             * y estos provienen de los datos de los combos de los campos competencia y atleta y nada nos garantiza que
             * estos esten listos al inicializar el combo de priuebas (porque las llamadas ajax de los dos primeros son
             * asincronicas) ,  Estos datos para evitar el problema descrito ya vienen preparados en los datos del registro a editar
             * desde la grilla.
             *
             * 2) Dado que ahora este combo de pruebas depende de estos datos es aqui que forzamos un fetch
             * ya que dado la propiedad  fetchMissingValues esta en false,ya no habra ectura automatica.
             *
             * 3) Actualizamos el estado de los campos de las marcas acorde al tipo de prueba actual en
             * edicion.
             *
             * @param {ListGrid} component la grilla origen o fuente del registro a editar.
             */
            editSelectedData: function (component) {
                var record = component.getSelectedRecord();
                console.log('El record en editSelectedData')
                console.log(record)

                // Conservamos primero que todo los campos que se requieren para la criteria
                // del combo de pruebas. Por optimizacion y garantizar que estos esten definidos
                // antes de la busqueda , provienen de la grilla.
                formAtletasPruebasResultados._cachedData.categorias_codigo = record.categorias_codigo;
                formAtletasPruebasResultados._cachedData.atletas_sexo = record.atletas_sexo;
                formAtletasPruebasResultados._cachedData.apppruebas_multiple = record.apppruebas_multiple;

                formAtletasPruebasResultados._cachedData.competencias_descripcion = record.competencias_descripcion;
                formAtletasPruebasResultados._cachedData.paises_descripcion = record.paises_descripcion;
                formAtletasPruebasResultados._cachedData.ciudades_descripcion = record.ciudades_descripcion;
                formAtletasPruebasResultados._cachedData.atletas_nombre_completo = record.atletas_nombre_completo;
                formAtletasPruebasResultados._cachedData.pruebas_descripcion = record.pruebas_descripcion;


                this.Super('editSelectedData', arguments);


                // Aqui forzamos solo a leer un registro justo el que corresponde a la prueba
                // de este registro.
                // Para que esto funcione ok es necesario que el combo de pruebas indique
                //      fetchMissingValues: false,
                //      autoFetchData: false
                // De tal manera que se anulen lecturas no deseadas.
                winAtletasPruebasResultadosForm.fetchFieldRecord('pruebas_codigo',
                        {"pruebas_codigo": record.pruebas_codigo,"pruebas_descripcion":undefined});
            },
            fieldDataFetched: function(formFieldName,record) {
                if (formFieldName === 'pruebas_codigo') {
                    formAtletasPruebasResultados._updateMarcasFieldsStatus(record, false, false,true);
                } 
            },

            /*******************************************************************
             *
             * FUNCIONES DE SOPORTE PARA LA FORMA
             */
            _updateSeriesValues: function (tipoSerieValue) {
                var itTipoSerie = formAtletasPruebasResultados.getItem('competencias_pruebas_tipo_serie');
                var itNroSerie = formAtletasPruebasResultados.getItem('competencias_pruebas_nro_serie');

                if (tipoSerieValue == 'SU' || tipoSerieValue == 'FI') {
                    itNroSerie.setValue(1);
                    itNroSerie.hide();
                }
                else {
                    itNroSerie.setRequired(true);
                    itNroSerie.show();
                }
                // Si es multiple ademas no se puede cambiar el tipo de serie por no haber.
                if (formAtletasPruebasResultados._cachedData.apppruebas_multiple == true) {
                    itTipoSerie.setValue('FI');
                    itTipoSerie.hide();
                    itNroSerie.setValue(1);
                    itNroSerie.hide();
                }
                else {
                    itTipoSerie.show();
                }
            },
            _updateMarcasFieldsStatus: function (record, clearResultado, pruebaChanged,initOnly) {
                if (record) {
                    formAtletasPruebasResultados._cachedData.apppruebas_multiple = record.apppruebas_multiple;
                    formAtletasPruebasResultados.__updateMarcasFieldsStatus(pruebaChanged, clearResultado, record.unidad_medida_tipo, record.unidad_medida_regex_e, 
                        record.unidad_medida_regex_m, record.apppruebas_verifica_viento,initOnly);
                }
                else {
                    formAtletasPruebasResultados._cachedData.apppruebas_multiple = undefined;
                    formAtletasPruebasResultados.__updateMarcasFieldsStatus(true, true, undefined, undefined, undefined, undefined,initOnly);
                }
            },
            /**
             * @param {object} record ,, con el registro de la clasificacion de prueba seleccionado en el
             * campo pruebas_clasificacion_codigo.
             * @param {boolean} clearFields , true si los campos de marca menor y mayor deben ser limpiados y activados
             */
            __updateMarcasFieldsStatus: function (pruebaChanged, clearResultado, unidad_medida_tipo, unidad_medida_regex_e, unidad_medida_regex_m, apppruebas_verifica_viento,initOnly) {
 
                var thisForm = formAtletasPruebasResultados; // para velocidad
                var itemEsManual = thisForm.getItem('competencias_pruebas_manual');
                var itViento = thisForm.getItem('competencias_pruebas_viento');
                var itResultado = thisForm.getItem('atletas_resultados_resultado');
                var itPuesto = thisForm.getItem('atletas_resultados_puesto');
                var itAnemometro = thisForm.getItem('competencias_pruebas_anemometro');
                var itMaterial = thisForm.getItem('competencias_pruebas_material_reglamentario');
                //    var itSerie = thisForm.getItem('competencias_pruebas_tipo_serie');
                // Si la unidad de medida es tiempo , si la prueba es cambiada se activa y se muestra el checkbox
                // de manual  , de lo contrario de limpia el campo y se esconde.
                if (unidad_medida_tipo == 'T') {
                    if (pruebaChanged) {
                        thisForm._setFieldStatus(itemEsManual, true, false, true,initOnly);
                        thisForm._setFieldStatus(itPuesto, true, false, true,initOnly);
                        thisForm._setFieldStatus(itViento, false, true, true,initOnly);
                    }
                    else {
                        thisForm._setFieldStatus(itemEsManual, true, false, false,initOnly);
                    }
                }
                else {
                    thisForm._setFieldStatus(itemEsManual, false, true, true,initOnly);
                }

                // Si la prueba requeire verificacion de viento , se enciende el
                // campo de viento y si la unidad de medida es tiempo o Metros (para los saltos largo/triple)
                // se indica requerido.
                if (apppruebas_verifica_viento == true && (unidad_medida_tipo == 'T' || unidad_medida_tipo == 'M')) {
                        // Si la prueba verifica viento , veamos si esta encendido el anemometro
                        thisForm._setFieldStatus(itAnemometro, true, false, false,initOnly);
                        thisForm._setupViento(itAnemometro.getValue());
                }
                else {
                    // Si no se requiere se apaga y se indica no requerido.
                    thisForm._setFieldStatus(itAnemometro, false, true, true,initOnly);
                    thisForm._setupViento(false);
                }



                // De acuerdo a si es manual o no se cambia la expresion regular para el input,
                if (itemEsManual.getValue() == false) {
                    itResultado.validators[0].expression = unidad_medida_regex_e;
                }
                else {
                    itResultado.validators[0].expression = unidad_medida_regex_m;
                }

                // Para el caso de pruebas multiples no se requiere mostrar o editar los resultados de la
                // prueba , ya que seran un summary de la grilla de detalle.
                if (thisForm._cachedData.apppruebas_multiple) {

                    itResultado.setRequired(false);
                    thisForm._setFieldStatus(itResultado, false, true, false,initOnly);
                    thisForm._setFieldStatus(itMaterial, false, true, false,initOnly);
                }
                else {
                    itResultado.setRequired(true);
                    // Si el resultado debe ser blanqueado se procede.
                    thisForm._setFieldStatus(itResultado, true, false, clearResultado,initOnly);
                    thisForm._setFieldStatus(itMaterial, true, false, false,initOnly);
                }
            },
            _setupViento: function(withAnemometro) {
                var itViento = formAtletasPruebasResultados.getItem('competencias_pruebas_viento');
                if (withAnemometro === true) {
                    itViento.enable();
                    itViento.show();
                } else {
                    itViento.clearValue();
                    itViento.hide();
                }
            },
            /**
             * Funcion de soporte para limpiar un campo , sus errores y activarlo o desactivarlo.
             * @param {FormItem} campo de la forma
             * @param {boolean} enable true para activar , false para desactivar.
             * @param {boolean} hide true para esconder , false para mostrar.
             * @param {boolean} clear true para limpiar campo, false no tocarlo.
             * @param {boolean} initOnly Si se solo init no debera blanquarse ningun campo.
             */
            _setFieldStatus: function (field, enable, hide, clear,initOnly) {
                    if (clear == true ) {
                        field.clearErrors();
                        if (initOnly === false) {
                            field.clearValue();
                        }
                    }
                    if (hide == true) {
                        field.hide();
                    } else {
                        field.show();
                    }
                    if (enable == false) {
                        field.disable();
                    } else {
                        field.enable();
                    }
                }
           // }
            //  , cellBorder: 1
        });
    },
    canShowTheDetailGrid: function (mode) {
        return formAtletasPruebasResultados._cachedData.apppruebas_multiple;
    },
    isRequiredReadDetailGridData: function () {
        // Si es multiple se requiere releer , de lo ocntraio no es necesario.
        return formAtletasPruebasResultados._cachedData.apppruebas_multiple;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            height: 280,
            sectionTitle: 'Resultados Individuales',
            gridProperties: {
                ID: 'g_atletaspruebas_resultados_detalle',
                fetchOperation: 'fetchJoined',
                // solicitado un resultset con el join a atletas resuelto por eficiencia
                dataSource: 'mdl_atletaspruebas_resultados_detalles',
                sortField: "competencias_pruebas_id",
                autoFetchData: false,
                canRemoveRecords: false,
                canAdd: false,
                canSort: false,
                showGridSummary: true,
                fields: [{
                    name: "pruebas_descripcion",
                    width: '50%'
                }, {
                    name: "competencias_pruebas_fecha"
                }, {
                    name: "competencias_pruebas_manual"                    
                }, {
                    name: "competencias_pruebas_anemometro"
                }, {
                    name: "competencias_pruebas_material_reglamentario"
                }, {
                    name: "atletas_resultados_resultado",
                    align: 'right'
                }, {
                    name: "competencias_pruebas_viento",
                    align: 'right',
                    showGridSummary: false
                }, {
                    name: "atletas_resultados_puntos",
                    align: 'right',
                    showGridSummary: true,
                    summaryFunction: 'sum'
                },{
                    name: "atletas_resultados_puesto",
                    align: 'right',
                    showGridSummary: false
                }]
            },
            getFormComponent: function () {
                var newGrid;
                if (this.getChildForm() == undefined) {
                    newGrid = isc.DynamicFormExt.create({
                        ID: "gform_atletaspruebas_resultados_detalle",
                        numCols: 6,
                        colWidths: ["100", "250", "*", "*", "*", "*"],
                        titleWidth: 100,
                        fixedColWidths: false,
                        padding: 5,
                        dataSource: mdl_atletaspruebas_resultados_detalles,
                        formMode: this.formMode, // parametro de inicializacion
                        focusInEditFld: 'competencias_pruebas_fecha',
                        fields: [{
                             name: "pruebas_descripcion",
                             colSpan: 2,
                             width: 250,
                             canEdit: false
                         }, {
                             name: "competencias_pruebas_fecha",
                             useTextField: true,
                             showPickerIcon: false,
                             width: 150,
                             endRow:true
                         }, {
                             name: "competencias_pruebas_manual",title: 'Manual ?',labelAsTitle: true,showPending: true,
                             changed: function (form, item, value) {
                                 var record = g_atletaspruebas_resultados_detalle.getSelectedRecord();
                                 gform_atletaspruebas_resultados_detalle._setResultadoExpression(record, value);
                                 gform_atletaspruebas_resultados_detalle.getField('atletas_resultados_resultado').setValue( '');
                             }
                         }, {
                             name: "competencias_pruebas_anemometro",title: 'Anemometro ?',labelAsTitle: true,showPending: true,
                             changed: function (form, item, value) {
                                 gform_atletaspruebas_resultados_detalle._setupViento(value);
                             }
                         }, {
                             name: "competencias_pruebas_material_reglamentario",title: 'Material Reglamentario ?',labelAsTitle: true,showPending: true,endRow:true
                         }, {
                             name: "atletas_resultados_resultado",                          
                             showPending: true,
                             validators: [{
                                 type: "regexp",
                                 expression: '^$'
                             }]
                         }, {
                             name: "competencias_pruebas_viento",
                             showPending: true,
                             endRow:true
                         }, {
                             name: "atletas_resultados_puntos",
                             showPending: true,
                             startRow: true
                         },{
                            name: "atletas_resultados_puesto",
                            showPending: true
                        }],
                        editSelectedData: function(component) {
                            this.Super('editSelectedData',arguments);
                            var record = component.getSelectedRecord();
                            gform_atletaspruebas_resultados_detalle._setResultadoExpression(record, record.competencias_pruebas_manual);

                            if (record.unidad_medida_tipo != 'T') {
                                gform_atletaspruebas_resultados_detalle.getField('competencias_pruebas_manual').hide();
                            } else {
                                gform_atletaspruebas_resultados_detalle.getField('competencias_pruebas_manual').show();
                            }

                            var compViento = gform_atletaspruebas_resultados_detalle.getField('competencias_pruebas_viento');

                            if (record.apppruebas_verifica_viento == false) {
                                compViento .hide();
                                gform_atletaspruebas_resultados_detalle.getField('competencias_pruebas_anemometro').hide();
                            } else {
                                compViento.show();
                                gform_atletaspruebas_resultados_detalle.getField('competencias_pruebas_anemometro').show();
                                gform_atletaspruebas_resultados_detalle._setupViento(record.competencias_pruebas_anemometro);
                            }

                        },
                        _setupViento: function(withAnemometro) {
                            var compViento = gform_atletaspruebas_resultados_detalle.getField('competencias_pruebas_viento');
                            if (withAnemometro === false) {
                               compViento.setValue( null);
                               compViento.hide();
                            } else {
                               compViento.show();
                            }
                        },
                                                /**
                         * Este metodo es llamado por el controlador cuando una linea de la grilla es debidamente grabada,
                         * en este caso dado que cada vez que se graba un item en la grilla el header es modificaco
                         * en el server con el nuevo total de la prueba combinada , se aprovecha en forzar
                         * en releer los datos y presentarlos adecuadamente, usando para eso updateCaches luego de un fetch.
                         * Hay que recordar que se fuerza un fetchJoined que trae la mism data que lo que se presenta en la grilla
                         * y en la forma de dicion (que trabaj sobre el selected record , claro).
                         */
                        afterDetailGridRecordSaved: function (listControl, rowNum, colNum, newValues, oldValues) {

                            if (this.formMode === 'edit') {
                                // Preservamos valores que no son leidos al grabarse.
                                    newValues.unidad_medida_regex_e = oldValues.unidad_medida_regex_e;
                                    newValues.unidad_medida_regex_m = oldValues.unidad_medida_regex_m;
                                    newValues.unidad_medida_tipo = oldValues.unidad_medida_tipo;
                                    newValues.pruebas_descripcion =  oldValues.pruebas_descripcion;
                                    newValues.apppruebas_verifica_viento =  oldValues.apppruebas_verifica_viento;

                                    // Dado que los valores de las pruebas individuales cambian el total de los puntos de la prueba
                                    // y asi mismo pueden introducir observaciones , leemos el registro principal en edicion
                                    // para actualizar los datos en la grilla principal y se reflejen los cambios infdirectos
                                    // que pueden ocasionarse en las pruebas individuales.
                                    var searchCriteria = {
                                        atletas_resultados_id: formAtletasPruebasResultados.getValue('atletas_resultados_id')
                                    };
                                    formAtletasPruebasResultados.filterData(searchCriteria, function (dsResponse, data, dsRequest) {
                                        if (dsResponse.status === 0) {
                                            // aprovechamos el mismo ds response pero le cambiamos el tipo de operacion
                                            // este update caches actualiza tanto la forma como la grilla (ambos comparten
                                            // el mismo modelo).
                                            dsResponse.operationType = 'update';
                                            DataSource.get(mdl_atletaspruebas_resultados).updateCaches(dsResponse);
                                        }
                                    }, {
                                        operationId: 'fetchJoined',
                                        textMatchStyle: 'exact'
                                    });
                            }
                        },
                        _setResultadoExpression: function (record, manualStatus) {
                            var itResultado = gform_atletaspruebas_resultados_detalle.getField('atletas_resultados_resultado');
                            // De acuerdo a si es manual o no se cambia la expresion regular para el input,
                            // validator.
                            if (manualStatus != true) {
                                itResultado.validators[0].expression = record.unidad_medida_regex_e;
                            }
                            else {
                                itResultado.validators[0].expression = record.unidad_medida_regex_m;
                            }
                        }
                       // , cellBorder: 1
                    });
                } else {
                    newGrid = g_atletaspruebas_resultados_detalle.getChildForm();
                }
                return newGrid;
            }
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});