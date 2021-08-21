<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los tipos de costos globnales
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author Carlos Arana Reategui
 * @since 13-May-2021
 * @version 1.00
 * @history ''
 *
 */
class TipoCostoGlobalBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoCostoGlobalDAO", "tcosto_global", "msg_tcosto_global");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoCostoGlobalModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoCostoGlobalModel();
        // Leo el id enviado en el DTO
        $model->set_tcosto_global_codigo($dto->getParameterValue('tcosto_global_codigo'));
        $model->set_tcosto_global_descripcion($dto->getParameterValue('tcosto_global_descripcion'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoCostoGlobalModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoCostoGlobalModel();
        // Leo el id enviado en el DTO
        $model->set_tcosto_global_codigo($dto->getParameterValue('tcosto_global_codigo'));
        $model->set_tcosto_global_descripcion($dto->getParameterValue('tcosto_global_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoCostoGlobalModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new TipoCostoGlobalModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoCostoGlobalModel();
        $model->set_tcosto_global_codigo($dto->getParameterValue('tcosto_global_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
