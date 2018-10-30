/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los tipos de competencia.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:42:48 -0500 (mar, 25 mar 2014) $
 * $Rev: 108 $
 */
isc.defineClass("WinCompetenciaTipoWindow", "WindowGridListExt");
isc.WinCompetenciaTipoWindow.addProperties({
    ID: "winCompetenciaTipoWindow",
    title: "Tipos De Competencia",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CompetenciaTipoList",
            alternateRecordStyles: true,
            dataSource: mdl_competencia_tipo,
            autoFetchData: true,
            fields: [
                {name: "competencia_tipo_codigo", title: "Codigo", width: '25%'},
                {name: "competencia_tipo_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'competencia_tipo_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
