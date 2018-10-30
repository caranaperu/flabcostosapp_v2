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
isc.defineClass("WinCotizacionForm", "WindowBasicFormExt");
isc.WinCotizacionForm.addProperties({
    ID: "winCotizacionForm",
    title: "Mantenimiento de Cotizaciones",
    width: 700,
    height: 200,
    efficientDetailGrid: false,
    joinKeyFields: [{
        fieldName: 'cotizacion_id',
        fieldValue: ''
    }],
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCotizacion",
            numCols: 4,
            colWidths: ["100", "120", "100", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_cotizacion,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['cotizacion_numero', 'cotizacion_fecha'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'moneda_codigo',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
         //   disableValidation: true,
            fields: [
                {
                    name: "cotizacion_id",
                    hidden: true
                },
                {
                    name: "empresa_id",
                    hidden: true,
                    defaultValue: glb_empresaId
                },
                {
                    name: "cotizacion_numero",
                    canEdit: false,
                    showPending: true,
                    width: "85"
                },
                {
                    name: "cotizacion_fecha",
                    showPending: true,
                    // length: 60,
                    width: "220"
                },
                {
                    name: "moneda_codigo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "moneda_codigo",
                    displayField: "moneda_descripcion",
                    optionDataSource: mdl_moneda,
                    pickListFields: [{
                        name: "moneda_codigo",
                        width: '30%'
                    }, {
                        name: "moneda_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'moneda_descripcion'}],
                    startRow: true
                },
                {
                    name: "cliente_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "240",
                    valueField: "cliente_id",
                    displayField: "cliente_razon_social",
                    optionDataSource: mdl_cliente_cotizacion,
                    optionOperationId: 'fetchForCotizacion',
                    pickListFields: [{
                        name: "cliente_razon_social"
                    }, {name: "tipo_empresa_codigo"}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    pickListCriteria: {empresa_id: glb_empresaId},
                    startRow: true,
                    changed: function(form, item, value) {
                        var record = item.getSelectedRecord();
                        if (record) {
                            if (record.tipo_empresa_codigo !== 'CLI') {
                                form.getItem('cotizacion_es_cliente_real').setValue(false);
                            } else {
                                form.getItem('cotizacion_es_cliente_real').setValue(true);
                            }
                        } else {
                            form.getItem('cotizacion_es_cliente_real').setValue(undefined);
                        }
                    }
                },
                {
                    name: "cotizacion_cerrada",
                    showPending: true,
                    defaultValue: false,
                    setValue: function(value) {
                        if (value == true) {
                            this.title = 'Cerrada';
                        } else {
                            this.title = 'Abierta';
                        }
                        this.Super('setValue', arguments);
                    }
                },
                {
                    name: "cotizacion_es_cliente_real",
                    hidden: true
                }
            ],
            /**
             * Override para aprovecha que solo en modo add se blanqueen todas las variables de cache y el estado
             * de los campos a su modo inicial o default.
             *
             * @param {string} mode 'add' o 'edit'
             */
            setEditMode: function(mode) {
                this.Super("setEditMode", arguments);
                if (mode == 'add') {
                    formCotizacion.getField('cotizacion_numero').setRequired(false);
                    formCotizacion.getField('moneda_codigo').enable();
                    formCotizacion.getField('cliente_id').enable();
                    formCotizacion.getField('cotizacion_cerrada').enable();
                } else {
                    formCotizacion.getField('cotizacion_numero').setRequired(true);
                }
            },
            /**
             * IMPORTANTE:
             * Aqui se usa la capacidad de los combobox de utilizar como parte de su criteria lo que viene especificado
             * en optionCriteria . dado que en este caso particular al editarse un registro como parte del combo client_id
             * este solo envia client_id al servidor , pero dado que en realidad ese id puede ser de un cliente o una empresa
             * requerimos indicarle de que tipo es, para esto usamos el campo cotizacion_es_cliente_real del registro principal
             *
             * Este campo es adicionado a optioCriteria ya que de esta manera logramos que sea enviado al servidor y
             * el lado servidor sepa de que tabla buscar.
             *
             * Este truco puede servir para cualquier caso que se requiera enviar datos adicionales durante la edicion de
             * un registro sin cambiar en nada el comportamiento del framework cliente.
             *
             * Importante : usar setOptionCriteria() no optionCriteria= ya que no funcionaria.
             *
             * @param component
             */
            editSelectedData: function(component) {
                var fieldCliente = formCotizacion.getField('cliente_id');
                var origCriteria = isc.clone(fieldCliente.optionCriteria);

                // cliente_id es automatico
                fieldCliente.setOptionCriteria(isc.addProperties({}, {"cotizacion_es_cliente_real": component.getSelectedRecord().cotizacion_es_cliente_real}));
                this.Super('editSelectedData', arguments);

                // retornamos el valor original
                fieldCliente.setOptionCriteria(isc.clone(origCriteria));

                var record = component.getSelectedRecord();
                if (record && record.cotizacion_cerrada == true) {
                    formCotizacion.getField('moneda_codigo').disable();
                    formCotizacion.getField('cliente_id').disable();
                    formCotizacion.getField('cotizacion_cerrada').disable();
                } else {
                    formCotizacion.getField('moneda_codigo').enable();
                    formCotizacion.getField('cliente_id').enable();
                    formCotizacion.getField('cotizacion_cerrada').enable();
                }
            }
        });
    },
    canShowTheDetailGridAfterAdd: function() {
        return true;
    },
    createDetailGridContainer: function(mode) {
        return isc.DetailGridContainer.create({
            height: 300,
            sectionTitle: 'Productos',
            gridProperties: {
                ID: 'g_cotizacion_detalle',
                fetchOperation: 'fetchJoined',
                dataSource: 'mdl_cotizaciondetalle',
                sortField: "cotizacion_detalle_id",
                autoFetchData: false,
                canRemoveRecords: true,
                canAdd: true,
                canSort: false,
                showHeaderMenuButton: false,
                showGridSummary: true,
                width: 680,
                fields: [
                    {
                        name: "insumo_descripcion",
                        width: '30%'
                    }, {
                        name: "cotizacion_detalle_cantidad",
                        align: 'right',
                        showGridSummary: false,
                        width: '10%'
                    }, {
                        name: "unidad_medida_descripcion",
                        width: '15%'
                    }, {
                        name: "cotizacion_detalle_precio",
                        align: 'right',
                        showGridSummary: false
                    }, {
                        name: "cotizacion_detalle_total",
                        align: 'right',
                        showGridSummary: true
                    }
                ],
                getCellCSSText: function(record, rowNum, colNum) {
                    if (record.cotizacion_detalle_total < 0) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            // Dado que se requiere que la lista de productos a elegir en la forma
            // de edicion/adicion de un registro de la grilla no sea ni el producto principal
            // ni alguno ya encomponente , aprovechamos este metodo para setear el pickListCriteria
            // del campo insumo_id de la forma interna con el valor del principal.
            // El uso de optionCriteria: {insumo_id_origen: formCotizacion.getValue('insumo_id')} no
            // funcionaria ya que se setea estaticamente y no dinamicamente.
            //
            childFormShow: function() {
              gform_cotizacion_detalle.getField('insumo_id').setOptionCriteria(isc.addProperties({}, {cotizacion_id: formCotizacion.getValue('cotizacion_id')}));

                this.Super("childFormShow", arguments);
            },
            getFormComponent: function() {
                var newForm;
                if (this.getChildForm() == undefined) {
                    newForm = isc.DynamicFormExt.create({
                        ID: "gform_cotizacion_detalle",
                        numCols: 4,
                        colWidths: ["80", "120", "*", "*"],
                        titleWidth: 100,
                        fixedColWidths: false,
                        padding: 5,
                        dataSource: mdl_cotizaciondetalle,
                        addOperation: 'readAfterSaveJoined',
                        updateOperation: 'readAfterUpdateJoined',
                        formMode: this.formMode, // parametro de inicializacion
                        focusInEditFld: 'insumo_id',
                        fields: [
                            {
                                name: "cotizacion_id",
                                hidden: true
                            },
                            {
                                name: "insumo_id",
                                editorType: "comboBoxExt",
                                showPending: true,
                                width: 180,
                                valueField: "insumo_id",
                                displayField: "insumo_descripcion",
                                optionDataSource: mdl_producto_cotizacion_detalle,
                                optionOperationId: 'fetchForCotizacionDetalle',
                                pickListFields: [
                                    {
                                        name: "insumo_codigo"
                                    }, {
                                        name: "insumo_descripcion"
                                    }, {
                                        name: 'unidad_medida_descripcion'
                                    }, {
                                        name: 'moneda_simbolo', title: ' '
                                    }, {
                                        name: 'precio_original', align: 'right'
                                    }, {
                                        name: 'precio_cotizar', align: 'right'
                                    }],
                                cachePickListResults: false,
                                filterLocally: false,
                                pickListWidth: 420,
                                completeOnTab: true,
                                // Solo es pasado al servidor si no existe cache data all en el modelo
                                // de lo contrario el sort se hace en el lado cliente.
                                initialSort: [{property: 'insumo_descripcion'}],
                                changed: function(form, item, value) {
                                    var record = item.getSelectedRecord();
                                    if (record) {
                                        form.getItem('unidad_medida_codigo').setValue(record.unidad_medida_codigo);
                                        form.getItem('unidad_medida_descripcion').setValue(record.unidad_medida_descripcion);
                                        form.getItem('cotizacion_detalle_precio').setValue(record.precio_cotizar);

                                    } else {
                                        form.getItem('unidad_medida_codigo').setValue('NING');
                                        form.getItem('unidad_medida_descripcion').setValue(undefined);
                                        form.getItem('cotizacion_detalle_precio').setValue(0.00);
                                    }
                                    form.getItem('cotizacion_detalle_total').calculateTotal();
                                }
                            },
                            {
                                name: "cotizacion_detalle_cantidad",
                                showPending: true,
                                width: '80',
                                startRow: true,
                                changed: function(form,item,value) {
                                    form.getItem('cotizacion_detalle_total').calculateTotal();
                                }
                            },
                            {
                                name: "unidad_medida_codigo", hidden: true
                            },
                            {
                                name: "unidad_medida_descripcion",
                                hidden: true
                            },
                            {
                                name: "cotizacion_detalle_precio",
                                canEdit: false,
                                readOnlyDisplay:"static",
                                showPending: true,
                                canFocus: false,
                                setValue: function(value) {
                                    var ntitle = this.getTitle();
                                    if (ntitle.indexOf(" x ") > 0) {
                                        ntitle = ntitle.substring(0, ntitle.indexOf(" x "));
                                    }
                                    if (value) {
                                        ntitle += ' x ' + gform_cotizacion_detalle.getItem('unidad_medida_descripcion').getValue();
                                    }
                                    this.title = ntitle;
                                    this.Super('setValue', arguments);
                                }
                            },
                            {
                                name: "cotizacion_detalle_total",
                                showPending: true,
                                width: '80',
                                canEdit: false,
                                canFocus: false,
                                readOnlyDisplay:"static",
                                calculateTotal: function() {
                                    var value = gform_cotizacion_detalle.getItem('cotizacion_detalle_cantidad').getValue()*gform_cotizacion_detalle.getItem('cotizacion_detalle_precio').getValue();
                                    this.setValue(value.toFixed(2));
                                }
                            }
                        ]
                        // , cellBorder: 1
                    });
                } else {
                    newForm = g_cotizacion_detalle.getChildForm();
                }
                return newForm;
            }
        });
    },

    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});