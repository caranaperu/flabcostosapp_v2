/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de las ligas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:58:27 -0500 (mar, 24 jun 2014) $
 * $Rev: 237 $
 */
isc.defineClass("WinLigasForm", "WindowBasicFormExt");
isc.WinLigasForm.addProperties({
    ID: "winLigasForm",
    title: "Mantenimiento de Ligas",
    width: 780, height: 310,
    joinKeyFields: [{fieldName: 'ligas_codigo', fieldValue: ''}],
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formLigas",
            numCols: 4,
            colWidths: ["150", "*", "*", "*"],
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_ligas,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['ligas_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'ligas_descripcion',
            fields: [
                {name: "ligas_codigo", title: "Codigo", type: "text", showPending: true, width: "90", mask: ">AAAAAAAAAA", endRow: true},
                {name: "ligas_descripcion", title: "Descripcion", showPending: true, length: 120, width: "260"},
                {name: "ub_separator", defaultValue: "Ubicacion/Contacto", type: "section", colSpan: 4, width: "*", canCollapse: false, align: 'center',
                    itemIds: ["ligas_persona_contacto", "ligas_direccion", "ligas_telefono_oficina", "ligas_telefono_celular", "ligas_email", "ligas_web_url"]
                },
                {name: "ligas_persona_contacto", showPending: true, length: 150, width: "*", colSpan: 4},
                {name: "ligas_direccion", showPending: true, length: 250, width: "*", colSpan: 4},
                {name: "ligas_telefono_oficina", showPending: true, lenght: 13},
                {name: "ligas_telefono_celular", showPending: true, lenght: 13, endRow: true},
                {name: "ligas_email", showPending: true, length: 100, width: "*", colSpan: 4, endRow: true},
                {name: "ligas_web_url", showPending: true, length: 200, width: "*", colSpan: 4, endRow: true}
            ]//, cellBorder: 1
        });
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            height: 200,
            sectionTitle: 'Clubes Asociados',
            gridProperties: {
                ID: 'g_ligasclubes',
                fetchOperation: 'fetchJoined', // solicitado un resultset con el join a atletas resuelto por eficiencia
                dataSource: 'mdl_ligasclubes',
                sortField: "clubes_descripcion",
                fields: [
                    {name: "clubes_codigo", title: 'Club', editorType: "comboBoxExt",
                        valueField: "clubes_codigo", displayField: "clubes_descripcion",
                        pickListFields: [{name: "clubes_codigo", width: '20%'}, {name: "clubes_descripcion", width: '80%'}],
                        completeOnTab: true,
                        width: '90%',
                        editorProperties: {
                            // Aqui es la mejor posicion del optionDataSource en cualquiera de los otros lados
                            // en pickListProperties o afuera funciona de distinta manera.
                            optionDataSource: mdl_clubes,
                            minimumSearchLength: 3,
                            autoFetchData: false,
                            textMatchStyle: 'substring',
                            sortField: "clubes_descripcion",
                            showPending: true
                        }
                    },
                    {name: "ligasclubes_desde", title: "Desde", useTextField: true, textFieldProperties: {defaultValue: '01/01/1940'}, editorProperties: {showPending: true}, showPickerIcon: false, width: 100},
                    {name: "ligasclubes_hasta", title: "Hasta", useTextField: true, textFieldProperties: {defaultValue: '01/01/2035'}, editorProperties: {showPending: true}, showPickerIcon: false, width: 100},
                    {name: "activo", editorProperties: {showPending: true}, width: '10%', canToggle: false}
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
                        oldValue = oldValues.clubes_descripcion;
                    }

                    // el registro es null si se ha eliminado
                    // Si los valores no han cambiado es generalmente que viene de un delete
                    if (dsResponse.data[0] && newValues.clubes_descripcion != oldValue) {
                        if (newValues.clubes_descripcion) {
                            dsResponse.data[0].clubes_descripcion = newValues.clubes_descripcion;
                        } else {
                            dsResponse.data[0].clubes_descripcion = oldValue;
                        }
                    }
                },
            }});
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});