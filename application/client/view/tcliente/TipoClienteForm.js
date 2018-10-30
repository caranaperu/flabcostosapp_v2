/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los tipos de cliente.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoClienteForm", "WindowBasicFormExt");
isc.WinTipoClienteForm.addProperties({
    ID: "wintipoClienteForm",
    title: "Mantenimiento de Tipo De Clientes",
    width: 470, height: 175,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formtipoCliente",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_tipocliente,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['tipo_cliente_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'tipo_cliente_descripcion',
            fields: [
                {name: "tipo_cliente_codigo",  type: "text", showPending: true, width: "60", mask: ">LLL"},
                {name: "tipo_cliente_descripcion",  showPending: true, length: 60, width: "260"},
                {name: "tipo_cliente_protected", hidden:true,defaultValue: false}
            ],
            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.tipo_cliente_protected == true) {
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