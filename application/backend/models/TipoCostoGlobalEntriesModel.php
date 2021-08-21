<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada entrada de valor para cada tipo de costo global valido
 * desde una determinada fecha.
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class TipoCostoGlobalEntriesModel extends TSLDataModel {

    protected $tcosto_global_entries_id;
    protected $tcosto_global_entries_fecha_desde;
    protected $tcosto_global_codigo;
    protected $tcosto_global_entries_valor;
    protected $moneda_codigo;


    public function set_tcosto_global_entries_id(int $tcosto_global_entries_id) : void {
        $this->tcosto_global_entries_id = $tcosto_global_entries_id;
        $this->setId($tcosto_global_entries_id);
    }

    public function get_tcosto_global_entries_id() : int {
        return $this->tcosto_global_entries_id;
    }


    /**
     * Setea la fecha de la importacion
     *
     * @param string $tcosto_global_entries_fecha_desde la fecha desde la que se usara el valor del movimento
     * de costo global.
     * Debe represetar una fecha compatible con la persistencia en uso.
     */
    public function set_tcosto_global_entries_fecha_desde(string $tcosto_global_entries_fecha_desde): void {
        $this->tcosto_global_entries_fecha_desde = $tcosto_global_entries_fecha_desde;
    }


    /**
     * Retorna la fecha desde la que se usara el valor del movimento
     * de costo global.
     *
     * @return string la fecha
     */
    public function get_tcosto_global_entries_fecha_desde(): string {
        return $this->tcosto_global_entries_fecha_desde;
    }

    /**
     * Setea codigo de costo global al cual pertenece la entrada de valor a gregar.
     *
     * @param string $tcosto_global_codigo codigo del tipo de costo global.
     */
    public function set_tcosto_global_codigo(string $tcosto_global_codigo) : void {
        $this->tcosto_global_codigo = $tcosto_global_codigo;
    }


    /**
     * Retorna el codigo del tipo de costo global al cual pertenece la entrada de valor a agregar
     *
     * @return string el codigo del tipo de costo global
     */
    public function get_tcosto_global_codigo() : string {
        return $this->tcosto_global_codigo;
    }


    /**
     * Retorna el valor total asignado al tipo de costo global.
     *
     * @return float con el valor total asignado al tipo de costo global.
     */
    public function get_tcosto_global_entries_valor() : float {
        return $this->tcosto_global_entries_valor;
    }

    /**
     * Setea el valor total asignado al tipo de costo global.
     *
     * @param float $tcosto_global_entries_valor el valor total asignado al tipo de costo global.
     */
    public function set_tcosto_global_entries_valor(float $tcosto_global_entries_valor) : void {
        $this->tcosto_global_entries_valor = $tcosto_global_entries_valor;
    }

    /**
     * Retorna el codigo de la moneda a usar para el valor de la entrada.
     *
     * @return string con el codigo de la moneda.
     */
    public function get_moneda_codigo() : string {
        return $this->moneda_codigo;
    }

    /**
     * Setea el codigo de la moneda a usar para el valor de la entrada.
     *
     * @param string $moneda_codigo el codigo de la moneda.
     */
    public function set_moneda_codigo(string $moneda_codigo) : void {
        $this->moneda_codigo = $moneda_codigo;
    }

    public function &getPKAsArray() : array {
        $pk['tcosto_global_entries_id'] = $this->getId();

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
