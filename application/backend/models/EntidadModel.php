<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos basicos de la entidad
 * usuaria del sistema como nombre , direccion , telefonos, etc.
 *
 * @author $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class EntidadModel extends TSLDataModel {

    protected $entidad_id;
    protected $entidad_razon_social;
    protected $entidad_ruc;
    protected $entidad_direccion;
    protected $entidad_correo;
    protected $entidad_telefonos;
    protected $entidad_fax;

    public function get_entidad_id() : int {
        return $this->entidad_id;
    }

    public function get_entidad_razon_social() : string {
        return $this->entidad_razon_social;
    }

    public function get_entidad_ruc() : string {
        return $this->entidad_ruc;
    }


    public function get_entidad_direccion() : string {
        return $this->entidad_direccion;
    }


    public function get_entidad_correo() : string {
        return $this->entidad_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @return string con los telefonos
     */
    public function get_entidad_telefonos() : string {
        return $this->entidad_telefonos;
    }

    public function get_entidad_fax() : string {
        return $this->entidad_fax;
    }


    public function set_entidad_id(int $entidad_id) : void {
        $this->entidad_id = $entidad_id;
        $this->setId($entidad_id);
    }

    public function set_entidad_razon_social(string $entidad_razon_social) : void {
        $this->entidad_razon_social = $entidad_razon_social;
    }

    public function set_entidad_ruc(string $entidad_ruc) : void {
        $this->entidad_ruc = $entidad_ruc;
    }



    public function set_entidad_direccion(string $entidad_direccion) : void {
        $this->entidad_direccion = $entidad_direccion;
    }


    public function set_entidad_correo(string $entidad_correo) : void {
        $this->entidad_correo = $entidad_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @param string $entidad_telefonos con los telefonos
     */
    public function set_entidad_telefonos(string $entidad_telefonos) : void {
        $this->entidad_telefonos = $entidad_telefonos;
    }

    public function set_entidad_fax(string $entidad_fax) : void {
        $this->entidad_fax = $entidad_fax;
    }


    public function &getPKAsArray() : array {
        $pk['entidad_id'] = $this->getId();
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
