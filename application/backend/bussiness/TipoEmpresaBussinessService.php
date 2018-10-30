<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los tipos de empresas.
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
class TipoEmpresaBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoEmpresaDAO", "tempresa", "msg_tempresa");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoEmpresaModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoEmpresaModel();
        // Leo el id enviado en el DTO
        $model->set_tipo_empresa_codigo($dto->getParameterValue('tipo_empresa_codigo'));
        $model->set_tipo_empresa_descripcion($dto->getParameterValue('tipo_empresa_descripcion'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoEmpresaModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoEmpresaModel();
        // Leo el id enviado en el DTO
        $model->set_tipo_empresa_codigo($dto->getParameterValue('tipo_empresa_codigo'));
        $model->set_tipo_empresa_descripcion($dto->getParameterValue('tipo_empresa_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoEmpresaModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new TipoEmpresaModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoEmpresaModel();
        $model->set_tipo_empresa_codigo($dto->getParameterValue('tipo_empresa_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

