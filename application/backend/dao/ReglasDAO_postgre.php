<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico de las reglas para los costos entre 2 empresas.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class ReglasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_reglas WHERE regla_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  ReglasModel */

        return 'insert into tb_reglas (regla_empresa_origen_id,regla_empresa_destino_id,'
        . 'regla_by_costo,regla_porcentaje,activo,usuario) values(' .
        $record->get_regla_empresa_origen_id() . ',' .
        $record->get_regla_empresa_destino_id() . ',\'' .
        ($record->get_regla_by_costo() != TRUE ? '0' : '1') . '\'::boolean,' .
        $record->get_regla_porcentaje() . ',\'' .
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
            $sql = 'select regla_id,regla_empresa_origen_id,regla_empresa_destino_id,regla_by_costo,regla_porcentaje,activo,xmin AS "versionId"'.
                'FROM  tb_reglas rg ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where rg.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            if ($subOperation == 'fetchJoined') {
                // Mapeamos las virtuales a los campos reales
                $where = str_replace('"empresa_razon_social_o"', 'e1.empresa_razon_social', $where);
                $where = str_replace('"empresa_razon_social_d"', 'e2.empresa_razon_social', $where);
            }
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
            $sql .= ' WHERE regla_id = ' . $code;
        } else {
            $sql =  'select regla_id,regla_empresa_origen_id,regla_empresa_destino_id,regla_by_costo,regla_porcentaje,activo,xmin AS "versionId"'.
                        'FROM  tb_reglas  WHERE regla_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  ReglasModel */
        return 'update tb_reglas set regla_id=' . $record->get_regla_id() . ',' .
        'regla_empresa_origen_id=' . $record->get_regla_empresa_origen_id() . ',' .
        'regla_empresa_destino_id=' . $record->get_regla_empresa_destino_id() . ',' .
        'regla_by_costo=\'' . ($record->get_regla_by_costo() != TRUE ? '0' : '1') . '\'::boolean,' .
        'regla_porcentaje=' . $record->get_regla_porcentaje() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "regla_id" = ' . $record->get_regla_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {

        $sql = 'select regla_id,regla_empresa_origen_id,e1.empresa_razon_social as empresa_razon_social_o,regla_empresa_destino_id,e2.empresa_razon_social as empresa_razon_social_d,regla_by_costo,'.
                'regla_porcentaje,rg.activo,rg.xmin AS "versionId" '.
                'FROM  tb_reglas rg '.
                'INNER JOIN tb_empresa e1 on e1.empresa_id = rg.regla_empresa_origen_id ' .
                'INNER JOIN tb_empresa e2 on e2.empresa_id = rg.regla_empresa_destino_id ' ;
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_reglas_regla_id_seq\')';
    }
}