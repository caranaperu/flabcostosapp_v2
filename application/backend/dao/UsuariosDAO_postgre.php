<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los usuarios
 *
 * @author  $Author: aranape@gmail.com $
 * @since   06-FEB-2013
 * @version $Id: UsuariosDAO_postgre.php 57 2015-08-23 22:46:22Z aranape@gmail.com $
 * @history ''
 *
 * $Date: 2015-08-23 17:46:22 -0500 (dom, 23 ago 2015) $
 * $Rev: 57 $
 */
class UsuariosDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * No usable en este caso siempre sera false
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct(false);
    }

    /**
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string {
        return 'delete from tb_usuarios where usuarios_id = ' . $id . '  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL)  : string {
        /* @var $record  UsuariosModel  */
        return 'insert into tb_usuarios (usuarios_code,usuarios_password,usuarios_nombre_completo,empresa_id,usuarios_admin,activo,usuario) values(\''.
                $record->get_usuarios_code() . '\',\'' .
                $record->get_usuarios_password() . '\',\'' .
                $record->get_usuarios_nombre_completo() . '\',' .
                $record->get_empresa_id() . ',\'' .
                ($record->get_usuarios_admin() != TRUE ? '0' : '1') .  '\',\'' .
                ($record->getActivo() != TRUE ? '0' : '1') . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string {
        if ($subOperation == 'fetchJoined') {
            $sql = $this->_getFecthNormalized();
        } else {
            $sql = 'select usuarios_id,usuarios_code,usuarios_password,usuarios_nombre_completo,usuarios_admin,empresa_id,activo,xmin as "versionId" from  tb_usuarios u';
        }


        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where u.activo=TRUE ';
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

        $sql = str_replace('like', 'ilike', $sql);
//echo $sql;
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' WHERE usuarios_id = ' . $code;
        } else if ($subOperation == 'checkLogin') {

            $usuarios_code = $constraints->getFilterField('usuarios_code');
            $usuarios_password = $constraints->getFilterField('usuarios_password');

            $sql ='select usuarios_id,usuarios_code,usuarios_nombre_completo,usuarios_admin,empresa_id from tb_usuarios '
                . 'where usuarios_code =  \'' . $usuarios_code . '\' and usuarios_password = \''.$usuarios_password.'\' and activo=true ';
        } else {
            $sql ='select usuarios_id,usuarios_code,usuarios_password,usuarios_nombre_completo,usuarios_admin,empresa_id,activo,xmin as "versionId" from tb_usuarios '
                . 'where usuarios_id =  ' . $code;
        }

        return $sql;
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  UsuariosModel  */
        return 'update tb_usuarios set usuarios_code=\'' . $record->get_usuarios_code() . '\',' .
                'usuarios_password=\''.$record->get_usuarios_password(). '\',' .
                'usuarios_nombre_completo=\''.$record->get_usuarios_nombre_completo(). '\',' .
                'usuarios_admin=\''.($record->get_usuarios_admin() != TRUE ? '0' : '1') . '\',' .
                'empresa_id='.$record->get_empresa_id() . ',' .
                'activo=\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "usuarios_id" = ' . $record->get_usuarios_id() . '  and xmin =' . $record->getVersionId();
    }

    private function _getFecthNormalized() {
        $sql = 'select usuarios_id,usuarios_code,usuarios_password,usuarios_nombre_completo,usuarios_admin,'.
                'u.empresa_id,empresa_razon_social,u.activo,u.xmin as "versionId" from tb_usuarios u '.
                'inner join tb_empresa e on e.empresa_id=u.empresa_id ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL)  : string {
        return 'SELECT currval(\'tb_usuarios_usuarios_id_seq\')';
    }

}
