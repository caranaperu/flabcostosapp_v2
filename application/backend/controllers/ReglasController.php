<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las reglas de costos entre empresas.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ReglasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'reglas', "validationId" => 'reglas_validation', "validationGroupId" => 'v_reglas', "validationRulesId" => 'getReglas'],
                "add" => ["langId" => 'reglas', "validationId" => 'reglas_validation', "validationGroupId" => 'v_reglas', "validationRulesId" => 'addReglas'],
                "del" => ["langId" => 'reglas', "validationId" => 'reglas_validation', "validationGroupId" => 'v_reglas', "validationRulesId" => 'delReglas'],
                "upd" => ["langId" => 'reglas', "validationId" => 'reglas_validation', "validationGroupId" => 'v_reglas', "validationRulesId" => 'updReglas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['regla_id', 'verifyExist'],
                "add" => ['regla_empresa_origen_id','regla_empresa_destino_id','regla_by_costo','regla_porcentaje','activo'],
                "del" => ['regla_id', 'versionId'],
                "upd" => ['regla_id','regla_empresa_origen_id','regla_empresa_destino_id','regla_by_costo','regla_porcentaje','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['regla_',],
            "paramsFixableToValue" => ["regla_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'regla_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ReglasBussinessService();
    }
}
