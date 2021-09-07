<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de la cabecera de la relacion producto-procesos
 *  tales como listar , agregar , eliminar , etc.
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class ProductoProcesosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("ProductoProcesosDAO", "producto_procesos", "msg_producto_procesos");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como ProductoProcesosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ProductoProcesosModel();
        // Leo el id enviado en el DTO
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_producto_procesos_fecha_desde($dto->getParameterValue('producto_procesos_fecha_desde'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como ProductoProcesosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ProductoProcesosModel();
        // Leo el id enviado en el DTO
        $model->set_producto_procesos_id($dto->getParameterValue('producto_procesos_id'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_producto_procesos_fecha_desde($dto->getParameterValue('producto_procesos_fecha_desde'));


        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como ProductoProcesosModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new ProductoProcesosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ProductoProcesosModel();
        $model->set_producto_procesos_id($dto->getParameterValue('producto_procesos_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

