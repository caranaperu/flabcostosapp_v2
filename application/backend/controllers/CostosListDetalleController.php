<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los items de la lista de costos
 *
 * @author Carlos Arana
 * @since 17-JUL-2021
 *
 */
class CostosListDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'costos_list_detalle', "validationId" => 'costos_list_detalle_validation', "validationGroupId" => 'v_costos_list_detalle', "validationRulesId" => 'getCostosListDetalle'],
                "add" => ["langId" => 'costos_list_detalle', "validationId" => 'costos_list_detalle_validation', "validationGroupId" => 'v_costos_list_detalle', "validationRulesId" => 'addCostosListDetalle'],
                "del" => ["langId" => 'costos_list_detalle', "validationId" => 'costos_list_detalle_validation', "validationGroupId" => 'v_costos_list_detalle', "validationRulesId" => 'delCostosListDetalle'],
                "upd" => ["langId" => 'costos_list_detalle', "validationId" => 'costos_list_detalle_validation', "validationGroupId" => 'v_costos_list_detalle', "validationRulesId" => 'updCostosListDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => [],
                "add" => [],
                "del" => ['costos_list_detalle_id', 'versionId'],
                "upd" => [],
            ],
            "paramsFixableToNull" => ['costos_list_detalle_', 'costos_list_', 'insumo_','moneda_'],
            "paramsFixableToValue" => ["costos_list_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'costos_list_detalle_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new CostosListDetalleBussinessService();
    }

}
