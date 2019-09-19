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


    public function &getPKAsArray() : array {
        $pk['tpresentacion_codigo'] = $this->getId();
        return $pk;
    }

}
