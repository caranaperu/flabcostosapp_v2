 /**
 * Clase especifica para la definicion de la conversion de las
 * unidades de medida.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:51:33 -0500 (mar, 24 jun 2014) $
 * $Rev: 235 $
 */
isc.defineClass("WinUMConversionForm", "WindowBasicFormExt");
isc.WinUMConversionForm.addProperties({
    ID: "winUMConversionForm",
    title: "Mantenimiento de Conversion de Unidades de Medida",
    width: 470, height: 205,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formUMConversion",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_umconversion,
            formMode: this.formMode, // parametro de inicializacion
           // keyFields: ['unidad_medida_conversion_id'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'unidad_medida_origen',
            addOperation:'readAfterSaveJoined',
            updateOperation:'readAfterUpdateJoined',
            fields: [
                {name: "unidad_medida_origen",  editorType: "comboBoxExt",showPending: true, width: "120",
                    valueField: "unidad_medida_codigo", displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{name: "unidad_medida_codigo", width: '30%'}, {name: "unidad_medida_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'unidad_medida_descripcion'}]
                },
                {name: "unidad_medida_destino", editorType: "comboBoxExt",showPending: true, width: "120",
                    valueField: "unidad_medida_codigo", displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{name: "unidad_medida_codigo", width: '30%'}, {name: "unidad_medida_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'unidad_medida_descripcion'}]
                },
                {name: "unidad_medida_conversion_factor",  showPending: true,width:'80'}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});