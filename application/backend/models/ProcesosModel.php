<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las procesos a asociar a los productos.
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class ProcesosModel extends TSLDataModel
{
    protected $procesos_codigo;
    protected $procesos_descripcion;

    /**
     * Setea el codigo del proceso
     *
     * @param string $procesos_codigo codigo unico del proceso
     */
    public function set_procesos_codigo(string $procesos_codigo) : void
    {
        $this->procesos_codigo = $procesos_codigo;
        $this->setId($procesos_codigo);
    }

    /**
     * @return string retorna el codigo unico del proceso
     */
    public function get_procesos_codigo() : string
    {
        return $this->procesos_codigo;
    }

    /**
     * Setea la descrpcion del proceso
     *
     * @param string $procesos_descripcion la descrpcion del proceso
     */
    public function set_procesos_descripcion(string $procesos_descripcion) : void
    {
        $this->procesos_descripcion = $procesos_descripcion;
    }

    /**
     *
     * @return string la descripcion del proceso
     */
    public function get_procesos_descripcion() : string
    {
        return $this->procesos_descripcion;
    }

    public function &getPKAsArray() : array
    {
        $pk['procesos_codigo'] = $this->getId();
        return $pk;
    }

}
