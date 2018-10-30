<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las datos generales de los clientes
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ClienteController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'cliente', "validationId" => 'cliente_validation', "validationGroupId" => 'v_cliente', "validationRulesId" => 'getCliente'],
                "add" => ["langId" => 'cliente', "validationId" => 'cliente_validation', "validationGroupId" => 'v_cliente', "validationRulesId" => 'addCliente'],
                "del" => ["langId" => 'cliente', "validationId" => 'cliente_validation', "validationGroupId" => 'v_cliente', "validationRulesId" => 'delCliente'],
                "upd" => ["langId" => 'cliente', "validationId" => 'cliente_validation', "validationGroupId" => 'v_cliente', "validationRulesId" => 'updCliente']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['cliente_id', 'verifyExist'],
                "add" => ['empresa_id','cliente_razon_social', 'tipo_cliente_codigo','cliente_ruc', 'cliente_direccion', 'cliente_telefonos', 'cliente_fax', 'cliente_correo', 'activo'],
                "del" => ['cliente_id', 'versionId'],
                "upd" => ['cliente_id','empresa_id', 'cliente_razon_social', 'tipo_cliente_codigo', 'cliente_ruc', 'cliente_direccion', 'cliente_telefonos', 'cliente_fax',  'cliente_correo', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['cliente_','tipo_cliente_','empresa_'],
            "paramsFixableToValue" => ["cliente_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'cliente_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ClienteBussinessService();
    }

}
