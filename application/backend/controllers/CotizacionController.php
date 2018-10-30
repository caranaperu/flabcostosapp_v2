<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de la cabecera de cotizacion.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class CotizacionController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'cotizacion', "validationId" => 'cotizacion_validation', "validationGroupId" => 'v_cotizacion', "validationRulesId" => 'getCotizacion'],
                "add" => ["langId" => 'cotizacion', "validationId" => 'cotizacion_validation', "validationGroupId" => 'v_cotizacion', "validationRulesId" => 'addCotizacion'],
                "del" => ["langId" => 'cotizacion', "validationId" => 'cotizacion_validation', "validationGroupId" => 'v_cotizacion', "validationRulesId" => 'delCotizacion'],
                "upd" => ["langId" => 'cotizacion', "validationId" => 'cotizacion_validation', "validationGroupId" => 'v_cotizacion', "validationRulesId" => 'updCotizacion']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['cotizacion_id', 'verifyExist'],
                "add" => ['empresa_id','cliente_id','cotizacion_es_cliente_real','cotizacion_cerrada','cotizacion_numero','moneda_codigo','cotizacion_fecha','activo'],
                "del" => ['cotizacion_id', 'versionId'],
                "upd" => ['cotizacion_id', 'empresa_id','cliente_id','cotizacion_es_cliente_real','cotizacion_cerrada','cotizacion_numero','moneda_codigo','cotizacion_fecha','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['cotizacion_', 'empresa_', 'moneda_'],
            "paramsFixableToValue" => ["cotizacion_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'cotizacion_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new CotizacionBussinessService();
    }

}
