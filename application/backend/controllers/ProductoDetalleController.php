<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las prudctos o insumos
 * que componen otro producto.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ProductoDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'productodetalle', "validationId" => 'productodetalle_validation', "validationGroupId" => 'v_productodetalle', "validationRulesId" => 'getProductoDetalle'],
                "add" => ["langId" => 'productodetalle', "validationId" => 'productodetalle_validation', "validationGroupId" => 'v_productodetalle', "validationRulesId" => 'addProductoDetalle'],
                "del" => ["langId" => 'productodetalle', "validationId" => 'productodetalle_validation', "validationGroupId" => 'v_productodetalle', "validationRulesId" => 'delProductoDetalle'],
                "upd" => ["langId" => 'productodetalle', "validationId" => 'productodetalle_validation', "validationGroupId" => 'v_productodetalle', "validationRulesId" => 'updProductoDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['producto_detalle_id', 'verifyExist'],
                "add" => ['insumo_id_origen','insumo_id','insumo_descripcion','empresa_id','unidad_medida_codigo','unidad_medida_descripcion','producto_detalle_cantidad','producto_detalle_valor','producto_detalle_merma', 'activo'],
                "del" => ['producto_detalle_id', 'versionId'],
                "upd" => ['producto_detalle_id','insumo_id_origen','insumo_id','empresa_id','insumo_descripcion','unidad_medida_codigo','unidad_medida_descripcion','producto_detalle_cantidad','producto_detalle_valor','producto_detalle_merma', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['producto_detalle_', 'unidad_medida_','insumo_'],
            "paramsFixableToValue" => ["producto_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'producto_detalle_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ProductoDetalleBussinessService();
    }

}
