<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las tios de Aplicacion de los poductos
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesDAO_postgre.php 275 2014-06-27 22:29:31Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 17:29:31 -0500 (vie, 27 jun 2014) $
 * $Rev: 275 $
 */
class TipoAplicacionDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_taplicacion where taplicacion_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  TipoAplicacionModel  */
        return 'insert into tb_taplicacion (taplicacion_codigo,taplicacion_descripcion,'
        . 'activo,usuario) values(\'' .
        $record->get_taplicacion_codigo() . '\',\'' .
        $record->get_taplicacion_descripcion() . '\',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select taplicacion_codigo,taplicacion_descripcion,activo,xmin as "versionId" from  tb_taplicacion ';

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
        // el campo taplicacion_protected es mapeado a 1 o 0 dado que la conversion a booleana del php no funcionaria
        // correctamente.
        return 'select taplicacion_codigo,taplicacion_descripcion,activo,' .
                'xmin as "versionId" from tb_taplicacion where taplicacion_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  TipoAplicacionModel  */

        return 'update tb_taplicacion set taplicacion_codigo=\'' . $record->get_taplicacion_codigo() . '\','.
        'taplicacion_descripcion=\'' . $record->get_taplicacion_descripcion() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "taplicacion_codigo" = \'' . $record->get_taplicacion_codigo() . '\'  and xmin =' . $record->getVersionId();

    }

}
