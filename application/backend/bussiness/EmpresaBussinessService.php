<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones a los datos
 * de las empresas .
 *
 * @author $Author: aranape $
 * @version $Id: EmpresaBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class EmpresaBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("EmpresaDAO", "empresa", "msg_empresa");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como EmpresaModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new EmpresaModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_razon_social($dto->getParameterValue('empresa_razon_social'));
        $model->set_tipo_empresa_codigo($dto->getParameterValue('tipo_empresa_codigo'));
        $model->set_empresa_ruc($dto->getParameterValue('empresa_ruc'));
        $model->set_empresa_direccion($dto->getParameterValue('empresa_direccion'));
        $model->set_empresa_telefonos($dto->getParameterValue('empresa_telefonos'));
        $model->set_empresa_fax($dto->getParameterValue('empresa_fax'));
        $model->set_empresa_correo($dto->getParameterValue('empresa_correo'));

        // En el caso de agregar una entidad siempre ira en true
        $model->setActivo(TRUE);
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como EmpresaModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new EmpresaModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_empresa_razon_social($dto->getParameterValue('empresa_razon_social'));
        $model->set_tipo_empresa_codigo($dto->getParameterValue('tipo_empresa_codigo'));
        $model->set_empresa_ruc($dto->getParameterValue('empresa_ruc'));
        $model->set_empresa_direccion($dto->getParameterValue('empresa_direccion'));
        $model->set_empresa_telefonos($dto->getParameterValue('empresa_telefonos'));
        $model->set_empresa_fax($dto->getParameterValue('empresa_fax'));
        $model->set_empresa_correo($dto->getParameterValue('empresa_correo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como EmpresaModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new EmpresaModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new EmpresaModel();
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}
