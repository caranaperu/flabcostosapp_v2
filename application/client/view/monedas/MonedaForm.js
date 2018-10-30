/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de las monedas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:43:44 -0500 (dom, 06 abr 2014) $
 * $Rev: 146 $
 */
isc.defineClass("WinMonedaForm", "WindowBasicFormExt");
isc.WinMonedaForm.addProperties({
    ID: "winMonedaForm",
    title: "Mantenimiento de Monedas",
    width: 470, height: 220,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formMoneda",
            numCols: 2,
            colWidths: ["120", "*"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_moneda,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['moneda_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'moneda_simbolo',
            fields: [
                {name: "moneda_codigo", type: "text", showPending: true, width: "90", mask: ">LLLLLLL"},
                {name: "moneda_simbolo", showPending: true, length: 6, width: "260"},
                {name: "moneda_descripcion", showPending: true, length: 120, width: "260"}
            ],
            isAllowedToSave: function (values, oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.moneda_protected == true) {
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