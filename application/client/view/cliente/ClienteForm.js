/**
 * Clase que crea la ventana de ingreso de datos para los clientes.
 *
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinClienteForm", "WindowBasicFormExt");

isc.WinClienteForm.addProperties({
    ID: "winClienteForm",
    title: "Mantenimiento de Datos de Cliente",
    width: 565,
    height: 275,
    canDragResize: true,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formClienteDocumento",
            numCols: 4,
            //  colWidths: ["90", "*"],
            fixedColWidths: false,
            padding: 5,
            errorOrientation: "right",
            validateOnExit: true,
            dataSource: mdl_cliente,
            autoFocus: true,
            formMode: 'edit', // parametro de inicializacion
            // keyFields: ['cliente_razon_social'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'cliente_razon_social',
            //disableValidation: true,
            addOperation:'readAfterSaveJoined',
            updateOperation:'readAfterUpdateJoined',
            fields: [
                {
                    name: "cliente_razon_social",
                    showPending: true,
                    width: "300",
                    length: 200,
                    type: 'text',
                    colSpan: 4
                },
                {
                    name: "tipo_cliente_codigo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "tipo_cliente_codigo",
                    displayField: "tipo_cliente_descripcion",
                    optionDataSource: mdl_tipocliente,
                    pickListFields: [{
                        name: "tipo_cliente_codigo",
                        width: '30%'
                    }, {
                        name: "tipo_cliente_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'tipo_cliente_descripcion'}],
                    startRow: true
                },
                {
                    name: "cliente_direccion",
                    showPending: true,
                    width: "300",
                    length: 200,
                    colSpan: 4
                },
                {
                    name: "cliente_ruc",
                    showPending: true,
                    width: "120",
                    endRow: true,
                    colSpan: 4
                },
                {
                    name: "cliente_correo",
                    showPending: true,
                    width: "220",
                    length: 100,
                    colSpan: 4
                },
                {
                    name: "cliente_telefonos",
                    showPending: true,
                    width: "240",
                    length: 60
                },
                {
                    name: "cliente_fax",
                    showPending: true,
                    width: "120",
                    length: 10,
                    endRow: true
                },
                {
                    name: "empresa_id",
                    hidden: true,
                    defaultValue: glb_empresaId
                }
            ]
            // ,cellBorder: 1
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }

});