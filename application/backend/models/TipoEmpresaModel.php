<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de empresas
 *
 * @author  $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class TipoEmpresaModel extends TSLDataModel
{

    protected $tipo_empresa_codigo;
    protected $tipo_empresa_descripcion;

    /**
     * Setea el codigo del tipo de empresa
     *
     * @param string $tipo_empresa_codigo codigo unico del tipo de empresa
     */
    public function set_tipo_empresa_codigo(string $tipo_empresa_codigo) : void
    {
        $this->tipo_empresa_codigo = $tipo_empresa_codigo;
        $this->setId($tipo_empresa_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de empresa.
     */
    public function get_tipo_empresa_codigo() : string
    {
        return $this->tipo_empresa_codigo;
    }

    /**
     * Setea la descrpcion del tipo de moneda.
     *
     * @param string $tipo_empresa_descripcion la descrpcion del tipo de empresa.
     */
    public function set_tipo_empresa_descripcion(string $tipo_empresa_descripcion) : void
    {
        $this->tipo_empresa_descripcion = $tipo_empresa_descripcion;
    }

    /**
     *
     * @return string la descripcion del tipo de empresa.
     */
    public function get_tipo_empresa_descripcion() : string
    {
        return $this->tipo_empresa_descripcion;
    }


    public function &getPKAsArray() : array
    {
        $pk['tipo_empresa_codigo'] = $this->getId();
        return $pk;
    }

}
