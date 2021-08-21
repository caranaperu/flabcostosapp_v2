
/**
 * Clase que crea la ventana de ingreso de datos basicos para la entidad usuaria
 * del sistema.
 *
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinEntidadForm", "WindowBasicFormExt");

isc.WinEntidadForm.addProperties({
    ID: "winEntidadForm",
    title: "Mantenimiento de Datos de la Entidad",
    width: 565, height: 260,
    canDragResize: true,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formEntidadDocumento",
            numCols: 4,
            //colWidths: ["90", "*"],
            fixedColWidths: false,
            padding: 5,
            errorOrientation: "right",
            validateOnExit: true,
            dataSource: mdl_entidad,
            autoFocus: true,
            formMode: 'edit', // parametro de inicializacion
            // keyFields: ['entidad_razon_social'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'entidad_razon_social',
            //disableValidation: true,
            fields: [
                {name: "entidad_razon_social", showPending: true, width: "300", length: 200, type: 'text', colSpan: 4},
                {name: "entidad_direccion", showPending: true, width: "300", length: 200, colSpan: 4},
                {name: "entidad_ruc", showPending: true, width: "120", endRow: true, colSpan: 4},
                {name: "entidad_correo", showPending: true, width: "220", length: 100, colSpan: 4},
                {name: "entidad_telefonos", showPending: true, width: "240", length: 60},
                {name: "entidad_fax", showPending: true, width: "120", length: 10, endRow: true}
            ],
            /**
             * Override , ver clase base
             */
            getInitialFormData: function(params) {
                this.fetchData(null, function(dsResponse, data) {
                    if (dsResponse.status < 0) {
                        formEntidadDocumento.hide();
                    }
                });
            }
            // ,cellBorder: 1
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }

});