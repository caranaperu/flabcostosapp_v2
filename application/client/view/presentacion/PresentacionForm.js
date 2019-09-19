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
isc.defineClass("WinPresentacionForm", "WindowBasicFormExt");
isc.WinPresentacionForm.addProperties({
    ID: "winPresentacionForm",
    title: "Mantenimiento de Presentaciones",
    width: 470, height: 175,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formPresentacion",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_presentacion,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['tpresentacion_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'tpresentacion_descripcion',
            fields: [
                {name: "tpresentacion_codigo",  type: "text", showPending: true, width: "75", mask: ">LLLLLLLLLL"},
                {name: "tpresentacion_descripcion",  showPending: true, length: 60, width: "260"},
                {name: "tpresentacion_protected", hidden:true,defaultValue: false}
            ],
            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.tpresentacion_protected == true) {
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