/**
 * Clase especifica para la definicion de los tipos de cambio.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:51:33 -0500 (mar, 24 jun 2014) $
 * $Rev: 235 $
 */
isc.defineClass("WinTipoCambioForm", "WindowBasicFormExt");
isc.WinTipoCambioForm.addProperties({
    ID: "winTipoCambioForm",
    title: "Mantenimiento de Tipos De Cambio",
    width: 400, height: 270,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoCambio",
            numCols: 2,
            colWidths: ["120", "180"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_tipocambio,
            formMode: this.formMode, // parametro de inicializacion
           // keyFields: ['unidad_medida_conversion_id'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'moneda_codigo_origen',
            addOperation:'readAfterSaveJoined',
            updateOperation:'readAfterUpdateJoined',
            fields: [
                {name: "moneda_codigo_origen",  editorType: "comboBoxExt",showPending: true, width: "140",
                    valueField: "moneda_codigo", displayField: "moneda_descripcion",
                    optionDataSource: mdl_moneda,
                    pickListFields: [{name: "moneda_codigo", width: '30%'}, {name: "moneda_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'moneda_descripcion'}]
                },
                {name: "moneda_codigo_destino", editorType: "comboBoxExt",showPending: true, width: "140",
                    valueField: "moneda_codigo", displayField: "moneda_descripcion",
                    optionDataSource: mdl_moneda,
                    pickListFields: [{name: "moneda_codigo", width: '30%'}, {name: "moneda_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'moneda_descripcion'}]
                },
                {name: "tipo_cambio_fecha_desde", showPending: true,useTextField: true, showPickerIcon: true, width: 100,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && formTipoCambio.getValue('tipo_cambio_fecha_hasta')) {
                            if (value.getTime() > formTipoCambio.getValue('tipo_cambio_fecha_hasta').getTime()) {
                                isc.say('La fecha inicial no puede ser mayor que la final');
                                return false;
                            }
                        }
                        return true;
                    }},
                {name: "tipo_cambio_fecha_hasta", showPending: true,useTextField: true, showPickerIcon: true, width: 100,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && formTipoCambio.getValue('tipo_cambio_fecha_desde')) {
                            if (value.getTime() < formTipoCambio.getValue('tipo_cambio_fecha_desde').getTime()) {
                                isc.say('La fecha final no puede ser menor que la final');
                                return false;
                            }
                        }
                        return true;
                    }},
                {name: "tipo_cambio_tasa_compra",  showPending: true,width:'80'},
                {name: "tipo_cambio_tasa_venta",  showPending: true,width:'80'}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});