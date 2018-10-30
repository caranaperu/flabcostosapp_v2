<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las ddatos generales de las empresas
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class EmpresaController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'empresa', "validationId" => 'empresa_validation', "validationGroupId" => 'v_empresa', "validationRulesId" => 'getEmpresa'],
                "add" => ["langId" => 'empresa', "validationId" => 'empresa_validation', "validationGroupId" => 'v_empresa', "validationRulesId" => 'addEmpresa'],
                "del" => ["langId" => 'empresa', "validationId" => 'empresa_validation', "validationGroupId" => 'v_empresa', "validationRulesId" => 'delEmpresa'],
                "upd" => ["langId" => 'empresa', "validationId" => 'empresa_validation', "validationGroupId" => 'v_empresa', "validationRulesId" => 'updEmpresa']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['empresa_id', 'verifyExist'],
                "add" => ['empresa_razon_social', 'tipo_empresa_codigo','empresa_ruc', 'empresa_direccion', 'empresa_telefonos', 'empresa_fax', 'empresa_correo', 'activo'],
                "del" => ['empresa_id', 'versionId'],
                "upd" => ['empresa_id', 'empresa_razon_social', 'tipo_empresa_codigo', 'empresa_ruc', 'empresa_direccion', 'empresa_telefonos', 'empresa_fax',  'empresa_correo', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['empresa_','tipo_empresa_'],
            "paramsFixableToValue" => ["empresa_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'empresa_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new EmpresaBussinessService();
    }

}
