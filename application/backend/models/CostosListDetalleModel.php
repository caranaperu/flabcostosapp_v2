<?php


if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Modelo fisico de cada item de la lista de costos
 *
 * @author Carlos Arana Reategui
 * @history , 22-07-2021
 */
class CostosListDetalleModel extends TSLDataModel {

    protected $costos_list_detalle_id;
    protected $costos_list_id;
    protected $insumo_id;
    protected $insumo_descripcion;
    protected $moneda_descripcion;
    protected $taplicacion_entries_descripcion;
    protected $unidad_medida_siglas;
    protected $costos_list_detalle_qty_presentacion;
    protected $costos_list_detalle_costo_base;
    protected $costos_list_detalle_costo_agregado;
    protected $costos_list_detalle_costo_total;


    public function set_costos_list_detalle_id(int $costos_list_detalle_id) : void {
        $this->costos_list_detalle_id = $costos_list_detalle_id;
        $this->setId($costos_list_detalle_id);
    }

    public function get_costos_list_detalle_id() : int {
        return $this->costos_list_detalle_id;
    }


    /**
     * Setea el id a que lista corresponde este item
     *
     * @param int $costos_list_id id de la lista que corresponde.
     */
    public function set_costos_list_id(int $costos_list_id) : void {
        $this->costos_list_id = $costos_list_id;
    }

    /**
     * @return int con el id de la lista a que corresponde este item.
     */
    public function get_costos_list_id() : int {
        return $this->costos_list_id;
    }

    /**
     * Setea el insumo (producto) costeado
     *
     * @param integer $insumo_id id del insumo a cotizar.
     */
    public function set_insumo_id(int $insumo_id) : void {
        $this->insumo_id = $insumo_id;
    }


    /**
     * Retorna el id del insumo costeado.
     *
     * @return int con el el id del insumo a cotizar.
     */
    public function get_insumo_id() : int {
        return $this->insumo_id;
    }

    /**
     * Retorna la descripcion del producto costeado
     *
     * @return string la descripcion
     */
    public function get_insumo_descripcion() : string {
        return $this->insumo_descripcion;
    }

    /**
     * Setea la descripcion del producto costeado
     *
     * @param string $insumo_descripcion la descripcion
     */
    public function set_insumo_descripcion(string $insumo_descripcion) : void {
        $this->insumo_descripcion = $insumo_descripcion;
    }

    /**
     * Retorna el codigo de la moneda del producto costeado.
     *
     * @return string con el codigo de moneda.
     */
    public function get_moneda_descripcion() : string {
        return $this->moneda_descripcion;
    }

    /**
     * Setea el codigo de la moneda del producto costeado , esto
     * dependera de la moneda de trabajo del mismo.
     *
     * @param string $moneda_descripcion codigo de la moneda
     */
    public function set_moneda_descripcion(string $moneda_descripcion) : void {
        $this->moneda_descripcion = $moneda_descripcion;
    }

    /**
     * Retorna la descripcion del modo de aplicacion del producto costeado
     *
     * @return string con la descripcion.
     */
    public function get_taplicacion_entries_descripcion() : string {
        return $this->taplicacion_entries_descripcion;
    }

    /**
     * Setea la descripcion del modo de aplicacion del producto costeado.
     *
     * @param string $taplicacion_entries_descripcion la descripcion
     */
    public function set_taplicacion_entries_descripcion(string $taplicacion_entries_descripcion) : void {
        $this->taplicacion_entries_descripcion = $taplicacion_entries_descripcion;
    }

    /**
     * Retorna la descripcion de la unidad de medida asociada a la
     * presentacion del producto.
     *
     * @return string con la descripcion.
     */
    public function get_unidad_medida_siglas() : string {
        return $this->unidad_medida_siglas;
    }

    /**
     * Setea la descripcion de la unidad de medida asociada a la
     * presentacion del producto.
     *
     * @param string $unidad_medida_siglas la descripcion
     */
    public function set_unidad_medida_siglas(string $unidad_medida_siglas) : void {
        $this->unidad_medida_siglas = $unidad_medida_siglas;
    }

    /**
     * Retorna el costo del insumo(Producto)..
     *
     * @return float el costo.
     */
    public function get_costos_list_detalle_costo_base() : float {
        return $this->costos_list_detalle_costo_base;
    }

    /**
     * Setea el costo base osea derivado unicamente de la receta del producto
     *
     * @param float $costos_list_detalle_costo_base el costo base
     */
    public function set_costos_list_detalle_costo_base(float $costos_list_detalle_costo_base) : void  {
        $this->costos_list_detalle_costo_base = $costos_list_detalle_costo_base;
    }


    /**
     * Retorna la cantidad de presentacion del producto, ej 120 ML
     *
     * @return float la cantidad de presentacion
     */
    public function get_costos_list_detalle_qty_presentacion() : float {
        return $this->costos_list_detalle_qty_presentacion;
    }

    /**
     * Setea la cantidad de presentacion del producto, ej 120 ML
     *
     * @param float $costos_list_detalle_qty_presentacion la vcantidad de presentacion
     */
    public function set_costos_list_detalle_qty_presentacion(float $costos_list_detalle_qty_presentacion) : void  {
        $this->costos_list_detalle_qty_presentacion = $costos_list_detalle_qty_presentacion;
    }

    /**
     * Retorna los costos del producto asociados a los costos globales agregados
     * a distribuir.
     *
     * @return float el costo agregado.
     */
    public function get_costos_list_detalle_costo_agregado() : float {
        return $this->costos_list_detalle_costo_agregado;
    }

    /**
     * Setea los costos del producto asociados a los costos globales agregados
     * a distribuir.
     *
     * @param float $costos_list_detalle_costo_agregado el costo agregado
     */
    public function set_costos_list_detalle_costo_agregado(float $costos_list_detalle_costo_agregado) : void  {
        $this->costos_list_detalle_costo_agregado = $costos_list_detalle_costo_agregado;
    }


    /**
     * Retorna el costo base osea derivado unicamente de la receta del producto
     *
     * @return float el costo base.
     */
    public function get_costos_list_detalle_costo() : float {
        return $this->costos_list_detalle_costo_total;
    }

    /**
     * Setea el costo del insumo (Producto)
     *
     * @param float $costos_list_detalle_costo la cantidad a cotizar.
     */
    public function set_costos_list_detalle_costo(float $costos_list_detalle_costo) : void  {
        $this->costos_list_detalle_costo_total = $costos_list_detalle_costo;
    }



    public function &getPKAsArray() : array {
        $pk['costos_list_detalle_id'] = $this->getId();

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
