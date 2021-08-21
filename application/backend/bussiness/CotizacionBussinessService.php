<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de la cabecera de cotizaciones
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
class CotizacionBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CotizacionDAO", "cotizacion", "msg_cotizacion");
    }

    /**
     * El numero de cotizacion no se envia al agregar ya que se determina en el
     * momento del add y no puede ser determinado desde el cliente.
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CotizacionModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CotizacionModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_cliente_id($dto->getParameterValue('cliente_id'));
        $model->set_cotizacion_es_cliente_real(($dto->getParameterValue('cotizacion_es_cliente_real')== 'true' ? true : false));
        $model->set_cotizacion_cerrada(($dto->getParameterValue('cotizacion_cerrada')== 'true' ? true : false));
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));
        $model->set_cotizacion_fecha($dto->getParameterValue('cotizacion_fecha'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CotizacionModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CotizacionModel();
        // Leo el id enviado en el DTO
        $model->set_cotizacion_id($dto->getParameterValue('cotizacion_id'));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_cliente_id($dto->getParameterValue('cliente_id'));
        $model->set_cotizacion_es_cliente_real(($dto->getParameterValue('cotizacion_es_cliente_real')== 'true' ? true : false));
        $model->set_cotizacion_cerrada(($dto->getParameterValue('cotizacion_cerrada') == 'true' ? true : false));
        $model->set_cotizacion_numero($dto->getParameterValue('cotizacion_numero'));
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));
        $model->set_cotizacion_fecha($dto->getParameterValue('cotizacion_fecha'));


        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como CotizacionModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new CotizacionModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CotizacionModel();
        $model->set_cotizacion_id($dto->getParameterValue('cotizacion_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

