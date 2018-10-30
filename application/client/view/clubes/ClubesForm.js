/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los clubes
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:58:27 -0500 (mar, 24 jun 2014) $
 * $Rev: 237 $
 */
isc.defineClass("WinClubesForm", "WindowBasicFormExt");
isc.WinClubesForm.addProperties({
    ID: "winClubesForm",
    title: "Mantenimiento de Clubes",
    width: 780, height: 315,
    joinKeyFields: [{fieldName: 'clubes_codigo', fieldValue: ''}],
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formClubes",
            numCols: 4,
            colWidths: ["150", "*", "*", "*"],
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_clubes,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['clubes_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'clubes_descripcion',
            fields: [
                {name: "clubes_codigo", title: "Codigo", type: "text", showPending: true, width: "90", mask: ">AAAAAAAAAA", endRow: true},
                {name: "clubes_descripcion", title: "Descripcion", showPending: true, length: 120, width: "300"},
                {name:"clubes_separator",defaultValue: "Ubicacion/Contacto", type: "section", colSpan: 4, width: "*", canCollapse: false, align: 'center',
                    itemIds: ["clubes_persona_contacto", "clubes_direccion", "clubes_telefono_oficina", "clubes_telefono_celular", "clubes_email", "clubes_web_url"]
                },
                {name: "clubes_persona_contacto", showPending: true, length: 150, width: "*", colSpan: 4},
                {name: "clubes_direccion", showPending: true, length: 250, width: "*", colSpan: 4},
                {name: "clubes_telefono_oficina", showPending: true, lenght: 13},
                {name: "clubes_telefono_celular", showPending: true, lenght: 13, endRow: true},
                {name: "clubes_email", showPending: true, length: 100, width: "*", colSpan: 4, endRow: true},
                {name: "clubes_web_url", showPending: true, length: 200, width: "*", colSpan: 4, endRow: true}
            ]
        });
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            height: '200',
            sectionTitle: 'Atletas asociados',
            gridProperties: {
                ID: 'g_clubesatletas',
                fetchOperation: 'fetchJoined', // solicitado un resultset con el join a atletas resuelto por eficiencia
                dataSource: 'mdl_clubesatletas',
                sortField: "atletas_nombre_completo",
                autoFetchData: false,
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
                        autoFetchData: false,
                        // De no colocarse estas opciones dentro de editorProperties pero si afuera  curiosamente sucede
                        // que el control de la grilla invoca inmediatamente modelo de este combo solicitando todos los registros.
                        // Por ese motivo es necesario se coloque en esta seccion lo que corresponde al datasource.
                        editorProperties: {
                            showPending: true,
                            autoFetchData: false,
                            optionDataSource: mdl_atletas,
                            textMatchStyle: 'substring',
                            sortField: "atletas_nombre_completo",
                        }
                    },
                    {name: "clubesatletas_desde", title: "Desde", useTextField: true, textFieldProperties: {defaultValue: '01/01/1940'},
                        editorProperties: {showPending: true}, showPickerIcon: false, width: 100},
                    {name: "clubesatletas_hasta", title: "hasta", useTextField: true, textFieldProperties: {defaultValue: '01/01/2035'},
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
                },
            }});
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});