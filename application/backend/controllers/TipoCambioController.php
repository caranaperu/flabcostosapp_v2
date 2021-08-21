<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las tasas de tipo de cambio
 * entre 2 fechas.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class TipoCambioController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'tipocambio', "validationId" => 'tipocambio_validation', "validationGroupId" => 'v_tipocambio', "validationRulesId" => 'getTipoCambio'],
                "add" => ["langId" => 'tipocambio', "validationId" => 'tipocambio_validation', "validationGroupId" => 'v_tipocambio', "validationRulesId" => 'addTipoCambio'],
                "del" => ["langId" => 'tipocambio', "validationId" => 'tipocambio_validation', "validationGroupId" => 'v_tipocambio', "validationRulesId" => 'delTipoCambio'],
                "upd" => ["langId" => 'tipocambio', "validationId" => 'tipocambio_validation', "validationGroupId" => 'v_tipocambio', "validationRulesId" => 'updTipoCambio']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['tipo_cambio_id', 'verifyExist'],
                "add" => ['moneda_codigo_origen','moneda_codigo_destino','tipo_cambio_fecha_desde','tipo_cambio_fecha_hasta','tipo_cambio_tasa_compra','tipo_cambio_tasa_venta', 'activo'],
                "del" => ['tipo_cambio_id', 'versionId'],
                "upd" => ['tipo_cambio_id', 'moneda_codigo_origen','moneda_codigo_destino','tipo_cambio_fecha_desde','tipo_cambio_fecha_hasta','tipo_cambio_tasa_compra','tipo_cambio_tasa_venta', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['tipo_cambio_', 'moneda_'],
            "paramsFixableToValue" => ["tipo_cambio_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'tipo_cambio_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new TipoCambioBussinessService();
    }

}
