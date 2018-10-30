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
class UnidadMedidaConversionBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService
{

    function __construct()
    {
        //    parent::__construct();
        $this->setup("UnidadMedidaConversionDAO", "unidadmedida_conversion", "msg_unidadmedida_conversion");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel en este caso UnidadMedidaConversionModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new UnidadMedidaConversionModel();
        // Leo el id enviado en el DTO
        $model->set_unidad_medida_origen($dto->getParameterValue('unidad_medida_origen'));
        $model->set_unidad_medida_destino($dto->getParameterValue('unidad_medida_destino'));
        $model->set_unidad_medida_conversion_factor($dto->getParameterValue('unidad_medida_conversion_factor'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel en este caso UnidadMedidaConversionModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new UnidadMedidaConversionModel();
        // Leo el id enviado en el DTO
        $model->set_unidad_medida_conversion_id($dto->getParameterValue('unidad_medida_conversion_id'));
        $model->set_unidad_medida_origen($dto->getParameterValue('unidad_medida_origen'));
        $model->set_unidad_medida_destino($dto->getParameterValue('unidad_medida_destino'));
        $model->set_unidad_medida_conversion_factor($dto->getParameterValue('unidad_medida_conversion_factor'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel en este caso  UnidadMedidaConversionModel
     */
    protected function &getEmptyModel() : \TSLDataModel
    {
        $model = new UnidadMedidaConversionModel();

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto): \TSLDataModel
    {
        $model = new UnidadMedidaConversionModel();
        $model->set_unidad_medida_conversion_id($dto->getParameterValue('unidad_medida_conversion_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
