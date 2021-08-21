<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las monedas
 *
 * @author  $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : moneda_protected no es usada por ahora , ver si queda o sale.
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class MonedaModel extends TSLDataModel
{

    protected $moneda_codigo;
    protected $moneda_simbolo;
    protected $moneda_descripcion;
    protected $moneda_protected;

    /**
     * Setea el codigo de la monedas
     *
     * @param string $moneda_codigo codigo unico de la monedas
     */
    public function set_moneda_codigo(string $moneda_codigo) : void
    {
        $this->moneda_codigo = $moneda_codigo;
        $this->setId($moneda_codigo);
    }

    /**
     * @return string retorna el codigo unico de la monedas
     */
    public function get_moneda_codigo() : string
    {
        return $this->moneda_codigo;
    }

    /**
     * Setea el simbolo que representa a la monedas
     *
     * @param string $moneda_simbolo simbolo de la monedas
     */
    public function set_moneda_simbolo(string $moneda_simbolo) : void
    {
        $this->moneda_simbolo = $moneda_simbolo;
    }

    /**
     * @return string retorna el simbolo que representa a la monedas
     */
    public function get_moneda_simbolo() : string
    {
        return $this->moneda_simbolo;
    }

    /**
     * Setea la descrpcion de la monedas
     *
     * @param string $moneda_descripcion la descrpcion de la monedas
     */
    public function set_moneda_descripcion(string $moneda_descripcion) : void
    {
        $this->moneda_descripcion = $moneda_descripcion;
    }

    /**
     *
     * @return string la descripcion de la monedas
     */
    public function get_moneda_descripcion() : string
    {
        return $this->moneda_descripcion;
    }


    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_moneda_protected() : bool
    {
        if (!isset($this->moneda_protected)) {
            return false;
        }

        return $this->moneda_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param boolean $moneda_protected
     */
    public function set_moneda_protected(bool $moneda_protected) : void
    {
        $this->moneda_protected = self::getAsBool($moneda_protected);
    }

    public function &getPKAsArray() : array
    {
        $pk['moneda_codigo'] = $this->getId();
        return $pk;
    }

}
