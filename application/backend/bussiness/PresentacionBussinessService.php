<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los presentaciones de
 *  productos tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 05-Mar-2019
 */
class PresentacionBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("PresentacionDAO", "tpresentacion", "msg_tpresentacion");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como PresentacionModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new PresentacionModel();
        // Leo el id enviado en el DTO
        $model->set_tpresentacion_codigo($dto->getParameterValue('tpresentacion_codigo'));
        $model->set_tpresentacion_descripcion($dto->getParameterValue('tpresentacion_descripcion'));
        $model->set_tpresentacion_protected(($dto->getParameterValue('tpresentacion_protected') == 'true' ? true : false));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como PresentacionModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new PresentacionModel();
        // Leo el id enviado en el DTO
        $model->set_tpresentacion_codigo($dto->getParameterValue('tpresentacion_codigo'));
        $model->set_tpresentacion_descripcion($dto->getParameterValue('tpresentacion_descripcion'));
        $model->set_tpresentacion_protected(($dto->getParameterValue('tpresentacion_protected') == 'true' ? true : false));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como PresentacionModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new PresentacionModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new PresentacionModel();
        $model->set_tpresentacion_codigo($dto->getParameterValue('tpresentacion_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
