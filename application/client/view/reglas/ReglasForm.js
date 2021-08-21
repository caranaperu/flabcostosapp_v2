/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de las reglas de costos entre empresas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinReglasForm", "WindowBasicFormExt");
isc.WinReglasForm.addProperties({
    ID: "winReglasForm",
    title: "Mantenimiento de Reglas",
    width: 340, height: 220,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formReglas",
            numCols: 2,
            colWidths: ["120", "180"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_reglas,
            formMode: this.formMode, // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'regla_empresa_origen_id',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
            fields: [
                {
                    name: "regla_empresa_origen_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "150",
                    valueField: "empresa_id",
                    displayField: "empresa_razon_social",
                    optionDataSource: mdl_empresa,
                    pickListFields: [{
                        name: "empresa_razon_social"
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    initialSort: [{property: 'empresa_razon_social'}]
                },
                {
                    name: "regla_empresa_destino_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "150",
                    valueField: "empresa_id",
                    displayField: "empresa_razon_social",
                    optionDataSource: mdl_empresa,
                    pickListFields: [{
                        name: "empresa_razon_social"
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    initialSort: [{property: 'empresa_razon_social'}]
                },
                {
                    name: "regla_by_costo", showPending: true, defaultValue: true,
                    changed: function(form, item, value) {
                        this.updateTitle(value);
                    },
                    /**
                     * Metodo para actualizar el title del campo segun sea su valor
                     * @param value true - Precio de Costo , false - Precio de Mercado.
                     */
                    updateTitle: function(value) {
                        if (value == true) {
                            this.title = 'Por Costo';
                        } else {
                            this.title = 'Por Precio Mercado';
                        }
                        this.redraw();
                    }
                },
                {name: "regla_porcentaje", showPending: true, width: 80}
            ],
            setEditMode: function(mode) {
                this.Super('setEditMode', arguments);
                if (mode == 'add') {
                    this.getField('regla_by_costo').updateTitle(true);
                }
            },
            editSelectedData: function(component) {
                this.Super('editSelectedData', arguments);

                var record = component.getSelectedRecord();
                this.getField('regla_by_costo').updateTitle(record.regla_by_costo);
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});