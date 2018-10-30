<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las tios de insumo-
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesDAO_postgre.php 275 2014-06-27 22:29:31Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 17:29:31 -0500 (vie, 27 jun 2014) $
 * $Rev: 275 $
 */
class TipoInsumoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_tinsumo where tinsumo_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  TipoInsumoModel  */
        return 'insert into tb_tinsumo (tinsumo_codigo,tinsumo_descripcion,tinsumo_protected,'
        . 'activo,usuario) values(\'' .
        $record->get_tinsumo_codigo() . '\',\'' .
        $record->get_tinsumo_descripcion() . '\',' .
        ($record->get_tinsumo_protected() != TRUE ? '0' : '1') . '::boolean,\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select tinsumo_codigo,tinsumo_descripcion,tinsumo_protected,activo,xmin as "versionId" from  tb_tinsumo ';

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
        return 'select tinsumo_codigo,tinsumo_descripcion,tinsumo_protected,activo,' .
                'xmin as "versionId" from tb_tinsumo where tinsumo_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  TipoInsumoModel  */

        return 'update tb_tinsumo set tinsumo_codigo=\'' . $record->get_tinsumo_codigo() . '\','.
        'tinsumo_descripcion=\'' . $record->get_tinsumo_descripcion() . '\',' .
        'tinsumo_protected=\'' . ($record->get_tinsumo_protected() != TRUE ? '0' : '1') . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "tinsumo_codigo" = \'' . $record->get_tinsumo_codigo() . '\'  and xmin =' . $record->getVersionId();

    }

}
