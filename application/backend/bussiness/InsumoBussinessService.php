<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los insumos
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("InsumoDAO", "insumo", "msg_insumo");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como InsumoModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new InsumoModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_insumo_tipo($dto->getParameterValue('insumo_tipo'));
        $model->set_insumo_codigo($dto->getParameterValue('insumo_codigo'));
        $model->set_insumo_descripcion($dto->getParameterValue('insumo_descripcion'));
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->set_unidad_medida_codigo_ingreso($dto->getParameterValue('unidad_medida_codigo_ingreso'));
        $model->set_unidad_medida_codigo_costo($dto->getParameterValue('unidad_medida_codigo_costo'));
        $model->set_insumo_merma($dto->getParameterValue('insumo_merma'));
        $model->set_insumo_costo($dto->getParameterValue('insumo_costo'));
        $model->set_insumo_precio_mercado($dto->getParameterValue('insumo_precio_mercado'));
        $model->set_moneda_codigo_costo($dto->getParameterValue('moneda_codigo_costo'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como InsumoModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new InsumoModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->set_insumo_tipo($dto->getParameterValue('insumo_tipo'));
        $model->set_insumo_codigo($dto->getParameterValue('insumo_codigo'));
        $model->set_insumo_descripcion($dto->getParameterValue('insumo_descripcion'));
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->set_unidad_medida_codigo_ingreso($dto->getParameterValue('unidad_medida_codigo_ingreso'));
        $model->set_unidad_medida_codigo_costo($dto->getParameterValue('unidad_medida_codigo_costo'));
        $model->set_insumo_merma($dto->getParameterValue('insumo_merma'));
        $model->set_insumo_costo($dto->getParameterValue('insumo_costo'));
        $model->set_insumo_precio_mercado($dto->getParameterValue('insumo_precio_mercado'));
        $model->set_moneda_codigo_costo($dto->getParameterValue('moneda_codigo_costo'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como InsumoModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new InsumoModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new InsumoModel();
        $model->set_insumo_id($dto->getParameterValue('insumo_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

