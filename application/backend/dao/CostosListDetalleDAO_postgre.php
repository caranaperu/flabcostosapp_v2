<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO para el manejo de los items de la lista de costos, la unica
 * operacion permitida es fetch ya que estos registros seran generados por
 * un proceso interno y no mantenimiento alguno.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class CostosListDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
{

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     *
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE)
    {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string
    {
        // Debe eliminarse la cabecera y cada item sera eliminado automaticamente
        return 'NOT SUPPORTED';
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        // Los items son producto de un calculo por proceso , no se agregaran manualmente
        return 'NOT SUPPORTED';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        if ($subOperation == 'fetchForProductoCostosHistoricos') {
            $insumo_id = $constraints->getFilterField('insumo_id');
            $p_date_from = $constraints->getFilterField('p_date_from');
            $p_date_to = $constraints->getFilterField('p_date_to');

            $sql = 'SELECT costos_list_detalle_id,costos_list_fecha,costos_list_descripcion,moneda_descripcion,costos_list_detalle_costo_base,costos_list_detalle_costo_agregado,'.
                'costos_list_detalle_costo_total ' .
                'FROM  tb_costos_list_detalle cd '.
                'inner join tb_costos_list c on c.costos_list_id = cd.costos_list_id '.
                'where insumo_id='.$insumo_id.' ';
                if (isset($p_date_from) && isset($p_date_to)) {
                    $sql .= 'and costos_list_fecha >= \''.$p_date_from.'\' and costos_list_fecha <= \''.$p_date_to.'\' ';
                }
                $sql .= 'order by costos_list_fecha desc';

        } else {
            $sql = 'SELECT costos_list_detalle_id,costos_list_id,insumo_id,insumo_descripcion,moneda_descripcion,taplicacion_entries_descripcion,'.
                'unidad_medida_siglas,costos_list_detalle_qty_presentacion,costos_list_detalle_costo_base,costos_list_detalle_costo_agregado,'.
                'costos_list_detalle_costo_total,xmin AS "versionId" ' .
                'FROM  tb_costos_list_detalle ';


            $where = $constraints->getFilterFieldsAsString();

            if (strlen($where) > 0) {
                $sql .= ' where ' . $where;
            }

            if (isset($constraints)) {
                $orderby = $constraints->getSortFieldsAsString();
                if ($orderby !== NULL) {
                    $sql .= ' order by ' . $orderby;
                }
            }
        }

        // Chequeamos paginacion
        $startRow = $constraints->getStartRow();
        $endRow = $constraints->getEndRow();

        if ($endRow > $startRow) {
            $sql .= ' LIMIT ' . ($endRow - $startRow) . ' OFFSET ' . $startRow;
        }

        $sql = str_replace('like', 'ilike', $sql);
        //echo $sql;
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        return 'NOT SUPPORTED';
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string
    {
        return 'NOT SUPPORTED';
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {
        return 'NOT SUPORTED';
    }


    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_costos_list_detalle_costos_list_detalle_id_seq\')';
    }
}