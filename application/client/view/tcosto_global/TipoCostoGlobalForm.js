/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de las tipos de dostos globales
 *
 * @version 1.00
 * @since 13-MAY-2021
 * @Author: Carlos Arana Reategui
 */
isc.defineClass("WinTipoCostoGlobalForm", "WindowBasicFormExt");
isc.WinTipoCostoGlobalForm.addProperties({
    ID: "winTipoCostoGlobalForm",
    title: "Mantenimiento de Tipos de Costos Globales",
    width: 470, height: 165,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoCostoGlobal",
            numCols: 2,
            colWidths: ["120", "*"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_tcosto_global,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['tcosto_global_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'tcosto_global_descripcion',
            fields: [
                {name: "tcosto_global_codigo", type: "text", showPending: true, width: 90, mask: ">LLLLLLL"},
                {name: "tcosto_global_descripcion", showPending: true, length: 120, width: 260}
            ],
            isAllowedToSave: function (values, oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.tcosto_global_protected == true) {
                    isc.say('No puede actualizarse el registro  debido a que es un registro del sistema y esta protegido');
                    return false;
                } else {
                    return true;
                }
            }

        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});