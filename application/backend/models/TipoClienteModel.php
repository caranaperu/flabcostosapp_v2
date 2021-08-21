<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de clientes
 *
 * @author  $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class TipoClienteModel extends TSLDataModel
{

    protected $tipo_cliente_codigo;
    protected $tipo_cliente_descripcion;

    /**
     * Setea el codigo del tipo de cliente.
     *
     * @param string $tipo_cliente_codigo codigo unico del tipo de cliente.
     */
    public function set_tipo_cliente_codigo(string $tipo_cliente_codigo) : void
    {
        $this->tipo_cliente_codigo = $tipo_cliente_codigo;
        $this->setId($tipo_cliente_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de cliente.
     */
    public function get_tipo_cliente_codigo() : string
    {
        return $this->tipo_cliente_codigo;
    }

    /**
     * Setea la descripcion del tipo de cliente.
     *
     * @param string $tipo_cliente_descripcion la descrpcion del tipo cliente.
     */
    public function set_tipo_cliente_descripcion(string $tipo_cliente_descripcion) : void
    {
        $this->tipo_cliente_descripcion = $tipo_cliente_descripcion;
    }

    /**
     *
     * @return string la descripcion del tipo de cliente.
     */
    public function get_tipo_cliente_descripcion() : string
    {
        return $this->tipo_cliente_descripcion;
    }


    public function &getPKAsArray() : array
    {
        $pk['tipo_cliente_codigo'] = $this->getId();
        return $pk;
    }

}
