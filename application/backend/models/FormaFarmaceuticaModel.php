<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las diversas formas farmaceuticas de los productos
 *
 * @author  $Author: aranape $
 * @history , 05-03-2019 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class FormaFarmaceuticaModel extends TSLDataModel {

    protected $ffarmaceutica_codigo;
    protected $ffarmaceutica_descripcion;
    protected $ffarmaceutica_protected;

    /**
     * Setea el codigo unico que identifica la forma farmaceutica
     *
     * @param string $ffarmaceutica_codigo codigo de la forma farmaceutica
     */
    public function set_ffarmaceutica_codigo(string $ffarmaceutica_codigo) : void {
        $this->ffarmaceutica_codigo = $ffarmaceutica_codigo;
        $this->setId($ffarmaceutica_codigo);
    }

    /**
     * @return string retorna el codigo unico de la forma farmaceutica.
     */
    public function get_ffarmaceutica_codigo() : string {
        return $this->ffarmaceutica_codigo;
    }

    /**
     * Setea el nombre de la forma farmaceutica.
     *
     * @param string $ffarmaceutica_descripcion nombre de la forma farmaceutica.
     */
    public function set_ffarmaceutica_descripcion(string $ffarmaceutica_descripcion) : void {
        $this->ffarmaceutica_descripcion = $ffarmaceutica_descripcion;

    }

    /**
     * Setea si la forma farmaceutica es protegido
     * o de sistema, este flag indicara si ùede eliminarse o no.
     *
     * @param boolean $ffarmaceutica_protected TRUE si la forma farmaceutica es protegido
     */
    public function set_ffarmaceutica_protected(bool $ffarmaceutica_protected) : void {
        $this->ffarmaceutica_protected = self::getAsBool($ffarmaceutica_protected);
    }

    /**
     * @return boolean retorna si la forma farmaceutica es protegida
     */
    public function get_ffarmaceutica_protected() : bool {
        if (!isset($this->ffarmaceutica_protected)) {
            return false;
        }

        return $this->ffarmaceutica_protected;
    }

    /**
     *
     * @return string con el nombre de la forma farmaceutica.
     */
    public function get_ffarmaceutica_descripcion() : string {
        return $this->ffarmaceutica_descripcion;
    }


    public function &getPKAsArray() : array {
        $pk['ffarmaceutica_codigo'] = $this->getId();
        return $pk;
    }

}
