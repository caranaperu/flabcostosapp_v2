/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los items de las cotizaciones.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoAplicacionForm", "WindowBasicFormExt");
isc.WinTipoAplicacionForm.addProperties({
    ID: "winTipoAplicacionForm",
    title: "Mantenimiento de Tipo Aplicacion / Subtipos",
    width: 700,
    height: 150,
    efficientDetailGrid: false,
    joinKeyFields: [{
        fieldName: 'taplicacion_codigo',
        fieldValue: ''
    }],
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoAplicacion",
            numCols: 4,
            colWidths: ["100", "120", "100", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_taplicacion,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['taplicacion_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'taplicacion',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
            disableValidation: true,
            fields: [
                {name: "taplicacion_codigo", type: "text", showPending: true, width: "85", mask: ">LLLLLLLLLL"},
                {name: "taplicacion_descripcion", showPending: true, length: 60, width: "220"},
            ]
        });
    },
    canShowTheDetailGridAfterAdd: function() {
        return true;
    },
    createDetailGridContainer: function(mode) {
        return isc.DetailGridContainer.create({
            height: 300,
            sectionTitle: 'SubTipos',
            gridProperties: {
                ID: 'g_tipo_aplicacion_entries',
                //fetchOperation: 'fetchJoined',
                dataSource: 'mdl_taplicacion_entries',
                sortField: "taplicacion_entries_id",
                autoFetchData: false,
                canRemoveRecords: true,
                canAdd: true,
                canSort: false,
                showHeaderMenuButton: false,
                showGridSummary: true,
                width: 680,
                fields: [
                    {
                        name: "taplicacion_entries_descripcion",
                        width: '100%'
                    }
                ]
            },
            // Dado que se requiere que la lista de productos a elegir en la forma
            // de edicion/adicion de un registro de la grilla no sea ni el producto principal
            // ni alguno ya encomponente , aprovechamos este metodo para setear el pickListCriteria
            // del campo insumo_id de la forma interna con el valor del principal.
            // El uso de optionCriteria: {insumo_id_origen: formTipoAplicacion.getValue('insumo_id')} no
            // funcionaria ya que se setea estaticamente y no dinamicamente.
            //
            //childFormShow: function() {
            //gform_producto_procesos_detalle.getField('insumo_id').setOptionCriteria(isc.addProperties({}, {taplicacion_codigo: formTipoAplicacion.getValue('taplicacion_codigo')}));
            //  this.Super("childFormShow", arguments);
            //},
            getFormComponent: function() {
                var newForm;
                if (this.getChildForm() == undefined) {
                    newForm = isc.DynamicFormExt.create({
                        ID: "gform_producto_procesos_detalle",
                        numCols: 4,
                        colWidths: ["80", "120", "*", "*"],
                        titleWidth: 100,
                        fixedColWidths: false,
                        padding: 5,
                        dataSource: mdl_taplicacion_entries,
                       // addOperation: 'readAfterSaveJoined',
                       // updateOperation: 'readAfterUpdateJoined',
                        formMode: this.formMode, // parametro de inicializacion
                        focusInEditFld: 'taplicacion_entries_descripcion',
                        disableValidation: true,
                        fields: [
                            {
                                name: "taplicacion_codigo",
                                hidden: true
                            },
                            {name: "taplicacion_entries_descripcion", showPending: true, length: 60, width: "500"}
                        ]
                    });
                } else {
                    newForm = g_tipo_aplicacion_entries.getChildForm();
                }
                return newForm;
            }
        });
    },

    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});