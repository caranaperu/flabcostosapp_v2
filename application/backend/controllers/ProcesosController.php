<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las procesos.
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class ProcesosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'procesos', "validationId" => 'procesos_validation', "validationGroupId" => 'v_procesos', "validationRulesId" => 'getProcesos'],
                "add" => ["langId" => 'procesos', "validationId" => 'procesos_validation', "validationGroupId" => 'v_procesos', "validationRulesId" => 'addProcesos'],
                "del" => ["langId" => 'procesos', "validationId" => 'procesos_validation', "validationGroupId" => 'v_procesos', "validationRulesId" => 'delProcesos'],
                "upd" => ["langId" => 'procesos', "validationId" => 'procesos_validation', "validationGroupId" => 'v_procesos', "validationRulesId" => 'updProcesos']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['procesos_codigo', 'verifyExist'],
                "add" => ['procesos_codigo', 'procesos_descripcion', 'activo'],
                "del" => ['procesos_codigo', 'versionId'],
                "upd" => ['procesos_codigo', 'procesos_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['procesos_'],
            "paramsFixableToValue" => ["procesos_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'procesos_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ProcesosBussinessService();
    }

}
