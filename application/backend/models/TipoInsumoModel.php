<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las tipos de insumos a utilizar en una composicion
 * o mezcla.
 *
 * @author  $Author: aranape $
 * @history , 08-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class TipoInsumoModel extends TSLDataModel {

    protected $tinsumo_codigo;
    protected $tinsumo_descripcion;
    protected $tinsumo_protected;

    /**
     * Setea el codigo unico del tipo de insumo.
     *
     * @param string $tinsumo_codigo codigo  unico del tipo de insumo
     */
    public function set_tinsumo_codigo(string $tinsumo_codigo) : void {
        $this->tinsumo_codigo = $tinsumo_codigo;
        $this->setId($tinsumo_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de insumo.
     */
    public function get_tinsumo_codigo() : string {
        return $this->tinsumo_codigo;
    }

    /**
     * Setea el nombre del tipo de insumo.
     *
     * @param string $tinsumo_descripcion nombre del tipo de insumo.
     */
    public function set_tinsumo_descripcion(string $tinsumo_descripcion) : void {
        $this->tinsumo_descripcion = $tinsumo_descripcion;

    }

    /**
     * Setea si el tipo de insumo es protegido
     * o de sistema, este flag indicara si ùede eliminarse o no.
     *
     * @param boolean $tinsumo_protected TRUE si el tipo de insumo es protegido
     */
    public function set_tinsumo_protected(bool $tinsumo_protected) : void {
        $this->tinsumo_protected = self::getAsBool($tinsumo_protected);
    }

    /**
     * @return boolean retorna si el tipo de insumo es protegido
     */
    public function get_tinsumo_protected() : bool {
        if (!isset($this->tinsumo_protected)) {
            return false;
        }

        return $this->tinsumo_protected;
    }

    /**
     *
     * @return string con el nombre del tipo de insumo.
     */
    public function get_tinsumo_descripcion() : string {
        return $this->tinsumo_descripcion;
    }


    public function &getPKAsArray() : array {
        $pk['tinsumo_codigo'] = $this->getId();
        return $pk;
    }

}
