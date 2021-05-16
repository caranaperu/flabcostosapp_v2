<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las importaciones a los insumos
 * IMPORTANTE:
 * El campo  unidad_medida_codigo_qty no se han trabajado ya que por ahora usa default
 * KILOS.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 *
 */
class InsumoEntriesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_insumo_entries WHERE insumo_entries_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  InsumoEntriesModel */

        return 'insert into tb_insumo_entries (insumo_entries_fecha,insumo_id,insumo_entries_qty,insumo_entries_value,activo,usuario) values(\'' .
        $record->get_insumo_entries_fecha() . '\',' .
        $record->get_insumo_id() . ',' .
        $record->get_insumo_entries_qty() . ',' .
        $record->get_insumo_entries_value() . ',\'' .
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
        } else if ($subOperation == 'fetchForInsumosEntriesAssoc') {
            $insumo_id = $constraints->getFilterField('insumo_id');
            $sql = 'SELECT insumo_entries_fecha,insumo_entries_qty,insumo_entries_value,(select fn_get_insumo_factor_ajuste('.$insumo_id.','.insumo_entries_fecha.'::date)) as insumo_factor_ajuste ' .
                'FROM  tb_insumo_entries pd ';
        } else {
            $sql = 'SELECT insumo_entries_fecha,insumo_id,insumo_entries_qty,insumo_entries_value,activo,xmin AS "versionId" ' .
                   'FROM  tb_insumo_entries pd ';
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
            // No se permite ordenar por datos externois cuando se buscan entradas de insumos
            // ya que esto ya esta prederteminado para una vista.
            if ($subOperation !== 'fetchForInsumosEntriesAssoc') {
                $orderby = $constraints->getSortFieldsAsString();
                if ($orderby !== NULL) {
                    $sql .= ' order by ' . $orderby;
                }
            } else {
                // el order by predeterminado para fetchForInsumosEntriesAssoc
                $sql .= 'order by insumo_entries_fecha,insumo_entries_id ';
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
            $sql .= ' WHERE insumo_entries_id = ' . $code;
        } else {
            $sql =  'SELECT insumo_entries_id,insumo_entries_fecha,insumo_id,insumo_entries_qty,insumo_entries_value,activo,xmin AS "versionId" ' .
                    'FROM tb_insumo_entries WHERE insumo_entries_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  InsumoEntriesModel */

        return 'update tb_insumo_entries set insumo_id=' . $record->get_insumo_id() . ',' .
        'insumo_entries_fecha=\'' . $record->get_insumo_entries_fecha() . '\',' .
        'insumo_entries_qty=' . $record->get_insumo_entries_qty() . ',' .
        'insumo_entries_value=' . $record->get_insumo_entries_value() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "insumo_entries_id" = ' . $record->get_insumo_entries_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT insumo_entries_id,insumo_entries_fecha,pd.insumo_id,insumo_descripcion,'.
            'insumo_entries_qty,insumo_entries_value,'.
            'pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_insumo_entries pd ' .
            'INNER JOIN tb_insumo ins on ins.insumo_id = pd.insumo_id ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_insumo_entries_insumo_entries_id_seq\')';
    }
}