<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de la definicion de las conversiones
 * de las unidades de medida.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class UnidadMedidaConversionDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_unidad_medida_conversion WHERE unidad_medida_conversion_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  UnidadMedidaConversionModel */

        return 'insert into tb_unidad_medida_conversion (unidad_medida_origen,unidad_medida_destino,unidad_medida_conversion_factor,'
        . 'activo,usuario) values(\'' .
        $record->get_unidad_medida_origen() . '\',\'' .
        $record->get_unidad_medida_destino() . '\',' .
        $record->get_unidad_medida_conversion_factor() . ',\'' .
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
            $sql = 'SELECT unidad_medida_conversion_id,unidad_medida_origen,unidad_medida_destino,unidad_medida_conversion_factor,activo,xmin AS "versionId" ' .
                'FROM  tb_unidad_medida_conversion pd ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            // Mapeamos las virtuales a los campos reales
            $where = str_replace('"unidad_medida_descripcion_o"', 'um1.unidad_medida_descripcion', $where);
            $where = str_replace('"unidad_medida_descripcion_d"', 'um2.unidad_medida_descripcion', $where);

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
            $sql .= ' WHERE unidad_medida_conversion_id = ' . $code;
        } else {
            $sql =  'SELECT unidad_medida_conversion_id,unidad_medida_origen,unidad_medida_destino,unidad_medida_conversion_factor,activo,xmin AS "versionId" ' .
            'FROM tb_unidad_medida_conversion WHERE unidad_medida_conversion_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  UnidadMedidaConversionModel */

        return 'update tb_unidad_medida_conversion set unidad_medida_conversion_id=' . $record->get_unidad_medida_conversion_id() . ',' .
        'unidad_medida_origen=\'' . $record->get_unidad_medida_origen() . '\',' .
        'unidad_medida_destino=\'' . $record->get_unidad_medida_destino() . '\',' .
        'unidad_medida_conversion_factor=' . $record->get_unidad_medida_conversion_factor() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "unidad_medida_conversion_id" = ' . $record->get_unidad_medida_conversion_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT unidad_medida_conversion_id,unidad_medida_origen,um1.unidad_medida_descripcion as unidad_medida_descripcion_o,'.
            'unidad_medida_destino,um2.unidad_medida_descripcion as unidad_medida_descripcion_d,unidad_medida_conversion_factor,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_unidad_medida_conversion pd ' .
            'INNER JOIN tb_unidad_medida um1 on um1.unidad_medida_codigo = pd.unidad_medida_origen ' .
            'INNER JOIN tb_unidad_medida um2 on um2.unidad_medida_codigo = pd.unidad_medida_destino';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_unidad_medida_conversion_unidad_medida_conversion_id_seq\')';
    }
}