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
isc.defineClass("WinCostoListForm", "WindowBasicFormExt");
isc.WinCostoListForm.addProperties({
    ID: "winCostoListForm",
    title: "Mantenimiento de CostoListes",
    width: 700,
    height: 200,
    useSaveButton: false,
    titleFirstTab : 'Lista de Costos',
    efficientDetailGrid: false,
    joinKeyFields: [{
        fieldName: 'costos_list_id',
        fieldValue: ''
    }],
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCostoList",
            numCols: 4,
            colWidths: ["100", "120", "100", "*"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_costos_list,
            formMode: this.formMode, // parametro de inicializacion
            focusInEditFld: 'costos_list_descripcion',
            //   disableValidation: true,
            fields: [
                {
                    name: "costos_list_id",
                    hidden: true
                },
                {
                    name: "HeaderLabel",
                    type: 'header',
                    align: 'center'
                }
            ],
            postSetFieldsToEdit: function() {
                var record = this.getValues();
                var txt = record.costos_list_descripcion + " - (" + DateUtil.format(record.costos_list_fecha, 'dd/MM/yyyy H.ma') + " )<br/>";
                txt += "Costos Globales entre : " + DateUtil.format(record.costos_list_fecha_desde, 'dd/MM/yyyy') + " - " + DateUtil.format(record.costos_list_fecha_hasta, 'dd/MM/yyyy') + "<br/>";
                txt += "Tipo De Cambio a Fecha : " + DateUtil.format(record.costos_list_fecha_tcambio, 'dd/MM/yyyy') + "<br/>&nbsp<br/>";

                formCostoList.getField('HeaderLabel').setValue(txt);
            },

        });
    },
    canShowTheDetailGridAfterAdd: function() {
        return true;
    },
    createDetailGridContainer: function(mode) {
        return isc.DetailGridContainer.create({
            height: 300,
            sectionTitle: 'Costos',
            onlyForListGrid: true,

            gridProperties: {
                ID: 'g_costos_list_detalle',
                fetchOperation: 'fetch',
                dataSource: 'mdl_costos_list_detalle',
                sortField: "insumo_descripcion",
                autoFetchData: false,
                canRemoveRecords: false,
                //canAdd: false,
                canSort: false,
                showHeaderMenuButton: false,
                autoFitWidthApproach: "both",
                //showGridSummary: true,
                width: 680,
                fields: [
                    {name: "insumo_descripcion"},
                    {
                        name: "costos_list_detalle_qty_presentacion",
                        formatCellValue(value, record) {
                            return value + " " + record.unidad_medida_siglas;
                        }
                    },
                    {
                        name: "unidad_medida_siglas",
                        hidden: true
                    },
                    {name: "taplicacion_entries_descripcion"},
                    {name: "moneda_descripcion"},
                    {name: "costos_list_detalle_costo_base"},
                    {name: "costos_list_detalle_costo_agregado"},
                    {name: "costos_list_detalle_costo_total"},
                ],
                getCellCSSText: function(record, rowNum, colNum) {
                    if (record.costos_list_detalle_costo_base < 0 || record.costos_list_detalle_costo_agregado < 0) {
                        return "font-weight:bold; color:red;";
                    }
                }
            }
        });
    },

    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});