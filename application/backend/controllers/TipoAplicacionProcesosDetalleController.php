<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de cada entrada de proceso a asignar en la relacion tipo aplicacion-procesos.
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui

 *
 */
class TipoAplicacionProcesosDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'taplicacion_procesos_detalle', "validationId" => 'taplicacion_procesos_detalle_validation', "validationGroupId" => 'v_taplicacion_procesos_detalle', "validationRulesId" => 'getTipoAplicacionProcesosDetalle'],
                "add" => ["langId" => 'taplicacion_procesos_detalle', "validationId" => 'taplicacion_procesos_detalle_validation', "validationGroupId" => 'v_taplicacion_procesos_detalle', "validationRulesId" => 'addTipoAplicacionProcesosDetalle'],
                "del" => ["langId" => 'taplicacion_procesos_detalle', "validationId" => 'taplicacion_procesos_detalle_validation', "validationGroupId" => 'v_taplicacion_procesos_detalle', "validationRulesId" => 'delTipoAplicacionProcesosDetalle'],
                "upd" => ["langId" => 'taplicacion_procesos_detalle', "validationId" => 'taplicacion_procesos_detalle_validation', "validationGroupId" => 'v_taplicacion_procesos_detalle', "validationRulesId" => 'updTipoAplicacionProcesosDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['taplicacion_procesos_detalle_id', 'verifyExist'],
                "add" => ['taplicacion_procesos_id','procesos_codigo','taplicacion_procesos_detalle_porcentaje','activo'],
                "del" => ['taplicacion_procesos_detalle_id', 'versionId'],
                "upd" => ['taplicacion_procesos_detalle_id','taplicacion_procesos_id', 'procesos_codigo','taplicacion_procesos_detalle_porcentaje','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['taplicacion_procesos_detalle_', 'procesos_'],
            "paramsFixableToValue" => ["taplicacion_procesos_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'taplicacion_procesos_detalle_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoAplicacionProcesosDetalleBussinessService();
    }

}
