<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los perfiles que se asocian a un usuario
 * para cada sistema.
 *
 * @author  $Author: aranape $
 * @history , 09-02-2017 , primera version adaptada a php 7.1 .
 * @TODO : Las funciones que vienen de la clase padre faltan ser adaptadas.
 */
class UsuariosPerfilModel extends TSLDataModel {

    protected $usuario_perfil_id;
    protected $usuarios_id;
    protected $perfil_id;

    public function set_usuario_perfil_id(int $usuario_perfil_id) : void {
        $this->usuario_perfil_id = $usuario_perfil_id;
        $this->setId($usuario_perfil_id);
    }

    public function get_usuario_perfil_id() : int {
        return $this->usuario_perfil_id;
    }

    /**
     * Retorna el unique id del usuario al que se asociara el perfil
     * identificado por $perfil_id.
     *
     * @return int el id del usuario al que se le asocia el perfil
     */
    public function get_usuarios_id() : int {
        return $this->usuarios_id;
    }

    /**
     * Setea el unique id del usuario al que se asociara el perfil
     * identificado por $perfil_id.
     *
     * @param int $usuarios_id el id unico del usuario al que se asocian los
     * perfiles.
     */
    public function set_usuarios_id(int $usuarios_id) : void {
        $this->usuarios_id = $usuarios_id;
    }

    /**
     *
     * @return int el id unico del perfil a asociar al usuario
     */
    public function get_perfil_id() : int {
        return $this->perfil_id;
    }

    /**
     * Setea el unique id del perfil a asociar al usuario.
     *
     * @param int $perfil_id con el unique id del perfil
     */
    public function set_perfil_id(int $perfil_id) : void {
        $this->perfil_id = $perfil_id;
    }



    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return bool true
     */
    public function isPKSequenceOrIdentity() : bool {
        return true;
    }

    public function &getPKAsArray() : array {
        $pk['usuario_perfil_id'] = $this->getId();
        return $pk;
    }

}
