<?php

$config['v_login'] = array(
    'checkLogin' => array(
        array(
            'field' => 'usuarios_code',
            'label' => 'lang:usuarios_code',
            'rules' => 'required|max_length[15]'
        ),
        array(
            'field' => 'usuarios_password',
            'label' => 'lang:usuarios_password',
            'rules' => 'required|max_length[20]'
        )
    ),
    'doLogout' => array(
        array(
            'field' => 'usuarios_code',
            'label' => 'lang:usuarios_code',
            'rules' => 'required|max_length[15]'
        )
    )
);
