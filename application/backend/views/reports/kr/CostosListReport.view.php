<?php

use koolreport\widgets\koolphp\Table;

?>

<html>
<head>
    <link rel="stylesheet" href="../../../../koolreport/core/src/clients/bootstrap/css/bootstrap.min.css"/>
    <style>
        .reppage-container {
            margin-left: 5%;
            margin-right: 5%;
            width: 90%;
        }

        .koolphp-table table {
            font-size: 12px;
        }

        .koolphp-table table > tbody > tr > td {
            line-height: normal;
            border-top: 0px;
            padding: 2px;
        }

        .koolphp-table table > tfoot > tr > td {
            padding: 0px;
        }

        @media screen {
            .only-screen {
                display: block;
            }

            .only-print {
                display: none;
            }
        }

        @media print {
            .only-screen {
                display: none;
            }

            ul.pagination {
                display: none;
            }

            .only-print {
                display: block;
            }

        }

    </style>
</head>
<body>

<div class="reppage-container">
    <div class="page-header" style="height:60px;">
        <span style="text-align: center;line-height: normal;">
            <h5>
            Lista De Costos<br/>
            Entre <?php
                $dt = new DateTime(substr($this->dataStore("sql_costos_list_header")->get(0, "costos_list_fecha_desde"), 0, 10));
                echo $dt->format('d-m-Y'); ?>
                al <?php
                $dt = new DateTime(substr($this->dataStore("sql_costos_list_header")->get(0, "costos_list_fecha_hasta"), 0, 10));
                echo $dt->format('d-m-Y'); ?>
                <br/>
                <table style="font-size: 12px;width:100%">
                    <tr style="padding:20px;">
                        <td colspan="3" width="70%">
                            Descripcion: <?php echo $this->dataStore("sql_costos_list_header")->get(0, "costos_list_descripcion"); ?></td>
                    </tr>
                </table>
            </h5>
        </span>
    </div>


    <?php
    $setup = [
        "dataStore" => $this->dataStore('sql_costos_list_detail'),
        "columns" => [

            "insumo_descripcion" => ["label" => "Producto"],
            "taplicacion_entries_descripcion" => ["label" => "Modo Empleo"],
            "costos_list_detalle_qty_presentacion" => [
                "label" => "Presentacion",
                "formatValue" => function ($value, $row) {
                    return $value." ".$row['unidad_medida_siglas'];
                }
            ],
            "moneda_descripcion" => ["label" => "Moneda"],
            "costos_list_detalle_costo_base" => [
                "label" => "Costo Base",
                "type" => "number",
                "decimals" => "2",
                "cssStyle" => "text-align:right"
            ],
            "costos_list_detalle_costo_agregado" => [
                "label" => "Costo Agregado",
                "type" => "number",
                "decimals" => "2",
                "cssStyle" => "text-align:right"
            ],
            "costos_list_detalle_costo_total" => [
                "label" => "Costo Total",
                "type" => "number",
                "decimals" => "2",
                "cssStyle" => "text-align:right"
            ],
        ],
        "paging" => [
            "pageSize" => 25,
            "align" => "center",
            "pageIndex" => 0,
        ],
    ];

    if (!isset($this->params["PARAM_toScreen"])) {
        unset($setup["paging"]);
    }

    Table::create($setup);
    ?>
</div>

</body>
</html>