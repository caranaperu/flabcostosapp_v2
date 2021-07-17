<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada entrada de proceso a asignar en la relacion tipo aplicacion-procesos.
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class TipoAplicacionProcesosDetalleModel extends TSLDataModel {

    protected $taplicacion_procesos_detalle_id;
    protected $taplicacion_procesos_id;
    protected $procesos_codigo;
    protected $taplicacion_procesos_detalle_porcentaje;


    public function set_taplicacion_procesos_detalle_id(int $taplicacion_procesos_detalle_id) : void {
        $this->taplicacion_procesos_detalle_id = $taplicacion_procesos_detalle_id;
        $this->setId($taplicacion_procesos_detalle_id);
    }

    public function get_taplicacion_procesos_detalle_id() : int {
        return $this->taplicacion_procesos_detalle_id;
    }


    /**
     * Setea a que relacion tipo aplicacion-proceso pertenece esta entrada.
     *
     * @param int $taplicacion_procesos_id id de la relacion producto-proceso.
     */
    public function set_taplicacion_procesos_id(int $taplicacion_procesos_id) : void {
        $this->taplicacion_procesos_id = $taplicacion_procesos_id;
    }

    /**
     * @return int con el id de la relacion tipo aplicacion-proceso pertenece esta entrada.
     */
    public function get_taplicacion_procesos_id() : int {
        return $this->taplicacion_procesos_id;
    }


    /**
     * Retorna el codigo del proceso a asignar a esta entrada , debe ser unico para
     * cada relacion producto-proceso.
     *
     * @return string codigo del proceso a asignar.
     */
    public function get_procesos_codigo() : string {
        return $this->procesos_codigo;
    }

    /**
     * Setea el codigo del proceso a asignar a esta entrada , debe ser unico para
     * cada relacion producto-proceso.
     *
     * @param string $procesos_codigo codigo de la unidad de medida
     */
    public function set_procesos_codigo(string $procesos_codigo) : void {
        $this->procesos_codigo = $procesos_codigo;
    }

    /**
     * Retorna el porcentaje que el proceso asignado tendra sobre el costo.
     *
     * @return float con el porcentaje.
     */
    public function get_taplicacion_procesos_detalle_porcentaje() : float {
        return $this->taplicacion_procesos_detalle_porcentaje;
    }

    /**
     * Setea el porcentaje que el proceso asignado tendra sobre el costo
     *
     * @param float $taplicacion_procesos_detalle_porcentaje el precio unitario del producto.
     */
    public function set_taplicacion_procesos_detalle_porcentaje(float $taplicacion_procesos_detalle_porcentaje) : void {
        $this->taplicacion_procesos_detalle_porcentaje = $taplicacion_procesos_detalle_porcentaje;
    }



    public function &getPKAsArray() : array {
        $pk['taplicacion_procesos_detalle_id'] = $this->getId();

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
