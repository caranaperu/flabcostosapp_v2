<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO para el manejo de la cabecera de la lista de costos, dado que esta es creada por un proceso y no
 * manenimiento desde el usuario, solo permitira las operaciones de fetch y delete.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   22/07/2021
 *
 */
class CostosListDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
     * @{inheritdoc}
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string
    {
        return 'DELETE FROM tb_costos_list WHERE costos_list_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        return 'NOT SUPPORTED';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        /* @var $record  CostosListModel  */

        if ($subOperation == 'fetchProceso') {

            $sql = 'select * from sp_generate_costos_list_for_productos(\''.$constraints->getFilterField('costos_list_descripcion').'\',\''.$constraints->getFilterField('costos_list_fecha_desde').
                '\'::date,\''.$constraints->getFilterField('costos_list_fecha_hasta').'\'::date,\''.$constraints->getFilterField('costos_list_fecha_tcambio').'\'::date)';
        }
        else {
            $sql =  'SELECT costos_list_id,costos_list_descripcion,costos_list_fecha,costos_list_fecha_desde,costos_list_fecha_hasta,costos_list_fecha_tcambio,xmin AS "versionId" ' .
                'FROM tb_costos_list ';

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

            // Chequeamos paginacion
            $startRow = $constraints->getStartRow();
            $endRow = $constraints->getEndRow();

            if ($endRow > $startRow) {
                $sql .= ' LIMIT ' . ($endRow - $startRow) . ' OFFSET ' . $startRow;
            }

            $sql = str_replace('like', 'ilike', $sql);

        }
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        return "NOT SUPORTED";
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string
    {
        return "NOT SUPORTED";
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {
        return "NOT SUPORTED";
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_costos_list_costos_list_id_seq\')';
    }
}