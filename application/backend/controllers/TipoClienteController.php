<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de cliente.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoClienteController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tcliente', "validationId" => 'tcliente_validation', "validationGroupId" => 'vtipo_cliente', "validationRulesId" => 'getTipoCliente'],
                "add" => ["langId" => 'tcliente', "validationId" => 'tcliente_validation', "validationGroupId" => 'vtipo_cliente', "validationRulesId" => 'addTipoCliente'],
                "del" => ["langId" => 'tcliente', "validationId" => 'tcliente_validation', "validationGroupId" => 'vtipo_cliente', "validationRulesId" => 'delTipoCliente'],
                "upd" => ["langId" => 'tcliente', "validationId" => 'tcliente_validation', "validationGroupId" => 'vtipo_cliente', "validationRulesId" => 'updTipoCliente']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tipo_cliente_codigo', 'verifyExist'],
                "add" => ['tipo_cliente_codigo','tipo_cliente_descripcion', 'activo'],
                "del" => ['tipo_cliente_codigo', 'versionId'],
                "upd" => ['tipo_cliente_codigo', 'tipo_cliente_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tipo_cliente_'],
            "paramsFixableToValue" => ["tipo_cliente_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'tipo_cliente_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoClienteBussinessService();
    }

}
