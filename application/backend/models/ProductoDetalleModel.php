<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo de entidad fisica que representa los datos de los items que componen un producto,
 * estos pueden ser otro producto o un insumo.
 *
 * @author $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class ProductoDetalleModel extends TSLDataModel {

    protected $producto_detalle_id;
    protected $insumo_id_origen;
    protected $insumo_id;
    protected $empresa_id;
    protected $unidad_medida_codigo;
    protected $producto_detalle_cantidad;
    protected $producto_detalle_valor;
    protected $producto_detalle_merma;


    public function set_producto_detalle_id(int $producto_detalle_id): void {
        $this->producto_detalle_id = $producto_detalle_id;
        $this->setId($producto_detalle_id);
    }

    public function get_producto_detalle_id(): int {
        return $this->producto_detalle_id;
    }

    /**
     * Setea el id del insumo (producto) del cual sera comoponente
     * este registro.
     *
     * @param int $insumo_id_origen el id del insumo(producto) del cual es componente.
     */
    public function set_insumo_id_origen(int $insumo_id_origen): void {
        $this->insumo_id_origen = $insumo_id_origen;
    }

    /**
     * Retorna  el id del insumo (producto) del cual sera comoponente
     * este registro.
     *
     * @return integer con el id del insumo (producto origen).
     */
    public function get_insumo_id_origen(): int {
        return $this->insumo_id_origen;
    }


    /**
     * Setea el id del insumo que es parte del costo del
     * producto principal , este puede ser insumo u otro
     * producto.
     *
     * @param int $insumo_id el ide del insumo o producto parte de este.
     */
    public function set_insumo_id(int $insumo_id): void {
        $this->insumo_id = $insumo_id;
    }

    /**
     * Retorna  el id del insumo que es parte del costo del
     * producto principal , este puede ser insumo u otro
     * producto.
     *
     * @return integer con el id del insumo.
     */
    public function get_insumo_id(): int {
        return $this->insumo_id;
    }

    /**
     * Retorna a que empresa pertenece la creacion de este item.
     *
     * @return int empresa_id con el id de la empresa asociada a este item.
     */
    public function get_empresa_id(): int {
        return $this->empresa_id;
    }

    /**
     * Setea a que empresa esta asociado este item , hay que indicar
     * que para un solo producto puede haber diferentes definiciones , segun
     * sea la empresa por ejemplo importadora , fabrica , distribuidora.
     *
     * @param int $empresa_id con el id de la empresa asociada a este item
     */
    public function set_empresa_id(int $empresa_id): void {
        $this->empresa_id = $empresa_id;
    }

    /**
     * Setea el codigo de la unidad de medida en la que se costeara este
     * insumo o producto.
     *
     * @param string $unidad_medida_codigo codigo de la unidad de medida en que se costeara.
     */
    public function set_unidad_medida_codigo(string $unidad_medida_codigo): void {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }


    /**
     * Retorna el codigo de la unidad de medida en la que se costeara este
     * insumo o producto.
     *
     * @return string codigo de la unidad de medida en que se costeara.
     */
    public function get_unidad_medida_codigo(): string {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea la cantidad en las unidades de medida en que se costeara este elemento dentro
     * del producto al que aporta.
     *
     * @param float $producto_detalle_cantidad cantidad en las unidades de medida en que se costeara.
     */
    public function set_producto_detalle_cantidad(float $producto_detalle_cantidad): void {
        $this->producto_detalle_cantidad = $producto_detalle_cantidad;
    }


    /**
     * Retorna la cantidad en las unidades de medida en que se costeara este elemento dentro
     * del producto al que aporta.
     *
     * @return float con la cantidad.
     */
    public function get_producto_detalle_cantidad(): float {
        return $this->producto_detalle_cantidad;
    }

    /**
     * Setea el valor de base que sirve para calcular el costo , este debe estar en la
     * moneda original del insumo / producto siempre.
     *
     * @param float $producto_detalle_valor valor de base que sirve para calcular el costo.
     */
    public function set_producto_detalle_valor(float $producto_detalle_valor): void {
        $this->producto_detalle_valor = $producto_detalle_valor;
    }


    /**
     * Retorna el valor de base que sirve para calcular el costo , este estara en la
     * moneda original del insumo / producto padre siempre.
     *
     * @return float con el valor
     */
    public function get_producto_detalle_valor(): float {
        return $this->producto_detalle_valor;
    }

    /**
     * Retorna la merma del producto o insumo al aplicarse al principal.
     *
     * @return float la merma del producto o insumo
     */
    public function get_producto_detalle_merma() {
        return $this->producto_detalle_merma;
    }

    /**
     * Setea la merma del producto o insumo al aplicarse al principal.
     *
     * @param float $producto_detalle_merma la merma del producto o insumo
     */
    public function set_producto_detalle_merma(float $producto_detalle_merma): void {
        $this->producto_detalle_merma = $producto_detalle_merma;
    }


    public function &getPKAsArray() : array  {
        $pk['producto_detalle_id'] = $this->getId();

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
