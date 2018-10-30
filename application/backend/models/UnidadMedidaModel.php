<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo  para definir las unidades de medida
 *
 * @author  $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1 y correccion de
 * get_unidad_medida_protected la cual actuaba como
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class UnidadMedidaModel extends TSLDataModel {

    protected $unidad_medida_codigo;
    protected $unidad_medida_siglas;
    protected $unidad_medida_descripcion;
    protected $unidad_medida_tipo;
    protected $unidad_medida_protected;
    protected $unidad_medida_default;
    private static $_UM_TIPO = [
        'P',
        'V',
        'L',
        'T'
    ];

    /**
     * Setea el codigo de la unidad de medida
     *
     * @param string $unidad_medida_codigo codigo unico de la unidad de medida
     */
    public function set_unidad_medida_codigo(string $unidad_medida_codigo): void {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
        $this->setId($unidad_medida_codigo);
    }

    /**
     * @return string retorna el codigo unico de la unidad de medida
     */
    public function get_unidad_medida_codigo(): string {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea las siglas de la unidad de medida
     *
     * @param string $unidad_medida_siglas siglas de la unidad de medida
     */
    public function set_unidad_medida_siglas(string $unidad_medida_siglas): void {
        $this->unidad_medida_siglas = $unidad_medida_siglas;
    }

    /**
     * @return string retorna las siglas de la unidad de medida
     */
    public function get_unidad_medida_siglas() : string {
        return $this->unidad_medida_siglas;
    }

    /**
     * Setea la descrpcion de la unidad de medida
     *
     * @param string $unidad_medida_descripcion la descrpcion de la unidad de medida
     */
    public function set_unidad_medida_descripcion(string $unidad_medida_descripcion) : void {
        $this->unidad_medida_descripcion = $unidad_medida_descripcion;
    }

    /**
     *
     * @return string la descripcion de la unidad de medida
     */
    public function get_unidad_medida_descripcion() : string {
        return $this->unidad_medida_descripcion;
    }


    /**
     * Los valores que retorna como tipo de unidad de medida son:
     *      'P' - Peso
     *      'V' - Volumen
     *      'L' - Longitud
     *      'T' - Tiempo
     *
     * @return string el tipo de unidad de medida de un solo caracter,
     * null si no esta bien definido.
     */
    public function get_unidad_medida_tipo() : string {
        return $this->unidad_medida_tipo;
    }

    /**
     * Setea  el tipo de unidad de medida, los cuales pueden ser
     *      'P' - Peso
     *      'V' - Volumen
     *      'L' - Longitud
     *      'T' - Tiempo
     *
     * @param string $unidad_medida_tipo con el tipo (u caracter)
     * @TODO: Deberia poder indicarse que en realidad devuelve un caracter.
     */
    public function set_unidad_medida_tipo(string $unidad_medida_tipo) : void {
        $unidad_medida_tipo_u = strtoupper($unidad_medida_tipo);

        if (in_array($unidad_medida_tipo_u, UnidadMedidaModel::$_UM_TIPO)) {
            $this->unidad_medida_tipo = $unidad_medida_tipo_u;
        } else {
            $this->unidad_medida_tipo = null;
        }
    }

    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_unidad_medida_protected() : bool {
        if (!isset($this->unidad_medida_protected)) {
            return false;
        }

        return $this->unidad_medida_protected;

    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param bool $unidad_medida_protected
     */
    public function set_unidad_medida_protected(bool $unidad_medida_protected) : void {
        $this->unidad_medida_protected = self::getAsBool($unidad_medida_protected);
    }

    /**
     * Setea si esta unidad de medida sera usada como default de conversion cuando
     * se requiera saber todos los componentes de un producto y alguno exista mas de una
     * vez con diferente unidad de medida (del mismo tipo).
     *
     * @param boolean $unidad_medida_default true /  false.
     */
    public function set_unidad_medida_default(bool $unidad_medida_default) : void{
        $this->unidad_medida_default = self::getAsBool($unidad_medida_default);
    }

    /**
     * Retorna si esta unidad de medida es la default de conversion.
     *
     *
     * @return boolean true / true.
     */
    public function get_unidad_medida_default() : bool {
        if (!isset($this->unidad_medida_default)) {
            return false;
        }

        return $this->unidad_medida_default;
    }

    public function &getPKAsArray() : array {
        $pk['unidad_medida_codigo'] = $this->getId();

        return $pk;
    }

}
