<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los insumos
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData() : void {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => [],
                "read" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'getInsumo'],
                "add" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'addInsumo'],
                "del" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'delInsumo'],
                "upd" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'updInsumo']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['insumo_id', 'verifyExist'],
                "add" => ['empresa_id','insumo_tipo', 'insumo_codigo', 'insumo_descripcion','tinsumo_codigo','tcostos_codigo','unidad_medida_codigo_ingreso','unidad_medida_codigo_costo','insumo_merma','insumo_costo','insumo_precio_mercado','moneda_codigo_costo','activo'],
                "del" => ['insumo_id', 'versionId'],
                "upd" => ['empresa_id','insumo_id','insumo_tipo','insumo_codigo', 'insumo_descripcion','tinsumo_codigo','tcostos_codigo','unidad_medida_codigo_ingreso','unidad_medida_codigo_costo','insumo_merma','insumo_costo','insumo_precio_mercado','moneda_codigo_costo','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['insumo_','tinsumo_','unidad_medida_','tcostos_','moneda_','empresa_'],
            "paramsFixableToValue" => ["insumo_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true],
                                       "insumo_tipo" => ["valueToFix" => 'null', "valueToReplace" => 'IN', "isID" => false]],
           "paramToMapId" => 'insumo_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new InsumoBussinessService();
    }
}
