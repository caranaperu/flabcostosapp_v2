/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las reglas de costos entre empresas.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinReglasWindow", "WindowGridListExt");
isc.WinReglasWindow.addProperties({
    ID: "winReglasWindow",
    title: "Reglas",
    width: 520, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ReglasList",
            alternateRecordStyles: true,
            dataSource: mdl_reglas,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {name: "empresa_razon_social_o",  width: '35%'},
                {name: "empresa_razon_social_d",  width: '35%'},
                {name: "regla_by_costo",
                    filterOperator: 'equals',
                    width: '15%'},
                {name: "regla_porcentaje",  width: '15%',filterOperator: 'equals'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'empresa_razon_social_o'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
