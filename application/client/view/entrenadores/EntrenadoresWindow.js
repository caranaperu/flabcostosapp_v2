/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los registros de Personals.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinEntrenadoresWindow", "WindowGridListExt");
isc.WinEntrenadoresWindow.addProperties({
    ID: "winEntrenadoresWindow",
    title: "Entrenadores",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "EntrenadoresList",
            alternateRecordStyles: true,
            dataSource: mdl_entrenadores,
            autoFetchData: true,
            dataPageSize: 40,
             // Estos 2 permiten que solo se lea lo que el tamaño de la pagina indica
            drawAheadRatio: 1,
            drawAllMaxCells: 0,
            fields: [
                {name: "entrenadores_codigo", width: '10%'},
                {name: "entrenadores_nombre_completo", width: '65%'},
                {name: "entrenadores_nivel_codigo", width: '25%', type: "selectExt",
                    optionDataSource: mdl_entrenadores_nivel, valueField: 'entrenadores_nivel_codigo',
                    displayField: 'entrenadores_nivel_descripcion', pickListWidth: 200}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            autoFitWidthApproach: 'both'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
