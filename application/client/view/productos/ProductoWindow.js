/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los insumos
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinProductoWindow", "WindowGridListExt");
isc.WinProductoWindow.addProperties({
    ID: "winProductoWindow",
    title: "Productos",
    width: 800,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ProductoList",
            alternateRecordStyles: true,
            dataSource: mdl_producto,
            autoFetchData: true,
            fields: [
                {
                    name: "insumo_codigo",
                    width: '10%'
                },
                {
                    name: "insumo_descripcion",
                    width: '18%'
                },
                {
                    name: "insumo_merma",
                    align: 'right',
                    width: '8%',
                    filterEditorProperties: {
                        operator: "equals"
                    }
                },
                {
                    name: "unidad_medida_descripcion_costo",
                    width: '10%'
                },
                {
                    name: "moneda_descripcion",
                    width: '10%'
                },
                {
                    name: "insumo_costo",
                    align: 'right',
                    width: '8%',
                    filterOperator: "equals"
                },
                {
                    name: "insumo_precio_mercado", align: 'right', width: '8%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                }
            ],
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.insumo_costo < 0) {
                    return "font-weight:bold; color:red;";
                }
            },
            initialCriteria: {
                _constructor: "AdvancedCriteria",
                operator: "and",
                criteria: [{
                    fieldName: 'insumo_tipo',
                    value: 'PR',
                    operator: 'equals'
                }, {
                    fieldName: 'empresa_id',
                    value: glb_empresaId,
                    operator: 'equals'
                }]
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'insumo_descripcion'

        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
