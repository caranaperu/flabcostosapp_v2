<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de la cabecera de la relacion producto-procesos
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class ProductoProcesosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'producto_procesos', "validationId" => 'producto_procesos_validation', "validationGroupId" => 'v_producto_procesos', "validationRulesId" => 'getProductoProcesos'],
                "add" => ["langId" => 'producto_procesos', "validationId" => 'producto_procesos_validation', "validationGroupId" => 'v_producto_procesos', "validationRulesId" => 'addProductoProcesos'],
                "del" => ["langId" => 'producto_procesos', "validationId" => 'producto_procesos_validation', "validationGroupId" => 'v_producto_procesos', "validationRulesId" => 'delProductoProcesos'],
                "upd" => ["langId" => 'producto_procesos', "validationId" => 'producto_procesos_validation', "validationGroupId" => 'v_producto_procesos', "validationRulesId" => 'updProductoProcesos']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['producto_procesos_id', 'verifyExist'],
                "add" => ['insumo_id','producto_procesos_fecha_desde','activo'],
                "del" => ['producto_procesos_id', 'versionId'],
                "upd" => ['producto_procesos_id', 'insumo_id','producto_procesos_fecha_desde','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['producto_procesos_', 'insumo_'],
            "paramsFixableToValue" => ["producto_procesos_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'producto_procesos_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ProductoProcesosBussinessService();
    }

}
