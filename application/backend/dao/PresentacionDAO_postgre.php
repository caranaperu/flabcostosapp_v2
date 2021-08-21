<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las presentaciones de producto
 *
 * @author  $Author: aranape $
 * @since   04-MAR-2019
 * @history ''
 *
 */
class PresentacionDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_tpresentacion where tpresentacion_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  TipoInsumoModel  */
        return 'insert into tb_tpresentacion (tpresentacion_codigo,tpresentacion_descripcion,tpresentacion_protected,'
        . 'activo,usuario) values(\'' .
        $record->get_tpresentacion_codigo() . '\',\'' .
        $record->get_tpresentacion_descripcion() . '\',' .
        ($record->get_tpresentacion_protected() != TRUE ? '0' : '1') . '::boolean,\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select tpresentacion_codigo,tpresentacion_descripcion,tpresentacion_protected,activo,xmin as "versionId" from  tb_tpresentacion ';

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where "activo"=TRUE ';
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
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation );
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // el campo tpresentacion_protected es mapeado a 1 o 0 dado que la conversion a booleana del php no funcionaria
        // correctamente.
        return 'select tpresentacion_codigo,tpresentacion_descripcion,case when tpresentacion_protected = \'f\' then \'0\' else \'1\' end as tpresentacion_protected,activo,' .
                'xmin as "versionId" from tb_tpresentacion where tpresentacion_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  TipoInsumoModel  */

        return 'update tb_tpresentacion set tpresentacion_codigo=\'' . $record->get_tpresentacion_codigo() . '\','.
        'tpresentacion_descripcion=\'' . $record->get_tpresentacion_descripcion() . '\',' .
        'tpresentacion_protected=\'' . ($record->get_tpresentacion_protected() != TRUE ? '0' : '1') . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "tpresentacion_codigo" = \'' . $record->get_tpresentacion_codigo() . '\'  and xmin =' . $record->getVersionId();

    }

}
