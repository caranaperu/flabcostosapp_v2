/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:40:54 -0500 (mar, 25 mar 2014) $
 * $Rev: 106 $
 */
isc.defineClass("WinPruebasTipoForm", "WindowBasicFormExt");
isc.WinPruebasTipoForm.addProperties({
    ID: "winPruebasTipoForm",
    title: "Mantenimiento de Tipos de Pruebas",
    width: 470, height: 160,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formPruebasTipo",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_pruebas_tipo,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['pruebas_tipo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'pruebas_tipo_descripcion',
            fields: [
                {name: "pruebas_tipo_codigo", title: "Codigo", type: "text", showPending: true, width: "50", mask: ">LLLLLLL"},
                {name: "pruebas_tipo_descripcion", title: "Descripcion", showPending: true, length: 120, width: "260"}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});