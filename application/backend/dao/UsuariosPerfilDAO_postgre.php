<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO manipula la relacion del usuario con los perfiles
 * asociados para cada sistema.
 *
 * @author  $Author: aranape $
 * @version $Id: UsuariosPerfilDAO_postgre.php 389 2014-01-11 09:18:02Z aranape $
 * @history ''
 *
 * $Date: 2014-01-11 04:18:02 -0500 (sáb, 11 ene 2014) $
 * $Rev: 389 $
 */
class UsuariosPerfilDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        // Aqui deberan resentarse sean activos o no.
        parent::__construct(FALSE);
    }

    /**
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string {
        return 'delete from tb_sys_usuario_perfiles where "usuario_perfil_id" = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record UsuariosPerfilModel */
        $sql = 'insert into tb_sys_usuario_perfiles (usuarios_id,perfil_id,activo,usuario) values(' .
                $record->get_usuarios_id() . ',' .
                $record->get_perfil_id() . ',\'' .
                ($record->getActivo() ? 'true' : 'false') . '\',\'' .
                $record->getUsuario() . '\')';

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
//        $sql = 'select usuario_perfil_id,usuarios_id,perfil_id,activo,xmin as "versionId"';


        if ($subOperation == 'fetchFull') {
            $sql = 'select usuario_perfil_id,usuarios_id,up.perfil_id,up.activo,up.xmin as "versionId",sys_systemcode from tb_sys_usuario_perfiles up
                    inner join tb_sys_perfil pr on pr.perfil_id = up.perfil_id ';
        } else {
            $sql = 'select usuario_perfil_id,usuarios_id,up.perfil_id,up.activo,up.xmin as "versionId" from tb_sys_usuario_perfiles up ';
        }

        /*  if ($this->activeSearchOnly == TRUE) {
          // Solo activos
          $sql .= ' where activo=TRUE ';
          } */

        $where = $constraints->getFilterFieldsAsString();
        if (strlen($where) > 0) {
            $sql .= ' where ' . $where;
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

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        return 'select usuario_perfil_id,usuarios_id,perfil_id,activo,xmin as "versionId" from tb_sys_usuario_perfiles where usuario_perfil_id = ' . $id;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string {
        return $this->getRecordQuery($code,$constraints, $subOperation);
    }

    /**
     * La metodologia para el update es un hack por problemas en el psotgresql cuando un insert
     * es llevado a una function procedure , recomendamos leer el stored procedure.
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record UsuariosPerfilModel */
        $sql = 'update tb_sys_usuario_perfiles set ' .
                'usuario_perfil_id=' . $record->get_usuario_perfil_id() . ',' .
                'usuarios_id=' . $record->get_usuarios_id() . ',' .
                'perfil_id=' . $record->get_perfil_id() . ',' .
                'activo=\'' . ($record->getActivo() ? 'true' : 'false') . '\'' .
                ',"usuario_mod"=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "usuario_perfil_id" = ' . $record->getId() . '  and xmin =' . $record->getVersionId();
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL)  : string {
        return 'SELECT currval(\'tb_sys_usuario_perfiles_usuario_perfil_id_seq\')';
    }

}
