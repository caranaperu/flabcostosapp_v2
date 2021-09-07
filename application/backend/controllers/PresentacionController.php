<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las presentaciones de productos
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2019 Carlos Arana Reategui.
 * @license GPL
 *
 */
class PresentacionController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tpresentacion', "validationId" => 'tpresentacion_validation', "validationGroupId" => 'v_tpresentacion', "validationRulesId" => 'getTPresentacion'],
                "add" => ["langId" => 'tpresentacion', "validationId" => 'tpresentacion_validation', "validationGroupId" => 'v_tpresentacion', "validationRulesId" => 'addTPresentacion'],
                "del" => ["langId" => 'tpresentacion', "validationId" => 'tpresentacion_validation', "validationGroupId" => 'v_tpresentacion', "validationRulesId" => 'delTPresentacion'],
                "upd" => ["langId" => 'tpresentacion', "validationId" => 'tpresentacion_validation', "validationGroupId" => 'v_tpresentacion', "validationRulesId" => 'updTPresentacion']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tpresentacion_codigo', 'verifyExist'],
                "add" => ['tpresentacion_codigo','tpresentacion_descripcion','unidad_medida_codigo_costo','tpresentacion_cantidad_costo','tpresentacion_protected','activo'],
                "del" => ['tpresentacion_codigo', 'versionId'],
                "upd" => ['tpresentacion_codigo', 'tpresentacion_descripcion','unidad_medida_codigo_costo','tpresentacion_cantidad_costo','tpresentacion_protected','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tpresentacion_','unidad_medida'],
            "paramsFixableToValue" => ["tpresentacion_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'tpresentacion_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new PresentacionBussinessService();
    }
}
