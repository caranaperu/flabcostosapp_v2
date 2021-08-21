<?php

$config['v_ffarmaceutica'] = array(
    'getFFarmaceutica' => array(
        array(
            'field' => 'ffarmaceutica_codigo',
            'label' => 'lang:ffarmaceutica_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        )
    ),
    'updFFarmaceutica' => array(
        array(
            'field' => 'ffarmaceutica_codigo',
            'label' => 'lang:ffarmaceutica_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'ffarmaceutica_descripcion',
            'label' => 'lang:ffarmaceutica_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'ffarmaceutica_protected',
            'label' => 'lang:ffarmaceutica_protected',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delFFarmaceutica' => array(
        array(
            'field' => 'ffarmaceutica_codigo',
            'label' => 'lang:ffarmaceutica_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addFFarmaceutica' => array(
        array(
            'field' => 'ffarmaceutica_codigo',
            'label' => 'lang:ffarmaceutica_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'ffarmaceutica_descripcion',
            'label' => 'lang:ffarmaceutica_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'ffarmaceutica_protected',
            'label' => 'lang:ffarmaceutica_protected',
            'rules' => 'required|is_boolean'
        )
    )
);
