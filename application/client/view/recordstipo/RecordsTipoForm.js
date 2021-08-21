/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Estados de documentos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-16 00:07:23 -0500 (mié, 16 jul 2014) $
 * $Rev: 312 $
 */
isc.defineClass("WinRecordsTipoForm", "WindowBasicFormExt");
isc.WinRecordsTipoForm.addProperties({
    ID: "winRecordsTipoForm",
    title: "Mantenimiento de Tipos de Record",
    width: 470, height: 260,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formRecordsTipo",
            numCols: 2,
            colWidths: ["140", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_records_tipo,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['records_tipo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'records_tipo_descripcion',
            fields: [
                {name: "records_tipo_codigo", type: "text", showPending: true, width: "100", mask: ">AAAAAAAAAA"},
                {name: "records_tipo_descripcion", showPending: true, length: 100, width: "260"},
                {name: "records_tipo_abreviatura", showPending: true, length: 2, width: "40"},
                {name: "records_tipo_tipo", showPending: true},
                {name: "records_tipo_clasificacion", showPending: true},
                {name: "records_tipo_peso", showPending: true, length: 4, width: "60"},
                {name: "records_tipo_protected", showPending: true, visible: false, defaultValue: false}
            ],
            isAllowedToSave: function(values,oldValues) {
                // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                if (values.records_tipo_protected == true) {
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