/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros que relacionan un producto y sus procesos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinProductoProcesosForm", "WindowBasicFormExt");
isc.WinProductoProcesosForm.addProperties({
    ID: "winProductoProcesosForm",
    title: "Mantenimiento de Producto / Procesos",
    width: 700,
    height: 150,
    efficientDetailGrid: false,
    joinKeyFields: [{
        fieldName: 'producto_procesos_id',
        fieldValue: ''
    }],
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formProductoProcesos",
            numCols: 4,
            colWidths: ["100", "120", "100", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_producto_procesos,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['insumo_id'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'insumo_descripcion',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
         //   disableValidation: true,
            fields: [
                {
                    name: "producto_procesos_id",
                    hidden: true
                },
                {
                    name: "insumo_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "insumo_id",
                    displayField: "insumo_descripcion",
                    optionDataSource: mdl_producto,
                    optionOperationId: 'fetchProductoForSimpleList',
                    pickListFields: [{
                        name: "insumo_codigo",
                        width: '30%'
                    }, {
                        name: "insumo_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'insumo_descripcion'}],
                    startRow: true
                },
                {
                    name: "producto_procesos_fecha_desde",
                    showPending: true,
                    // length: 60,
                    width: "220"
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
                ID: 'g_producto_procesos_detalle',
                fetchOperation: 'fetchJoined',
                dataSource: 'mdl_producto_procesos_detalle',
                sortField: "producto_procesos_detalle_id",
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
                        name: "producto_procesos_detalle_porcentaje",
                        align: 'right',
                        showGridSummary: true,
                        width: '10%'
                    }
                ],
                getCellCSSText: function(record, rowNum, colNum) {
                    if (record.producto_procesos_detalle_porcentaje < 0 || record.producto_procesos_detalle_porcentaje >100.00) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            // Dado que se requiere que la lista de productos a elegir en la forma
            // de edicion/adicion de un registro de la grilla no sea ni el producto principal
            // ni alguno ya encomponente , aprovechamos este metodo para setear el pickListCriteria
            // del campo insumo_id de la forma interna con el valor del principal.
            // El uso de optionCriteria: {insumo_id_origen: formProductoProcesos.getValue('insumo_id')} no
            // funcionaria ya que se setea estaticamente y no dinamicamente.
            //
            //childFormShow: function() {
              //gform_producto_procesos_detalle.getField('insumo_id').setOptionCriteria(isc.addProperties({}, {producto_procesos_id: formProductoProcesos.getValue('producto_procesos_id')}));
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
                        dataSource: mdl_producto_procesos_detalle,
                        addOperation: 'readAfterSaveJoined',
                        updateOperation: 'readAfterUpdateJoined',
                        formMode: this.formMode, // parametro de inicializacion
                        focusInEditFld: 'procesos_codigo',
                        //disableValidation: true,
                        fields: [
                            {
                                name: "producto_procesos_id",
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
                                //optionOperationId: 'fetchForProductoProcesosDetalle',
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
                                name: "producto_procesos_detalle_porcentaje",
                                showPending: true,
                                width: '80'
                            }
                        ]
                    });
                } else {
                    newForm = g_producto_procesos_detalle.getChildForm();
                }
                return newForm;
            }
        });
    },

    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});