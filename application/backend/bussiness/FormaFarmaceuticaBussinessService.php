<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los formas farmaceuticas
 *  de los productos productos tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 05-Mar-2019
 */
class FormaFarmaceuticaBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("FormaFarmaceuticaDAO", "ffarmaceutica", "msg_ffarmaceutica");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como FormaFarmaceuticaModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new FormaFarmaceuticaModel();
        // Leo el id enviado en el DTO
        $model->set_ffarmaceutica_codigo($dto->getParameterValue('ffarmaceutica_codigo'));
        $model->set_ffarmaceutica_descripcion($dto->getParameterValue('ffarmaceutica_descripcion'));
        $model->set_ffarmaceutica_protected(($dto->getParameterValue('ffarmaceutica_protected') == 'true' ? true : false));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como FormaFarmaceuticaModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new FormaFarmaceuticaModel();
        // Leo el id enviado en el DTO
        $model->set_ffarmaceutica_codigo($dto->getParameterValue('ffarmaceutica_codigo'));
        $model->set_ffarmaceutica_descripcion($dto->getParameterValue('ffarmaceutica_descripcion'));
        $model->set_ffarmaceutica_protected(($dto->getParameterValue('ffarmaceutica_protected') == 'true' ? true : false));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como FormaFarmaceuticaModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new FormaFarmaceuticaModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new FormaFarmaceuticaModel();
        $model->set_ffarmaceutica_codigo($dto->getParameterValue('ffarmaceutica_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
