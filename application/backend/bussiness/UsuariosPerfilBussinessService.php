<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los perfiles asociados
 * a u determinado usuario.
 *
 * @author $Author: aranape $
 * @version $Id: UsuariosPerfilBussinessService.php 400 2014-01-11 09:27:19Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-01-11 04:27:19 -0500 (sáb, 11 ene 2014) $
 * $Rev: 400 $
 */
class UsuariosPerfilBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("UsuariosPerfilDAO", "usuario_perfil", "msg_usuario_perfil");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel en este caso UsuariosPerfilModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosPerfilModel();
        //
        $model->set_usuarios_id($dto->getParameterValue('usuarios_id'));
        $model->set_perfil_id($dto->getParameterValue('perfil_id'));

        $model->setActivo($dto->getParameterValue('activo'));

        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel en este caso UsuariosPerfilModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel{
        $model = new UsuariosPerfilModel();
        //
        $model->set_usuario_perfil_id($dto->getParameterValue('usuario_perfil_id'));
        $model->set_usuarios_id($dto->getParameterValue('usuarios_id'));
        $model->set_perfil_id($dto->getParameterValue('perfil_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel en este caso UsuariosPerfilModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new UsuariosPerfilModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosPerfilModel();
        $model->set_usuario_perfil_id($dto->getParameterValue('usuario_perfil_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}
