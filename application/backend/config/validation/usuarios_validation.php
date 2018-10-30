<?php

$config['v_usuarios'] = array(
    'getUsuarios' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer'
        )
    ),
    'updUsuarios' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'usuarios_code',
            'label' => 'lang:usuarios_code',
            'rules' => 'required|max_length[15]'
        ),
        array(
            'field' => 'usuarios_password',
            'label' => 'lang:usuarios_password',
            'rules' => 'required|max_length[20]'
        ),
        array(
            'field' => 'usuarios_nombre_completo',
            'label' => 'lang:usuarios_nombre_completo',
            'rules' => 'required|max_length[250]'
        ),
        array(
            'field' => 'usuarios_admin',
            'label' => 'lang:usuarios_admin',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delUsuarios' => array(
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
    'addUsuarios' => array(
        array(
            'field' => 'usuarios_code',
            'label' => 'lang:usuarios_code',
            'rules' => 'required|max_length[15]'
        ),
        array(
            'field' => 'usuarios_password',
            'label' => 'lang:usuarios_password',
            'rules' => 'required|max_length[20]'
        ),
        array(
            'field' => 'usuarios_nombre_completo',
            'label' => 'lang:usuarios_nombre_completo',
            'rules' => 'required|max_length[250]'
        ),
        array(
            'field' => 'usuarios_admin',
            'label' => 'lang:usuarios_admin',
            'rules' => 'required|is_boolean'
        )
    )
);
