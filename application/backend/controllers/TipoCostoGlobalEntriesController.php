<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los ingresos de movimentos de los tipo de costos
 * globales.
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class TipoCostoGlobalEntriesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tcosto_global_entries', "validationId" => 'tcostoglobal_entries_validation', "validationGroupId" => 'v_tcostoglobal_entries', "validationRulesId" => 'getTipoCostoGlobalEntries'],
                "add" => ["langId" => 'tcosto_global_entries', "validationId" => 'tcostoglobal_entries_validation', "validationGroupId" => 'v_tcostoglobal_entries', "validationRulesId" => 'addTipoCostoGlobalEntries'],
                "del" => ["langId" => 'tcosto_global_entries', "validationId" => 'tcostoglobal_entries_validation', "validationGroupId" => 'v_tcostoglobal_entries', "validationRulesId" => 'delTipoCostoGlobalEntries'],
                "upd" => ["langId" => 'tcosto_global_entries', "validationId" => 'tcostoglobal_entries_validation', "validationGroupId" => 'v_tcostoglobal_entries', "validationRulesId" => 'updTipoCostoGlobalEntries']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tcosto_global_entries_id', 'verifyExist'],
                "add" => ['tcosto_global_entries_fecha_desde','tcosto_global_codigo','tcosto_global_entries_valor','moneda_codigo','activo'],
                "del" => ['tcosto_global_entries_id', 'versionId'],
                "upd" => ['tcosto_global_entries_id','tcosto_global_entries_fecha_desde','tcosto_global_codigo','tcosto_global_entries_valor','moneda_codigo', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tcosto_global_entries_id_','tcosto_global_','moneda_'],
            "paramsFixableToValue" => ["tcosto_global_entries_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'tcosto_global_entries_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoCostoGlobalEntriesBussinessService();
    }

}
