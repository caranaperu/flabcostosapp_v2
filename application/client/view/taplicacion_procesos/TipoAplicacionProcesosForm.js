/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de la relacion tipo aplicacion-procesos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoAplicacionProcesosForm", "WindowBasicFormExt");
isc.WinTipoAplicacionProcesosForm.addProperties({
    ID: "winTipoAplicacionProcesosForm",
    title: "Mantenimiento de Modo de Aplicacion / Procesos",
    width: 700,
    height: 150,
    efficientDetailGrid: false,
    joinKeyFields: [{
        fieldName: 'taplicacion_procesos_id',
        fieldValue: ''
    }],
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formTipoAplicacionProcesos",
            numCols: 4,
            colWidths: ["100", "120", "100", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_taplicacion_procesos,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['taplicacion_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'taplicacion_procesos_fecha_desde',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
         //   disableValidation: true,
            fields: [
                {
                    name: "taplicacion_procesos_id",
                    hidden: true
                },
                {
                    name: "taplicacion_codigo",
                    editorType: "comboBoxExt",
                    mask: ">LLLLLLLLLL",
                    showPending: true,
                    width: 120,
                    valueField: "taplicacion_codigo",
                    displayField: "taplicacion_descripcion",
                    optionDataSource: mdl_taplicacion,
                    optionOperationId: 'fetchProductoForSimpleList',
                    pickListFields: [{
                        name: "taplicacion_codigo",
                        width: '30%'
                    }, {
                        name: "taplicacion_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'taplicacion_descripcion'}],
                    startRow: true
                },
                {
                    name: "taplicacion_procesos_fecha_desde",
                    showPending: true,
                    // length: 60,
                    width: 220
                }
            ]
        });
    },
    canShowTheDetailGridAfterAdd: function() {
        return true;
    },
    createDetailGridContainer: function(mode) {
        return isc.DetailGridContainer.create({
            height: 300,
            sectionTitle: 'Procesos',
            gridProperties: {
                ID: 'g_taplicacion_procesos_detalle',
                fetchOperation: 'fetchJoined',
                dataSource: 'mdl_taplicacion_procesos_detalle',
                sortField: "taplicacion_procesos_detalle_id",
                autoFetchData: false,
                canRemoveRecords: true,
                canAdd: true,
                canSort: false,
                showHeaderMenuButton: false,
                showGridSummary: true,
                width: 680,
                fields: [
                    {
                        name: "procesos_descripcion",
                        width: '30%'
                    }, {
                        name: "taplicacion_procesos_detalle_porcentaje",
                        align: 'right',
                        showGridSummary: true,
                        width: '10%'
                    }
                ],
                getCellCSSText: function(record, rowNum, colNum) {
                    if (record.taplicacion_procesos_detalle_porcentaje < 0 || record.taplicacion_procesos_detalle_porcentaje >100.00) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            getFormComponent: function() {
                var newForm;
                if (this.getChildForm() == undefined) {
                    newForm = isc.DynamicFormExt.create({
                        ID: "gform_taplicacion_procesos_detalle",
                        numCols: 4,
                        colWidths: ["80", "120", "*", "*"],
                        titleWidth: 100,
                        fixedColWidths: false,
                        padding: 5,
                        dataSource: mdl_taplicacion_procesos_detalle,
                        addOperation: 'readAfterSaveJoined',
                        updateOperation: 'readAfterUpdateJoined',
                        formMode: this.formMode, // parametro de inicializacion
                        focusInEditFld: 'procesos_codigo',
                        //disableValidation: true,
                        fields: [
                            {
                                name: "taplicacion_procesos_id",
                                hidden: true
                            },
                            {
                                name: "procesos_codigo",
                                editorType: "comboBoxExt",
                                showPending: true,
                                width: 180,
                                valueField: "procesos_codigo",
                                displayField: "procesos_descripcion",
                                optionDataSource: mdl_procesos,
                                //optionOperationId: 'fetchForTipoAplicacionProcesosDetalle',
                                pickListFields: [
                                    {
                                        name: "procesos_codigo"
                                    }, {
                                        name: "procesos_descripcion"
                                    }],
                                cachePickListResults: false,
                                filterLocally: false,
                                pickListWidth: 420,
                                completeOnTab: true,
                                // Solo es pasado al servidor si no existe cache data all en el modelo
                                // de lo contrario el sort se hace en el lado cliente.
                                initialSort: [{property: 'procesos_descripcion'}],
                            },
                            {
                                name: "taplicacion_procesos_detalle_porcentaje",
                                showPending: true,
                                width: 80
                            }
                        ]
                    });
                } else {
                    newForm = g_taplicacion_procesos_detalle.getChildForm();
                }
                return newForm;
            }
        });
    },

    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});