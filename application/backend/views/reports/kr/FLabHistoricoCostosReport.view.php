<?php

use \koolreport\widgets\koolphp\Table;

?>

<html>
<head>
    <link rel="stylesheet" href="../../../../kr3/src/clients/bootstrap/css/bootstrap.min.css"/>
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

    </style></head>
<body>

<div class="reppage-container">
    <div class="page-header" style="height:60px;">
        <span style="text-align: center;line-height: normal;">
            <h5>
            Historico De Costos<br/>
            Entre <?php
                    $dt = new DateTime(substr($this->dataStore("sql_historico_costos_header")->get(0, "from_date"),0,10));
                    echo $dt->format('d-m-Y'); ?>
                al <?php
                    $dt = new DateTime(substr($this->dataStore("sql_historico_costos_header")->get(0, "to_date"),0,10));
                    echo $dt->format('d-m-Y'); ?>
                <br/>
                <?php echo $this->dataStore("sql_historico_costos_header")->get(0, "insumo_descripcion"); ?>
                <table style="font-size: 12px;width:100%">
                    <tr style="padding:20px;">
                        <td colspan="3" width="70%">
                            Codigo: <?php echo $this->dataStore("sql_historico_costos_header")->get(0, "insumo_codigo"); ?></td>
                        <td align="right">
                            Tipo: <?php echo $this->dataStore("sql_historico_costos_header")->get(0, "tinsumo_descripcion"); ?></td>
                    </tr>
                </table>
            </h5>
        </span>
    </div>


    <?php
    $setup = [
        "dataStore" => $this->dataStore('sql_historico_costos_detail'),
        "columns" => [

            "fecha" => ["label" => "Fecha"],
          //  "insumo_descripcion" => ["label" => "Descripcion"],
            "tipo_costo" => ["label" => "Tipo Costo"],
            "merma" => [
                "label" => "Merma",
                "cssStyle" => "text-align:right"
            ],
            "unidad_medida" => ["label" => "Unidad Medida Costo"],
            "costo" => [
                "label" => "Costo",
                "cssStyle" => "text-align:right"
            ],
            "precio_mercado" => [
                "label" => "Precio Mercado",
                "type" => "number",
                "decimals" => "2",
                "cssStyle" => "text-align:right"
            ],
            "moneda_costo" => ["label" => "Moneda Costo"],
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