/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los tipos de competencia.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:43:29 -0500 (mar, 25 mar 2014) $
 * $Rev: 109 $
 */
isc.defineClass("WinCompetenciasWindow", "WindowGridListExt");
isc.WinCompetenciasWindow.addProperties({
    ID: "winCompetenciasWindow",
    title: "Competencias",
    width: 830, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CompetenciasList",
            alternateRecordStyles: true,
            dataSource: mdl_competencias,
            autoFetchData: true,
            fetchOperation: 'fetchJoined', // solicitado un resultset con el join a atletas resuelto por eficiencia
            fields: [
                {name: "competencias_codigo", title: "Codigo", width: '12%'},
                {name: "competencias_descripcion", title: "Nombre", width: '25%'},
                {name: "competencia_tipo_descripcion", width: '12%'},
                {name: "paises_descripcion", width: "12%"},
                {name: "ciudades_descripcion", width: "12%"},
                {name: "categorias_descripcion", width: "12%"},
                {name: "agno", width: "5%"}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'competencias_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
