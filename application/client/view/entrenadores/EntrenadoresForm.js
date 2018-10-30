/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los entrenadores.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Id: EntrenadoresForm.js 237 2014-06-24 07:58:27Z aranape $
 * $Date: 2014-06-24 02:58:27 -0500 (mar, 24 jun 2014) $
 * $Rev: 237 $
 */
isc.defineClass("WinEntrenadoresForm", "WindowBasicFormExt");
isc.WinEntrenadoresForm.addProperties({
    ID: "winEntrenadoresForm",
    title: "Mantenimiento de Entrenadores",
    width: 770, height: 180,
    joinKeyFields: [{fieldName: 'entrenadores_codigo', fieldValue: ''}],
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formEntrenadores",
            numCols: 4,
            width: '740',
            /*colWidths: ["105","200", "200","250"],*/
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_entrenadores,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['entrenadores_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'entrenadores_apellido_paterno',
            fields: [
                {name: "entrenadores_codigo", type: "text", showPending: true, width: "60", mask: ">AAAAA"},
                {name: "entrenadores_ap_paterno", title: "Nombres", showPending: true, hint: 'Apellido Paterno', showHintInField: true, length: 60, width: 200, startRow: true},
                {name: "entrenadores_ap_materno", hint: 'Apellido Materno', showPending: true, showHintInField: true, showTitle: false, length: 60, width: 200},
                {name: "entrenadores_nombres", hint: 'Nombres', showPending: true, showTitle: false, showHintInField: true, length: 100, width: 250, endRow: true},
                {name: "entrenadores_nivel_codigo", editorType: "comboBoxExt", showPending: true, length: 50, width: "220",
                    valueField: "entrenadores_nivel_codigo", displayField: "entrenadores_nivel_descripcion",
                    optionDataSource: mdl_entrenadores_nivel,
                    pickListFields: [{name: "entrenadores_nivel_codigo", width: '20%'}, {name: "entrenadores_nivel_descripcion", width: '80%'}],
                    pickListWidth: 240
                }
            ]//,
                // cellBorder: 1
        });
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            height: 200,
            sectionTitle: 'Atletas asociados',
            gridProperties: {
                ID: 'g_entrenadoresatletas',
                fetchOperation: 'fetchJoined', // solicitado un resultset con el join a atletas resuelto por eficiencia
                dataSource: 'mdl_entrenadoresatletas',
                sortField: "atletas_nombre_completo",
                fields: [
                    // En este caso observese que no hay option datasource , y que la operacion es fetchJoined, eta tecnica
                    // hace que el servidor traiga los nombres del atleta joined con la tabla principal , pero aun asi
                    // el combo pagina y lee paginadamente , para esto usa la definicion del modelo que le indica que
                    // hay un foreign key a los atletas.
                    {name: "atletas_codigo", title: 'Atleta', editorType: "comboBoxExt",
                        valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                        pickListFields: [{name: "atletas_codigo", width: '20%'}, {name: "atletas_nombre_completo", width: '80%'}],
                        completeOnTab: true,
                        width: '90%',
                        editorProperties: {
                            // Aqui es la mejor posicion del optionDataSource en cualquiera de los otros lados
                            // en pickListProperties o afuera funciona de distinta manera.
                            optionDataSource: mdl_atletas,
                            autoFetchData: false,
                            textMatchStyle: 'substring',
                            sortField: "atletas_nombre_completo",
                            showPending: true
                        }
                    },
                    {name: "entrenadoresatletas_desde", title: "Desde", useTextField: true, textFieldProperties: {defaultValue: '01/01/1940'},
                        editorProperties: {showPending: true}, showPickerIcon: false, width: 100},
                    {name: "entrenadoresatletas_hasta", title: "hasta", useTextField: true, textFieldProperties: {defaultValue: '01/01/2035'},
                        editorProperties: {showPending: true}, showPickerIcon: false, width: 100}
                ],
                editComplete: function (rowNum, colNum, newValues, oldValues, editCompletionEvent, dsResponse) {
                    // Actualizamos el registro GRBADO no puedo usar setEditValue porque asumiria que el regisro recien grabado
                    // difiere de lo editado y lo tomaria como pendiente de grabar.d
                    // Tampoco puedo usar el record basado en el rowNum ya que si la lista esta ordenada al reposicionarse los registros
                    // el rownum sera el que equivale al actual orden y no realmente al editado.
                    // En otras palabras este evento es llamado despues de grabar correctamente Y ORDENAR SI HAY UN ORDER EN LA GRILLA
                    // Para resolver esto actualizamos la data del response la cual luego sera usada por el framework SmartClient para actualizar el registro visual.

                    var oldValue = null;
                    // El valor anterior por si acaso oldValues no este definido.
                    if (oldValues) {
                        oldValue = oldValues.atletas_nombre_completo;
                    }

                    // el registro es null si se ha eliminado
                    // Si los valores no han cambiado es generalmente que viene de un delete
                    if (dsResponse.data[0] && newValues.atletas_nombre_completo != oldValue) {
                        if (newValues.atletas_nombre_completo) {
                            dsResponse.data[0].atletas_nombre_completo = newValues.atletas_nombre_completo;
                        } else {
                            dsResponse.data[0].atletas_nombre_completo = oldValue;
                        }
                    }

                }
            }});
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
        //  Date.setInputFormat({DateInputFormat: 'DMY'});
    }
});