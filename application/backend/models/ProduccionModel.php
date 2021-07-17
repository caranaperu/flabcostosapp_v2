<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada entrada de produccion para un determinado subtipo
 * de modo de aplicacion
 *
 * @author $Author: aranape $
 * @history , 02-07-2021
 */
class ProduccionModel extends TSLDataModel {

    protected $produccion_id;
    protected $produccion_fecha;
    protected $taplicacion_entries_id;
    protected $produccion_qty;
    protected $unidad_medida_codigo;


    public function set_produccion_id(int $produccion_id) : void {
        $this->produccion_id = $produccion_id;
        $this->setId($produccion_id);
    }

    public function get_produccion_id() : int {
        return $this->produccion_id;
    }


    /**
     * Setea la fecha de la produccion
     *
     * @param string $produccion_fecha la fecha de la produccion
     */
    public function set_produccion_fecha(string $produccion_fecha): void {
        $this->produccion_fecha = $produccion_fecha;
    }


    /**
     * Retorna la fecha de produccion
     *
     * @return string la fecha de produccion..
     */
    public function get_produccion_fecha(): string {
        return $this->produccion_fecha;
    }

    /**
     * Retorna el id del taplicacion_entries al cual pertenece la entrada de importacion a agregar
     *
     * @return int con el el id del taplicacion_entries a procesar.
     */
    public function get_taplicacion_entries_id() : int {
        return $this->taplicacion_entries_id;
    }


    /**
     * Setea el id del modo de aplicacion producido
     *
     * @param integer $taplicacion_entries_id id del modo de aplicacion producido.
     */
    public function set_taplicacion_entries_id(int $taplicacion_entries_id) : void {
        $this->taplicacion_entries_id = $taplicacion_entries_id;
    }


    /**
     * Retorna la cantidad producida..
     *
     * @return float la cabtidad.
     */
    public function get_produccion_qty() : float {
        return $this->produccion_qty;
    }

    /**
     * Retorna el codigo de la unidad de medida de la cantidad producida.
     *
     * @return string codigo de la  unidad de medida.
     */
    public function get_unidad_medida_codigo() : string {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea la unidad de medida de la cantidad producida.
     *
     * @param string $unidad_medida_codigo codigo de la unidad de medida
     */
    public function set_unidad_medida_codigo(string $unidad_medida_codigo) : void {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
    }
    /**
     * Setea la cantidad producida.
     *
     * @param float $produccion_qty la cantidad.
     */
    public function set_produccion_qty(float $produccion_qty) : void  {
        $this->produccion_qty = $produccion_qty;
    }


    public function &getPKAsArray() : array {
        $pk['produccion_id'] = $this->getId();

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
