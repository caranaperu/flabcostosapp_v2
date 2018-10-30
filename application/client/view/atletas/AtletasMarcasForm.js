
/**
 * Clase que crea el pane container para el tab de informacion de resultados de un atleta.
 * implementa infoKey , onInfoKeyChanged y getInfoMember para que el TabSetExt pueda coordinar los
 * datos a mostrar con la forma principal de ingrreso de datos.
 *
 *
 * $Author: aranape $
 * $Date: 2014-06-24 03:03:08 -0500 (mar, 24 jun 2014) $
 * $Rev: 240 $
 */
isc.defineClass("AtletaMarcasForm", "VLayout");
isc.AtletaMarcasForm.addProperties({
    title: 'Marcas Personales',
    autoCenter: true,
    autoDraw: false,
    autoSize: true,
    height: 400,
    //  width: 870,
    ID: 'AtletaMarcasFormID',
    infoKey: undefined,
    /**
     * Llamada couando la llave principal indica que ha camado  en este caso
     * lo que hace es limpiar la grilla de resultados.
     */
    onInfoKeyChanged: function(formRecord) {
        atletasMarcasInfoLabel.setContents('<span style="font-weight:bold; font-size:16px">' + formRecord.atletas_nombre_completo + '</span> (' + formRecord.atletas_fecha_nacimiento.toEuropeanShortDate() + ')'
                )
        // Limpio la grilla.
        var obj = [];
        AtletasMarcasList.setData(obj);
    },
    /**
     * Requerido por TabSetExt cuando necesita refresacar la lista de pruebas.
     */
    getInfoMember: function() {
        return this.getMember('atletasMarcasContainer').getMember('AtletasPruebasMarcasList');
    },
    initWidget: function() {
        isc.Label.create({
            ID: 'atletasMarcasInfoLabel',
            height: 30,
            padding: 5,
            valign: "center",
            wrap: false,
            contents: undefined}
        );
        isc.HLayout.create({
            ID: 'atletasMarcasContainer',
            width: "100%",
            height: "100%",
            members: [
                // Lista de pruebas
                isc.ListGrid.create({
                    ID: "AtletasPruebasMarcasList",
                    width: '150px',
                    autoFetchData: false,
                    dataSource: "mdl_atletas_pruebas",
                    fetchOperation: 'fetchPruebasPorAtleta',
                    textMatchStyle: 'exact',
                    fields: [{name: "apppruebas_descripcion"}],
                    sortField: 'apppruebas_descripcion',
                    gridComponents: ["header", "body",
                        isc.ToolStrip.create({
                            width: "100%", height: 24,
                            autoDraw: false,
                            members: [
                                isc.ToolStripButton.create({
                                    icon: "[SKIN]/actions/refresh.png",
                                    prompt: "Actualizar lista",
                                    click: function() {
                                        AtletasPruebasMarcasList.invalidateCache();
                                    }
                                })
                            ]
                        })],
                    rowClick: function(record, recordNum, fieldNum) {
                        AtletasMarcasList.fetchOperation = 'fetchAtletasResultadoPrueba';
                        AtletasMarcasList.filterData(
                                {atletas_codigo: AtletaMarcasFormID.infoKey, apppruebas_codigo: record.apppruebas_codigo}, undefined,
                                {textMatchStyle: 'exact'}
                        );
                    }
                }),
                // Lista de marcas
                isc.ListGrid.create({
                    autoDraw: false,
                    ID: "AtletasMarcasList",
                    dataSource: "mdl_atletasmarcas",
                    showHeaderMenuButton: false,
                    showHeaderContextMenu: false,
                    autoFetchData: false,
                    alternateRecordStyles: true,
                    dataPageSize: 25,
                    canReorderFields: false,
                    showFilterEditor: true,
                    sortField: 'competencias_pruebas_fecha',
                    sortDirection: 'descending',
                    gridComponents: ["header", "filterEditor", "body",
                        isc.ToolStrip.create({
                            width: "100%", height: 24,
                            autoDraw: false,
                            members: [
                                isc.ToolStripButton.create({
                                    icon: "[SKIN]/actions/refresh.png",
                                    prompt: "Actualizar lista",
                                    click: function() {
                                        AtletasMarcasList.invalidateCache();
                                    }
                                })
                            ]
                        })],
                    fields: [
                        {name: "serie", width: '8%'},
                        {name: "atletas_resultados_resultado", width: '10%', align: 'right',
                            // Internamente el campo que se debe usar para ordenar los resultados
                            // es el campo norm_resultado.
                            sortNormalizer: function(record) {
                                return record.norm_resultado;
                            }},
                        {name: "competencias_pruebas_viento", width: '8%', align: 'right'},
                        {name: "obs", width: '10%'},
                        {name: "categorias_codigo", width: '8%'},
                        {name: "pruebas_record_hasta", width: '8%'},
                        {name: "competencias_pruebas_fecha", width: '12%', align: 'right'},
                        {name: "lugar", width: '36%'}
                    ],
                    getCellCSSText: function(record, rowNum, colNum) {
                        var style = 'font-style:normal;';
                        if (record.origen === 'C') {
                            style = 'font-style:italic;'
                        }

                        if (record.obs != '-----') {
                            style += 'color:red;'
                        }
                        return style;
                    },
                    canExpandRecords: true,
                    canExpandRecordProperty: 'apppruebas_multiple',
                    expansionMode: "related",
                    detailDS: "mdl_atletasmarcas_detalle",
                    expansionRelatedProperties: {
                        height: '220',
                        alternateRecordStyles: true,
                        fetchOperation: 'fetchDetalleForPrueba',
                        sortField: 'pruebas_detalle_orden',
                        canReorderFields: false,
                        showHeaderMenuButton: false,
                        showHeaderContextMenu: false,
                        fields: [
                            {name: 'pruebas_descripcion', width: '*'},
                            {name: 'competencias_pruebas_fecha', width: '15%'},
                            {name: 'atletas_resultados_resultado', align: 'right', width: '15%'},
                            {name: 'competencias_pruebas_viento', width: '15%'},
                            {name: 'obs', width: '10%'},
                            {name: 'atletas_resultados_puntos', width: '15%'}
                        ]
                    }
                })
            ]
        });

        this.Super("initWidget", arguments);

        this.addMember(atletasMarcasInfoLabel);
        this.addMember(atletasMarcasContainer);

        AtletasPruebasMarcasList.filterData({atletas_codigo: this.infoKey});
    }
});