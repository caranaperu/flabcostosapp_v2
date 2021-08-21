<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los ingresos de produccion de determinado
 * sub modo de aplicacion
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 *
 */
class ProduccionController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'produccion', "validationId" => 'produccion_validation', "validationGroupId" => 'v_produccion', "validationRulesId" => 'getProduccion'],
                "add" => ["langId" => 'produccion', "validationId" => 'produccion_validation', "validationGroupId" => 'v_produccion', "validationRulesId" => 'addProduccion'],
                "del" => ["langId" => 'produccion', "validationId" => 'produccion_validation', "validationGroupId" => 'v_produccion', "validationRulesId" => 'delProduccion'],
                "upd" => ["langId" => 'produccion', "validationId" => 'produccion_validation', "validationGroupId" => 'v_produccion', "validationRulesId" => 'updProduccion']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['produccion_id', 'verifyExist'],
                "add" => ['produccion_fecha','taplicacion_entries_id','produccion_qty','activo'],
                "del" => ['produccion_id', 'versionId'],
                "upd" => ['produccion_id','produccion_fecha','taplicacion_entries_id','produccion_qty','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['produccion_id_', 'unidad_medida_','taplicacion_entries_'],
            "paramsFixableToValue" => ["produccion_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'produccion_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ProduccionBussinessService();
    }

}
