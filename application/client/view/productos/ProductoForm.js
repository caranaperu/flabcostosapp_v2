/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los productos y aua items.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinProductoForm", "WindowBasicFormExt");
isc.WinProductoForm.addProperties({
    ID: "winProductoForm",
    title: "Mantenimiento de Productos",
    width: 700,
    height: 245,
    efficientDetailGrid: false,
    joinKeyFields: [{
        fieldName: 'insumo_id',
        fieldValue: '',
        mapTo: 'insumo_id_origen'
    }],
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formProducto",
            numCols: 4,
            colWidths: ["100", "120", "100", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_producto,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['insumo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'insumo_descripcion',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
            fields: [
                {
                    name: "insumo_id",
                    hidden: true
                },
                {
                    name: "empresa_id",
                    hidden: true,
                    defaultValue: glb_empresaId
                },
                {
                    name: "insumo_tipo",
                    defaultValue: "PR",
                    hidden: true
                },
                {
                    name: "insumo_codigo",
                    type: "text",
                    showPending: true,
                    width: "85",
                    mask: ">LLLLLLLLLL"
                },
                {
                    name: "insumo_descripcion",
                    showPending: true,
                    length: 60,
                    width: "220"
                },
                {
                    name: "insumo_merma",
                    showPending: true,
                    width: '80'
                },
                {
                    name: "producto_separator_01",
                    defaultValue: "Costo",
                    type: "section",
                    colSpan: 4,
                    width: "*",
                    canCollapse: false,
                    align: 'center',
                    itemIds: ["unidad_medida_codigo_costo", "moneda_codigo_costo"]
                },
                {
                    name: "unidad_medida_codigo_costo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "unidad_medida_codigo",
                    displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{
                        name: "unidad_medida_codigo",
                        width: '30%'
                    }, {
                        name: "unidad_medida_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'unidad_medida_descripcion'}],
                    startRow: true
                },
                {
                    name: "moneda_codigo_costo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "140",
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
                    initialSort: [{property: 'moneda_descripcion'}]
                },
                {name: "insumo_precio_mercado", showPending: true, width: '80'
                 //   visibleWhen: {tcostos_indirecto: false}
                }
            ]
            //, cellBorder: 1
        });
    },
    canShowTheDetailGridAfterAdd: function() {
        return true;
    },
    createDetailGridContainer: function(mode) {
        return isc.DetailGridContainer.create({
            height: 300,
            sectionTitle: 'Componentes',
            gridProperties: {
                ID: 'g_productos_detalle',
                fetchOperation: 'fetchJoined',
                dataSource: 'mdl_productodetalle',
                sortField: "producto_detalle_id",
                autoFetchData: false,
                canRemoveRecords: true,
                canAdd: true,
                canSort: false,
                showHeaderMenuButton: false,
                showGridSummary: true,
                groupByField: "tcostos_indirecto",
                groupStartOpen: "all",
                showGroupSummary: true,
                showGroupSummaryInHeader: true,
                width: 700,
                fields: [
                    {
                        name: "empresa_razon_social",
                        width: '20%'
                    },
                    {
                        name: "insumo_descripcion",
                        width: '20%'
                    }, {
                        name: "unidad_medida_descripcion",
                        showGridSummary: false,
                        showGroupSummary: false
                    }, {
                        name: "producto_detalle_cantidad",
                        align: 'right',
                        width: '10%',
                        showGridSummary: false,
                        showGroupSummary: false
                    }, {
                        name: "producto_detalle_valor",
                        align: 'right',
                        showGridSummary: false,
                        showGroupSummary: false,
                        formatCellValue: function(value, record) {
                            if (record) {
                                value = record.moneda_simbolo + ' ' + value;
                            }
                            return value;
                        }
                    }, {
                        name: "producto_detalle_merma",
                        align: 'right',
                        width: '10%',
                        showGridSummary: false,
                        showGroupSummary: false
                    }, {
                        name: "producto_detalle_costo",
                        align: 'right',
                        showGridSummary: true,
                        summaryFunction: 'sum'
                    },
                    {
                        name: "tcostos_indirecto",
                        hidden: true,
                        getGroupTitle: function(groupValue, groupNode, field, fieldName, grid) {
                            if (groupValue == true) {
                                return 'Ind';
                            } else {
                                return 'Dir';
                            }
                        }
                    }],
                getCellCSSText: function(record, rowNum, colNum) {
                    if (record.producto_detalle_costo < 0) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            // Dado que se requiere que la lista de insumos/productos a elegir en la forma
            // de edicion/adicion de un registro de la grilla no sea ni el producto principal
            // ni alguno ya encomponente , aprovechamos este metodo para setear el pickListCriteria
            // del campo insumo_id de la forma interna con el valor del principal.
            // El uso de optionCriteria: {insumo_id_origen: formProducto.getValue('insumo_id')} no
            // funcionaria ya que se setea estaticamente y no dinamicamente.
            //
            // Asi mismo seteamos _canFetchInsumos = true lo cual habilita que forzemos la relevtura de los insumos o productos
            // que se pueden agregar como items , esto es necesario ya que luego de un ins/prod es usado como un item este no puede
            // aparecer nuevamente como sleleccionable para agregar, este falg es usado por el campo insumo_id de la forma de edicion
            // de items de la grilla.
            childFormShow: function() {
                gform_productos_detalle.getField('insumo_id').pickListCriteria = {insumo_id_origen: formProducto.getValue('insumo_id')};
                gform_productos_detalle._canFetchInsumos = true;
                this.Super("childFormShow", arguments);
            },
            getFormComponent: function() {
                var newForm;
                if (this.getChildForm() == undefined) {
                    newForm = isc.DynamicFormExt.create({
                        ID: "gform_productos_detalle",
                        numCols: 4,
                        colWidths: ["80", "120", "*", "*"],
                        titleWidth: 100,
                        fixedColWidths: false,
                        padding: 5,
                        dataSource: mdl_productodetalle,
                        addOperation: 'readAfterSaveJoined',
                        updateOperation: 'readAfterUpdateJoined',
                        formMode: this.formMode, // parametro de inicializacion
                        focusInEditFld: 'insumo_id',
                        _canFetchInsumos: true, // para forzar o no la relectura del combo de insumo_id de esta forma.
                        fields: [
                            {
                                name: "insumo_id_origen",
                                hidden: true
                            },
                            {
                                name: "moneda_simbolo",
                                hidden: true
                            },
                            {
                                name: "empresa_id",
                                hidden: true
                            },
                            {
                                name: "insumo_id",
                                editorType: "comboBoxExt",
                                showPending: true,
                                width: 180,
                                valueField: "insumo_id",
                                displayField: "insumo_descripcion",
                                optionDataSource: mdl_insumo_producto_detalle,
                                optionOperationId: 'fetchForProductoDetalle',
                                pickListFields: [
                                    {
                                        name: "insumo_codigo",
                                        width: '20%'
                                    }, {
                                        name: "insumo_descripcion",
                                        width: '40%'
                                    }, {
                                        name: 'empresa_razon_social',
                                        width: '40%'
                                    }],
                                useClientFiltering: false,
                                cachePickListResults: false,
                                filterLocally: false,
                                pickListWidth: 350,
                                completeOnTab: true,
                                pickListProperties: {
                                    getCellCSSText: function(record, rowNum, colNum) {
                                        if (record.insumo_tipo === 'IN') {
                                            return "font-weight:bold; color:blue;";
                                        }
                                    },
                                    dataProperties: {useClientFiltering: false}
                                },
                                // Para forzar de ser necesario la relectura de los items del combo.
                                showPicker: function() {
                                    // Si el flag _canFetchInsumos  esta encendido hacemos fetchData y lo
                                    // apagamos para evitar relecturas inutiles mientras aun se edita el mismo item.
                                    if (gform_productos_detalle._canFetchInsumos === true) {
                                        this.fetchData();
                                    }
                                    // Luego de la relectura apagamos el flag.
                                    gform_productos_detalle._canFetchInsumos = false;
                                    this.Super('showPicker', arguments);
                                },
                                change: function(form, item, value, oldValue) {
                                    // Validacion de componente no puede ser el principal.
                                    if (value == formProducto.getField('insumo_id').getValue()) {
                                        isc.say('El producto principal no puede ser un componente');
                                        return false;
                                    }
                                    return true;
                                },
                                changed: function(form, item, value) {
                                    var record = item.getSelectedRecord();
                                    if (record) {
                                        form.getItem('tcostos_indirecto').setValue(record.tcostos_indirecto);
                                        form.getItem('empresa_id').setValue(record.empresa_id);
                                        if (record.tcostos_indirecto == true) {
                                            form.getItem('unidad_medida_codigo').setValue('NING');
                                            form.getItem('producto_detalle_merma').setValue(0.00);
                                            // form.getItem('producto_detalle_valor').setCanEdit(true);

                                        } else {
                                            form.getItem('unidad_medida_codigo').setValue(record.unidad_medida_codigo_costo);
                                            form.getItem('producto_detalle_merma').setValue(record.insumo_merma);
                                            // form.getItem('producto_detalle_valor').setCanEdit(false);

                                        }
                                        form.getItem('moneda_simbolo').setValue(record.moneda_simbolo);
                                        form.getItem('producto_detalle_valor').setValue(record.insumo_costo);
                                    } else {
                                        form.getItem('empresa_id').setValue(-1);
                                        form.getItem('unidad_medida_codigo').setValue('NING');
                                        form.getItem('producto_detalle_merma').setValue(0.00);
                                        form.getItem('tcostos_indirecto').setValue(false);
                                        form.getItem('moneda_simbolo').setValue(undefined);
                                        form.getItem('producto_detalle_valor').setValue(undefined);
                                        //form.getItem('producto_detalle_valor').setCanEdit(false);

                                    }
                                }
                            }, {
                                name: "unidad_medida_codigo",
                                editorType: "comboBoxExt",
                                showPending: true,
                                width: "120",
                                valueField: "unidad_medida_codigo",
                                displayField: "unidad_medida_descripcion",
                                optionDataSource: mdl_unidadmedida,
                                pickListFields: [{
                                    name: "unidad_medida_codigo",
                                    width: '30%'
                                }, {
                                    name: "unidad_medida_descripcion",
                                    width: '70%'
                                }],
                                pickListWidth: 260,
                                completeOnTab: true,
                                // Solo es pasado al servidor si no existe cache data all en el modelo
                                // de lo contrario el sort se hace en el lado cliente.
                                initialSort: [{property: 'unidad_medida_descripcion'}],
                                visibleWhen: {tcostos_indirecto: false}
                            },
                            {
                                name: "producto_detalle_cantidad",
                                showPending: true,
                                width: '80',
                                startRow: true
                            },
                            {
                                name: "producto_detalle_valor",
                                showPending: true,
                                width: '80',
                                canEdit: false,
                                // Override para cambiar el tipo de moneda al titulo del campo
                                // de acuerdo a la moneda de costo del insumo.
                                setValue: function(value) {
                                    var ntitle = 'Valor';
                                    if (value) {
                                        ntitle += ' (' + gform_productos_detalle.getItem('moneda_simbolo').getValue() + ')';
                                    }
                                    this.title = ntitle;
                                    this.Super('setValue', arguments);
                                }
                            },
                            {
                                name: "producto_detalle_merma",
                                showPending: true,
                                width: '80',
                                visibleWhen: {tcostos_indirecto: false}
                            },
                            {
                                name: "tcostos_indirecto",
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
                                //  this.getItem('producto_detalle_valor').setCanEdit(false);
                            }
                        },
                        editSelectedData: function(component) {
                            this.Super("editSelectedData", arguments);
                            //  var record = component.getSelectedRecord();
                            //  this.getItem('producto_detalle_valor').setCanEdit(record.tcostos_indirecto);

                        },
                        // Luego de agregarse un item debemos encender el flag _canFetchInsumos a true ya que la siguiente
                        // vez que se pique un insumoproducto a agregarse como item hay que releer ya que no queremos que
                        // se muestre el recien agregado, Recordar que en modo add esta forma no se cierra en el modo
                        // update la forma se cierra por ende no es necesario hacerlo aqui si no cuando la forma se
                        // abra nevamente  (show).
                        afterDetailGridRecordSaved: function(listControl, rowNum, colNum, newValues, oldValues) {
                            if (this.formMode == 'add') {
                                gform_productos_detalle._canFetchInsumos = true;
                            }

                            // Dado que los valores de las pruebas individuales cambian el total de los puntos de la prueba
                            // y asi mismo pueden introducir observaciones , leemos el registro principal en edicion
                            // para actualizar los datos en la grilla principal y se reflejen los cambios infdirectos
                            // que pueden ocasionarse en las pruebas individuales.
                            /*    var searchCriteria = {
                             insumo_id: formProducto.getValue('insumo_id')
                             };
                             formProducto.filterData(searchCriteria, function(dsResponse, data, dsRequest) {
                             if (dsResponse.status === 0) {
                             // aprovechamos el mismo ds response pero le cambiamos el tipo de operacion
                             // este update caches actualiza tanto la forma como la grilla (ambos comparten
                             // el mismo modelo).
                             dsResponse.operationType = 'update';
                             DataSource.get(mdl_producto).updateCaches(dsResponse);
                             }
                             }, {
                             operationId: 'fetchJoined',
                             textMatchStyle: 'exact'
                             });*/

                        }
                        // , cellBorder: 1
                    });
                } else {
                    newForm = g_productos_detalle.getChildForm();
                }
                return newForm;
            }
        });
    },
    /**
     * Metodo llamado durante de la inicializacion de la clase
     * para si se desea agregar mas tabs a la pantalla principal
     * para esto eso debe hacerse en un override de este metodo.
     *
     * Observese que el TabSet es del tipo TabSetExt el cual soporta el metodo
     * addAditionalTab.
     *
     * @param isc.TabSetExt tabset El tab set principal al cual agregar.
     */
    addAdditionalTabs: function (tabset) {
        tabset.addAdditionalTab({
            ID: 'TabInfoCostosHistoricosFormProducto',
            title: 'Historico de Costos',
            paneClass: 'InsumoCostosHistoricosForm',
            joinField: 'insumo_id'
        });

        tabset.addAdditionalTab({
            ID: 'TabInfoUsedByFormProducto',
            title: 'Usado Por',
            paneClass: 'InsumoUsedByForm',
            joinField: 'insumo_id'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});