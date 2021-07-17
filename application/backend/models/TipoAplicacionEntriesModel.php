<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada entrada del subtipo de tipo de aplicacion.
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class TipoAplicacionEntriesModel extends TSLDataModel {

    protected $taplicacion_entries_id;
    protected $taplicacion_codigo;
    protected $taplicacion_entries_descripcion;


    public function set_taplicacion_entries_id(int $taplicacion_entries_id) : void {
        $this->taplicacion_entries_id = $taplicacion_entries_id;
        $this->setId($taplicacion_entries_id);
    }

    public function get_taplicacion_entries_id() : int {
        return $this->taplicacion_entries_id;
    }


    /**
     * Retorna a que tipo de aplicacion padre corresponde esta entrada
     *
     * @return string codigo del tipo de aplicacion padre.
     */
    public function get_taplicacion_codigo() : string {
        return $this->taplicacion_codigo;
    }

    /**
     * Setea a que tipo de aplicacion padre corresponde esta entrada
     *
     * @param string $taplicacion_codigo codigo del tipo de aplicacion padre.
     */
    public function set_taplicacion_codigo(string $taplicacion_codigo) : void {
        $this->taplicacion_codigo = $taplicacion_codigo;
    }

    /**
     * Retorna la descripcion de este sub tipo de aplicacion.
     *
     * @return string con la descripcion.
     */
    public function get_taplicacion_entries_descripcion() : string {
        return $this->taplicacion_entries_descripcion;
    }

    /**
     * Setea la descripcion del sub tipo de aplicacion
     *
     * @param string $taplicacion_entries_descripcion la descripcion
     */
    public function set_taplicacion_entries_descripcion(string $taplicacion_entries_descripcion) : void {
        $this->taplicacion_entries_descripcion = $taplicacion_entries_descripcion;
    }



    public function &getPKAsArray() : array {
        $pk['taplicacion_entries_id'] = $this->getId();

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
