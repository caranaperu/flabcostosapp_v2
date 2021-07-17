/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de valor para cada tipo de costo global valido
 * desde una determinada fecha.
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 */
isc.defineClass("WinTipoCostoGlobalEntriesForm", "WindowBasicFormExt");
isc.WinTipoCostoGlobalEntriesForm.addProperties({
    ID: "winTipoCostoGlobalEntriesForm",
    title: "Movimiento de Tipo de Costo Globales",
    width: 425,
    height: 220,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoCostoGlobalEntries",
            numCols: 2,
            colWidths: ["100",  "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_tcosto_global_entries,
            formMode: this.formMode, // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'tcosto_global_entries_fecha',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
         //   disableValidation: true,
            fields: [
                {
                    name: "tcosto_global_entries_id",
                    hidden: true
                },
                {
                    name: "tcosto_global_entries_fecha_desde",
                    showPending: true,
                    useTextField: true,
                    showPickerIcon: true,
                    width: "100"
                },
                {
                    name: "tcosto_global_codigo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: 250,
                    valueField: "tcosto_global_codigo",
                    displayField: "tcosto_global_descripcion",
                    optionDataSource: mdl_tcosto_global,
                    optionOperationId: 'fetchForTipoCostoGlobalEntries',
                    pickListFields: [
                        {
                            name: "tcosto_global_codigo",
                            width: '20%'
                        }, {
                            name: "tcosto_global_descripcion",
                            width: '40%'
                        }],
                    useClientFiltering: false,
                    cachePickListResults: false,
                    filterLocally: false,
                    pickListWidth: 350,
                    completeOnTab: true
                },
                {name: "moneda_codigo",  editorType: "comboBoxExt",showPending: true, width: "140",
                    valueField: "moneda_codigo", displayField: "moneda_descripcion",
                    optionDataSource: mdl_moneda,
                    pickListFields: [{name: "moneda_codigo", width: '30%'}, {name: "moneda_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'moneda_descripcion'}]
                },
                {
                    name: "tcosto_global_entries_valor",
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