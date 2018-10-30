<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las conversiones entre 2 unidades
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class UnidadMedidaConversionController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData(): void {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => [],
                "read" => ["langId" => 'unidadmedida_conversion', "validationId" => 'unidadmedida_conversion_validation', "validationGroupId" => 'v_unidadmedida_conversion', "validationRulesId" => 'getUnidadMedidaConversion'],
                "add" => ["langId" => 'unidadmedida_conversion', "validationId" => 'unidadmedida_conversion_validation', "validationGroupId" => 'v_unidadmedida_conversion', "validationRulesId" => 'addUnidadMedidaConversion'],
                "del" => ["langId" => 'unidadmedida_conversion', "validationId" => 'unidadmedida_conversion_validation', "validationGroupId" => 'v_unidadmedida_conversion', "validationRulesId" => 'delUnidadMedidaConversion'],
                "upd" => ["langId" => 'unidadmedida_conversion', "validationId" => 'unidadmedida_conversion_validation', "validationGroupId" => 'v_unidadmedida_conversion', "validationRulesId" => 'updUnidadMedidaConversion']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['unidad_medida_conversion_id', 'verifyExist'],
                "add" => ['unidad_medida_origen','unidad_medida_destino','unidad_medida_conversion_factor', 'activo'],
                "del" => ['unidad_medida_conversion_id', 'versionId'],
                "upd" => ['unidad_medida_conversion_id', 'unidad_medida_origen','unidad_medida_destino','unidad_medida_conversion_factor', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['unidad_medida_conversion_', 'unidad_medida_'],
            "paramsFixableToValue" => ["unidad_medida_conversion_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'unidad_medida_conversion_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService()  : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new UnidadMedidaConversionBussinessService();
    }

}
