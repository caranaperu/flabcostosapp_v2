<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las regiones atleticas.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoInsumoController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tipoinsumo', "validationId" => 'tipoinsumo_validation', "validationGroupId" => 'v_tinsumo', "validationRulesId" => 'getTInsumo'],
                "add" => ["langId" => 'tipoinsumo', "validationId" => 'tipoinsumo_validation', "validationGroupId" => 'v_tinsumo', "validationRulesId" => 'addTInsumo'],
                "del" => ["langId" => 'tipoinsumo', "validationId" => 'tipoinsumo_validation', "validationGroupId" => 'v_tinsumo', "validationRulesId" => 'delTInsumo'],
                "upd" => ["langId" => 'tipoinsumo', "validationId" => 'tipoinsumo_validation', "validationGroupId" => 'v_tinsumo', "validationRulesId" => 'updTInsumo']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tinsumo_codigo', 'verifyExist'],
                "add" => ['tinsumo_codigo','tinsumo_descripcion','tinsumo_protected','activo'],
                "del" => ['tinsumo_codigo', 'versionId'],
                "upd" => ['tinsumo_codigo', 'tinsumo_descripcion','tinsumo_protected','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tinsumo_'],
            "paramsFixableToValue" => ["tinsumo_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'tinsumo_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoInsumoBussinessService();
    }
}
