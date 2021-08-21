<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo de entidad fisica que representa los datos de los tipos
 * de cambio por rango de fechas .
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 *
 */
class TipoCambioModel extends TSLDataModel {

    protected $tipo_cambio_id;
    protected $moneda_codigo_origen;
    protected $moneda_codigo_destino;
    protected $tipo_cambio_fecha_desde;
    protected $tipo_cambio_fecha_hasta;
    protected $tipo_cambio_tasa_compra;
    protected $tipo_cambio_tasa_venta;


    public function set_tipo_cambio_id(int $tipo_cambio_id): void {
        $this->tipo_cambio_id = $tipo_cambio_id;
        $this->setId($tipo_cambio_id);
    }

    public function get_tipo_cambio_id(): int {
        return $this->tipo_cambio_id;
    }

    /**
     * Setea el codigo de la moneda origen del TC.
     *
     * @param string $moneda_codigo_origen codigo de la moneda origen del TC.
     */
    public function set_moneda_codigo_origen(string $moneda_codigo_origen) {
        $this->moneda_codigo_origen = $moneda_codigo_origen;
    }


    /**
     * Retorna el codigo de la moneda origen del TC
     *
     * @return string codigo de la unidad de la moneda origen del TC.
     */
    public function get_moneda_codigo_origen(): string {
        return $this->moneda_codigo_origen;
    }

    /**
     * Setea el codigo de la moneda destino del TC
     *
     * @param string $moneda_codigo_destino codigo de la moneda destino del TC.
     */
    public function set_moneda_codigo_destino(string $moneda_codigo_destino) {
        $this->moneda_codigo_destino = $moneda_codigo_destino;
    }


    /**
     * Retorna el codigo de la moneda destino del TC.
     *
     * @return string codigo de la moneda destino del TC.
     */
    public function get_moneda_codigo_destino(): string {
        return $this->moneda_codigo_destino;
    }

    /**
     * Setea desde que fecha es valida el TC.
     *
     * @param string $tipo_cambio_fecha_desde desde que fecha es valida la TC.
     * Este string debera tener el formato aceptado por la persistencia.
     */
    public function set_tipo_cambio_fecha_desde(string $tipo_cambio_fecha_desde): void {
        $this->tipo_cambio_fecha_desde = $tipo_cambio_fecha_desde;
    }

    /**
     * Retorna desde que fecha es valida la TC.
     *
     * @return string desde que fecha es valida la TC.
     */
    public function get_tipo_cambio_fecha_desde(): string {
        return $this->tipo_cambio_fecha_desde;
    }

    /**
     * Setea hasta que fecha es valida el TC.
     *
     * @param string $tipo_cambio_fecha_hasta hasta que fecha es valida el TC.
     * Este string debera tener el formato aceptado por la persistencia.
     *
     */
    public function set_tipo_cambio_fecha_hasta(string $tipo_cambio_fecha_hasta): void {
        $this->tipo_cambio_fecha_hasta = $tipo_cambio_fecha_hasta;
    }

    /**
     * Retorn hasta que fecha es valida el TC.
     *
     * @return string en formato date hasta que fecha es valida el TC.
     */
    public function get_tipo_cambio_fecha_hasta(): string {
        return $this->tipo_cambio_fecha_hasta;
    }

    /**
     * Setea la tasa de conversion entre la moneda origen y  destino a
     * su tasa de compra
     *
     * @param float $tipo_cambio_tasa_compra tasa de compra.
     */
    public function set_tipo_cambio_tasa_compra(float $tipo_cambio_tasa_compra): void {
        $this->tipo_cambio_tasa_compra = $tipo_cambio_tasa_compra;
    }


    /**
     * Retorna la tasa de conversion entre la moneda origen y  destino
     * a su tasa de compra.
     *
     * @return float con la tasa de compra.
     */
    public function get_tipo_cambio_tasa_compra(): float {
        return $this->tipo_cambio_tasa_compra;
    }

    /**
     * Setea la tasa de conversion entre la moneda origen y  destino a
     * su tasa de venta
     *
     * @param  float $tipo_cambio_tasa_venta tasa de compra.
     */
    public function set_tipo_cambio_tasa_venta(float $tipo_cambio_tasa_venta) {
        $this->tipo_cambio_tasa_venta = $tipo_cambio_tasa_venta;
    }


    /**
     * Retorna la tasa de conversion entre la moneda origen y  destino
     * a su tasa de venta.
     *
     * @return float con la tasa de venta.
     */
    public function get_tipo_cambio_tasa_venta(): float {
        return $this->tipo_cambio_tasa_venta;
    }

    public function &getPKAsArray() : array {
        $pk['tipo_cambio_id'] = $this->getId();

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
