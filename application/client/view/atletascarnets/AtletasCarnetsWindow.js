/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las unidades de medida.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:47:11 -0500 (mar, 25 mar 2014) $
 * $Rev: 111 $
 */
isc.defineClass("WinAtletasCarnetsWindow", "WindowGridListExt");
isc.WinAtletasCarnetsWindow.addProperties({
    ID: "winAtletasCarnetsWindow",
    title: "Registro de Carnets",
    width: 550, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "AtletasCarnetsList",
            alternateRecordStyles: true,
            dataSource: mdl_atletascarnets,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {name: "atletas_nombre_completo", width: '50%'},
                {name: "atletas_carnets_agno", width: '15%'},
                {name: "atletas_carnets_numero", width: '20%'},
                {name: "atletas_carnets_fecha", width: '15%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            initialSort: [{property: 'atletas_carnets_agno', direction: 'DESC'}, {property: 'atletas_carnets_numero'}]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
