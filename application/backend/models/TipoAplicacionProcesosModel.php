<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de la cabecera de la relacion tipo aplicacion-procesos
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class TipoAplicacionProcesosModel extends TSLDataModel {

    protected $taplicacion_procesos_id;
    protected $taplicacion_codigo;
    protected $taplicacion_procesos_fecha_desde;


    public function set_taplicacion_procesos_id(int $taplicacion_procesos_id): void {
        $this->taplicacion_procesos_id = $taplicacion_procesos_id;
        $this->setId($taplicacion_procesos_id);
    }

    public function get_taplicacion_procesos_id(): int {
        return $this->taplicacion_procesos_id;
    }


    /**
     * Setea al tipo de aplicacion que que se asignara los procesos.
     *
     * @param string $taplicacion_codigo el tipo de aplicacion.
     */
    public function set_taplicacion_codigo(string $taplicacion_codigo): void {
        $this->taplicacion_codigo = $taplicacion_codigo;
    }


    /**
     * Retorna el tipo de aplicacion que que se asignara los procesos.
     *
     * @return string con el codigo de tipo de aplicacion
     */
    public function get_taplicacion_codigo(): string {
        return $this->taplicacion_codigo;
    }


    /**
     * Setea la fecha desde que tiene validez esta relacion
     *
     * @param string $taplicacion_procesos_fecha_desde la fecha
     */
    public function set_taplicacion_procesos_fecha_desde(string $taplicacion_procesos_fecha_desde): void {
        $this->taplicacion_procesos_fecha_desde = $taplicacion_procesos_fecha_desde;
    }


    /**
     * Retorna la fecha desde que tiene validez esta relacion.
     *
     * @return string la fecha de la cotizacion..
     */
    public function get_taplicacion_procesos_fecha_desde(): string {
        return $this->taplicacion_procesos_fecha_desde;
    }


    public function &getPKAsArray() : array  {
        $pk['taplicacion_procesos_id'] = $this->getId();

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
