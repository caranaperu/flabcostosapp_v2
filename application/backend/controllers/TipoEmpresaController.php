<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de empresa.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoEmpresaController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tempresa', "validationId" => 'tempresa_validation', "validationGroupId" => 'vtipo_empresa', "validationRulesId" => 'getTipoEmprersa'],
                "add" => ["langId" => 'tempresa', "validationId" => 'tempresa_validation', "validationGroupId" => 'vtipo_empresa', "validationRulesId" => 'addTipoEmprersa'],
                "del" => ["langId" => 'tempresa', "validationId" => 'tempresa_validation', "validationGroupId" => 'vtipo_empresa', "validationRulesId" => 'delTipoEmprersa'],
                "upd" => ["langId" => 'tempresa', "validationId" => 'tempresa_validation', "validationGroupId" => 'vtipo_empresa', "validationRulesId" => 'updTipoEmprersa']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tipo_empresa_codigo', 'verifyExist'],
                "add" => ['tipo_empresa_codigo','tipo_empresa_descripcion', 'activo'],
                "del" => ['tipo_empresa_codigo', 'versionId'],
                "upd" => ['tipo_empresa_codigo', 'tipo_empresa_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tipo_empresa_'],
            "paramsFixableToValue" => ["tipo_empresa_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'tipo_empresa_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoEmpresaBussinessService();
    }

}
