<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de la cabecera de las listas de costos
 *
 * @author Carlos Arana
 * @since 17-JUL-2021
 *
 */
class CostosListController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "add" => ["langId" => 'costos_list', "validationId" => 'costos_list_validation', "validationGroupId" => 'v_costos_list', "validationRulesId" => 'addCostosList'],
                "del" => ["langId" => 'costos_list', "validationId" => 'costos_list_validation', "validationGroupId" => 'v_costos_list', "validationRulesId" => 'delCostosList'],
            ],
            "paramsList" => [
                "fetch" => [],
                "add" => ['costos_list_descripcion','costos_list_fecha_desde','costos_list_fecha_hasta','costos_list_fecha_tcambio'],
                "del" => ['costos_list_id', 'versionId'],
            ],
            "paramsFixableToNull" => ['costos_list_'],
            "paramsFixableToValue" => ["costos_list_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'costos_list_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new CostosListBussinessService();
    }

}
