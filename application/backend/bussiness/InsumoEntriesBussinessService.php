<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas los ingresos de importacion
 * de insumos.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoEntriesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService
{

    function __construct()
    {
        //    parent::__construct();
        $this->setup("InsumoEntriesDAO", "insumoentries", "msg_insumoentries");
    }

    /**
     *
     * No se pasara los valores para unidad_medida_codigo_qty
     * dado que en esta version tendra default en la base de datos KILOS.
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como InsumoEntriesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new InsumoEntriesModel();
        // Leo el id enviado en el DTO
        $model->set_insumo_entries_fecha($dto->getParameterValue('insumo_entries_fecha'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_insumo_entries_qty($dto->getParameterValue('insumo_entries_qty'));
        //$model->set_unidad_medida_codigo_qty($dto->getParameterValue('set_unidad_medida_codigo_qty'));
        $model->set_insumo_entries_value($dto->getParameterValue('insumo_entries_value'));
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
     * @return \TSLDataModel especificamente como InsumoEntriesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new InsumoEntriesModel();
        // Leo el id enviado en el DTO
        $model->set_insumo_entries_id($dto->getParameterValue('insumo_entries_id'));
        $model->set_insumo_entries_fecha($dto->getParameterValue('insumo_entries_fecha'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_insumo_entries_qty($dto->getParameterValue('insumo_entries_qty'));
        //$model->set_unidad_medida_codigo_qty($dto->getParameterValue('set_unidad_medida_codigo_qty'));
        $model->set_insumo_entries_value($dto->getParameterValue('insumo_entries_value'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como InsumoEntriesModel
     */
    protected function &getEmptyModel() : \TSLDataModel
    {
        $model = new InsumoEntriesModel();

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
        $model = new InsumoEntriesModel();
        $model->set_insumo_entries_id($dto->getParameterValue('insumo_entries_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
