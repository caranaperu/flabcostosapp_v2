<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los usuarios del sistema.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class UsuariosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'usuarios', "validationId" => 'usuarios_validation', "validationGroupId" => 'v_usuarios', "validationRulesId" => 'getUsuarios'],
                "add" => ["langId" => 'usuarios', "validationId" => 'usuarios_validation', "validationGroupId" => 'v_usuarios', "validationRulesId" => 'addUsuarios'],
                "del" => ["langId" => 'usuarios', "validationId" => 'usuarios_validation', "validationGroupId" => 'v_usuarios', "validationRulesId" => 'delUsuarios'],
                "upd" => ["langId" => 'usuarios', "validationId" => 'usuarios_validation', "validationGroupId" => 'v_usuarios', "validationRulesId" => 'updUsuarios']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['usuarios_id', 'verifyExist'],
                "add" => ['usuarios_code', 'usuarios_password', 'usuarios_nombre_completo', 'usuarios_admin','empresa_id', 'activo'],
                "del" => ['usuarios_id', 'versionId'],
                "upd" => ['usuarios_id', 'usuarios_code', 'usuarios_password', 'usuarios_nombre_completo', 'usuarios_admin','empresa_id', 'versionId', 'activo']
            ],
            "paramsFixableToNull" => ['usuarios_id','empresa_'],
            "paramsFixableToValue" => ["usuarios_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'usuarios_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new UsuariosBussinessService();
    }

}
