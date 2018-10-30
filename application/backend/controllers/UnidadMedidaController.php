<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las unidades de medidas a usarse en las pruebas
 * atleticas.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class UnidadMedidaController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'unidadmedida', "validationId" => 'unidadmedida_validation', "validationGroupId" => 'v_unidadmedida', "validationRulesId" => 'getUnidadMedida'],
                "add" => ["langId" => 'unidadmedida', "validationId" => 'unidadmedida_validation', "validationGroupId" => 'v_unidadmedida', "validationRulesId" => 'addUnidadMedida'],
                "del" => ["langId" => 'unidadmedida', "validationId" => 'unidadmedida_validation', "validationGroupId" => 'v_unidadmedida', "validationRulesId" => 'delUnidadMedida'],
                "upd" => ["langId" => 'unidadmedida', "validationId" => 'unidadmedida_validation', "validationGroupId" => 'v_unidadmedida', "validationRulesId" => 'updUnidadMedida']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['unidad_medida_codigo', 'verifyExist'],
                "add" => ['unidad_medida_codigo','unidad_medida_siglas', 'unidad_medida_descripcion', 'unidad_medida_tipo','unidad_medida_default','unidad_medida_protected', 'activo'],
                "del" => ['unidad_medida_codigo', 'versionId'],
                "upd" => ['unidad_medida_codigo', 'unidad_medida_siglas','unidad_medida_descripcion', 'unidad_medida_tipo','unidad_medida_default','unidad_medida_protected','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['unidad_medida_'],
            "paramsFixableToValue" => ["unidad_medida_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'unidad_medida_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new UnidadMedidaBussinessService();
    }

}
