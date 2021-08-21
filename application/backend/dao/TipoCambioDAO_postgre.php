<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de la definicion de los registros
 * del tipo de cambio.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class TipoCambioDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_tipo_cambio WHERE tipo_cambio_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  TipoCambioModel */

        return 'insert into tb_tipo_cambio (moneda_codigo_origen,moneda_codigo_destino,tipo_cambio_fecha_desde,' .
        'tipo_cambio_fecha_hasta,tipo_cambio_tasa_compra,tipo_cambio_tasa_venta,activo,usuario) values(\'' .
        $record->get_moneda_codigo_origen() . '\',\'' .
        $record->get_moneda_codigo_destino() . '\',\'' .
        $record->get_tipo_cambio_fecha_desde() . '\',\'' .
        $record->get_tipo_cambio_fecha_hasta() . '\',' .
        $record->get_tipo_cambio_tasa_compra() . ',' .
        $record->get_tipo_cambio_tasa_venta() . ',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {

        $sql = $this->_getFecthNormalized();

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            // Mapeamos las virtuales a los campos reales
            $where = str_replace('"moneda_descripcion_o"', 'mo_o.moneda_descripcion', $where);
            $where = str_replace('"moneda_descripcion_d"', 'mo_d.moneda_descripcion', $where);
            
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
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' where tipo_cambio_id = ' . $code;
        } else {
            $sql =  'SELECT tipo_cambio_id,moneda_codigo_origen,moneda_codigo_destino,tipo_cambio_fecha_desde,'.
                'tipo_cambio_fecha_hasta,tipo_cambio_tasa_compra,,tipo_cambio_tasa_venta,activo,xmin AS "versionId" ' .
                'FROM tb_tipo_cambio WHERE tipo_cambio_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  TipoCambioModel */

        return 'update tb_tipo_cambio set tipo_cambio_id=' . $record->get_tipo_cambio_id() . ',' .
        'moneda_codigo_origen=\'' . $record->get_moneda_codigo_origen() . '\',' .
        'moneda_codigo_destino=\'' . $record->get_moneda_codigo_destino() . '\',' .
        'tipo_cambio_fecha_desde=\'' . $record->get_tipo_cambio_fecha_desde() . '\',' .
        'tipo_cambio_fecha_hasta=\'' . $record->get_tipo_cambio_fecha_hasta() . '\',' .
        'tipo_cambio_tasa_compra=' . $record->get_tipo_cambio_tasa_compra() . ',' .
        'tipo_cambio_tasa_venta=' . $record->get_tipo_cambio_tasa_venta() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "tipo_cambio_id" = ' . $record->get_tipo_cambio_id() . '  and xmin =' . $record->getVersionId();

    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_tipo_cambio_tipo_cambio_id_seq\')';
    }

    private function _getFecthNormalized() {
        $sql = 'SELECT tipo_cambio_id,pd.moneda_codigo_origen,mo_o.moneda_descripcion as moneda_descripcion_o,'.
            'pd.moneda_codigo_destino,mo_d.moneda_descripcion as moneda_descripcion_d,tipo_cambio_fecha_desde,' .
            'tipo_cambio_fecha_hasta,tipo_cambio_tasa_compra,tipo_cambio_tasa_venta,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_tipo_cambio pd '.
            'INNER JOIN tb_moneda mo_o on mo_o.moneda_codigo = pd.moneda_codigo_origen '.
            'INNER JOIN tb_moneda mo_d on mo_d.moneda_codigo = pd.moneda_codigo_destino ';
        return $sql;
    }

}