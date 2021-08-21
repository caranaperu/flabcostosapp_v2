<?php
require_once dirname(__FILE__)."/../../../../../../kr3/autoload.php";


class FLabHistoricoCostosReport extends \koolreport\KoolReport {

    use \koolreport\codeigniter\Friendship;
    use \koolreport\excel\ExcelExportable;


    public function setup() {
        $sqlQry = "select i.insumo_codigo,
                           i.insumo_descripcion,
                           case when i.insumo_tipo != 'PR' then
                                ti.tinsumo_descripcion
                           else 'Producto'
                           end as tinsumo_descripcion,
                           :from_date as from_date,
                           :to_date as to_date
                    from tb_insumo i
                    inner join tb_tinsumo ti on ti.tinsumo_codigo = i.tinsumo_codigo
                    where i.insumo_id = :insumo_id";
        $this->src('default')->query($sqlQry)
            ->params(array(
                ":insumo_id"=>$this->params["insumo_id"],
                ":from_date"=>$this->params["from_date"],
                ":to_date"=>$this->params["to_date"]
            ))
            ->pipe($this->dataStore('sql_historico_costos_header'));

        $sqlQry = "select i.insumo_codigo,
               i.insumo_descripcion::TEXT,
               to_char(insumo_history_fecha,'DD-MM-YYYY hh24:mi:ss') as fecha,
               case when ih.insumo_tipo != 'PR' then
                    ti.tinsumo_descripcion
               else 'Producto'
               end as tipo_insumo,
               case when ih.insumo_tipo != 'PR' then
                    tc.tcostos_descripcion::TEXT
               else NULL
               end as tipo_costo,
               um.unidad_medida_descripcion as unidad_medida,
               case when tc.tcostos_indirecto = TRUE then
                    null
               else to_char(ih.insumo_merma,'9990.9999')
               end as merma,
               to_char(ih.insumo_costo,'999999990.9999') as costo,
               mo.moneda_descripcion::TEXT as moneda_costo,
               case when  ih.insumo_tipo != 'PR' or tc.tcostos_indirecto = TRUE then
                    null
               else to_char(ih.insumo_precio_mercado,'9999990.99')
               end as precio_mercado
        from tb_insumo_history ih
        inner join tb_insumo i on i.insumo_id = ih.insumo_id
        inner join tb_tinsumo ti on ti.tinsumo_codigo = ih.tinsumo_codigo
        inner join tb_tcostos tc on tc.tcostos_codigo = ih.tcostos_codigo
        inner join tb_unidad_medida um on um.unidad_medida_codigo = ih.unidad_medida_codigo_costo
        inner join tb_moneda mo on mo.moneda_codigo = ih.moneda_codigo_costo
        where  i.insumo_id = :insumo_id and insumo_history_fecha between  :from_date  and  :to_date
        order by insumo_history_fecha";

        $this->src('default')->query($sqlQry)
            ->params(array(
                ":insumo_id"=>$this->params["insumo_id"],
                ":from_date"=>$this->params["from_date"],
                ":to_date"=>$this->params["to_date"]
            ))
            ->pipe($this->dataStore('sql_historico_costos_detail'));
    }
}


