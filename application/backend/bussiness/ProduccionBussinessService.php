<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas los ingresos de produccion de determinado
 * sub modo de aplicacion
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 14-07-2021
 *
 */
class ProduccionBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService
{

    function __construct()
    {
        //    parent::__construct();
        $this->setup("ProduccionDAO", "produccion", "msg_produccion");
    }

    /**
     *
     * No se pasara los valores para unidad_medida_codigo
     * dado que en esta version tendra default en la base de datos LITROS.
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como ProduccionModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new ProduccionModel();
        // Leo el id enviado en el DTO
        $model->set_produccion_fecha($dto->getParameterValue('produccion_fecha'));
        $model->set_taplicacion_entries_id($dto->getParameterValue('taplicacion_entries_id'));
        $model->set_produccion_qty($dto->getParameterValue('produccion_qty'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     * No se pasara los valores para unidad_medida_codigo
     * dado que en esta version tendra default en la base de datos LITROS.
     *
     * @param \TSLIDataTransferObj $dto
     *
     * @return \TSLDataModel especificamente como ProduccionModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel
    {
        $model = new ProduccionModel();
        // Leo el id enviado en el DTO
        $model->set_produccion_id($dto->getParameterValue('produccion_id'));
        $model->set_produccion_fecha($dto->getParameterValue('produccion_fecha'));
        $model->set_taplicacion_entries_id($dto->getParameterValue('taplicacion_entries_id'));
        $model->set_produccion_qty($dto->getParameterValue('produccion_qty'));
        //$model->set_unidad_medida_codigo_qty($dto->getParameterValue('set_unidad_medida_codigo_qty'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como ProduccionModel
     */
    protected function &getEmptyModel() : \TSLDataModel
    {
        $model = new ProduccionModel();

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
        $model = new ProduccionModel();
        $model->set_produccion_id($dto->getParameterValue('produccion_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}
