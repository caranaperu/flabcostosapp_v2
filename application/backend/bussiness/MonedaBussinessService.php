<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las monedas
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
class MonedaBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("MonedaDAO", "moneda", "msg_moneda");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como MonedaModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new MonedaModel();
        // Leo el id enviado en el DTO
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));
        $model->set_moneda_descripcion($dto->getParameterValue('moneda_descripcion'));
        $model->set_moneda_simbolo($dto->getParameterValue('moneda_simbolo'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como MonedaModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new MonedaModel();
        // Leo el id enviado en el DTO
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));
        $model->set_moneda_descripcion($dto->getParameterValue('moneda_descripcion'));
        $model->set_moneda_simbolo($dto->getParameterValue('moneda_simbolo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como MonedaModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new MonedaModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new MonedaModel();
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
