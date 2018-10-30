<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir cada entrada del menu del sistema
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: SystemMenuModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history ''
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class SystemMenuModel extends TSLDataModel {

    protected $sys_systemcode;
    protected $menu_id;
    protected $menu_codigo;
    protected $menu_descripcion;
    protected $menu_parent_id;
    protected $menu_accesstype;
    protected $menu_orden;

    /**
     * Para soportar una sola tabla para muultiples sistemas , cada entrada
     * de menu debe infdicar a que sistema pertene.
     *
     * @param string $sys_systemcode con el identificador unico del sistema
     */
    public function set_sys_systemcode(string $sys_systemcode) : void {
        $this->sys_systemcode = $sys_systemcode;
    }

    /**
     *
     * @return string con el identificador de sistema
     */
    public function get_menu_systemcode() : string {
        return $this->sys_systemcode;
    }

    public function set_menu_id(int $menu_id) : void {
        $this->menu_id = $menu_id;
    }

    public function get_menu_id() : int {
        return $this->menu_id;
    }

    /**
     * Setea el identificador unico del menu.
     *
     * @param string $menu_codigo identificador unico de la opcion de menu
     */
    public function set_menu_codigo(string $menu_codigo) : void {
        $this->menu_codigo = $menu_codigo;
    }

    /**
     * @return string retorna el identificador unico del menu.
     */
    public function get_menu_codigo() : string {
        return $this->menu_codigo;
    }

    /**
     * Setea la descripcion o texto que se presentara en la pantalla.
     *
     * @param string $menu_descripcion texto a presentarse en pantalla
     */
    public function set_menu_descripcion(string $menu_descripcion) : void {
        $this->menu_descripcion = $menu_descripcion;
    }

    /**
     *
     * @return string con el texto a presentarse en pantalla
     */
    public function get_menu_descripcion() : string {
        return $this->menu_descripcion;
    }

    /**
     *
     * @param int $menu_parent_id el id unico del menu parent 0 si no tiene
     */
    public function set_menu_parent_id(int $menu_parent_id) : void {
        $this->menu_parent_id = $menu_parent_id;
    }

    /**
     *
     * @return int
     */
    public function get_menu_parent_id() : int {
        return $this->menu_parent_id;
    }

    /**
     * Lista de accesos permitiods a este menu :
     * 'A' - Accesable
     * 'C' - Agregar o Crear registros
     * 'R' - Leer registros
     * 'U' - Actualizar registros
     * 'D' - Eliminar registros
     * 'P' - Imprimir
     *
     * Si la 'A' no aparece los demas son irrelevantes.
     * @param string $menu_accesstype
     */
    public function set_menu_accesstype(string $menu_accesstype) : void {
        // Si es un valor valido se asume de lo contrario se deja en null
        if (($menu_accesstype == 'A' || $menu_accesstype == 'C' || $menu_accesstype == 'R' ||
                $menu_accesstype == 'U' || $menu_accesstype == 'D' || $menu_accesstype == 'P')) {
            $this->menu_accesstype = $menu_accesstype;
        } else {
            $this->menu_accesstype = NULL;
        }
    }

    /**
     * Valores posibles de retornar :
     * 'A' - Accesable
     * 'C' - Agregar o Crear registros
     * 'R' - Leer registros
     * 'U' - Actualizar registros
     * 'D' - Eliminar registros
     * 'P' - Imprimir
     *
     * @return String con los accesos permitidos a este menu.
     */
    public function get_menu_accesstype() : string {
        return $this->menu_accesstype;
    }

    public function set_menu_orden(int $menu_orden) : void {
        $this->menu_orden = $menu_orden;
    }

    public function get_menu_orden() : int {
        return $this->menu_orden;
    }

    public function &getPKAsArray() : array {
        $pk['per_id'] = $this->getId();
        return $pk;
    }

}
