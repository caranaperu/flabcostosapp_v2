<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de la produccion de los modos de aplicacion
 * IMPORTANTE:
 * El campo  unidad_medida_codigo no se han trabajado ya que por ahora usa default
 * LITROS.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 *
 */
class ProduccionDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_produccion WHERE produccion_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  ProduccionModel */

        return 'insert into tb_produccion (produccion_fecha,taplicacion_entries_id,produccion_qty,activo,usuario) values(\'' .
        $record->get_produccion_fecha() . '\',' .
        $record->get_taplicacion_entries_id() . ',' .
        $record->get_produccion_qty() . ',\'' .
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
        } else {
            $sql = 'SELECT produccion_id,produccion_fecha,taplicacion_entries_id,produccion_qty,activo,xmin AS "versionId" ' .
                   'FROM  tb_produccion pd ';
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
            $sql .= ' WHERE produccion_id = ' . $code;
        } else {
            $sql =  'SELECT produccion_id,produccion_fecha,taplicacion_entries_id,produccion_qty,activo,xmin AS "versionId" ' .
                    'FROM tb_produccion WHERE produccion_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  ProduccionModel */

        return 'update tb_produccion set taplicacion_entries_id=' . $record->get_taplicacion_entries_id() . ',' .
        'produccion_fecha=\'' . $record->get_produccion_fecha() . '\',' .
        'produccion_qty=' . $record->get_produccion_qty() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "produccion_id" = ' . $record->get_produccion_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT produccion_id,produccion_fecha,pd.taplicacion_entries_id,taplicacion_entries_descripcion,'.
            'produccion_qty,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_produccion pd ' .
            'INNER JOIN tb_taplicacion_entries ins on ins.taplicacion_entries_id = pd.taplicacion_entries_id ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_produccion_produccion_id_seq\')';
    }
}