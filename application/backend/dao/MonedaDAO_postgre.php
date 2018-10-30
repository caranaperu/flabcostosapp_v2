<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las monedas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UnidadMedidaDAO_postgre.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class MonedaDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_moneda where moneda_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  MonedaModel  */
        return 'insert into tb_moneda (moneda_codigo,moneda_descripcion,moneda_simbolo,'
        . 'activo,usuario) values(\'' .
                $record->get_moneda_codigo() . '\',\'' .
                $record->get_moneda_descripcion() . '\',\'' .
                $record->get_moneda_simbolo(). '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select moneda_codigo,moneda_simbolo,moneda_descripcion,moneda_protected,activo,xmin as "versionId" from  tb_moneda ';

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
        return 'select moneda_codigo,moneda_simbolo,moneda_descripcion,moneda_protected,activo,' .
                'xmin as "versionId" from tb_moneda where "moneda_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  MonedaModel  */
        return 'update tb_moneda set moneda_codigo=\'' . $record->get_moneda_codigo() . '\','.
                'moneda_descripcion=\'' . $record->get_moneda_descripcion() . '\',' .
                'moneda_simbolo=\'' . $record->get_moneda_simbolo() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "moneda_codigo" = \'' . $record->get_moneda_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}
