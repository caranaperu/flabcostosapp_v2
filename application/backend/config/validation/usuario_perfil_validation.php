<?php

$config['v_usuario_perfil'] = array(
// Para la lectura de un contribuyente basado eb su id
    'getUsuarioPerfil' => array(
        array(
            'field' => 'usuario_perfil_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        )
    ),
    'updUsuarioPerfil' => array(
        array(
            'field' => 'usuario_perfil_id',
            'label' => 'lang:usuario_perfil_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'perfil_id',
            'label' => 'lang:perfil_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delUsuarioPerfil' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addUsuarioPerfil' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'perfil_id',
            'label' => 'lang:perfil_id',
            'rules' => 'required|integer'
        )
    )
);
