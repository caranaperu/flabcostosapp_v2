<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los tipos de clientes
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: UnidadMedidaBussinessService.php 136 2014-04-07 00:31:52Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class TipoClienteBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoClienteDAO", "tcliente", "msg_tcliente");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoClienteModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoClienteModel();
        // Leo el id enviado en el DTO
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->set_tipo_cliente_descripcion($dto->getParameterValue('tipo_cliente_descripcion'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoClienteModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoClienteModel();
        // Leo el id enviado en el DTO
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->set_tipo_cliente_descripcion($dto->getParameterValue('tipo_cliente_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoClienteModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new TipoClienteModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoClienteModel();
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
