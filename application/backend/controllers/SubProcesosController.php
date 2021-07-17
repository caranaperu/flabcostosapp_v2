<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las subprocesos.
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class SubProcesosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'subprocesos', "validationId" => 'subprocesos_validation', "validationGroupId" => 'v_subprocesos', "validationRulesId" => 'getSubProcesos'],
                "add" => ["langId" => 'subprocesos', "validationId" => 'subprocesos_validation', "validationGroupId" => 'v_subprocesos', "validationRulesId" => 'addSubProcesos'],
                "del" => ["langId" => 'subprocesos', "validationId" => 'subprocesos_validation', "validationGroupId" => 'v_subprocesos', "validationRulesId" => 'delSubProcesos'],
                "upd" => ["langId" => 'subprocesos', "validationId" => 'subprocesos_validation', "validationGroupId" => 'v_subprocesos', "validationRulesId" => 'updSubProcesos']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['subprocesos_codigo', 'verifyExist'],
                "add" => ['subprocesos_codigo', 'subprocesos_descripcion', 'activo'],
                "del" => ['subprocesos_codigo', 'versionId'],
                "upd" => ['subprocesos_codigo', 'subprocesos_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['subprocesos_'],
            "paramsFixableToValue" => ["subprocesos_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'subprocesos_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new SubProcesosBussinessService();
    }

}
