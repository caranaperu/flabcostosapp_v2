<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las tipos de costos globales-
 *
 * @author  Carlos Arana Reategui
 * @since   13-MAY-2021
 * @version 1.00
 * @history ''
 *
 */
class TipoCostoGlobalDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string {
        return 'delete from tb_tcosto_global where tcosto_global_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  TipoCostoGlobalModel  */
        return 'insert into tb_tcosto_global (tcosto_global_codigo,tcosto_global_descripcion,activo,usuario) values(\'' .
                $record->get_tcosto_global_codigo() . '\',\'' .
                $record->get_tcosto_global_descripcion() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select tcosto_global_codigo,tcosto_global_descripcion,tcosto_global_protected,activo,xmin as "versionId" from  tb_tcosto_global ';

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where "activo"=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();
        if (strlen($where) > 0) {
            $sql .= ' and ' . $where;
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
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints,$subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        return 'select tcosto_global_codigo,tcosto_global_descripcion,tcosto_global_protected,activo,' .
                'xmin as "versionId" from tb_tcosto_global where "tcosto_global_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  TipoCostoGlobalModel  */
        return 'update tb_tcosto_global set tcosto_global_codigo=\'' . $record->get_tcosto_global_codigo() . '\','.
                'tcosto_global_descripcion=\'' . $record->get_tcosto_global_descripcion() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "tcosto_global_codigo" = \'' . $record->get_tcosto_global_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}
