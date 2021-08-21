<?php

$config['v_taplicacion'] = array(
    'getTAplicacion' => array(
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        )
    ),
    'updTAplicacion' => array(
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'taplicacion_descripcion',
            'label' => 'lang:taplicacion_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTAplicacion' => array(
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTAplicacion' => array(
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'taplicacion_descripcion',
            'label' => 'lang:taplicacion_descripcion',
            'rules' => 'required|max_length[60]'
        )
    )
);
