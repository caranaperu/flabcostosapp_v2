/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los tipos de costos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoCostosForm", "WindowBasicFormExt");
isc.WinTipoCostosForm.addProperties({
    ID: "winTipoCostosForm",
    title: "Mantenimiento de Tipo De Costos",
    width: 470, height: 200,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoCostos",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_tcostos,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['tcostos_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'tcostos_descripcion',
            fields: [
                {name: "tcostos_codigo",  type: "text", showPending: true, width: "75", mask: ">LLLL"},
                {name: "tcostos_descripcion",  showPending: true, length: 60, width: "260"},
                {name: "tcostos_indirecto",showPending: true,defaultValue: false},
                {name: "tcostos_protected", hidden:true,defaultValue: false}
            ],

            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.tcostos_protected == true) {
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