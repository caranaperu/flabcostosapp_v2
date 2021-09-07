<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las diversas presentaciones de los productos
 *
 * @author  $Author: aranape $
 * @history , 05-03-2019 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class PresentacionModel extends TSLDataModel {

    protected $tpresentacion_codigo;
    protected $tpresentacion_descripcion;
    protected $unidad_medida_codigo_costo;
    protected $tpresentacion_cantidad_costo;
    protected $tpresentacion_protected;

    /**
     * Setea el codigo unico que identifica la presentacion
     *
     * @param string $tpresentacion_codigo codigo de la presentacion
     */
    public function set_tpresentacion_codigo(string $tpresentacion_codigo) : void {
        $this->tpresentacion_codigo = $tpresentacion_codigo;
        $this->setId($tpresentacion_codigo);
    }

    /**
     * @return string retorna el codigo unico de la presentacion.
     */
    public function get_tpresentacion_codigo() : string {
        return $this->tpresentacion_codigo;
    }

    /**
     * Setea el nombre de la presentacion.
     *
     * @param string $tpresentacion_descripcion nombre de la presentacion.
     */
    public function set_tpresentacion_descripcion(string $tpresentacion_descripcion) : void {
        $this->tpresentacion_descripcion = $tpresentacion_descripcion;

    }

    /**
     * Setea si la presentacion es protegido
     * o de sistema, este flag indicara si ùede eliminarse o no.
     *
     * @param boolean $tpresentacion_protected TRUE si la presentacion es protegido
     */
    public function set_tpresentacion_protected(bool $tpresentacion_protected) : void {
        $this->tpresentacion_protected = self::getAsBool($tpresentacion_protected);
    }

    /**
     * @return boolean retorna si la presentacion es protegida
     */
    public function get_tpresentacion_protected() : bool {
        if (!isset($this->tpresentacion_protected)) {
            return false;
        }

        return $this->tpresentacion_protected;
    }

    /**
     *
     * @return string con el nombre de la presentacion.
     */
    public function get_tpresentacion_descripcion() : string {
        return $this->tpresentacion_descripcion;
    }



    /**
     * Setea el codigo de la unidad de medida que la presentacion usara para costeo
     *
     * @param string $unidad_medida_codigo_costo codigo de la unidad de medida
     */
    public function set_unidad_medida_codigo_costo(string $unidad_medida_codigo_costo) : void {
        $this->unidad_medida_codigo_costo = $unidad_medida_codigo_costo;
    }

    /**
     * Retorna el codigo de la unidad de medida que la presentacion usara para costeo
     *
     * @return string el codigo de la unidad de medida
     */
    public function get_unidad_medida_codigo_costo() : string {
        return $this->unidad_medida_codigo_costo;
    }

    /**
     *
     * Retorna cantidad  de costo o lo que es lo mismo la cantidad de la presentacion
     * del producto ej. 120M , lo cual estara expresado en la unidad de costo
     *
     * @param float con la cantidad
     */
    public function get_tpresentacion_cantidad_costo() : float {
        return $this->tpresentacion_cantidad_costo;
    }


    /**
     * Setea la cantidad de costo o lo que es lo mismo la cantidad de la presentacion
     * del producto ej. 120, lo cual estara expresado en la unidad de costo
     *
     * @param double $tpresentacion_cantidad_costo la cantidad
     */
    public function set_tpresentacion_cantidad_costo(float $tpresentacion_cantidad_costo) : void {
        $this->tpresentacion_cantidad_costo = $tpresentacion_cantidad_costo;
    }

    public function &getPKAsArray() : array {
        $pk['tpresentacion_codigo'] = $this->getId();
        return $pk;
    }

}
