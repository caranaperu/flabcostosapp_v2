<?php
//declare(strict_types=1);

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones a los datos
 * de los clientes..
 *
 * @author $Author: aranape $
 * @history
 *          09-02-2017 Compatibilidad con php 7 .
 *                      Dado que los modelos usan ahora declare(strict_types=1) , bastara con eso
 *                      para que rechaze valores no validos en el modelo.
 */
class ClienteBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("ClienteDAO", "cliente", "msg_cliente");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como ClienteModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ClienteModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_cliente_razon_social($dto->getParameterValue('cliente_razon_social'));
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->set_cliente_ruc($dto->getParameterValue('cliente_ruc'));
        $model->set_cliente_direccion($dto->getParameterValue('cliente_direccion'));
        $model->set_cliente_telefonos($dto->getParameterValue('cliente_telefonos'));
        $model->set_cliente_fax($dto->getParameterValue('cliente_fax'));
        $model->set_cliente_correo($dto->getParameterValue('cliente_correo'));

        // En el caso de agregar una entidad siempre ira en true
        $model->setActivo(TRUE);
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como ClienteModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ClienteModel();
        // Leo el id enviado en el DTO
        $model->set_cliente_id($dto->getParameterValue('cliente_id'));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_cliente_razon_social($dto->getParameterValue('cliente_razon_social'));
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->set_cliente_ruc($dto->getParameterValue('cliente_ruc'));
        $model->set_cliente_direccion($dto->getParameterValue('cliente_direccion'));
        $model->set_cliente_telefonos($dto->getParameterValue('cliente_telefonos'));
        $model->set_cliente_fax($dto->getParameterValue('cliente_fax'));
        $model->set_cliente_correo($dto->getParameterValue('cliente_correo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como ClienteModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new ClienteModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new ClienteModel();
        $model->set_cliente_id($dto->getParameterValue('cliente_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}

