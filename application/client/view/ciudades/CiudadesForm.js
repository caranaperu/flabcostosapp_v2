/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:51:33 -0500 (mar, 24 jun 2014) $
 * $Rev: 235 $
 */
isc.defineClass("WinCiudadesForm", "WindowBasicFormExt");
isc.WinCiudadesForm.addProperties({
    ID: "winCiudadesForm",
    title: "Mantenimiento de Ciudades",
    width: 470, height: 205,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCiudades",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_ciudades,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['ciudades_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'ciudades_descripcion',
            fields: [
                {name: "ciudades_codigo", title: "Codigo", showPending: true, type: "text", width: "50", mask: "LLLLL"},
                {name: "ciudades_descripcion", title: "Descripcion", showPending: true, length: 120, width: "260"},
                {name: "paises_codigo", title: "Pais", showPending: true, editorType: "comboBoxExt", length: 80, width: "280",
                    valueField: "paises_codigo", displayField: "paises_descripcion",
                    optionDataSource: mdl_paises,
                    pickListFields: [{name: "paises_codigo", width: '20%'}, {name: "paises_descripcion", width: '80%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'paises_descripcion'}]
                },
                {name: "ciudades_altura", title: 'Esta en Altura?', showPending: true}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});