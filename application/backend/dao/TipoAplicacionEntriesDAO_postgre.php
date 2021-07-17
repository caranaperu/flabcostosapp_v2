<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las subtipos de Aplicacion de los productos
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesDAO_postgre.php 275 2014-06-27 22:29:31Z aranape $
 * @history ''
 *
 */
class TipoAplicacionEntriesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_taplicacion_entries where taplicacion_entries_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  TipoAplicacionEntriesModel  */
        return 'insert into tb_taplicacion_entries (taplicacion_codigo,taplicacion_entries_descripcion,'
        . 'activo,usuario) values(\'' .
        $record->get_taplicacion_codigo() . '\',\'' .
        $record->get_taplicacion_entries_descripcion() . '\',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        if ($subOperation == 'fetchForPick') {
            $sql = 'select taplicacion_entries_id,taplicacion_descripcion,taplicacion_entries_descripcion from tb_taplicacion_entries e '.
                'inner join tb_taplicacion a on a.taplicacion_codigo = e.taplicacion_codigo ';

        } else {
            $sql = 'select taplicacion_entries_id,taplicacion_codigo,taplicacion_entries_descripcion,activo,xmin as "versionId" from  tb_taplicacion_entries e ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where e.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();
        if (strlen($where) > 0) {
            if ($this->activeSearchOnly == TRUE) {
                $sql .= ' and ' . $where;
            } else {
                $sql .= ' where ' . $where;
            }
        }

        if ($subOperation == 'fetchForPick') {
            $sql .= ' order by taplicacion_descripcion,taplicacion_entries_descripcion';
        } else {
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
        }

        //echo $sql;
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
        return 'select taplicacion_entries_id,taplicacion_codigo,taplicacion_entries_descripcion,activo,' .
                'xmin as "versionId" from tb_taplicacion_entries where taplicacion_entries_id =  ' . $code ;
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  TipoAplicacionEntriesModel  */

        return 'update tb_taplicacion_entries set '.
            'taplicacion_entries_id= ' . $record->get_taplicacion_entries_id() . ','.
            'taplicacion_codigo=\'' . $record->get_taplicacion_codigo() . '\','.
            'taplicacion_entries_descripcion=\'' . $record->get_taplicacion_entries_descripcion() . '\',' .
            'activo=\'' . $record->getActivo() . '\',' .
            'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
            ' where "taplicacion_entries_id" = ' . $record->get_taplicacion_entries_id() . '  and xmin =' . $record->getVersionId();

    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_taplicacion_entries_taplicacion_entries_id_seq\')';
    }

}
