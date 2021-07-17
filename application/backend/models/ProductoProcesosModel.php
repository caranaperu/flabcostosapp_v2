<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de la cabecera de la relacion producto-procesos
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 */
class ProductoProcesosModel extends TSLDataModel {

    protected $producto_procesos_id;
    protected $insumo_id;
    protected $producto_procesos_fecha_desde;


    public function set_producto_procesos_id(int $producto_procesos_id): void {
        $this->producto_procesos_id = $producto_procesos_id;
        $this->setId($producto_procesos_id);
    }

    public function get_producto_procesos_id(): int {
        return $this->producto_procesos_id;
    }


    /**
     * Setea al insumo que representa al producto a asignarse los procesos
     *
     * @param integer $insumo_id el id de del producto.
     */
    public function set_insumo_id(int $insumo_id): void {
        $this->insumo_id = $insumo_id;
    }


    /**
     * Retorna al insumo que representa al producto a asignarse los procesos
     *
     * @return integer con el id al insumo que representa al producto a asignarse los procesos
     */
    public function get_insumo_id(): int {
        return $this->insumo_id;
    }


    /**
     * Setea la fecha desde que tiene validez esta relacion
     *
     * @param string $producto_procesos_fecha_desde la fecha
     */
    public function set_producto_procesos_fecha_desde(string $producto_procesos_fecha_desde): void {
        $this->producto_procesos_fecha_desde = $producto_procesos_fecha_desde;
    }


    /**
     * Retorna la fecha desde que tiene validez esta relacion.
     *
     * @return string la fecha de la cotizacion..
     */
    public function get_producto_procesos_fecha_desde(): string {
        return $this->producto_procesos_fecha_desde;
    }


    public function &getPKAsArray() : array  {
        $pk['producto_procesos_id'] = $this->getId();

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
