/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los tipos de insumo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoInsumoForm", "WindowBasicFormExt");
isc.WinTipoInsumoForm.addProperties({
    ID: "winTipoInsumoForm",
    title: "Mantenimiento de Tipo De Insumos",
    width: 470, height: 175,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoInsumo",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_tinsumo,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['tinsumo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'tinsumo_descripcion',
            fields: [
                {name: "tinsumo_codigo",  type: "text", showPending: true, width: "75", mask: ">LLLLLLLLLL"},
                {name: "tinsumo_descripcion",  showPending: true, length: 60, width: "260"},
                {name: "tinsumo_protected", hidden:true,defaultValue: false}
            ],
            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.tinsumo_protected == true) {
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