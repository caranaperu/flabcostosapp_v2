<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada item de la cotizacion.
 *
 * @author $Author: aranape $
 * @history , 08-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class CotizacionDetalleModel extends TSLDataModel {

    protected $cotizacion_detalle_id;
    protected $cotizacion_id;
    protected $insumo_id;
    protected $cotizacion_detalle_cantidad;
    protected $unidad_medida_codigo;
    protected $cotizacion_detalle_precio;
    protected $cotizacion_detalle_total;


    public function set_cotizacion_detalle_id(int $cotizacion_detalle_id) : void {
        $this->cotizacion_detalle_id = $cotizacion_detalle_id;
        $this->setId($cotizacion_detalle_id);
    }

    public function get_cotizacion_detalle_id() : int {
        return $this->cotizacion_detalle_id;
    }


    /**
     * Setea a la cotizacion que corresponde este item.
     *
     * @param int $cotizacion_id id de la cotizacion a la que corresponde este item.
     */
    public function set_cotizacion_id(int $cotizacion_id) : void {
        $this->cotizacion_id = $cotizacion_id;
    }

    /**
     * @return int con el id de la cotizacion a la que corresponde este item.
     */
    public function get_cotizacion_id() : int {
        return $this->cotizacion_id;
    }

    /**
     * Setea el insumo a cotizar, si la empresa es una fabrica o distribuidor
     * este debe ser del tipo producto.
     *
     * @param integer $insumo_id id del insumo a cotizar.
     */
    public function set_insumo_id(int $insumo_id) : void {
        $this->insumo_id = $insumo_id;
    }


    /**
     * Retorna el id del insumo a cotizar.
     *
     * @return int con el el id del insumo a cotizar.
     */
    public function get_insumo_id() : int {
        return $this->insumo_id;
    }


    /**
     * Setea el precio total del  insumo a cotizar..
     *
     * @param float $cotizacion_detalle_total precio del insumo.
     */
    public function set_cotizacion_detalle_total(float $cotizacion_detalle_total) : void {
        $this->cotizacion_detalle_total = $cotizacion_detalle_total;
    }

    /**
     * Retorna el el precio total del insumo a cotizar..
     *
     * @return float con el precio total  del insumo a cotizar..
     */
    public function get_cotizacion_detalle_total() : float {
        return $this->cotizacion_detalle_total;
    }

    /**
     * Retorna la cantidad a cotizar..
     *
     * @return float con la cantidad a cotizar.
     */
    public function get_cotizacion_detalle_cantidad() : float {
        return $this->cotizacion_detalle_cantidad;
    }

    /**
     * Setea la cantidad a cotizar..
     *
     * @param float $cotizacion_detalle_cantidad la cantidad a cotizar.
     */
    public function set_cotizacion_detalle_cantidad(float $cotizacion_detalle_cantidad) : void  {
        $this->cotizacion_detalle_cantidad = $cotizacion_detalle_cantidad;
    }

    /**
     * Retorna el codigo de la unidad de medida del producto a cotizar.
     *
     * @return string codigo de la  unidad de medida.
     */
    public function get_unidad_medida_codigo() : string {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea la unidad de medida del producto a cotizar.
     *
     * @param string $unidad_medida_codigo codigo de la unidad de medida
     */
    public function set_unidad_medida_codigo(string $unidad_medida_codigo) : void {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }

    /**
     * Retorna el precio unitario del producto.
     *
     * @return float con el precio unitario del producto.
     */
    public function get_cotizacion_detalle_precio() : float {
        return $this->cotizacion_detalle_precio;
    }

    /**
     * Setea el precio unitario del producto.
     *
     * @param float $cotizacion_detalle_precio el precio unitario del producto.
     */
    public function set_cotizacion_detalle_precio(float $cotizacion_detalle_precio) : void {
        $this->cotizacion_detalle_precio = $cotizacion_detalle_precio;
    }



    public function &getPKAsArray() : array {
        $pk['cotizacion_detalle_id'] = $this->getId();

        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() : bool {
        return true;
    }

}
