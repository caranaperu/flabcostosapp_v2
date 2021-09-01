<?php
require_once dirname(__FILE__)."/../../../../../../koolreport/core/autoload.php";


class CostosListReport extends \koolreport\KoolReport {

    use \koolreport\codeigniter\Friendship;
    use \koolreport\excel\ExcelExportable;


    public function setup() {
        $sqlQry = "select  i.costos_list_descripcion::TEXT,
                            to_char(i.costos_list_fecha,'DD-MM-YYYY hh24:mi:ss') as costos_list_fecha,
                            i.costos_list_fecha_desde,
                            i.costos_list_fecha_hasta,
                            i.costos_list_fecha_tcambio
                    from tb_costos_list i
                    where i.costos_list_id = :costos_list_id";
        $this->src('default')->query($sqlQry)
            ->params(array(
                ":costos_list_id"=>$this->params["costos_list_id"]
            ))
            ->pipe($this->dataStore('sql_costos_list_header'));

        $sqlQry = "select 
                insumo_descripcion::TEXT,
                taplicacion_entries_descripcion::TEXT,
                costos_list_detalle_qty_presentacion,
                unidad_medida_siglas,
                moneda_descripcion,
                costos_list_detalle_costo_base,
                costos_list_detalle_costo_agregado,
                costos_list_detalle_costo_total
        from tb_costos_list_detalle
            where costos_list_id = :costos_list_id";

        $this->src('default')->query($sqlQry)
            ->params(array(
                ":costos_list_id"=>$this->params["costos_list_id"]
            ))
            ->pipe($this->dataStore('sql_costos_list_detail'));
    }
}


