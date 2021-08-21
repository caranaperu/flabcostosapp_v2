<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las subprocesos a asociar a los productos/procesos.
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class SubProcesosModel extends TSLDataModel
{
    protected $subprocesos_codigo;
    protected $subprocesos_descripcion;

    /**
     * Setea el codigo del subproceso
     *
     * @param string $subprocesos_codigo codigo unico del subproceso
     */
    public function set_subprocesos_codigo(string $subprocesos_codigo) : void
    {
        $this->subprocesos_codigo = $subprocesos_codigo;
        $this->setId($subprocesos_codigo);
    }

    /**
     * @return string retorna el codigo unico del subproceso
     */
    public function get_subprocesos_codigo() : string
    {
        return $this->subprocesos_codigo;
    }

    /**
     * Setea la descrpcion del subproceso
     *
     * @param string $subprocesos_descripcion la descrpcion del subproceso
     */
    public function set_subprocesos_descripcion(string $subprocesos_descripcion) : void
    {
        $this->subprocesos_descripcion = $subprocesos_descripcion;
    }

    /**
     *
     * @return string la descripcion del subproceso
     */
    public function get_subprocesos_descripcion() : string
    {
        return $this->subprocesos_descripcion;
    }

    public function &getPKAsArray() : array
    {
        $pk['subprocesos_codigo'] = $this->getId();
        return $pk;
    }

}
