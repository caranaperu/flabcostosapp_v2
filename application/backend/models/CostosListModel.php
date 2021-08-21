<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de la de la cabecera de lista de costos
 *
 * @author Carlos Arana Reategui
 * @history , 22/07/2021
 */
class CostosListModel extends TSLDataModel {

    protected $costos_list_id;
    protected $costos_list_descripcion;
    protected $costos_list_fecha;
    protected $costos_list_fecha_desde;
    protected $costos_list_fecha_hasta;
    protected $costos_list_fecha_tcambio;


    public function set_costos_list_id(int $costos_list_id): void {
        $this->costos_list_id = $costos_list_id;
        $this->setId($costos_list_id);
    }

    public function get_costos_list_id(): int {
        return $this->costos_list_id;
    }

    /**
     * Setea la descripcion a asocia a esta lista.
     *
     * @param string $costos_list_descripcion la descripcion.
     */
    public function set_costos_list_descripcion(string $costos_list_descripcion): void {
        $this->costos_list_descripcion = $costos_list_descripcion;
    }


    /**
     * Retorna la descripcion asociada a la lista de costos.
     *
     * @return string la descripcion.
     */
    public function get_costos_list_descripcion(): string {
        return $this->costos_list_descripcion;
    }

    /**
     * Setea la fecha de ejecucion la lista.
     *
     * @param string $costos_list_fecha la fecha de la lista..
     * Debe represetar una fecha compatible con la persistencia en uso.
     */
    public function set_costos_list_fecha(string $costos_list_fecha): void {
        $this->costos_list_fecha = $costos_list_fecha;
    }


    /**
     * Retorna la fecha de ejecucion de la lista.
     *
     * @return string la fecha..
     */
    public function get_costos_list_fecha(): string {
        return $this->costos_list_fecha;
    }

    /**
     * Setea la fecha de inicio de rango para tomar los costos variable.
     *
     * @param string $costos_list_fecha la fecha.
     * Debe represetar una fecha compatible con la persistencia en uso.
     */
    public function set_costos_list_fecha_desde(string $costos_list_fecha_desde): void {
        $this->costos_list_fecha = $costos_list_fecha_desde;
    }


    /**
     * Retorna la fecha de inicio de rango para tomar los costos variable.
     *
     * @return string la fecha.
     */
    public function get_costos_list_fecha_desde(): string {
        return $this->costos_list_fecha_desde;
    }

    /**
     * Setea la fecha de fin de rango para tomar los costos variable.
     *
     * @param string $costos_list_fecha_hasta la fecha.
     * Debe represetar una fecha compatible con la persistencia en uso.
     */
    public function set_costos_list_fecha_hasta(string $costos_list_fecha_hasta): void {
        $this->costos_list_fecha = $costos_list_fecha_hasta;
    }


    /**
     * Retorna la fecha de fin de rango para tomar los costos variable.
     *
     * @return string la fecha..
     */
    public function get_costos_list_fecha_hasta(): string {
        return $this->costos_list_fecha_hasta;
    }

    /**
     * Setea la fecha para determinar los tipos de cambio.
     *
     * @param string $costos_list_fecha_tcambio la fecha.
     * Debe represetar una fecha compatible con la persistencia en uso.
     */
    public function set_costos_list_fecha_tcambio(string $costos_list_fecha_tcambio): void {
        $this->costos_list_fecha = $costos_list_fecha_tcambio;
    }


    /**
     * Retorna la fecha para determinar los tipos de cambio.
     *
     * @return string la fecha..
     */
    public function get_costos_list_fecha_tcambio(): string {
        return $this->costos_list_fecha_tcambio;
    }


    public function &getPKAsArray() : array  {
        $pk['costos_list_id'] = $this->getId();

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
