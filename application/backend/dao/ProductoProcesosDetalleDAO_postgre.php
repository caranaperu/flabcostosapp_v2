<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO para el manejo de las entradas de los procesos a asocias a cada relacion de producto-proceos.
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class ProductoProcesosDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_producto_procesos_detalle WHERE producto_procesos_detalle_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  ProductoProcesosDetalleModel */
        return 'insert into tb_producto_procesos_detalle (producto_procesos_id,procesos_codigo,producto_procesos_detalle_porcentaje,'.
        'activo,usuario) values(' .
        $record->get_producto_procesos_id() . ',\'' .
        $record->get_procesos_codigo().'\','.
        $record->get_producto_procesos_detalle_porcentaje() . ',\'' .
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
            $sql = 'SELECT producto_procesos_detalle_id,producto_procesos_id,procesos_codigo,producto_procesos_detalle_porcentaje,activo,xmin AS "versionId" ' .
                'FROM  tb_producto_procesos_detalle pd ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            // Mapeamos las virtuales a los campos reales
          //  $where = str_replace('"unidad_medida_descripcion_o"', 'um1.unidad_medida_descripcion', $where);

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
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string
    {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' WHERE producto_procesos_detalle_id = ' . $code;
        } else {
            $sql =  'SELECT producto_procesos_detalle_id,producto_procesos_id,procesos_codigo,producto_procesos_detalle_porcentaje,activo,xmin AS "versionId" ' .
            'FROM tb_producto_procesos_detalle WHERE producto_procesos_detalle_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  ProductoProcesosDetalleModel */

        return 'update tb_producto_procesos_detalle set producto_procesos_detalle_id=' . $record->get_producto_procesos_detalle_id() . ',' .
        'producto_procesos_id=' . $record->get_producto_procesos_id() . ',' .
        'procesos_codigo=\''. $record->get_procesos_codigo().'\','.
        'producto_procesos_detalle_porcentaje=' . $record->get_producto_procesos_detalle_porcentaje() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "producto_procesos_detalle_id" = ' . $record->get_producto_procesos_detalle_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT producto_procesos_detalle_id,producto_procesos_id,pd.procesos_codigo,procesos_descripcion,producto_procesos_detalle_porcentaje,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_producto_procesos_detalle pd ' .
            'INNER JOIN tb_procesos um on um.procesos_codigo = pd.procesos_codigo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_producto_procesos_detalle_producto_procesos_detalle_id_seq\')';
    }
}