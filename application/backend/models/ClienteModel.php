<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos basicos de los clientes
 *
 * @author $Author: aranape $
 * @history , 08-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 *

 */
class ClienteModel extends TSLDataModel {

    protected $cliente_id;
    protected $empresa_id;
    protected $cliente_razon_social;
    protected $cliente_ruc;
    protected $cliente_direccion;
    protected $cliente_correo;
    protected $cliente_telefonos;
    protected $cliente_fax;
    protected $tipo_cliente_codigo;

    public function get_cliente_id() : int {
        return $this->cliente_id;
    }

    /**
     * Retorna el id de la a la que empresa pertenece este cliente
     * @return int con el id de la empresa.
     */
    public function get_empresa_id() : int {
        return $this->empresa_id;
    }

    public function get_cliente_razon_social() : string {
        return $this->cliente_razon_social;
    }

    public function get_cliente_ruc() : string {
        return $this->cliente_ruc;
    }


    public function get_cliente_direccion() : string {
        return $this->cliente_direccion;
    }


    public function get_cliente_correo() : ?string {
        return $this->cliente_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @return string con los telefonos
     */
    public function get_cliente_telefonos() : ?string  {
        return $this->cliente_telefonos;
    }

    public function get_cliente_fax() : ?string  {
        return $this->cliente_fax;
    }


    public function set_cliente_id(int $cliente_id) : void {
        $this->cliente_id = $cliente_id;
        $this->setId($cliente_id);
    }

    /**
     * Setea a que empresa pertenece este cliente.
     *
     * @param int $empresa_id  id de la empresa
     */
    public function set_empresa_id(int $empresa_id) : void {
        $this->empresa_id = $empresa_id;
    }

    public function set_cliente_razon_social(string $cliente_razon_social) : void {
        $this->cliente_razon_social = $cliente_razon_social;
    }

    public function set_cliente_ruc(string $cliente_ruc) : void {
        $this->cliente_ruc = $cliente_ruc;
    }



    public function set_cliente_direccion(string $cliente_direccion) : void {
        $this->cliente_direccion = $cliente_direccion;
    }


    public function set_cliente_correo(?string $cliente_correo) : void {
        $this->cliente_correo = $cliente_correo;
    }

    /**
     * Es un simple string con la lista de telefonos para efectos
     * de impresion de documentos oficiales.
     *
     * @param string $cliente_telefonos con los telefonos
     */
    public function set_cliente_telefonos(?string $cliente_telefonos) : void {
        $this->cliente_telefonos = $cliente_telefonos;
    }

    public function set_cliente_fax(?string $cliente_fax) : void {
        $this->cliente_fax = $cliente_fax;
    }

    /**
     * Setea el tipo de cliente , ej, distribuidor,veterinaria ,etc
     * En realidad es un codigo de tipo de cliente
     *
     * @param string $tipo_cliente_codigo el codigo del tipo de empresa.
     */
    public function set_tipo_cliente_codigo(string $tipo_cliente_codigo) : void {
        $this->tipo_cliente_codigo = $tipo_cliente_codigo;
    }

    /**
     * @return string con el codigo del tipo de cliente.
     */
    public function get_tipo_cliente_codigo() : string {
        return $this->tipo_cliente_codigo;
    }


    public function &getPKAsArray() : array {
        $pk['cliente_id'] = $this->getId();
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
