<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de costos globales
 *
 * @author Carlos Arana Reategui
 * @since 13-May-2021
 * @version 1.00
 * @history ''
 *
 */
class TipoCostoGlobalController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tcosto_global', "validationId" => 'tcosto_global_validation', "validationGroupId" => 'v_tcosto_global', "validationRulesId" => 'getTipoCostoGlobal'],
                "add" => ["langId" => 'tcosto_global', "validationId" => 'tcosto_global_validation', "validationGroupId" => 'v_tcosto_global', "validationRulesId" => 'addTipoCostoGlobal'],
                "del" => ["langId" => 'tcosto_global', "validationId" => 'tcosto_global_validation', "validationGroupId" => 'v_tcosto_global', "validationRulesId" => 'delTipoCostoGlobal'],
                "upd" => ["langId" => 'tcosto_global', "validationId" => 'tcosto_global_validation', "validationGroupId" => 'v_tcosto_global', "validationRulesId" => 'updTipoCostoGlobal']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tcosto_global_codigo', 'verifyExist'],
                "add" => ['tcosto_global_codigo', 'tcosto_global_descripcion', 'activo'],
                "del" => ['tcosto_global_codigo', 'versionId'],
                "upd" => ['tcosto_global_codigo', 'tcosto_global_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tcosto_global_'],
            "paramsFixableToValue" => ["tcosto_global_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'tcosto_global_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoCostoGlobalBussinessService();
    }

}
