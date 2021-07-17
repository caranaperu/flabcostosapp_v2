<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas los ingresos de movimentos de los tipo de costos
 * globales.
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class TipoCostoGlobalEntriesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService
{

    function __construct()
    {
        //    parent::__construct();
        $this->setup("TipoCostoGlobalEntriesDAO", "tcosto_global_entries", "msg_tcosto_global_entries");
    }

    /**
     *
     * No se pasara los valores para unidad_medida_codigo_qty
     * dado que en esta version tendra default en la base de datos KILOS.
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como TipoCostoGlobalEntriesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new TipoCostoGlobalEntriesModel();
        // Leo el id enviado en el DTO
        $model->set_tcosto_global_entries_fecha_desde($dto->getParameterValue('tcosto_global_entries_fecha_desde'));
        $model->set_tcosto_global_codigo($dto->getParameterValue('tcosto_global_codigo'));
        $model->set_tcosto_global_entries_valor($dto->getParameterValue('tcosto_global_entries_valor'));
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     * No se pasara los valores para unidad_medida_codigo_qty
     * dado que en esta version tendra default en la base de datos KILOS.
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como TipoCostoGlobalEntriesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new TipoCostoGlobalEntriesModel();
        // Leo el id enviado en el DTO
        $model->set_tcosto_global_entries_id($dto->getParameterValue('tcosto_global_entries_id'));
        $model->set_tcosto_global_entries_fecha_desde($dto->getParameterValue('tcosto_global_entries_fecha_desde'));
        $model->set_tcosto_global_codigo($dto->getParameterValue('tcosto_global_codigo'));
        $model->set_tcosto_global_entries_valor($dto->getParameterValue('tcosto_global_entries_valor'));
        $model->set_moneda_codigo($dto->getParameterValue('moneda_codigo'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoCostoGlobalEntriesModel
     */
    protected function &getEmptyModel() : \TSLDataModel
    {
        $model = new TipoCostoGlobalEntriesModel();

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
        $model = new TipoCostoGlobalEntriesModel();
        $model->set_tcosto_global_entries_id($dto->getParameterValue('tcosto_global_entries_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
