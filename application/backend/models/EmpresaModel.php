<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos basicos de las empresas
 * sean asociadas (fabrica,distribuidora) o clientes.
 *
 * @author $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class EmpresaModel extends TSLDataModel {

    protected $empresa_id;
    protected $empresa_razon_social;
    protected $empresa_ruc;
    protected $empresa_direccion;
    protected $empresa_correo;
    protected $empresa_telefonos;
    protected $empresa_fax;
    protected $tipo_empresa_codigo;

    public function get_empresa_id() : int {
        return $this->empresa_id;
    }

    public function get_empresa_razon_social() : string {
        return $this->empresa_razon_social;
    }

    public function get_empresa_ruc() : string {
        return $this->empresa_ruc;
    }


    public function get_empresa_direccion() : string {
        return $this->empresa_direccion;
    }


    public function get_empresa_correo() : ?string {
        return $this->empresa_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @return string con los telefonos
     */
    public function get_empresa_telefonos() : ?string {
        return $this->empresa_telefonos;
    }

    public function get_empresa_fax() : ?string {
        return $this->empresa_fax;
    }


    public function set_empresa_id(int $empresa_id) : void {
        $this->empresa_id = $empresa_id;
        $this->setId($empresa_id);
    }

    public function set_empresa_razon_social(string $empresa_razon_social) : void {
        $this->empresa_razon_social = $empresa_razon_social;
    }

    public function set_empresa_ruc(string $empresa_ruc) : void {
        $this->empresa_ruc = $empresa_ruc;
    }



    public function set_empresa_direccion(string $empresa_direccion) : void {
        $this->empresa_direccion = $empresa_direccion;
    }


    public function set_empresa_correo(?string $empresa_correo) : void {
        $this->empresa_correo = $empresa_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @param string $empresa_telefonos con los telefonos
     */
    public function set_empresa_telefonos(?string $empresa_telefonos) : void {
        $this->empresa_telefonos = $empresa_telefonos;
    }

    public function set_empresa_fax(?string $empresa_fax) : void {
        $this->empresa_fax = $empresa_fax;
    }

    /**
     * Setea el tipo de empresa , sea cliente, importador ,etc
     * En realidad es un codigo de tipo de empresa
     *
     * @param string $tipo_empresa_codigo el codigo del tipo de empresa.
     */
    public function set_tipo_empresa_codigo(string $tipo_empresa_codigo) : void {
        $this->tipo_empresa_codigo = $tipo_empresa_codigo;
    }

    /**
     * @return string con el codigo del tipo de empresa.
     */
    public function get_tipo_empresa_codigo() : string {
        return $this->tipo_empresa_codigo;
    }


    public function &getPKAsArray() : array  {
        $pk['empresa_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return bool true
     */
    public function isPKSequenceOrIdentity() : bool {
        return true;
    }

}
