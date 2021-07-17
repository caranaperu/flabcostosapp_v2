<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de cada entrada de proceso a asignar en la relacion tipo aplicacion-procesos.
 *  tales como listar , agregar , eliminar , etc.
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class TipoAplicacionProcesosDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoAplicacionProcesosDetalleDAO", "taplicacion_procesos_detalle", "msg_taplicacion_procesos_detalle");
    }

    /**
     * @inheritdoc
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoAplicacionProcesosDetalleModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoAplicacionProcesosDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_taplicacion_procesos_id($dto->getParameterValue('taplicacion_procesos_id'));
        $model->set_procesos_codigo($dto->getParameterValue('procesos_codigo'));
        $model->set_taplicacion_procesos_detalle_porcentaje($dto->getParameterValue('taplicacion_procesos_detalle_porcentaje'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoAplicacionProcesosDetalleModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoAplicacionProcesosDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_taplicacion_procesos_detalle_id($dto->getParameterValue('taplicacion_procesos_detalle_id'));
        $model->set_taplicacion_procesos_id($dto->getParameterValue('taplicacion_procesos_id'));
        $model->set_procesos_codigo($dto->getParameterValue('procesos_codigo'));
        $model->set_taplicacion_procesos_detalle_porcentaje($dto->getParameterValue('taplicacion_procesos_detalle_porcentaje'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoAplicacionProcesosDetalleModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new TipoAplicacionProcesosDetalleModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoAplicacionProcesosDetalleModel();
        $model->set_taplicacion_procesos_detalle_id($dto->getParameterValue('taplicacion_procesos_detalle_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

