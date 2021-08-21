<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula los headers de perfiles de usuario.
 *
 * @author $Author: aranape $
 * @version $Id: PerfilBussinessService.php 402 2014-01-11 09:28:24Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-01-11 04:28:24 -0500 (sáb, 11 ene 2014) $
 * $Rev: 402 $
 */
class PerfilBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("app\\common\\dao\\impl\\TSLAppPerfilDAO", "perfil", "msg_perfil");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como \app\common\model\impl\TSLAppPerfilModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new \app\common\model\impl\TSLAppPerfilModel();
        //
        $model->set_sys_systemcode($dto->getParameterValue('sys_systemcode'));
        $model->set_perfil_codigo($dto->getParameterValue('perfil_codigo'));
        $model->set_perfil_descripcion($dto->getParameterValue('perfil_descripcion'));

        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        }
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como \app\common\model\impl\TSLAppPerfilModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new \app\common\model\impl\TSLAppPerfilModel();
        //
        $model->set_perfil_id($dto->getParameterValue('perfil_id'));
        $model->set_sys_systemcode($dto->getParameterValue('sys_systemcode'));
        $model->set_perfil_codigo($dto->getParameterValue('perfil_codigo'));
        $model->set_perfil_descripcion($dto->getParameterValue('perfil_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        }
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como \app\common\model\impl\TSLAppPerfilModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new \app\common\model\impl\TSLAppPerfilModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como \app\common\model\impl\TSLAppPerfilModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new \app\common\model\impl\TSLAppPerfilModel();
        $model->set_perfil_id($dto->getParameterValue('perfil_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}

