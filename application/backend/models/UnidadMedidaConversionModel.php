<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos de las conversiones
 * entre 2 unidades de medida.
 *
 * @author $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class UnidadMedidaConversionModel extends TSLDataModel
{

    protected $unidad_medida_conversion_id;
    protected $unidad_medida_origen;
    protected $unidad_medida_destino;
    protected $unidad_medida_conversion_factor;


    public function set_unidad_medida_conversion_id(int $unidad_medida_conversion_id) : void
    {
        $this->unidad_medida_conversion_id = $unidad_medida_conversion_id;
        $this->setId($unidad_medida_conversion_id);
    }

    public function get_unidad_medida_conversion_id() : int
    {
        return $this->unidad_medida_conversion_id;
    }

    /**
     * Setea el codigo de la unidad de medida origen de conversion.
     *
     * @param string $unidad_medida_origen codigo de la unidad de medida origen de conversion.
     */
    public function set_unidad_medida_origen(string $unidad_medida_origen) : void
    {
        $this->unidad_medida_origen = $unidad_medida_origen;
    }


    /**
     * Retorna el codigo de la unidad de medida origen de conversion.
     *
     * @return string codigo de la unidad de medida origen de conversion.
     */
    public function get_unidad_medida_origen() : string
    {
        return $this->unidad_medida_origen;
    }

    /**
     * Setea el codigo de la unidad de medida destino de conversion.
     *
     * @param string $unidad_medida_destino codigo de la unidad de medida destino de conversion.
     */
    public function set_unidad_medida_destino(string $unidad_medida_destino) : void
    {
        $this->unidad_medida_destino = $unidad_medida_destino;
    }


    /**
     * Retorna el codigo de la unidad de medida destino de conversion.
     *
     * @return string codigo de la unidad de medida destino de conversion.
     */
    public function get_unidad_medida_destino() : string
    {
        return $this->unidad_medida_destino;
    }

    /**
     * Setea el factor de conversion entre la unidad de medida y destino.
     *
     * @param float $unidad_medida_conversion_factor factor de conversion entre la unidad de medida y destino.
     */
    public function set_unidad_medida_conversion_factor(float $unidad_medida_conversion_factor) : void
    {
        $this->unidad_medida_conversion_factor = $unidad_medida_conversion_factor;
    }


    /**
     * Retorna el factor de conversion entre la unidad de medida y destino.
     *
     * @return double con el factor de conversion.
     */
    public function get_unidad_medida_conversion_factor() : float
    {
        return $this->unidad_medida_conversion_factor;
    }


    public function &getPKAsArray() : array
    {
        $pk['unidad_medida_conversion_id'] = $this->getId();
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
