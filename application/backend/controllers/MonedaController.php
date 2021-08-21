<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las monedas
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class MonedaController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData() : void  {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => [],
                "read" => ["langId" => 'moneda', "validationId" => 'moneda_validation', "validationGroupId" => 'v_moneda', "validationRulesId" => 'getMoneda'],
                "add" => ["langId" => 'moneda', "validationId" => 'moneda_validation', "validationGroupId" => 'v_moneda', "validationRulesId" => 'addMoneda'],
                "del" => ["langId" => 'moneda', "validationId" => 'moneda_validation', "validationGroupId" => 'v_moneda', "validationRulesId" => 'delMoneda'],
                "upd" => ["langId" => 'moneda', "validationId" => 'moneda_validation', "validationGroupId" => 'v_moneda', "validationRulesId" => 'updMoneda']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['moneda_codigo', 'verifyExist'],
                "add" => ['moneda_codigo','moneda_simbolo', 'moneda_descripcion', 'activo'],
                "del" => ['moneda_codigo', 'versionId'],
                "upd" => ['moneda_codigo', 'moneda_simbolo','moneda_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['moneda_'],
            "paramsFixableToValue" => ["moneda_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'moneda_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new MonedaBussinessService();
    }

}
