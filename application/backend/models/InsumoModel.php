<?php

if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo  para definir las tipos de insumos a utilizar en una composicion
 * o mezcla.
 * Este modelo es compartido con productos ya que estos son un sub conjunto
 * de datos de este modelo.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @author $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 *
 */
class InsumoModel extends ProductoModel {
    protected $tinsumo_codigo;
    protected $tcostos_codigo;
    protected $unidad_medida_codigo_ingreso;
    protected $insumo_costo;
    protected $insumo_precio_mercado;


    /**
     * Setea el codigo unico del tipo de  insumo.
     *
     * @param string $tinsumo_codigo codigo  unico del del insumo
     */
    public function set_tinsumo_codigo(string $tinsumo_codigo) : void {
        $this->tinsumo_codigo = $tinsumo_codigo;
    }

    /**
     * @return string retorna el codigo unico del tipo de insumo.
     */
    public function get_tinsumo_codigo() : string {
        return $this->tinsumo_codigo;
    }

    /**
     * Setea el codigo unico del tipo de  costos.
     *
     * @param string $tcostos_codigo codigo  unico del tipo de costo.
     */
    public function set_tcostos_codigo(string $tcostos_codigo) : void {
        $this->tcostos_codigo = $tcostos_codigo;
    }

    /**
     * @return string retorna el codigo unico del tipo de costos.
     */
    public function get_tcostos_codigo() : string {
        return $this->tcostos_codigo;
    }


    /**
     * Setea el codigo de la unidad de medida del insumo en las unidades de ingreso
     * al stock.
     *
     * @param string $unidad_medida_codigo_ingreso codigo de la unidad de medida del insumo
     */
    public function set_unidad_medida_codigo_ingreso(string $unidad_medida_codigo_ingreso) : void {
        $this->unidad_medida_codigo_ingreso = $unidad_medida_codigo_ingreso;
    }

    /**
     * Retorna el codigo de la unidad de medida del insumo en las unidades de ingreso
     * al stock.
     *
     * @return string el codigo de la unidad de medida del insumo.
     */
    public function get_unidad_medida_codigo_ingreso() : string {
        return $this->unidad_medida_codigo_ingreso;
    }

    /**
     * Setea el costo de produccion a unidades de costo.
     *
     * @param float $insumo_costo con el costo de produccion.
     */
    public function set_insumo_costo(float $insumo_costo) : void {
        $this->insumo_costo = $insumo_costo;
    }


    /**
     * Retorna el costo de produccion a unidades de costo.
     *
     * @return float con el costo de produccion
     */
    public function get_insumo_costo() : float {
        return $this->insumo_costo;
    }
}
