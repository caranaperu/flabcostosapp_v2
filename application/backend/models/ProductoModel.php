<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo  para definir los productos que contendran una formula o composicion
 * de una combinacion de insumo y otros productos.
 *
 * Este modelo es parte de insumos ya que los productos son un subconjunto de datos
 * de los insumos.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 *
 */
class ProductoModel extends TSLDataModel {
    protected $empresa_id;
    protected $insumo_id;
    protected $insumo_tipo;
    protected $insumo_codigo;
    protected $insumo_descripcion;
    protected $unidad_medida_codigo_costo;
    protected $insumo_merma;
    protected $moneda_codigo_costo;
    protected $insumo_precio_mercado;


    private static $_INSUMO_TIPO = ['IN', 'PR'];

    /**
     * Retorna a que empresa pertenece la creacion de este producto.
     *
     * @return int empresa_id con el id de la empresa asociada a este producto.
     */
    public function get_empresa_id() : int {
        return $this->empresa_id;
    }

    /**
     * Setea a que empresa esta asociado este producto , hay que indicar
     * que para un solo producto puede haber diferentes definiciones , segun
     * sea la empresa por ejemplo importadora , fabrica , distribuidora.
     *
     * @param int $empresa_id con el id de la empresa asociada a este producto
     */
    public function set_empresa_id(int $empresa_id) : void {
        $this->empresa_id = $empresa_id;
    }


    public function set_insumo_id(int $insumo_id) : void {
        $this->insumo_id = $insumo_id;
        $this->setId($insumo_id);
    }

    public function get_insumo_id() : int {
        return $this->insumo_id;
    }

    /**
     * Retorna con el tipo de insumo.
     *
     * @return string con el tipo de insumo.
     */
    public function get_insumo_tipo() : string {
        return $this->insumo_tipo;
    }

    /**
     * Setea el tipo de insumo , IN para insumo , PR para
     * producto.
     *
     * @param string $insumo_tipo con el tipo de insumo.
     * los valores pueden ser 'IN','PR'
     */
    public function set_insumo_tipo(string $insumo_tipo) : void {
        $insumo_tipo_u = strtoupper($insumo_tipo);

        if (in_array($insumo_tipo_u, ProductoModel::$_INSUMO_TIPO)) {
            $this->insumo_tipo = $insumo_tipo_u;
        } else {
            $this->insumo_tipo = '??';
        }
    }


    /**
     * Setea el codigo unico dek insumo.
     *
     * @param string $insumo_codigo codigo  unico del del insumo
     */
    public function set_insumo_codigo(string $insumo_codigo) : void {
        $this->insumo_codigo = $insumo_codigo;
    }

    /**
     * @return string retorna el codigo unico del insumo.
     */
    public function get_insumo_codigo() : string {
        return $this->insumo_codigo;
    }

    /**
     * Setea el nombre del insumo.
     *
     * @param string $insumo_descripcion nombre del insumo.
     */
    public function set_insumo_descripcion(string $insumo_descripcion) : void {
        $this->insumo_descripcion = $insumo_descripcion;
    }

    /**
     *
     * @return string con el nombre del insumo.
     */
    public function get_insumo_descripcion() : string {
        return $this->insumo_descripcion;
    }


    /**
     * Setea el codigo de la unidad de medida del insumo en las unidades minimas
     * de costeo.
     *
     * @param string $unidad_medida_codigo_costo codigo de la unidad de medida del insumo para costos
     */
    public function set_unidad_medida_codigo_costo(string $unidad_medida_codigo_costo) : void {
        $this->unidad_medida_codigo_costo = $unidad_medida_codigo_costo;
    }

    /**
     * Retorna el codigo de la unidad de medida del insumoen las unidades minimas
     * de costeo.
     *
     * @return string el codigo de la unidad de medida del insumo para costo
     */
    public function get_unidad_medida_codigo_costo() : string {
        return $this->unidad_medida_codigo_costo;
    }



    /**
     * Setea la cantidad de merma de produccion de este insumo.
     *
     * @param float $insumo_merma merma del insumo.
     */
    public function set_insumo_merma(float $insumo_merma) : void {
        $this->insumo_merma = $insumo_merma;
    }


    /**
     * Retorna la cantidad de merma de produccion de este insumo.
     *
     * @return float merma del insumo.
     */
    public function get_insumo_merma() : float {
        return $this->insumo_merma;
    }

    /**
     * Setea el codigo de la moneda el codigo de la moneda en el que se encuentra
     * el costo.
     *
     * @param string $moneda_codigo_costo codigo de la moneda .
     */
    public function set_moneda_codigo_costo(string $moneda_codigo_costo) : void {
        $this->moneda_codigo_costo = $moneda_codigo_costo;
    }


    /**
     * Retorna el codigo de la moneda en el que se encuentra
     * el costo.
     *
     * @return string codigo de la moneda.
     */
    public function get_moneda_codigo_costo() : string {
        return $this->moneda_codigo_costo;
    }
    
    /**
     * Retrona el precio de mercado.
     *
     * @return float con el precio del mercado.
     */
    public function get_insumo_precio_mercado() : float {
        return $this->insumo_precio_mercado;
    }

    /**
     * Setea el precio de mercado del insumo, esto es basicamente valido
     * si el insumo es de costo directo.
     *
     * @param double $insumo_precio_mercado con el precio de mercado.
     */
    public function set_insumo_precio_mercado(float $insumo_precio_mercado) : void {
        $this->insumo_precio_mercado = $insumo_precio_mercado;
    }

    public function &getPKAsArray() : array {
        $pk['insumo_id'] = $this->getId();

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
