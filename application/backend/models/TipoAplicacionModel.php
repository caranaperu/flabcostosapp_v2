<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las tipos de aplicacion principales de los productos.
 *
 * @author  Carlos Arana
 * @history , 08-02-2017 , primera version adaptada a php 7.1 .
 */
class TipoAplicacionModel extends TSLDataModel {

    protected $taplicacion_codigo;
    protected $taplicacion_descripcion;
    protected $taplicacion_protected;

    /**
     * Setea el codigo unico del tipo de aplicacion.
     *
     * @param string $taplicacion_codigo codigo  unico del tipo de aplicacion
     */
    public function set_taplicacion_codigo(string $taplicacion_codigo) : void {
        $this->taplicacion_codigo = $taplicacion_codigo;
        $this->setId($taplicacion_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de aplicacion.
     */
    public function get_taplicacion_codigo() : string {
        return $this->taplicacion_codigo;
    }

    /**
     * Setea el nombre del tipo de aplicacion.
     *
     * @param string $taplicacion_descripcion nombre del tipo de aplicacion.
     */
    public function set_taplicacion_descripcion(string $taplicacion_descripcion) : void {
        $this->taplicacion_descripcion = $taplicacion_descripcion;

    }

    /**
     *
     * @return string con el nombre del tipo de aplicacion.
     */
    public function get_taplicacion_descripcion() : string {
        return $this->taplicacion_descripcion;
    }


    public function &getPKAsArray() : array {
        $pk['taplicacion_codigo'] = $this->getId();
        return $pk;
    }

}
