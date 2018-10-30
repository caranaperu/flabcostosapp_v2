/**
 * Clase que crea la ventana de ingreso de datos para las empresas.
 *
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinEmpresaForm", "WindowBasicFormExt");

isc.WinEmpresaForm.addProperties({
    ID: "winEmpresaForm",
    title: "Mantenimiento de Datos de Empresa",
    width: 565,
    height: 275,
    canDragResize: true,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formEmpresaDocumento",
            numCols: 4,
            //  colWidths: ["90", "*"],
            fixedColWidths: false,
            padding: 5,
            errorOrientation: "right",
            dataSource: mdl_empresa,
            autoFocus: true,
            formMode: 'edit', // parametro de inicializacion
            // keyFields: ['empresa_razon_social'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'empresa_razon_social',
            //disableValidation: true,
            addOperation:'readAfterSaveJoined',
            updateOperation:'readAfterUpdateJoined',
            fields: [
                {
                    name: "empresa_razon_social",
                    showPending: true,
                    width: "300",
                    length: 200,
                    type: 'text',
                    colSpan: 4
                },
                {
                    name: "tipo_empresa_codigo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "tipo_empresa_codigo",
                    displayField: "tipo_empresa_descripcion",
                    optionDataSource: mdl_tipoempresa,
                    pickListFields: [{
                        name: "tipo_empresa_codigo",
                        width: '30%'
                    }, {
                        name: "tipo_empresa_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'tipo_empresa_descripcion'}],
                    startRow: true
                },
                {
                    name: "empresa_direccion",
                    showPending: true,
                    width: "300",
                    length: 200,
                    colSpan: 4
                },
                {
                    name: "empresa_ruc",
                    showPending: true,
                    width: "120",
                    endRow: true,
                    colSpan: 4
                },
                {
                    name: "empresa_correo",
                    showPending: true,
                    width: "220",
                    length: 100,
                    colSpan: 4
                },
                {
                    name: "empresa_telefonos",
                    showPending: true,
                    width: "240",
                    length: 60
                },
                {
                    name: "empresa_fax",
                    showPending: true,
                    width: "120",
                    length: 10,
                    endRow: true
                }
            ]
            // ,cellBorder: 1
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }

});