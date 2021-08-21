<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las ddatos generales de la entidad usuaria del sistema
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class EntidadController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'entidad', "validationId" => 'entidad_validation', "validationGroupId" => 'v_entidad', "validationRulesId" => 'getEntidad'],
                "add" => ["langId" => 'entidad', "validationId" => 'entidad_validation', "validationGroupId" => 'v_entidad', "validationRulesId" => 'addEntidad'],
                "del" => ["langId" => 'entidad', "validationId" => 'entidad_validation', "validationGroupId" => 'v_entidad', "validationRulesId" => 'delEntidad'],
                "upd" => ["langId" => 'entidad', "validationId" => 'entidad_validation', "validationGroupId" => 'v_entidad', "validationRulesId" => 'updEntidad']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['entidad_id', 'verifyExist'],
                "add" => ['entidad_razon_social', 'entidad_ruc', 'entidad_direccion', 'entidad_telefonos', 'entidad_fax', 'entidad_correo', 'activo'],
                "del" => ['entidad_id', 'versionId'],
                "upd" => ['entidad_id', 'entidad_razon_social', 'entidad_ruc', 'entidad_direccion', 'entidad_telefonos', 'entidad_fax',  'entidad_correo', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['entidad_'],
            "paramsFixableToValue" => ["entidad_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'entidad_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new EntidadBussinessService();
    }

}
