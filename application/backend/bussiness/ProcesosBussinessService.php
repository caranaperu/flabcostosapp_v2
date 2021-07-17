<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los procesos
 *  tales como listar , agregar , eliminar , etc.
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class ProcesosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("ProcesosDAO", "procesos", "msg_procesos");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como ProcesosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ProcesosModel();
        // Leo el id enviado en el DTO
        $model->set_procesos_codigo($dto->getParameterValue('procesos_codigo'));
        $model->set_procesos_descripcion($dto->getParameterValue('procesos_descripcion'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como ProcesosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ProcesosModel();
        // Leo el id enviado en el DTO
        $model->set_procesos_codigo($dto->getParameterValue('procesos_codigo'));
        $model->set_procesos_descripcion($dto->getParameterValue('procesos_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como ProcesosModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new ProcesosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ProcesosModel();
        $model->set_procesos_codigo($dto->getParameterValue('procesos_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
