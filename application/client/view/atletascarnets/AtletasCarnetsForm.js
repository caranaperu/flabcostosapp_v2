/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:47:11 -0500 (mar, 25 mar 2014) $
 * $Rev: 111 $
 */
isc.defineClass("WinAtletasCarnetsForm", "WindowBasicFormExt");
isc.WinAtletasCarnetsForm.addProperties({
    ID: "winAtletasCarnetsForm",
    title: "Registro de Carnet",
    width: 470, height: 205,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formAtletasCarnets",
            numCols: 2,
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_atletascarnets,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['atletas_carnets_agno', 'atletas_carnets_numero'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'atletas_codigo',
            // Campos virtuales del vie de la lista , se usan para preservar los valores originales
            _atletas_nombre_completo: undefined,
            fields: [
                {name: "atletas_carnets_agno", type: "text", showPending: true,width: "50", mask: "9999", defaultValue: new Date().getFullYear()},
                {name: "atletas_carnets_numero",showPending: true, length: 10, width: "120"},
                {name: "atletas_carnets_fecha", useTextField: true, showPending: true,width: "90"},
                {name: "atletas_codigo", editorType: "comboBoxExt", showPending: true,length: 200, width: "300",
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    optionDataSource: mdl_atletas,
                    pickListFields: [{name: "atletas_codigo", width: '25%'}, {name: "atletas_nombre_completo", width: '75%'}],
                    pickListWidth: 300,
                    completeOnTab: true,
                    minimumSearchLength: 3,
                    textMatchStyle: 'substring',
                    changed: function(form, item, value) {
                        formAtletasCarnets._atletas_nombre_completo = item.getSelectedRecord().atletas_nombre_completo;
                    }
                }
            ],
            postSetFieldsToEdit: function() {
                var record = this.getValues();
                formAtletasCarnets._atletas_nombre_completo = record.atletas_nombre_completo;
            },
            postSaveData: function(mode,record) {
                record.atletas_nombre_completo = formAtletasCarnets._atletas_nombre_completo;
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});