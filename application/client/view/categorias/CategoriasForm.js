/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 03:01:35 -0500 (mar, 24 jun 2014) $
 * $Rev: 239 $
 */
isc.defineClass("WinCategoriasForm", "WindowBasicFormExt");
isc.WinCategoriasForm.addProperties({
    ID: "winCategoriasForm",
    title: "Mantenimiento de Categorias",
    width: 470, height: 260,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCategorias",
            numCols: 2,
            colWidths: ["140", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_categorias,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['categorias_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'categorias_descripcion',
            fields: [
                {name: "categorias_codigo", title: "Codigo", type: "text", showPending: true, width: "100", mask: ">AAAAAAAAAA"},
                {name: "categorias_descripcion", title: "Descripcion", showPending: true, length: 120, width: "260"},
                {name: "categorias_edad_inicial", title: "Edad Inicial", showPending: true, keyPressFilter: "[0-9]", length: 2, width: '50',
                    validators: [{type: "custom",
                            // Valida que la edad inicial no sea mayor que la final
                            condition: function(item, validator, value) {
                                formCategorias.clearFieldErrors('categorias_edad_final', true);
                                var edadFinal = formCategorias.getValue('categorias_edad_final');
                                if (value > edadFinal) {
                                    validator.errorMessage = 'No puede ser mayor que la edad final';
                                    return false;
                                }
                                return true;
                            }
                        }]},
                {name: "categorias_edad_final", title: "Edad Final", showPending: true, keyPressFilter: "[0-9]", length: 2, width: '50',
                    validators: [{type: "custom",
                            // Valida que la edad final no sea mayor que la inicial
                            condition: function(item, validator, value) {
                                formCategorias.clearFieldErrors('categorias_edad_inicial', true);
                                var edadInicial = formCategorias.getValue('categorias_edad_inicial');
                                if (value < edadInicial) {
                                    validator.errorMessage = 'No puede ser menor que la edad inicial';
                                    return false;
                                }
                                return true;
                            }
                        }]},
                {name: "categorias_valido_desde", title: "Valido Desde", showPending: true, useTextField: true, textFieldProperties: {defaultValue: '01/01/1940'}, width: 100},
                {name: "categorias_validacion", editorType: "selectExt", showPending: true, width: "100",
                    valueField: "appcat_codigo", displayField: "appcat_codigo",
                    optionDataSource: mdl_appcategorias
                }
            ],
            /**
             * Override , ver clase base ,aprovechamos en dar valor default a la fecha,
             * esto no es lo mismo que el defaultValue del dateItem ya que ese es solo si no se da valor
             * alguno o se hace un reset.
             */
            setupFieldsToAdd: function(fieldsToAdd) {
                formCategorias.setValue("categorias_valido_desde", '01/01/1940');
            },
            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.categorias_protected == true) {
                    isc.say('No puede actualizarse el registro  debido a que es un registro del sistema y esta protegido');
                    return false;
                } else {
                    return true;
                }
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});