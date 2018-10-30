<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las tipos de costos.
 *
 * @author  $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1 y correccion de
 * set_tcostos_indirecto/get_tcostos_indirecto referenciaban incorrectamente al miembro
 * tinsumo_indirecto el cual no es parte del modelo.
 *
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class TipoCostosModel extends TSLDataModel {

    protected $tcostos_codigo;
    protected $tcostos_descripcion;
    protected $tcostos_protected;
    protected $tcostos_indirecto;

    /**
     * Setea el codigo unico del tipo de insumo.
     *
     * @param string $tcostos_codigo codigo  unico del tipo de insumo
     */
    public function set_tcostos_codigo(string $tcostos_codigo) : void {
        $this->tcostos_codigo = $tcostos_codigo;
        $this->setId($tcostos_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de insumo.
     */
    public function get_tcostos_codigo() : string {
        return $this->tcostos_codigo;
    }

    /**
     * Setea el nombre del tipo de insumo.
     *
     * @param string $tcostos_descripcion nombre del tipo de insumo.
     */
    public function set_tcostos_descripcion(string $tcostos_descripcion) : void {
        $this->tcostos_descripcion = $tcostos_descripcion;
    }

    /**
     *
     * @return string con el nombre del tipo de insumo.
     */
    public function get_tcostos_descripcion() : string {
        return $this->tcostos_descripcion;
    }

    /**
     * Setea si el tipo de costos es protegido
     * o de sistema, este flag indicara si puede eliminarse o no.
     *
     * @param boolean $tcostos_protected TRUE si el tipo de costos es protegido
     */
    public function set_tcostos_protected(bool $tcostos_protected) : void {
        $this->tcostos_protected = self::getAsBool($tcostos_protected);
    }

    /**
     * @return boolean retorna si el tipo de costos es protegido
     */
    public function get_tcostos_protected() : bool {
        if (!isset($this->tcostos_protected)) {
            return false;
        }

        return $this->tcostos_protected;
    }

    /**
     * Setea si el tipo de costo es indirecto.
     *
     * @param boolean $tcostos_indirecto TRUE O FALSE.
     */
    public function set_tcostos_indirecto(bool $tcostos_indirecto) : void {
        $this->tcostos_indirecto = self::getAsBool($tcostos_indirecto);
    }

    /**
     *
     * @return boolean indicando si el tipo de costo es indirecto o no.
     */
    public function get_tcostos_indirecto() : bool {
        if (!isset($this->tcostos_indirecto)) {
            return false;
        }

        return $this->tcostos_indirecto;
    }

    public function &getPKAsArray(): array {
        $pk['tcostos_codigo'] = $this->getId();
        return $pk;
    }

}
