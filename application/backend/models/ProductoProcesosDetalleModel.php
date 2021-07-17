<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada entrada de proceso a asignar en la relacion producto-procesos.
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class ProductoProcesosDetalleModel extends TSLDataModel {

    protected $producto_procesos_detalle_id;
    protected $producto_procesos_id;
    protected $procesos_codigo;
    protected $producto_procesos_detalle_porcentaje;


    public function set_producto_procesos_detalle_id(int $producto_procesos_detalle_id) : void {
        $this->producto_procesos_detalle_id = $producto_procesos_detalle_id;
        $this->setId($producto_procesos_detalle_id);
    }

    public function get_producto_procesos_detalle_id() : int {
        return $this->producto_procesos_detalle_id;
    }


    /**
     * Setea a que relacion producto-proceso pertenece esta entrada.
     *
     * @param int $producto_procesos_id id de la relacion producto-proceso.
     */
    public function set_producto_procesos_id(int $producto_procesos_id) : void {
        $this->producto_procesos_id = $producto_procesos_id;
    }

    /**
     * @return int con el id de la relacion producto-proceso pertenece esta entrada.
     */
    public function get_producto_procesos_id() : int {
        return $this->producto_procesos_id;
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
    public function get_producto_procesos_detalle_porcentaje() : float {
        return $this->producto_procesos_detalle_porcentaje;
    }

    /**
     * Setea el porcentaje que el proceso asignado tendra sobre el costo
     *
     * @param float $producto_procesos_detalle_porcentaje el precio unitario del producto.
     */
    public function set_producto_procesos_detalle_porcentaje(float $producto_procesos_detalle_porcentaje) : void {
        $this->producto_procesos_detalle_porcentaje = $producto_procesos_detalle_porcentaje;
    }



    public function &getPKAsArray() : array {
        $pk['producto_procesos_detalle_id'] = $this->getId();

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
