<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los items de cotizaciones
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
class CotizacionDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CotizacionDetalleDAO", "cotizacion_detalle", "msg_cotizacion_detalle");
    }

    /**
     * @inheritdoc
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CotizacionDetalleModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CotizacionDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_cotizacion_id($dto->getParameterValue('cotizacion_id'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_cotizacion_detalle_cantidad($dto->getParameterValue('cotizacion_detalle_cantidad'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_cotizacion_detalle_precio($dto->getParameterValue('cotizacion_detalle_precio'));
        $model->set_cotizacion_detalle_total($dto->getParameterValue('cotizacion_detalle_total'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CotizacionDetalleModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CotizacionDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_cotizacion_detalle_id($dto->getParameterValue('cotizacion_detalle_id'));
        $model->set_cotizacion_id($dto->getParameterValue('cotizacion_id'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_cotizacion_detalle_cantidad($dto->getParameterValue('cotizacion_detalle_cantidad'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_cotizacion_detalle_precio($dto->getParameterValue('cotizacion_detalle_precio'));
        $model->set_cotizacion_detalle_total($dto->getParameterValue('cotizacion_detalle_total'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como CotizacionDetalleModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new CotizacionDetalleModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CotizacionDetalleModel();
        $model->set_cotizacion_detalle_id($dto->getParameterValue('cotizacion_detalle_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

