<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO para el manejo de los items de la cotizacion.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class CotizacionDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_cotizacion_detalle WHERE cotizacion_detalle_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  CotizacionDetalleModel */
        return 'insert into tb_cotizacion_detalle (cotizacion_id,insumo_id,cotizacion_detalle_cantidad,unidad_medida_codigo,cotizacion_detalle_precio,cotizacion_detalle_total,'.
        'activo,usuario) values(' .
        $record->get_cotizacion_id() . ',' .
        $record->get_insumo_id() . ',' .
        $record->get_cotizacion_detalle_cantidad() . ',\'' .
        $record->get_unidad_medida_codigo().'\','.
        $record->get_cotizacion_detalle_precio().','.
        $record->get_cotizacion_detalle_total() . ',\'' .
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
            $sql = 'SELECT cotizacion_detalle_id,cotizacion_id,insumo_id,cotizacion_detalle_cantidad,unidad_medida_codigo,cotizacion_detalle_precio,cotizacion_detalle_total,activo,xmin AS "versionId" ' .
                'FROM  tb_cotizacion_detalle pd ';
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
            $sql .= ' WHERE cotizacion_detalle_id = ' . $code;
        } else {
            $sql =  'SELECT cotizacion_detalle_id,cotizacion_id,insumo_id,cotizacion_detalle_cantidad,unidad_medida_codigo,cotizacion_detalle_precio,cotizacion_detalle_total,activo,xmin AS "versionId" ' .
            'FROM tb_cotizacion_detalle WHERE cotizacion_detalle_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  CotizacionDetalleModel */

        return 'update tb_cotizacion_detalle set cotizacion_detalle_id=' . $record->get_cotizacion_detalle_id() . ',' .
        'cotizacion_id=' . $record->get_cotizacion_id() . ',' .
        'insumo_id=' . $record->get_insumo_id() . ',' .
        'cotizacion_detalle_cantidad=' . $record->get_cotizacion_detalle_cantidad() . ',' .
        'unidad_medida_codigo=\''. $record->get_unidad_medida_codigo().'\','.
        'cotizacion_detalle_precio='.$record->get_cotizacion_detalle_precio().','.
        'cotizacion_detalle_total=' . $record->get_cotizacion_detalle_total() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "cotizacion_detalle_id" = ' . $record->get_cotizacion_detalle_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT cotizacion_detalle_id,cotizacion_id,pd.insumo_id,insumo_descripcion,cotizacion_detalle_cantidad,pd.unidad_medida_codigo,unidad_medida_descripcion,cotizacion_detalle_precio,cotizacion_detalle_total,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_cotizacion_detalle pd ' .
            'INNER JOIN tb_insumo ins on ins.insumo_id = pd.insumo_id '.
            'INNER JOIN tb_unidad_medida um on um.unidad_medida_codigo = pd.unidad_medida_codigo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_cotizacion_detalle_cotizacion_detalle_id_seq\')';
    }
}