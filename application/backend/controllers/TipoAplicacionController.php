<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de aplicacion de productos.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoAplicacionController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tipoaplicacion', "validationId" => 'tipoaplicacion_validation', "validationGroupId" => 'v_taplicacion', "validationRulesId" => 'getTAplicacion'],
                "add" => ["langId" => 'tipoaplicacion', "validationId" => 'tipoaplicacion_validation', "validationGroupId" => 'v_taplicacion', "validationRulesId" => 'addTAplicacion'],
                "del" => ["langId" => 'tipoaplicacion', "validationId" => 'tipoaplicacion_validation', "validationGroupId" => 'v_taplicacion', "validationRulesId" => 'delTAplicacion'],
                "upd" => ["langId" => 'tipoaplicacion', "validationId" => 'tipoaplicacion_validation', "validationGroupId" => 'v_taplicacion', "validationRulesId" => 'updTAplicacion']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['taplicacion_codigo', 'verifyExist'],
                "add" => ['taplicacion_codigo','taplicacion_descripcion','activo'],
                "del" => ['taplicacion_codigo', 'versionId'],
                "upd" => ['taplicacion_codigo', 'taplicacion_descripcion','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['taplicacion_'],
            "paramsFixableToValue" => ["taplicacion_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'taplicacion_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoAplicacionBussinessService();
    }
}
