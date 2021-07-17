<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los tipos de aplicacion
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 26-Jun-2021
 * @version 1.0
 * @history
 */
class TipoAplicacionBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoAplicacionDAO", "tipoaplicacion", "msg_tipoaplicacion");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoAplicacionModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoAplicacionModel();
        // Leo el id enviado en el DTO
        $model->set_taplicacion_codigo($dto->getParameterValue('taplicacion_codigo'));
        $model->set_taplicacion_descripcion($dto->getParameterValue('taplicacion_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoAplicacionModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoAplicacionModel();
        // Leo el id enviado en el DTO
        $model->set_taplicacion_codigo($dto->getParameterValue('taplicacion_codigo'));
        $model->set_taplicacion_descripcion($dto->getParameterValue('taplicacion_descripcion'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoAplicacionModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new TipoAplicacionModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoAplicacionModel();
        $model->set_taplicacion_codigo($dto->getParameterValue('taplicacion_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
