<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title></title>
        <link rel="stylesheet" href="../../graphlib/amcharts/plugins/export/export.css" type="text/css"></script>
    <script src="../../graphlib/amcharts/amcharts.js" type="text/javascript"></script>
    <script src="../../graphlib/amcharts/serial.js" type="text/javascript"></script>
    <script src="../../graphlib/amcharts/themes/light.js" type="text/javascript"></script>
    <script src="../../graphlib/amcharts/amstock.js" type="text/javascript"></script>
    <script src="../../graphlib/amcharts/plugins/export/export.js" type="text/javascript"></script>
</script>
<style>
    body
    {
        font-size:11px;
        color:#000000;
        background-color:#ffffff;
        font-family:verdana,helvetica,arial,sans-serif;
    }
</style>

<script type="text/javascript">
    var chart;
    var chartDef;

    // PArche para que se imprima el grafico completo
    if ('matchMedia' in window) {
        // Chrome, Firefox, and IE 10 support mediaMatch listeners
        window.matchMedia('print').addListener(function (media) {
            chart.validateNow();
        });
    } else {
        // IE and Firefox fire before/after events
        window.onbeforeprint = function () {
            chart.validateNow();
        }
    }

    // Rutina de carga de datos
    AmCharts.loadJSON = function (url) {
        // create the request
        if (window.XMLHttpRequest) {
            // IE7+, Firefox, Chrome, Opera, Safari
            var request = new XMLHttpRequest();
        } else {
            // code for IE6, IE5
            var request = new ActiveXObject('Microsoft.XMLHTTP');
        }

        // Ejecuta el web service para obtener los resultados
        request.open('GET', url, false);
        request.send();

        if (request.status == 200) {
            try {
                var results = eval('(' + request.responseText.trim() + ')');
                if (results.response.status != 0) {
                    alert(results.response.error);
                }
            } catch (e) {
                alert(e.message + ' - ' + request.responseText);
            }

            // parse adn return the output
            return results;
        } else {
            alert(request.responseText);
            return null;
        }
    };

    AmCharts.prepareLabels = function (value, validate) {
        var size = chart.panels[0].stockGraphs[0].chart.graphs.length;
        for (var i = 0; i < size; i++) {
            chart.panels[0].stockGraphs[0].chart.graphs[i].labelText = value;
            chart.panels[0].stockGraphs[0].chart.graphs[i].labelPosition = 'right';
        }
        if (size > 1 && validate == true) {
            chart.validateNow();
        }
    }
    ;

    AmCharts.showLabels = function (prm) {
        if (chartDef) {
            if (prm == 1) {
                //chartDef.panels[0].stockGraphs[0].labelText = "[[value]]";
                AmCharts.prepareLabels("[[value]]", false);
                chart.panels[0].stockGraphs[0].showBullets();

            } else {
                AmCharts.prepareLabels("", false);
                chart.panels[0].stockGraphs[0].hideBullets();
            }
            chart.validateNow();
        }
    }

    AmCharts.prepareChartData = function (chartDef, chartData) {
        ///////////////////////////////////////////////////////////////////////////
        // Creamos los datasets

        var len = chartData.response.seriesTitles.length;
        if (len > 0) {
            chartDef.dataSets = [];
            for (var i = 0; i < len; i++) {
                chartDef.dataSets.push({
                    title: chartData.response.seriesTitles[i],
                    fieldMappings: [{
                            fromField: "nresultado",
                            toField: "nresultado"
                        }],
                    dataProvider: chartData.response.seriesData[i],
                    categoryField: "fecha"
                });
            }
        }

        ///////////////////////////////////////////////////////////////////////////
        // Procesamos as unidades requeridas por caso

        // En el caso que tengamos una prueba en segundos pero algun resultado exceda esto
        // por ser una marca pobre cambiamos la unidad de medida para que se comporte como minutos,segundos
        if (chartData.response.um == 'SEG') {
            if (len > 0) {
                for (var i = 0; i < len; i++) {
                    var lenData = chartData.response.seriesData[i].length
                    for (var j = 0; j < lenData; j++) {
                        if (chartData.response.seriesData[i][j].nresultado >= 60) {
                            chartData.response.um = 'MS';
                        }
                    }
                }
            }
        }

        console.log(chartData.response.um)
        if (chartData.response.um == 'MS' || chartData.response.um == 'HMS') {
            chartDef.valueAxesSettings.duration = "ss";
            chartDef.valueAxesSettings.durationUnits = {
                "hh": ":",
                "mm": ":",
                "ss": "s"
            }
            chartDef.panels[0].stockGraphs[0].precision = 2;
        } else if (chartData.response.um == 'SEG') {
            chartDef.valueAxesSettings.unit = "s";
            chartDef.panels[0].stockGraphs[0].precision = 2;
        } else if (chartData.response.um == 'MTSCM') {
            chartDef.valueAxesSettings.unit = "cm";
            chartDef.panels[0].stockGraphs[0].precision = 2;
            if (len > 0) {
                for (var i = 0; i < len; i++) {
                    var lenData = chartData.response.seriesData[i].length
                    for (var j = 0; j < lenData; j++) {
                        chartData.response.seriesData[i][j].nresultado = chartData.response.seriesData[i][j].nresultado / 100.00;
                    }
                }
            }
        } else if (chartData.response.um == 'PUNT') {
            chartDef.valueAxesSettings.unit = "ptos";
            chartDef.panels[0].stockGraphs[0].precision = 0;
        }

        ///////////////////////////////////////////////////////////////////////////
        // Creamos los stock events
        if (len > 0) {
            for (var i = 0; i < len; i++) {
                var lenData = chartData.response.seriesData[i].length;
                for (var j = 0; j < lenData; j++) {
                    if (chartData.response.seriesData[i][j].manual == 't') {
                        if (!chartDef.dataSets[i].stockEvents) {
                            chartDef.dataSets[i].stockEvents = [];
                        }
                        chartDef.dataSets[i].stockEvents.push({
                            date: chartData.response.seriesData[i][j].fecha,
                            type: "sign",
                            backgroundColor: "#FF9999",
                            backgroundAlpha: 1,
                            graph: "g1",
                            text: "m"
                        });

                    }

                    // Si tiene observaciones
                    if (chartData.response.seriesData[i][j].altura == 't') {
                        if (!chartDef.dataSets[i].stockEvents) {
                            chartDef.dataSets[i].stockEvents = [];
                        }
                        chartDef.dataSets[i].stockEvents.push({
                            date: chartData.response.seriesData[i][j].fecha,
                            type: "sign",
                            backgroundColor: "#ADEBFF",
                            backgroundAlpha: 1,
                            graph: "g1",
                            text: "x"
                        });

                    }
                }
            }
        }


        ///////////////////////////////////////////////////////////////////////////
        // Creamos el subtitulo sin filtro.
        var stitle = 'Desde <?php echo $_GET['fecha_desde'] ?> hasta <?php echo $_GET['fecha_hasta'] ?>';
<?php
if ($_GET['incluye_manuales'] == 'true' || $_GET['incluye_altura'] == 'true') {
    echo 'stitle +=  \' ( Incluye \';';
    if ($_GET['incluye_manuales'] == 'true') {
        echo 'stitle +=  \' Manuales \';';
    }
    if ($_GET['incluye_manuales'] == 'true' && $_GET['incluye_altura'] == 'true') {
        echo 'stitle +=  \' y \';';
    }
    if ($_GET['incluye_altura'] == 'true') {
        echo 'stitle +=  \' En Altura \';';
    }
    echo 'stitle +=  \' )\';';
}
?>
        chartDef.panels[0].titles.push(
            {text: stitle, size: 9}
        );
    }

    AmCharts.ready(function () {
        // Armo el url
<?php
$url = '/atletismo/index.php/recordsGraphDataController?op=fetch&libid=Amcharts&_operationId=fetchRecordsResumen';
foreach ($_GET as $key => $value) {
    $url .= '&' . $key . '=' . $value;
}
?>
        var chartData = AmCharts.loadJSON('<?php echo $url ?>');

        if (!chartData.response.seriesData || chartData.response.seriesData.length == 0) {
            return;
        }

        chartDef = {
            type: "stock",
            theme: "light",
            pathToImages: "../../graphlib/amcharts/images/",
            dataDateFormat: "YYYY-MM-DD",
            zoomOutOnDataSetChange: true,
            "export": {
                "enabled": true
            },
            panelsSettings: {
                creditsPosition: 'top-left',
                autoMargins: true,
                backgroundAlpha: 1,
                //backgroundColor: '#FFFFF0'
            },
            panels: [{
                    showCategoryAxis: true,
                    recalculateToPercents: 'never',
                    "titles": [{text: chartData.response.seriesTitles[0] + ' ' + chartData.response.prueba, size: 20}],
                    borderColor: '#0000FF',
                    borderAlpha: 1,
                    stockGraphs: [{
                            id: "g1",
                            valueField: "nresultado",
                            bullet: "round",
                            useLineColorForBulletBorder: false,
                            bulletBorderAlpha: 1,
                            bulletBorderColor: '#000000',
                            lineThickness: 2,
                            fontSize: 10,
                            labelText: "[[value]]",
                            labelPosition: 'left',
                            balloonFunction: function (graphDataItem, graph) {
                                //console.log(graph)
                                //console.log(graphDataItem)
                                var data = graphDataItem.dataContext.dataContext;

                                if (chartData.response.um !== 'HMS' && chartData.response.um !== 'MS') {
                                    return  "<b>" + data.atleta + "</b><br/>" + graph.title + ": <b>" + graphDataItem.values.value + "</b><br/>" + data.fecha + "<br/><span style='font-size:8px;'>" + data.comentario + "<br/>" + data.lugar + "</span>"
                                } else {
                                    return  "<b>" + data.atleta + "</b><br/>" + graph.title + ": <b>" + data.tresultado + "</b><br/>" + data.fecha + "<br/><span style='font-size:8px;'>" + data.comentario + "<br/>" + data.lugar + "</span>"
                                }
                            }
                        }

                    ],
                    stockLegend: {
                        valueTextRegular: "[[value]]"
                    }

                }
            ],
            valueAxesSettings: {
                inside: false,
                axisAlpha: 0.3,
                axisThickness: 2
            },
            categoryAxesSettings: {
                inside: false,
                axisAlpha: 0.3,
                axisThickness: 2,
                groupToPeriods: ["YYYY", "2MM", "WW","DD"]
            },
            balloon: {
                textAlign: 'left',
                fontSize: 8
            },
            chartScrollbarSettings: {
                graph: "g1",
                height: 30
            },
            chartCursorSettings: {
                valueBalloonsEnabled: true,
                categoryBalloonEnabled: false,
                cursorAlpha: 0.5,
                zoomable: true
            },
            periodSelector: {
                position: "top",
                hideOutOfScopePeriods: false,
                inputFieldsEnabled: false,
                //selectFromStart: true,
                periods: [{
                        period: "MM",
                        count: 1,
                        label: "1 Mes"
                    }, {
                        period: "YYYY",
                        count: 1,
                        label: "1 Año",
                    }, {
                        period: "YYYY",
                        label: "MAX",
                        count: 100,
                        selected: true,
                    }]
            }
        };
        AmCharts.prepareChartData(chartDef, chartData);
        //   console.log(chartDef)
        chart = AmCharts.makeChart("chartdiv", chartDef);

    });


</script>
</head>
<body>
    <div id = "chartdiv" style = "width: 100%; height: 420px;"></div>
    <div id = "selector" align="left">
        <label><input type = "checkbox" value = "0" id = "showLabels" checked = "checked" onclick = "AmCharts.showLabels(checked);"> Mostrar Valores</label>
    </div>
</body>
</html>
