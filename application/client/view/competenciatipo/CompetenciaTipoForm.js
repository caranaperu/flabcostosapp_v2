/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:42:48 -0500 (mar, 25 mar 2014) $
 * $Rev: 108 $
 */
isc.defineClass("WinCompetenciaTipoForm", "WindowBasicFormExt");
isc.WinCompetenciaTipoForm.addProperties({
    ID: "winCompetenciaTipoForm",
    title: "Mantenimiento de Tipos de Competencia",
    width: 470, height: 175,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCompetenciaTipo",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_competencia_tipo,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['competencia_tipo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'competencia_tipo_descripcion',
            fields: [
                {name: "competencia_tipo_codigo", title: "Codigo", showPending: true,type: "text", width: "50", mask: ">LLLLL"},
                {name: "competencia_tipo_descripcion", title: "Descripcion", showPending: true,length: 120, width: "260"}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});