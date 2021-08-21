<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada entrada de importacion de un insumo
 *
 * @author $Author: aranape $
 * @history , 02-04-2019
 */
class InsumoEntriesModel extends TSLDataModel {

    protected $insumo_entries_id;
    protected $insumo_entries_fecha;
    protected $insumo_id;
    protected $insumo_entries_qty;
    protected $unidad_medida_codigo_qty;
    protected $insumo_entries_value;


    public function set_insumo_entries_id(int $insumo_entries_id) : void {
        $this->insumo_entries_id = $insumo_entries_id;
        $this->setId($insumo_entries_id);
    }

    public function get_insumo_entries_id() : int {
        return $this->insumo_entries_id;
    }


    /**
     * Setea la fecha de la importacion
     *
     * @param string $insumo_entries_fecha la fecha de la importacion..
     * Debe represetar una fecha compatible con la persistencia en uso.
     */
    public function set_insumo_entries_fecha(string $insumo_entries_fecha): void {
        $this->insumo_entries_fecha = $insumo_entries_fecha;
    }


    /**
     * Retorna la fecha de la importacion.
     *
     * @return string la fecha de la importacion..
     */
    public function get_insumo_entries_fecha(): string {
        return $this->insumo_entries_fecha;
    }

    /**
     * Setea el insumo al cual pertenece la entrada de importacion a agregar
     *
     * @param integer $insumo_id id del insumo a procesar.
     */
    public function set_insumo_id(int $insumo_id) : void {
        $this->insumo_id = $insumo_id;
    }


    /**
     * Retorna el id del insumo al cual pertenece la entrada de importacion a agregar
     *
     * @return int con el el id del insumo a procesar.
     */
    public function get_insumo_id() : int {
        return $this->insumo_id;
    }


    /**
     * Retorna la cantidad a importar..
     *
     * @return float con la cantidad a importar.
     */
    public function get_insumo_entries_qty() : float {
        return $this->insumo_entries_qty;
    }

    /**
     * Setea la cantidad a importar..
     *
     * @param float $insumo_entries_qty la cantidad a importar.
     */
    public function set_insumo_entries_qty(float $insumo_entries_qty) : void  {
        $this->insumo_entries_qty = $insumo_entries_qty;
    }

    /**
     * Retorna el codigo de la unidad de medida del producto a importar.
     *
     * @return string codigo de la  unidad de medida.
     */
    public function get_unidad_medida_codigo_qty() : string {
        return $this->unidad_medida_codigo_qty;
    }

    /**
     * Setea la unidad de medida del producto a importar.
     *
     * @param string $unidad_medida_codigo_qty codigo de la unidad de medida
     */
    public function set_unidad_medida_codigo_qty(string $unidad_medida_codigo_qty) : void {
        $this->unidad_medida_codigo_qty = $unidad_medida_codigo_qty;
    }

    /**
     * Retorna el valor porcentual  de la concentracion de la importacion del insumo.
     *
     * @return float con el valor global de la importacion.
     */
    public function get_insumo_entries_value() : float {
        return $this->insumo_entries_value;
    }

    /**
     * Setea el valor porcentual de la concentracion  del insumo a importar.
     *
     * @param float $insumo_entries_value el valor global del insumo a importar.
     */
    public function set_insumo_entries_value(float $insumo_entries_value) : void {
        $this->insumo_entries_value = $insumo_entries_value;
    }



    public function &getPKAsArray() : array {
        $pk['insumo_entries_id'] = $this->getId();

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
