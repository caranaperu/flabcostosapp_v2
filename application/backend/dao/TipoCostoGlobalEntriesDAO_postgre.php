<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de cada entrada de valor para cada tipo de costo global valido
 * desde una determinada fecha.
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class TipoCostoGlobalEntriesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_tcosto_global_entries WHERE tcosto_global_entries_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  TipoCostoGlobalEntriesModel */

        return 'insert into tb_tcosto_global_entries (tcosto_global_entries_fecha_desde,tcosto_global_codigo,moneda_codigo,tcosto_global_entries_valor,activo,usuario) values(\'' .
        $record->get_tcosto_global_entries_fecha_desde() . '\',\'' .
        $record->get_tcosto_global_codigo() . '\',\'' .
        $record->get_moneda_codigo() . '\',' .
        $record->get_tcosto_global_entries_valor() . ',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {

        if ($subOperation == 'fetchJoined') {
            $sql = $this->_getFecthNormalized();
        }  else {
            $sql = 'SELECT tcosto_global_entries_fecha_desde,tcosto_global_codigo,tcosto_global_entries_valor,moneda_codigo,activo,xmin AS "versionId" ' .
                   'FROM  tb_tcosto_global_entries pd ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            if ($this->activeSearchOnly == TRUE) {
                $sql .= ' and ' . $where;
            } else {
                $sql .= ' where ' . $where;
            }
        }

        if (isset($constraints)) {
            if ($subOperation == 'fetchJoined') {
                $sql .= ' order by ins.tcosto_global_descripcion,tcosto_global_entries_fecha_desde ';
            } else {
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
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string
    {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' WHERE tcosto_global_entries_id = ' . $code;
        } else {
            $sql =  'SELECT tcosto_global_entries_id,tcosto_global_entries_fecha_desde,tcosto_global_codigo,costo_global_entries_valor,moneda_codigo,activo,xmin AS "versionId" ' .
                    'FROM tb_tcosto_global_entries WHERE tcosto_global_entries_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  TipoCostoGlobalEntriesModel */

        return 'update tb_tcosto_global_entries set tcosto_global_codigo=\'' . $record->get_tcosto_global_codigo() . '\',' .
        'tcosto_global_entries_fecha_desde=\'' . $record->get_tcosto_global_entries_fecha_desde() . '\',' .
        'tcosto_global_entries_valor=' . $record->get_tcosto_global_entries_valor() . ',' .
        'moneda_codigo=\'' . $record->get_moneda_codigo() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "tcosto_global_entries_id" = ' . $record->get_tcosto_global_entries_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT tcosto_global_entries_id,tcosto_global_entries_fecha_desde,pd.tcosto_global_codigo,ins.tcosto_global_descripcion,'.
            'tcosto_global_entries_valor,mn.moneda_codigo,mn.moneda_descripcion,'.
            'pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_tcosto_global_entries pd ' .
            'INNER JOIN tb_tcosto_global ins on ins.tcosto_global_codigo = pd.tcosto_global_codigo '.
            'INNER JOIN tb_moneda mn on mn.moneda_codigo = pd.moneda_codigo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_tcosto_global_entries_tcosto_global_entries_id_seq\')';
    }
}