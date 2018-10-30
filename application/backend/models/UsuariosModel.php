<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los usuarios del sistema
 *
 * @author  $Author: aranape@gmail.com $
 * @history , 09-02-2017 , primera version adaptada a php 7.1.
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class UsuariosModel extends TSLDataModel {

    protected $usuarios_id;
    protected $usuarios_code;
    protected $usuarios_password;
    protected $usuarios_nombre_completo;
    protected $usuarios_admin;
    protected $empresa_id;


    public function set_usuarios_id(int $usuarios_id) {
        $this->usuarios_id = $usuarios_id;
        $this->setId($usuarios_id);
    }

    public function get_usuarios_id() : int {
        return $this->usuarios_id;
    }

    /**
     * Setea el codigo unico del usuario
     *
     * @param string $usuarios_code
     */
    public function set_usuarios_code(string $usuarios_code) : void {
        $this->usuarios_code = $usuarios_code;
    }

    /**
     *
     * @return string con el codigo unico del usuario
     */
    public function get_usuarios_code() : string {
        return $this->usuarios_code;
    }

    /**
     * Setea el password del usuario, el formato debe ser texto este puede o no
     * estar encriptado y dependera de la implementacion.
     *
     * @param string $usuarios_password
     */
    public function set_usuarios_password(string $usuarios_password) : void {
        $this->usuarios_password = $usuarios_password;
    }

    /**
     * Retorna el password del usuario , este puede o no estar encriptado
     * dependiendo de la instalacion.
     *
     * @return string
     */
    public function get_usuarios_password() : string {
        return $this->usuarios_password;
    }

    /**
     * Setea el nombre completo del usuario.
     *
     * @param string $usuarios_nombre_completo
     */
    public function set_usuarios_nombre_completo(string $usuarios_nombre_completo) : void {
        $this->usuarios_nombre_completo = $usuarios_nombre_completo;
    }

    /**
     *
     * @return string con el nombre completo del usuario
     */
    public function get_usuarios_nombre_completo() : string {
        return $this->usuarios_nombre_completo;
    }

    /**
     * Setea si un usuario es administrador
     *
     * @param boolean $usuarios_admin true si es administrados.
     */
    public function set_usuarios_admin(bool $usuarios_admin) : void {
        $this->usuarios_admin = self::getAsBool($usuarios_admin);
    }

    /**
     * Retorna true si es admin y false si no lo es
     *
     * @return boolean
     */
    public function get_usuarios_admin() : bool {
        return $this->usuarios_admin;
    }

    /**
     * Retorna el id de la empresa al que esta asociado este
     * usuario.
     *
     * @return integer con el id al que pertenece el usuario.
     */
    public function get_empresa_id() : int {
        return $this->empresa_id;
    }

    /**
     * Setea el id de la empresa al que esta asociado este usuario.
     *
     * @param integer $empresa_id con el id de la empresa.
     */
    public function set_empresa_id(int $empresa_id) {
        $this->empresa_id = $empresa_id;
    }

    public function &getPKAsArray() : array {
        $pk['usuarios_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return bool true
     */
    public function isPKSequenceOrIdentity() : bool {
        return true;
    }

}
