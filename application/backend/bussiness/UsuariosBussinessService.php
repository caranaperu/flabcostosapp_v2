<?php
//declare(strict_types=1);

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las operaciones a los usuarios
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape@gmail.com $
 * @history 09-02-2017 Compatibilidad con php 7 , manejo del booleano se tuvo que ajustar.
 *
 *
 */
class UsuariosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("UsuariosDAO", "usuarios", "msg_usuarios");
    }

    /**
     * NO usada
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel en este caso UsuariosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosModel();
        $model->set_usuarios_code($dto->getParameterValue('usuarios_code'));
        $model->set_usuarios_password($dto->getParameterValue('usuarios_password'));
        $model->set_usuarios_nombre_completo($dto->getParameterValue('usuarios_nombre_completo'));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_usuarios_admin(($dto->getParameterValue('usuarios_admin') == 'true' ? true : false));

        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        } else {
            $model->setActivo(FALSE);
        }
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     * NO USADA
     * @param \TSLIDataTransferObj $dto
     * @return  \TSLDataModel en este caso UsuariosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto): \TSLDataModel {
        $model = new UsuariosModel();

        $model->set_usuarios_id($dto->getParameterValue('usuarios_id'));
        $model->set_usuarios_code($dto->getParameterValue('usuarios_code'));
        $model->set_usuarios_password($dto->getParameterValue('usuarios_password'));
        $model->set_usuarios_nombre_completo($dto->getParameterValue('usuarios_nombre_completo'));
        $model->set_usuarios_admin(($dto->getParameterValue('usuarios_admin') == 'true' ? true : false));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        } else {
            $model->setActivo(FALSE);
        }
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel en este caso UsuariosModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new UsuariosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosModel();
        $model->set_usuarios_id($dto->getParameterValue('usuarios_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}
