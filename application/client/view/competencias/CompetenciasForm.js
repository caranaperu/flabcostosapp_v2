/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Competencias.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-29 23:54:30 -0500 (mar, 29 jul 2014) $
 * $Rev: 323 $
 */
isc.defineClass("WinCompetenciasForm", "WindowBasicFormExt");
isc.WinCompetenciasForm.addProperties({
    ID: "winCompetenciasForm",
    title: "Mantenimiento de Competencias",
    width: 825, height: 250,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCompetencias",
            numCols: 4,
            colWidths: ["120", "280", "*", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_competencias,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['competencias_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'competencias_descripcion',
            // Campos virtuales del vie de la lista , se usan para preservar los valores originales
            _paises_descripcion: undefined,
            _ciudades_descripcion: undefined,
            _ciudades_altura: undefined,
            _categorias_descripcion: undefined,
            _competencia_tipo_descripcion: undefined,
            _agno: undefined,
            fields: [
                {name: "competencias_codigo", type: "text", showPending: true,width: "90", mask: ">AAAAAAAAAA", endRow: true},
                {name: "competencias_descripcion", title: "Descripcion", showPending: true,length: 150, width: "260"},
                {name: "competencia_tipo_codigo", editorType: "comboBoxExt", showPending: true,length: 50, width: "180", endRow: true,
                    valueField: "competencia_tipo_codigo", displayField: "competencia_tipo_descripcion",
                    completeOnTab: true,
                    optionDataSource: mdl_competencia_tipo,
                    fetchMissingValues: true,
                    textMatchStyle: 'substring',
                    pickListFields: [{name: "competencia_tipo_codigo", width: '20%'}, {name: "competencia_tipo_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    changed: function (form, item, value) {
                        formCompetencias._competencia_tipo_descripcion = item.getSelectedRecord().competencia_tipo_descripcion;
                    },
                },
                {name: "paises_codigo", editorType: "comboBoxExt", showPending: true,length: 50, width: "220",
                    valueField: "paises_codigo", displayField: "paises_descripcion",
                    completeOnTab: true,
                    optionDataSource: mdl_paises,
                    fetchMissingValues: true,
                    autoFetchData: false,
                    pickListFields: [{name: "paises_codigo", width: '20%'}, {name: "paises_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    changed: function (form, item, value) {
                        formCompetencias.clearValue('ciudades_codigo');
                        formCompetencias._paises_descripcion = item.getSelectedRecord().paises_descripcion;
                    }
                },
                {name: "ciudades_codigo", editorType: "comboBoxExt", showPending: true,length: 50, width: "220", endRow: true,
                    valueField: "ciudades_codigo", displayField: "ciudades_descripcion",
                    optionDataSource: mdl_ciudades,
                    fetchMissingValues: true,
                    autoFetchData: false,
                    pickListFields: [{name: "ciudades_codigo", width: '20%'}, {name: "ciudades_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    changed: function (form, item, value) {
                        var record = item.getSelectedRecord();
                        if (record) {
                            formCompetencias._ciudades_descripcion = record.ciudades_descripcion;
                            formCompetencias._ciudades_altura = record.ciudades_altura;
                        } else {
                            formCompetencias._ciudades_descripcion = undefined;
                            formCompetencias._ciudades_altura = undefined;

                        }
                    },
                    getPickListFilterCriteria: function () {
                        var pais = this.form.getValue("paises_codigo");
                        if (pais) {
                            return {paises_codigo: pais};
                        }
                    }
                },
                {name: "categorias_codigo", editorType: "comboBoxExt", showPending: true,length: 50, width: "180",
                    valueField: "categorias_codigo", displayField: "categorias_descripcion",
                    optionDataSource: mdl_categorias,
                    pickListFields: [{name: "categorias_codigo", width: '20%'}, {name: "categorias_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    changed: function (form, item, value) {
                        formCompetencias._categorias_descripcion = item.getSelectedRecord().categorias_descripcion;
                    }
                },
                {name: "competencias_clasificacion", showPending: true,endRow: true},
                {name: "competencias_fecha_inicio", showPending: true,useTextField: true, showPickerIcon: false, width: 100},
                {name: "competencias_fecha_final", showPending: true,useTextField: true, showPickerIcon: false, width: 100}
            ],
            postSetFieldsToEdit: function () {
                var record = this.getValues();
                formCompetencias._paises_descripcion = record.paises_descripcion;
                formCompetencias._ciudades_descripcion = record.ciudades_descripcion;
                formCompetencias._categorias_descripcion = record.categorias_descripcion;
                formCompetencias._competencia_tipo_descripcion = record.competencia_tipo_descripcion;
                formCompetencias._ciudades_altura = record.ciudades_altura;
            },
            postSaveData: function (mode,record) {
                record.paises_descripcion = formCompetencias._paises_descripcion;
                record.ciudades_descripcion = formCompetencias._ciudades_descripcion;
                record.categorias_descripcion = formCompetencias._categorias_descripcion;
                record.competencia_tipo_descripcion = formCompetencias._competencia_tipo_descripcion;
                record.agno = new Date(formCompetencias.getValue('competencias_fecha_inicio')).getFullYear();
                record.ciudades_altura = formCompetencias._ciudades_altura;
            }
        });
    },
    /**
     * Metodo llamado durante de la inicializacion de la clase
     * para si se desea agregar mas tabs a la pantalla principal
     * para esto eso debe hacerse en un override de este metodo.
     *
     * Observese que el TabSet es del tipo TabSetExt el cual soporta el metodo
     * addAditionalTab.
     *
     * @param {isc.TabSetExt} tabset El tab set principal al cual agregar.
     */
    addAdditionalTabs: function (tabset) {
        tabset.addAdditionalTab({ID: 'TabInfoCompetenciasResultadosForm', title: 'Resultados', paneClass: 'CompetenciasResultadosForm', joinField: 'competencias_codigo'});
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});