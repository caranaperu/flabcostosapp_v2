<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de cada entrada de proceso a asignar en la relacion producto-procesos.
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui

 *
 */
class ProductoProcesosDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'producto_procesos_detalle', "validationId" => 'producto_procesos_detalle_validation', "validationGroupId" => 'v_producto_procesos_detalle', "validationRulesId" => 'getProductoProcesosDetalle'],
                "add" => ["langId" => 'producto_procesos_detalle', "validationId" => 'producto_procesos_detalle_validation', "validationGroupId" => 'v_producto_procesos_detalle', "validationRulesId" => 'addProductoProcesosDetalle'],
                "del" => ["langId" => 'producto_procesos_detalle', "validationId" => 'producto_procesos_detalle_validation', "validationGroupId" => 'v_producto_procesos_detalle', "validationRulesId" => 'delProductoProcesosDetalle'],
                "upd" => ["langId" => 'producto_procesos_detalle', "validationId" => 'producto_procesos_detalle_validation', "validationGroupId" => 'v_producto_procesos_detalle', "validationRulesId" => 'updProductoProcesosDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['producto_procesos_detalle_id', 'verifyExist'],
                "add" => ['producto_procesos_id','procesos_codigo','producto_procesos_detalle_porcentaje','activo'],
                "del" => ['producto_procesos_detalle_id', 'versionId'],
                "upd" => ['producto_procesos_detalle_id','producto_procesos_id', 'procesos_codigo','producto_procesos_detalle_porcentaje','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['producto_procesos_detalle_', 'procesos_'],
            "paramsFixableToValue" => ["producto_procesos_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'producto_procesos_detalle_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ProductoProcesosDetalleBussinessService();
    }

}
