<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de costos.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoCostosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tipocostos', "validationId" => 'tipocostos_validation', "validationGroupId" => 'v_tcostos', "validationRulesId" => 'getTCostos'],
                "add" => ["langId" => 'tipocostos', "validationId" => 'tipocostos_validation', "validationGroupId" => 'v_tcostos', "validationRulesId" => 'addTCostos'],
                "del" => ["langId" => 'tipocostos', "validationId" => 'tipocostos_validation', "validationGroupId" => 'v_tcostos', "validationRulesId" => 'delTCostos'],
                "upd" => ["langId" => 'tipocostos', "validationId" => 'tipocostos_validation', "validationGroupId" => 'v_tcostos', "validationRulesId" => 'updTCostos']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tcostos_codigo', 'verifyExist'],
                "add" => ['tcostos_codigo', 'tcostos_descripcion','tcostos_indirecto','tcostos_protected','activo'],
                "del" => ['tcostos_codigo', 'versionId'],
                "upd" => ['tcostos_codigo', 'tcostos_descripcion','tcostos_indirecto','tcostos_protected', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tcostos_'],
            "paramsFixableToValue" => ["tcostos_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'tcostos_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoCostosBussinessService();
    }
}
