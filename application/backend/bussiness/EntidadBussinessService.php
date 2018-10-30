<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones a los datos
 * basicos de la entidad usuaria del producto.
 *
 * @author $Author: aranape $
 * @version $Id: EntidadBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class EntidadBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("EntidadDAO", "entidad", "msg_entidad");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como EntidadModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new EntidadModel();
        // Leo el id enviado en el DTO
        $model->set_entidad_razon_social($dto->getParameterValue('entidad_razon_social'));
        $model->set_entidad_ruc($dto->getParameterValue('entidad_ruc'));
        $model->set_entidad_direccion($dto->getParameterValue('entidad_direccion'));
        $model->set_entidad_telefonos($dto->getParameterValue('entidad_telefonos'));
        $model->set_entidad_fax($dto->getParameterValue('entidad_fax'));
        $model->set_entidad_correo($dto->getParameterValue('entidad_correo'));

        // En el caso de agregar una entidad siempre ira en true
        $model->setActivo(TRUE);
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como EntidadModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new EntidadModel();
        // Leo el id enviado en el DTO
        $model->set_entidad_id($dto->getParameterValue('entidad_id'));
        $model->set_entidad_razon_social($dto->getParameterValue('entidad_razon_social'));
        $model->set_entidad_ruc($dto->getParameterValue('entidad_ruc'));
        $model->set_entidad_direccion($dto->getParameterValue('entidad_direccion'));
        $model->set_entidad_telefonos($dto->getParameterValue('entidad_telefonos'));
        $model->set_entidad_fax($dto->getParameterValue('entidad_fax'));
        $model->set_entidad_correo($dto->getParameterValue('entidad_correo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como EntidadModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new EntidadModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new EntidadModel();
        $model->set_entidad_id($dto->getParameterValue('entidad_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}

