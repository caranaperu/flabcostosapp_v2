/* global mdl_atletaspruebas_resultados */

/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de registro de los resultados de los atletas,
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 05:10:21 -0500 (mar, 24 jun 2014) $
 * $Rev: 253 $
 */
isc.defineClass("WinAtletasPruebasResultadosWindow", "WindowGridListExt");
isc.WinAtletasPruebasResultadosWindow.addProperties({
    ID: "winAtletasPruebasResultadosWindow",
    title: "Resultados de Pruebas",
    width: 980,
    height: 400,
    createGridList: function () {
        return isc.ListGrid.create({
            ID: "AtletasPruebasResultadosList",
            alternateRecordStyles: true,
            showHeaderContextMenu: false,
            dataSource: mdl_atletaspruebas_resultados,
            autoFetchData: true,
            dataPageSize: 40,
            // Estos 2 permiten que solo se lea lo que el tamaño de la pagina indica
            drawAheadRatio: 1,
            drawAllMaxCells: 0,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "atletas_nombre_completo",
                    width: 150
                },
                {
                    name: "pruebas_descripcion",
                    width: 150
                },
                {
                    name: "serie",
                    width: 40
                },
                {
                    name: "atletas_resultados_resultado",
                    align: 'right',
                    width: 60
                },
                {
                    name: "competencias_pruebas_fecha",
                    align: 'center',
                    width: 70
                },
                {
                    name: "categorias_codigo",
                    width: 50
                },
                {
                    name: "obs",
                    width: 40,
                    filterOperator: 'equals'
                },
                {
                    name: "competencias_pruebas_viento",
                    title: 'V',
                    decimalPad: 2,
                    width: 30,
                    formatCellValue: function (value) {
                        if (value === null) {
                            return '';
                        } else {
                            return value;
                        }
                    }
                },
                {
                    name: "competencias_descripcion",
                    width: 150
                },
                {
                    name: "paises_descripcion",
                    width: 100
                },
                {
                    name: "ciudades_descripcion",
                    width: 100
                }

            ],
            getCellCSSText: function (record, rowNum, colNum) {
                if (record.obs === true) {
                    return "color:red;";
                }
            },
            isAllowedToDelete: function() {
              var record = this.getSelectedRecord();
                if (record && record.postas_id) {
                    isc.warn('No es posible eliminar postas aqui , ir a mantenimiento de competencias');
                    return false;
                }
                return true;
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            autoFitWidthApproach: 'both'
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});
