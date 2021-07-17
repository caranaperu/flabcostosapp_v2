<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los sub tipos de aplicacion
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoAplicacionEntriesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService
{

    function __construct()
    {
        //    parent::__construct();
        $this->setup("TipoAplicacionEntriesDAO", "tipoaplicacion_entries", "msg_tipoaplicacion_entries");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como TipoAplicacionEntriesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new TipoAplicacionEntriesModel();
        $model->set_taplicacion_codigo($dto->getParameterValue('taplicacion_codigo'));
        $model->set_taplicacion_entries_descripcion($dto->getParameterValue('taplicacion_entries_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como TipoAplicacionEntriesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new TipoAplicacionEntriesModel();
        // Leo el id enviado en el DTO
        $model->set_taplicacion_entries_id($dto->getParameterValue('taplicacion_entries_id'));
        $model->set_taplicacion_codigo($dto->getParameterValue('taplicacion_codigo'));
        $model->set_taplicacion_entries_descripcion($dto->getParameterValue('taplicacion_entries_descripcion'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como TipoAplicacionEntriesModel
     */
    protected function &getEmptyModel() : \TSLDataModel
    {
        $model = new TipoAplicacionEntriesModel();

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
        $model = new TipoAplicacionEntriesModel();
        $model->set_taplicacion_entries_id($dto->getParameterValue('taplicacion_entries_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
