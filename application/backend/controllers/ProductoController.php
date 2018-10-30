<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los productos (osea contenedor de insumos u otros
 * productos).
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ProductoController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'insumo', "validationId" => 'producto_validation', "validationGroupId" => 'v_producto', "validationRulesId" => 'getProducto'],
                "add" => ["langId" => 'insumo', "validationId" => 'producto_validation', "validationGroupId" => 'v_producto', "validationRulesId" => 'addProducto'],
                "del" => ["langId" => 'insumo', "validationId" => 'producto_validation', "validationGroupId" => 'v_producto', "validationRulesId" => 'delProducto'],
                "upd" => ["langId" => 'insumo', "validationId" => 'producto_validation', "validationGroupId" => 'v_producto', "validationRulesId" => 'updProducto']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['insumo_id', 'verifyExist'],
                "add" => ['empresa_id','insumo_tipo', 'insumo_codigo', 'insumo_descripcion','unidad_medida_codigo_costo','insumo_merma','insumo_precio_mercado','moneda_codigo_costo','activo'],
                "del" => ['insumo_id', 'versionId'],
                "upd" => ['empresa_id','insumo_id','insumo_tipo','insumo_codigo', 'insumo_descripcion','unidad_medida_codigo_costo','insumo_merma','insumo_precio_mercado','moneda_codigo_costo','versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['insumo_','unidad_medida_','moneda_','empresa_',],
            "paramsFixableToValue" => ["insumo_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true],
                                       "insumo_tipo" => ["valueToFix" => 'null', "valueToReplace" => 'PR', "isID" => false]],
           "paramToMapId" => 'insumo_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() : \app\common\bussiness\TSLAppCRUDBussinessService {
        return new ProductoBussinessService();
    }
}
