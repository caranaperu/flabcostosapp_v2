/**
 * Clase que crea el pane container para el tab de informacion de resultados de un atleta.
 * implementa infoKey , onInfoKeyChanged y getInfoMember para que el TabSetExt pueda coordinar los
 * datos a mostrar con la forma principal de ingrreso de datos.
 *
 *
 * $Author: aranape $
 * $Date: 2014-06-24 02:44:24 -0500 (mar, 24 jun 2014) $
 * $Rev: 234 $
 */
isc.defineClass("CompetenciasResultadosForm", "VLayout", "IControlledCanvas");
isc.CompetenciasResultadosForm.addProperties({
    title: 'Marcas Personales',
    autoCenter: true,
    autoDraw: false,
    autoSize: true,
    height: 400,
    ID: 'CompetenciasResultadosFormID',
    infoKey: undefined,
    // Para cache solamente y pasarlo a otras vistas
    _vcache_competencias_fecha_inicio: undefined,
    _vcache_competencias_fecha_final: undefined,
    /**
     * Este metodo es llamado por el controller cuando en la forma de mantenimiento , en la
     * grilla de detalle , de existir ha ocurrido una operacion sobre alguno de sus registros.
     */
    afterFormDetailGridRecordSaved: function (newValues, oldValues) {
        competenciasResultadosList.invalidateCache();


    },
    /**
     * Este metodo es llamado por el controller cuando en la forma de mantenimiento se agrega o modifica un registro.
     */
    afterFormRecordSaved: function (newValues, oldValues) {
        competenciasResultadosList.setCriteria({
            competencias_codigo: CompetenciasResultadosFormID.infoKey,
            pruebas_codigo: newValues.pruebas_codigo,
            pruebas_sexo: newValues.pruebas_sexo,
            serie: newValues.serie,
            origen: (newValues.competencias_pruebas_origen_id > 0 ? 'C' : 'D')
        });
        competenciasResultadosList.invalidateCache();
    },
    /**
     * Llamada couando la llave principal indica que ha camado  en este caso
     * lo que hace es limpiar la grilla de resultados.
     */
    onInfoKeyChanged: function (formRecord) {
        //  _vcache_sourceRecord = formRecord;
        var infLabelContents = '<span style="font-weight:bold; font-size:16px">' + formRecord.competencias_descripcion + '</span> (' + formRecord.categorias_codigo + ' / ' + formRecord.agno + ' / ' + formRecord.ciudades_descripcion + '-' + formRecord.paises_descripcion + ')';
        competenciasResultadosInfoLabel.setContents(infLabelContents);
        // Limpio la grilla.
        var obj = [];
        competenciasResultadosList.setData(obj);
        competenciasPruebasList.groupTree.closeAll();

        // Guardo las variables de cache a pasar a otra vista.
        CompetenciasResultadosFormID._vcache_competencias_fecha_inicio = formRecord.competencias_fecha_inicio;
        CompetenciasResultadosFormID._vcache_competencias_fecha_final = formRecord.competencias_fecha_final;

    },
    /**
     * En este caso la forma
     */
    getRequiredFieldsToAddOrEdit: function (mode) {
        // La vista que agrega pruebas requiere datos de la competencia, se los retorna.
        //return _vcache_sourceRecord;
        return {
            competencias_codigo: this.infoKey,
            competencias_descripcion_visual: competenciasResultadosInfoLabel.getContents(),
            competencias_fecha_inicio: CompetenciasResultadosFormID._vcache_competencias_fecha_inicio,
            competencias_fecha_final: CompetenciasResultadosFormID._vcache_competencias_fecha_final
        };
    },
    /**
     * Requerido por TabSetExt cuando necesita refresacar la lista de pruebas.
     */
    getInfoMember: function () {
        return this.getMember('competenciasResultadosContainer').getMember('competenciasPruebasList');
    },
    createGridList: function () {
        return isc.ListGrid.create({
            ID: "competenciasPruebasList",
            width: '260px',
            autoFetchData: false,
            dataSource: mdl_competencias_pruebas,
            fetchOperation: 'fetchPruebasPorCompetencia',
            lastComptenciaPruebaVisitedId: undefined,
            fields: [
                {
                    name: 'competencias_pruebas_id',
                    hidden: true
                },
                {
                    name: "pruebas_sexo",
                    hidden: true,
                    getGroupValue: function (value, record, field, fieldName, grid) {
                        if (value == 'F') {
                            return "Damas";
                        } else {
                            return "Varones";
                        }
                    }
                },
                {
                    name: "pruebas_generica_codigo",
                    hidden: true,
                    getGroupValue: function (value, record, field, fieldName, grid) {
                        return record.apppruebas_descripcion;
                    }
                },
                {
                    name: "pruebas_descripcion",
                    width: '85%'
                },
                {name: "serie"}
            ],
            initialSort: [
                {property: 'pruebas_sexo'},
                {property: 'apppruebas_descripcion'}],
            textMatchStyle: 'exact',
            groupByField: ['pruebas_sexo',
                           'pruebas_generica_codigo'],
            groupStartOpen: 'none',
            gridComponents: [CompetenciasResultadosFormID._toolStrip,
                             "header",
                             "body"],
            getCellCSSText: function (record, rowNum, colNum) {
                var style = 'font-style:normal;';
                if (record) {
                    if (record.competencias_pruebas_origen_id > 0) {
                        style = 'font-style:italic;'
                    }

                    if (record.pruebas_sexo == 'F') {
                        style += 'color:red;'
                    } else if (record.pruebas_sexo == 'M') {
                        style += 'color:blue;'
                    }
                }
                return style;
            },
            rowClick: function (record, recordNum, fieldNum) {
                this.Super("rowClick", arguments);
                if (!record.groupMembers) {
                    // Solo releer si la relacion competencia-prueba es cambiada.
                    if (this.lastComptenciaPruebaVisitedId !== record.competencias_pruebas_id) {
                        this.lastComptenciaPruebaVisitedId = record.competencias_pruebas_id;

                        competenciasResultadosList.filterData({
                                competencias_codigo: CompetenciasResultadosFormID.infoKey,
                                pruebas_codigo: record.pruebas_codigo,
                                pruebas_sexo: record.pruebas_sexo,
                                serie: record.serie,
                                origen: (record.competencias_pruebas_origen_id > 0 ? 'C' : 'D')
                            },
                            function (dsResponse, data, dsRequest) {
                                console.log('--------------------------');
                                console.log(data);
                                if (data && data.length > 0) {
                                    if (data[0].postas_atletas) {
                                        competenciasResultadosList.hideField('atletas_nombre_completo');
                                        competenciasResultadosList.showField('postas_atletas');
                                    } else {
                                        competenciasResultadosList.showField('atletas_nombre_completo');
                                        competenciasResultadosList.hideField('postas_atletas');
                                    }
                                } else {
                                    competenciasResultadosList.showField('atletas_nombre_completo');
                                    competenciasResultadosList.hideField('postas_atletas');
                                }
                            },
                            {textMatchStyle: 'exact'});
                    }
                }
            },
            // Refrescamos la lista de resultados para la prueba e indicamos relectura de la lista de pruebas.
            isPostRemoveDataRefreshMainListRequired: function (recordToDelete) {
                competenciasResultadosList.invalidateCache();
                return true;
            }
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);

        var toolStrip = this._createToolStrip();
        var gridList = this._createGridList();
        if (gridList.fetchOperation === undefined) {
            gridList.fetchOperation = 'fetch';
        }
        gridList.reselectOnUpdate = true;

        isc.Label.create({
                ID: 'competenciasResultadosInfoLabel',
                height: 30,
                padding: 5,
                valign: "center",
                wrap: false,
                contents: undefined
            }
        );
        isc.HLayout.create({
            ID: 'competenciasResultadosContainer',
            width: "100%",
            height: "100%",
            members: [
                CompetenciasResultadosFormID.getGridList(),
                // Lista de marcas
                isc.ListGrid.create({
                    autoDraw: false,
                    ID: "competenciasResultadosList",
                    dataSource: mdl_competenciasresultados,
                    fetchOperation: 'fetchCompetenciasResultadoPrueba',
                    showHeaderMenuButton: false,
                    showHeaderContextMenu: false,
                    autoFetchData: false,
                    alternateRecordStyles: true,
                    dataPageSize: 25,
                    canReorderFields: false,
                    showFilterEditor: true,
                    sortField: 'atletas_resultados_resultado',
                    sortDirection: 'descending',
                    gridComponents: [
                        isc.ToolStrip.create({
                            width: "100%",
                            autoDraw: false,
                            members: [
                                isc.ToolStripButton.create({
                                    icon: "[SKIN]/actions/refresh.png",
                                    prompt: "Actualizar lista",
                                    click: function () {
                                        competenciasResultadosList.invalidateCache();
                                    }
                                })
                            ]
                        }),
                        "header",
                        "filterEditor",
                        "body"],
                    fields: [
                        {
                            name: "atletas_nombre_completo",
                            width: '*'
                        },
                        {
                            name: "postas_atletas",
                            width: '*',
                            showHover:true,
                            hoverHTML:"return record.postas_atletas"
                        },
                        {
                            name: "serie",
                            width: '8%',
                            canFilter: false,
                            filterOperator: 'equals'
                        },
                        {
                            name: "atletas_resultados_resultado",
                            width: '12%',
                            align: 'right',
                            // Internamente el campo que se debe usar para ordenar los resultados
                            // es el campo norm_resultado.
                            sortNormalizer: function (record) {
                                return record.norm_resultado;
                            }
                        },
                        {
                            name: "competencias_pruebas_viento",
                            width: '10%',
                            align: 'right'
                        },
                        {
                            name: "obs",
                            width: '9%'
                        },
                        {
                            name: "categorias_codigo",
                            width: '8%'
                        },
                        {
                            name: "pruebas_record_hasta",
                            width: '8%'
                        },
                        {
                            name: "competencias_pruebas_fecha",
                            width: '12%',
                            align: 'right'
                        }
                    ],
                    getCellCSSText: function (record, rowNum, colNum) {
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
                        sortField: 'atletas_resultados_detalle_id',
                        canReorderFields: false,
                        showHeaderMenuButton: false,
                        showHeaderContextMenu: false,
                        fields: [
                            {
                                name: 'pruebas_descripcion',
                                width: '*'
                            }
                            ,
                            {
                                name: 'competencias_pruebas_fecha',
                                width: '15%'
                            },
                            {
                                name: 'atletas_resultados_resultado',
                                align: 'right',
                                width: '15%'
                            },
                            {
                                name: 'competencias_pruebas_viento',
                                width: '10%'
                            },
                            {
                                name: 'obs',
                                width: '12%'
                            },
                            {
                                name: 'atletas_resultados_puntos',
                                width: '12%'
                            }
                        ]
                    }
                })
            ]
        });

        this.addMember(competenciasResultadosInfoLabel);
        this.addMember(competenciasResultadosContainer);
        competenciasPruebasList.filterData({competencias_codigo: this.infoKey});

        var controller = isc.DefaultController.create({
            mainWindowClass: null,
            formWindowClass: 'WinCompetenciasResultadosMantForm'
        });
        controller.doSetupWithInstance(this, false);
    }
});