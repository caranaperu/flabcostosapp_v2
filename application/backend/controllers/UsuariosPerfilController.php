<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los usuarios de la entidad.
 *
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: usuariosPerfilController.php 394 2014-01-11 09:22:07Z aranape $
 * @history ''
 *
 * $Date: 2014-01-11 04:22:07 -0500 (sáb, 11 ene 2014) $
 * $Rev: 394 $
 */
class UsuariosPerfilController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'usuario_perfil', "validationId" => 'usuario_perfil_validation', "validationGroupId" => 'v_usuario_perfil', "validationRulesId" => 'getUsuarioPerfil'],
                "add" => ["langId" => 'usuario_perfil', "validationId" => 'usuario_perfil_validation', "validationGroupId" => 'v_usuario_perfil', "validationRulesId" => 'addUsuarioPerfil'],
                "del" => ["langId" => 'usuario_perfil', "validationId" => 'usuario_perfil_validation', "validationGroupId" => 'v_usuario_perfil', "validationRulesId" => 'delUsuarioPerfil'],
                "upd" => ["langId" => 'usuario_perfil', "validationId" => 'usuario_perfil_validation', "validationGroupId" => 'v_usuario_perfil', "validationRulesId" => 'updUsuarioPerfil']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['usuario_perfil_id', 'verifyExist'],
                "add" => ['usuarios_id', 'perfil_id', 'activo'],
                "del" => ['usuario_perfil_id', 'versionId'],
                "upd" => ['usuario_perfil_id','usuarios_id', 'perfil_id','versionId', 'activo']
            ],
            "paramsFixableToNull" => ['usuarioperfiles','usuarios_', 'perfil_','sys_'],
            "paramsFixableToValue" => ["usuario_perfil_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'usuario_perfil_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new UsuariosPerfilBussinessService();
    }
}
