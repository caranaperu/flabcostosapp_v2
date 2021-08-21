<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los perfiles a aplicar a los usuarios.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class PerfilController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'perfil', "validationId" => 'perfil_validation', "validationGroupId" => 'v_perfil', "validationRulesId" => 'getPerfil'],
                "add" => ["langId" => 'perfil', "validationId" => 'perfil_validation', "validationGroupId" => 'v_perfil', "validationRulesId" => 'addPerfil'],
                "del" => ["langId" => 'perfil', "validationId" => 'perfil_validation', "validationGroupId" => 'v_perfil', "validationRulesId" => 'delPerfil'],
                "upd" => ["langId" => 'perfil', "validationId" => 'perfil_validation', "validationGroupId" => 'v_perfil', "validationRulesId" => 'updPerfil']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['perfil_id', 'verifyExist'],
                "add" => ['perfil_codigo', 'perfil_descripcion', 'sys_systemcode', 'activo'],
                "del" => ['perfil_id', 'versionId'],
                "upd" => ['perfil_id', 'perfil_codigo', 'perfil_descripcion', 'sys_systemcode', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['perfil_', 'sys_'],
            "paramsFixableToValue" => ["perfil_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'perfil_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new PerfilBussinessService();
    }

    /**
     * {@inheritDoc}
     */
    protected function preExecuteOperation(string $operationCode) : void {
        if ($operationCode == 'add') {
            $constraints = NULL;

            // Si el parametro copy from perfil esta seteado generamos constraints para post procesar
            $copyFromPerfil = $this->input->get_post('prm_copyFromPerfil');
            if (isset($copyFromPerfil) && is_string($copyFromPerfil) && strlen($copyFromPerfil) > 0) {
                $constraints = &$this->DTO->getConstraints();
                // En este caso basta la asignacion directa
                $constraints->addParameter('prm_copyFromPerfil', $copyFromPerfil);
            }
        }
    }

}
