/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de las regiones atleticas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinRegionesForm", "WindowBasicFormExt");
isc.WinRegionesForm.addProperties({
    ID: "winRegionesForm",
    title: "Mantenimiento de Regiones",
    width: 470, height: 175,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formRegiones",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_regiones,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['regiones_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'regiones_descripcion',
            fields: [
                {name: "regiones_codigo", title: "Codigo", type: "text", showPending: true, width: "75", mask: "LLLLLLLLLL"},
                {name: "regiones_descripcion", title: "Descripcion", showPending: true, length: 120, width: "260"}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});