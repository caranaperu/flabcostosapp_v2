<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las importaciones de insumos
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 *
 */
class InsumoEntriesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'insumoentries', "validationId" => 'insumoentries_validation', "validationGroupId" => 'v_insumoentries', "validationRulesId" => 'getInsumoEntries'],
                "add" => ["langId" => 'insumoentries', "validationId" => 'insumoentries_validation', "validationGroupId" => 'v_insumoentries', "validationRulesId" => 'addInsumoEntries'],
                "del" => ["langId" => 'insumoentries', "validationId" => 'insumoentries_validation', "validationGroupId" => 'v_insumoentries', "validationRulesId" => 'delInsumoEntries'],
                "upd" => ["langId" => 'insumoentries', "validationId" => 'insumoentries_validation', "validationGroupId" => 'v_insumoentries', "validationRulesId" => 'updInsumoEntries']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['insumo_entries_id', 'verifyExist'],
                "add" => ['insumo_entries_fecha','insumo_id','insumo_entries_qty','insumo_entries_value','activo'],
                "del" => ['insumo_entries_id', 'versionId'],
                "upd" => ['insumo_entries_id','insumo_entries_fecha','insumo_id','insumo_entries_qty','insumo_entries_value', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['insumo_entries_id_', 'unidad_medida_','insumo_'],
            "paramsFixableToValue" => ["insumo_entries_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'insumo_entries_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new InsumoEntriesBussinessService();
    }

}
