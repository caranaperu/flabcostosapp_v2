/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de la produccion de los modos de aplicacion
 *
 * @version 1.00
 * @since 1.00
 */
isc.defineClass("WinProduccionForm", "WindowBasicFormExt");
isc.WinProduccionForm.addProperties({
    ID: "winProduccionForm",
    title: "Ingreso de Produccion",
    width: 425,
    height: 220,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formProduccion",
            numCols: 2,
            colWidths: ["100",  "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_produccion,
            formMode: this.formMode, // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'produccion_fecha',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
         //   disableValidation: true,
            fields: [
                {
                    name: "produccion_id",
                    hidden: true
                },
                {
                    name: "produccion_fecha",
                    showPending: true,
                    useTextField: true,
                    showPickerIcon: true,
                    width: "100"
                },
                {name: "taplicacion_entries_id", editorType: "comboBoxExt",
                    length: 50, width: 180,
                    showPending: true,
                    displayField: "taplicacion_entries_descripcion",
                    valueField: "taplicacion_entries_id",
                    pickListFields: [
                        {name: "taplicacion_descripcion", width: '50%'},
                        {name: "taplicacion_entries_descripcion", width: '50%'}
                    ],
                    pickListWidth: 240,
                    optionOperationId: 'fetchForPick',
                    optionDataSource: mdl_taplicacion_entries,
                    title: 'Tipo Aplicacion'
                },
                {
                    name: "produccion_qty",
                    showPending: true,
                    width: "85"
                }
            ]
        });
    },

    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});