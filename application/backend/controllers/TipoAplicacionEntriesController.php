<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las subtipos de aplicacion de producto.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoAplicacionEntriesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tipoaplicacion_entries', "validationId" => 'tipoaplicacion_entries_validation', "validationGroupId" => 'v_tipoaplicacion_entries', "validationRulesId" => 'getTipoAplicacionEntries'],
                "add" => ["langId" => 'tipoaplicacion_entries', "validationId" => 'tipoaplicacion_entries_validation', "validationGroupId" => 'v_tipoaplicacion_entries', "validationRulesId" => 'addTipoAplicacionEntries'],
                "del" => ["langId" => 'tipoaplicacion_entries', "validationId" => 'tipoaplicacion_entries_validation', "validationGroupId" => 'v_tipoaplicacion_entries', "validationRulesId" => 'delTipoAplicacionEntries'],
                "upd" => ["langId" => 'tipoaplicacion_entries', "validationId" => 'tipoaplicacion_entries_validation', "validationGroupId" => 'v_tipoaplicacion_entries', "validationRulesId" => 'updTipoAplicacionEntries']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['taplicacion_entries_id', 'verifyExist'],
                "add" => ['taplicacion_codigo','taplicacion_entries_descripcion', 'activo'],
                "del" => ['taplicacion_entries_id', 'versionId'],
                "upd" => ['taplicacion_entries_id','taplicacion_codigo','taplicacion_entries_descripcion','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['taplicacion_entries_', 'taplicacion_'],
            "paramsFixableToValue" => ["taplicacion_entries_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'taplicacion_entries_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoAplicacionEntriesBussinessService();
    }

}
