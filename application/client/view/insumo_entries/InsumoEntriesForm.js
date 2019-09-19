/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de las importaciones para el calculo
 * del factor de ajuste al costo
 *
 * @version 1.00
 * @since 1.00
 */
isc.defineClass("WinInsumoEntriesForm", "WindowBasicFormExt");
isc.WinInsumoEntriesForm.addProperties({
    ID: "winInsumoEntriesForm",
    title: "Ingreso de Insumos",
    width: 425,
    height: 220,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formInsumoEntries",
            numCols: 2,
            colWidths: ["100",  "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_insumo_entries,
            formMode: this.formMode, // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'insumo_entries_fecha',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
         //   disableValidation: true,
            fields: [
                {
                    name: "insumo_entries_id",
                    hidden: true
                },
                {
                    name: "insumo_entries_fecha",
                    showPending: true,
                    useTextField: true,
                    showPickerIcon: true,
                    width: "100"
                },
                {
                    name: "insumo_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: 250,
                    valueField: "insumo_id",
                    displayField: "insumo_descripcion",
                    optionDataSource: mdl_insumo_used_by,
                    optionOperationId: 'fetchForInsumoEntries',
                    pickListFields: [
                        {
                            name: "insumo_codigo",
                            width: '20%'
                        }, {
                            name: "insumo_descripcion",
                            width: '40%'
                        }],
                    useClientFiltering: false,
                    cachePickListResults: false,
                    filterLocally: false,
                    pickListWidth: 350,
                    completeOnTab: true
                },
                {
                    name: "insumo_entries_qty",
                    showPending: true,
                    width: "85"
                },
                {
                    name: "insumo_entries_value",
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