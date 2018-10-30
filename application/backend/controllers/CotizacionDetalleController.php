<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los items de la cotizacion_detalle.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class cotizacionDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'cotizacion_detalle', "validationId" => 'cotizacion_detalle_validation', "validationGroupId" => 'v_cotizacion_detalle', "validationRulesId" => 'getCotizacionDetalle'],
                "add" => ["langId" => 'cotizacion_detalle', "validationId" => 'cotizacion_detalle_validation', "validationGroupId" => 'v_cotizacion_detalle', "validationRulesId" => 'addCotizacionDetalle'],
                "del" => ["langId" => 'cotizacion_detalle', "validationId" => 'cotizacion_detalle_validation', "validationGroupId" => 'v_cotizacion_detalle', "validationRulesId" => 'delCotizacionDetalle'],
                "upd" => ["langId" => 'cotizacion_detalle', "validationId" => 'cotizacion_detalle_validation', "validationGroupId" => 'v_cotizacion_detalle', "validationRulesId" => 'updCotizacionDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['cotizacion_detalle_id', 'verifyExist'],
                "add" => ['cotizacion_id','insumo_id','cotizacion_detalle_cantidad','unidad_medida_codigo','cotizacion_detalle_precio','cotizacion_detalle_total','activo'],
                "del" => ['cotizacion_detalle_id', 'versionId'],
                "upd" => ['cotizacion_detalle_id','cotizacion_id','insumo_id','cotizacion_detalle_cantidad','unidad_medida_codigo','cotizacion_detalle_precio','cotizacion_detalle_total','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['cotizacion_detalle_', 'cotizacion_', 'insumo_'],
            "paramsFixableToValue" => ["cotizacion_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'cotizacion_detalle_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new CotizacionDetalleBussinessService();
    }

}
