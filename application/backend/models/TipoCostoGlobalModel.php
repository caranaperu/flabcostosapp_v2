<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de costos globales tales como la planilla
 * de personal administrativo, luz del area administrtiva , etc
 *
 * @author  Carlos Arana
 * @version 1.00
 * @since   13-MAY-2021
 * @history ''
 *
 * @TODO : tcosto_global_protected no es usada por ahora , ver si queda o sale.
 */
class TipoCostoGlobalModel extends TSLDataModel
{

    protected $tcosto_global_codigo;
    protected $tcosto_global_descripcion;
    protected $tcosto_global_protected;

    /**
     * Setea el codigo del tipo de costo global
     *
     * @param string $tcosto_global_codigo codigo unico de la monedas
     */
    public function set_tcosto_global_codigo(string $tcosto_global_codigo) : void
    {
        $this->tcosto_global_codigo = $tcosto_global_codigo;
        $this->setId($tcosto_global_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de costo global
     */
    public function get_tcosto_global_codigo() : string
    {
        return $this->tcosto_global_codigo;
    }


    /**
     * Setea la descrpcion del tipo de costo global
     *
     * @param string $tcosto_global_descripcion la descrpcion de la monedas
     */
    public function set_tcosto_global_descripcion(string $tcosto_global_descripcion) : void
    {
        $this->tcosto_global_descripcion = $tcosto_global_descripcion;
    }

    /**
     *
     * @return string la descripcion del tipo de costo global
     */
    public function get_tcosto_global_descripcion() : string
    {
        return $this->tcosto_global_descripcion;
    }


    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_tcosto_global_protected() : bool
    {
        if (!isset($this->tcosto_global_protected)) {
            return false;
        }

        return $this->tcosto_global_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * Por la forma que trabaja el PHP y la forma en que este valor es retornado por la base de datos
     * las cuales dependiendo de esta ultima pude vernir 0 o F para indicar falso , esto es tomado
     * como TRUE por el php, el parametro no es indicado especificamente como bool para preservar
     * el valor de entrada y sea interpretado por la funcion getAsBool.
     *
     * @param boolean $tcosto_global_protected
     */
    public function set_tcosto_global_protected($tcosto_global_protected) : void
    {
        $this->tcosto_global_protected = self::getAsBool($tcosto_global_protected);
    }

    public function &getPKAsArray() : array
    {
        $pk['tcosto_global_codigo'] = $this->getId();
        return $pk;
    }

}
