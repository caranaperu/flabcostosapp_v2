<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los yipos de insumo
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: RegionesBussinessService.php 271 2014-06-27 20:22:18Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-27 15:22:18 -0500 (vie, 27 jun 2014) $
 * $Rev: 271 $
 */
class TipoInsumoBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoInsumoDAO", "tipoinsumo", "msg_tipoinsumo");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoInsumoModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoInsumoModel();
        // Leo el id enviado en el DTO
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->set_tinsumo_descripcion($dto->getParameterValue('tinsumo_descripcion'));
        $model->set_tinsumo_protected(($dto->getParameterValue('tinsumo_protected') == 'true' ? true : false));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como TipoInsumoModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoInsumoModel();
        // Leo el id enviado en el DTO
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->set_tinsumo_descripcion($dto->getParameterValue('tinsumo_descripcion'));
        $model->set_tinsumo_protected(($dto->getParameterValue('tinsumo_protected') == 'true' ? true : false));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoInsumoModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new TipoInsumoModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new TipoInsumoModel();
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
