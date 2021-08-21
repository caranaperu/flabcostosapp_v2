<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de la cabecera de la relacion tipo aplicacion-procesos
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class TipoAplicacionProcesosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'taplicacion_procesos', "validationId" => 'taplicacion_procesos_validation', "validationGroupId" => 'v_taplicacion_procesos', "validationRulesId" => 'getTipoAplicacionProcesos'],
                "add" => ["langId" => 'taplicacion_procesos', "validationId" => 'taplicacion_procesos_validation', "validationGroupId" => 'v_taplicacion_procesos', "validationRulesId" => 'addTipoAplicacionProcesos'],
                "del" => ["langId" => 'taplicacion_procesos', "validationId" => 'taplicacion_procesos_validation', "validationGroupId" => 'v_taplicacion_procesos', "validationRulesId" => 'delTipoAplicacionProcesos'],
                "upd" => ["langId" => 'taplicacion_procesos', "validationId" => 'taplicacion_procesos_validation', "validationGroupId" => 'v_taplicacion_procesos', "validationRulesId" => 'updTipoAplicacionProcesos']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['taplicacion_procesos_id', 'verifyExist'],
                "add" => ['taplicacion_codigo','taplicacion_procesos_fecha_desde','activo'],
                "del" => ['taplicacion_procesos_id', 'versionId'],
                "upd" => ['taplicacion_procesos_id', 'taplicacion_codigo','taplicacion_procesos_fecha_desde','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['taplicacion_procesos_', 'taplicacion_'],
            "paramsFixableToValue" => ["taplicacion_procesos_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'taplicacion_procesos_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoAplicacionProcesosBussinessService();
    }

}
