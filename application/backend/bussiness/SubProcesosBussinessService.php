<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los subprocesos
 *  tales como listar , agregar , eliminar , etc.
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class SubProcesosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("SubProcesosDAO", "subprocesos", "msg_subprocesos");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como SubProcesosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new SubProcesosModel();
        // Leo el id enviado en el DTO
        $model->set_subprocesos_codigo($dto->getParameterValue('subprocesos_codigo'));
        $model->set_subprocesos_descripcion($dto->getParameterValue('subprocesos_descripcion'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como SubProcesosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new SubProcesosModel();
        // Leo el id enviado en el DTO
        $model->set_subprocesos_codigo($dto->getParameterValue('subprocesos_codigo'));
        $model->set_subprocesos_descripcion($dto->getParameterValue('subprocesos_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como SubProcesosModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new SubProcesosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new SubProcesosModel();
        $model->set_subprocesos_codigo($dto->getParameterValue('subprocesos_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
