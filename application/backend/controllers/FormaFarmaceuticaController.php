<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las formas farmaceuticas de productos
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2019 Carlos Arana Reategui.
 * @license GPL
 *
 */
class FormaFarmaceuticaController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'ffarmaceutica', "validationId" => 'ffarmaceutica_validation', "validationGroupId" => 'v_ffarmaceutica', "validationRulesId" => 'getFFarmaceutica'],
                "add" => ["langId" => 'ffarmaceutica', "validationId" => 'ffarmaceutica_validation', "validationGroupId" => 'v_ffarmaceutica', "validationRulesId" => 'addFFarmaceutica'],
                "del" => ["langId" => 'ffarmaceutica', "validationId" => 'ffarmaceutica_validation', "validationGroupId" => 'v_ffarmaceutica', "validationRulesId" => 'delFFarmaceutica'],
                "upd" => ["langId" => 'ffarmaceutica', "validationId" => 'ffarmaceutica_validation', "validationGroupId" => 'v_ffarmaceutica', "validationRulesId" => 'updFFarmaceutica']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['ffarmaceutica_codigo', 'verifyExist'],
                "add" => ['ffarmaceutica_codigo','ffarmaceutica_descripcion','ffarmaceutica_protected','activo'],
                "del" => ['ffarmaceutica_codigo', 'versionId'],
                "upd" => ['ffarmaceutica_codigo', 'ffarmaceutica_descripcion','ffarmaceutica_protected','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['ffarmaceutica_'],
            "paramsFixableToValue" => ["ffarmaceutica_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'ffarmaceutica_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new FormaFarmaceuticaBussinessService();
    }
}
