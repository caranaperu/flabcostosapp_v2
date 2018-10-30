<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los detalles de perfiles a aplicar a los mismos.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class PerfilDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData() : void  {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => [],
                "read" => ["langId" => 'perfildetalle', "validationId" => 'perfildetalle_validation', "validationGroupId" => 'v_perfildetalle', "validationRulesId" => 'getPerfilDetalle'],
                "add" => ["langId" => 'perfildetalle', "validationId" => 'perfildetalle_validation', "validationGroupId" => 'v_perfildetalle', "validationRulesId" => 'addPerfilDetalle'],
                "del" => ["langId" => 'perfildetalle', "validationId" => 'perfildetalle_validation', "validationGroupId" => 'v_perfildetalle', "validationRulesId" => 'delPerfilDetalle'],
                "upd" => ["langId" => 'perfildetalle', "validationId" => 'perfildetalle_validation', "validationGroupId" => 'v_perfildetalle', "validationRulesId" => 'updPerfilDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['perfdet_id', 'verifyExist'],
                "add" => ['perfil_id', 'perfdet_accessdef', 'perfdet_accleer', 'perfdet_accagregar', 'perfdet_accactualizar', 'perfdet_acceliminar', 'perfdet_accimprimir', 'menu_id', 'activo'],
                "del" => ['perfdet_id', 'versionId'],
                "upd" => ['perfdet_id', 'perfil_id', 'perfdet_accessdef', 'perfdet_accleer', 'perfdet_accagregar', 'perfdet_accactualizar', 'perfdet_acceliminar', 'perfdet_accimprimir', 'menu_id', 'versionId', 'activo']
            ],
            "paramsFixableToNull" => ['perfdet_', 'perfil_', 'menu_'],
            "paramsFixableToValue" => ["perfdet_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'perfdet_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new PerfilDetalleBussinessService();
    }

}
