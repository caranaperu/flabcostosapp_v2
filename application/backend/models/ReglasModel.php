<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las reglas de costeo entre 2 empresas que participan en el sistema.
 * Digasmos entre la fabrica y el importador.
 *
 * @author  $Author: aranape $
 * @history , 13-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class ReglasModel extends TSLDataModel
{

    protected $regla_id;
    protected $regla_empresa_origen_id;
    protected $regla_empresa_destino_id;
    protected $regla_by_costo;
    protected $regla_porcentaje;

    /**
     * Setea el id unico de la regla.
     *
     * @param int $regla_id id unico de la regla
     */
    public function set_regla_id(int $regla_id) : void {
        $this->regla_id = $regla_id;
        $this->setId($regla_id);
    }


    /**
     * @return int con el id unico de la regla.
     */
    public function get_regla_id() : int {
        return $this->regla_id;
    }

    /**
     * Setea el id de la empresa origen del factor de costo de la
     * empresa destino.
     *
     * @param int $regla_empresa_origen_id id de la empresa origen.
     */
    public function set_regla_empresa_origen_id(int $regla_empresa_origen_id) : void {
        $this->regla_empresa_origen_id = $regla_empresa_origen_id;
    }

    /**
     * Retorna el id de la empresa origen del factor de costo de la
     * empresa destino.
     *
     * @return int id de la empresa origen.
     */
    public function get_regla_empresa_origen_id() : int {
        return $this->regla_empresa_origen_id;
    }

    /**
     * Setea el id de la empresa destino del costo.
     *
     * @param int $regla_empresa_destino_id el id de la empresa destino
     */
    public function set_regla_empresa_destino_id(int $regla_empresa_destino_id) : void {
        $this->regla_empresa_destino_id = $regla_empresa_destino_id;
    }

    /**
     * Retorna el id de la empresa destino del costo.
     *
     * @return int con el id de la empresa destino
     */
    public function get_regla_empresa_destino_id() : int {
        return $this->regla_empresa_destino_id;
    }

    /**
     * Setea si el costo de la empresa destino sera calculado basandose
     * en el costo del insumo de la empresa de origen.
     *
     * Si es false el calculo sera basado en el precio de mercado del insumo con respecto
     * al valor otorgado por la empresa origen.
     *
     * @param boolean $regla_by_costo true basado en costo , false en precio mercado.
     */
    public function set_regla_by_costo(bool $regla_by_costo) : void {
        $this->regla_by_costo = self::getAsBool($regla_by_costo);
    }

    /**
     * Retorna si el costo de la empresa destino sera calculado basandose
     * en el costo del insumo de la empresa de origen.
     *
     * Si es false el calculo sera basado en el precio de mercado del insumo con respecto
     * al valor otorgado por la empresa origen.
     *
     * @return boolean true si el costo sera calculado basado en el costo de origen.
     */
    public function get_regla_by_costo() : bool {
        if (!isset($this->regla_by_costo)) {
            return false;
        }
        return $this->regla_by_costo;
    }

    /**
     * Retorna el porcentaje sobre costo o precio mercado
     *
     * @return double el porcentaje sobre costo o precio mercado
     */
    public function get_regla_porcentaje() : float {
        return $this->regla_porcentaje;
    }

    /**
     * Setea el porcentaje positivo o negativo sobre el costo o precio de mercado a aplicar.
     * El costo o precio de mercado se refieren al indicado por la empresa de origen
     * para el insumo a costear en la empresa destino.
     *
     * @param float $regla_porcentaje el porcentaje sobre costo o precio mercado
     */
    public function set_regla_porcentaje(float $regla_porcentaje) : void {
        $this->regla_porcentaje = $regla_porcentaje;
    }

    public function &getPKAsArray() : array
    {
        $pk['regla_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() : bool
    {
        return true;
    }

}
