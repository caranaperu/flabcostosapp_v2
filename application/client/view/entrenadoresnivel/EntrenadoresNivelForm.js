/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:17:30 -0500 (mar, 25 mar 2014) $
 * $Rev: 116 $
 */
isc.defineClass("WinEntrenadoresNivelForm", "WindowBasicFormExt");
isc.WinEntrenadoresNivelForm.addProperties({
    ID: "winEntrenadoresNivelForm",
    title: "Mantenimiento de Entrenadores - Niveles",
    width: 470, height: 170,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formEntrenadoresNivel",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_entrenadores_nivel,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['entrenadores_nivel_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'entrenadores_nivel_descripcion',
            fields: [
                {name: "entrenadores_nivel_codigo", title: "Codigo", type: "text",showPending: true, width: "80", mask: "AAAAAAAAAA"},
                {name: "entrenadores_nivel_descripcion", title: "Descripcion",showPending: true, length: 60, width: "260"}
            ],
            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.entrenadores_nivel_protected == true) {
                    isc.say('No puede actualizarse el registro  debido a que es un registro del sistema y esta protegido');
                    return false;
                } else {
                    return true;
                }
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});