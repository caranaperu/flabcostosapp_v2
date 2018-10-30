<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para el menu del sistema
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: SystemMenuDAO_postgre.php 142 2014-04-07 00:38:59Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:38:59 -0500 (dom, 06 abr 2014) $
 * $Rev: 142 $
 */
class SystemMenuDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * El orden ya esta prefijado ignorara cual parametro en ese sentido.
     *
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {

        if ($subOperation == 'fetchForUser') {
            $systemCode = $constraints->getFilterField('sys_systemcode');
            $usuario_id = $constraints->getFilterField('usuario_id');
            $empresa_id = $constraints->getFilterField('empresa_id');

            $sql = 'select sm.menu_id,menu_codigo,menu_descripcion,menu_parent_id,menu_orden '.
                    'from tb_usuarios u '.
                    'inner join tb_sys_usuario_perfiles up on up.usuarios_id = u.usuarios_id '.
                    'inner join tb_sys_perfil_detalle pd on pd.perfil_id = up.perfil_id '.
                    'inner join tb_sys_menu sm on sm.menu_id = pd.menu_id '.
                    'where u.usuarios_id = '.$usuario_id.' and u.empresa_id = '.$empresa_id.' and sm.sys_systemcode = \''.$systemCode .'\''.
                    ' and sm.activo=true and pd.activo=true and up.activo=true and u.activo = true and pd.perfdet_accleer = true ';

            // Posterior a este punto no deben ser usados
            $constraints->removeFilterField('sys_systemcode');
            $constraints->removeFilterField('usuario_id');
            $constraints->removeFilterField('empresa_id');

        } else {
            // Si la busqueda permite buscar solo activos e inactivos
            $sql = 'select sys_systemcode,menu_id,menu_codigo,menu_descripcion,menu_accesstype,menu_parent_id,menu_orden,activo,xmin as "versionId" from  tb_sys_menu ';

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where "activo"=TRUE ';
            }

            $where = $constraints->getFilterFieldsAsString();
            if (strlen($where) > 0) {
                $sql .= ' and ' . $where;
            }
        }

        $sql .= ' order by menu_parent_id,menu_orden';

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        $sql = 'select sys_systemcode,menu_id,menu_codigo,menu_descripcion,menu_accesstype,menu_parent_id,menu_orden,activo,xmin as "versionId" from  tb_sys_menu ';
        $sql .= 'where menu_id=' . $id;
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        $sql = 'select sys_systemcode,menu_id,menu_codigo,menu_descripcion,menu_accesstype,menu_parent_id,menu_orden,activo,xmin as "versionId" from  tb_sys_menu ';
        $sql .= 'where menu_codigo=' . $code;
        return $sql;
    }

    /***********************************************************
     * Por ahora no se usan
     * ********************************************************/
    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        return NULL;
    }

    /**
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string {
        return NULL;
    }

    /**
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        return NULL;
    }

}
