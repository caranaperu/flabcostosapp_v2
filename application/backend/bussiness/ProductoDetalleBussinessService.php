<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a la conversion
 * entre unidades de medida.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ProductoDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService
{

    function __construct()
    {
        //    parent::__construct();
        $this->setup("ProductoDetalleDAO", "productodetalle", "msg_productodetalle");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como ProductoDetalleModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new ProductoDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_insumo_id_origen($dto->getParameterValue('insumo_id_origen'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_producto_detalle_cantidad($dto->getParameterValue('producto_detalle_cantidad'));
        $model->set_producto_detalle_valor($dto->getParameterValue('producto_detalle_valor'));
        $model->set_producto_detalle_merma($dto->getParameterValue('producto_detalle_merma'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como ProductoDetalleModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new ProductoDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_producto_detalle_id($dto->getParameterValue('producto_detalle_id'));
        $model->set_insumo_id_origen($dto->getParameterValue('insumo_id_origen'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_producto_detalle_cantidad($dto->getParameterValue('producto_detalle_cantidad'));
        $model->set_producto_detalle_valor($dto->getParameterValue('producto_detalle_valor'));
        $model->set_producto_detalle_merma($dto->getParameterValue('producto_detalle_merma'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como ProductoDetalleModel
     */
    protected function &getEmptyModel() : \TSLDataModel
    {
        $model = new ProductoDetalleModel();

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new ProductoDetalleModel();
        $model->set_producto_detalle_id($dto->getParameterValue('producto_detalle_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
