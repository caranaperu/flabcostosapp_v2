/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los insumos
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinInsumoWindow", "WindowGridListExt");
isc.WinInsumoWindow.addProperties({
    ID: "winInsumoWindow",
    title: "Insumos",
    width: 840,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "InsumoList",
            alternateRecordStyles: true,
            dataSource: mdl_insumo,
            fetchOperation: 'fetchJoined',
            autoFetchData: true,
            fields: [
                //{name: "insumo_codigo",width: '10%'},
                {name: "insumo_descripcion", width: '20%'},
                {name: "tcostos_descripcion", width: '10%'},
                {name: "tinsumo_descripcion", width: '12%'},
                {name: "unidad_medida_descripcion_ingreso", width: '10%'},
                {
                    name: "insumo_merma", align: 'right', width: '8%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                },
                {name: "unidad_medida_descripcion_costo", width: '12%'},
                {name: "moneda_descripcion", width: '10%'},
                {
                    name: "insumo_costo", align: 'right', width: '8%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                },
                {
                    name: "insumo_precio_mercado", align: 'right', width: '8%',
                    filterEditorProperties: {
                        operator: "equals",
                        type: 'float'
                    }
                }
            ],
            initialCriteria: {
                _constructor: "AdvancedCriteria",
                operator: "and",
                criteria: [{
                    fieldName: 'insumo_tipo',
                    value: 'IN',
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
