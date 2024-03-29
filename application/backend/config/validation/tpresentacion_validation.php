<?php

$config['v_tpresentacion'] = array(
    'getTPresentacion' => array(
        array(
            'field' => 'tpresentacion_codigo',
            'label' => 'lang:tpresentacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        )
    ),
    'updTPresentacion' => array(
        array(
            'field' => 'tpresentacion_codigo',
            'label' => 'lang:tpresentacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'tpresentacion_descripcion',
            'label' => 'lang:tpresentacion_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'unidad_medida_codigo_costo',
            'label' => 'lang:unidad_medida_codigo_costo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'tpresentacion_cantidad_costo',
            'label' => 'lang:tpresentacion_cantidad_costo',
            'rules' => 'required|decimal|greater_than[0.00] '
        ),
        array(
            'field' => 'tpresentacion_protected',
            'label' => 'lang:tpresentacion_protected',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTPresentacion' => array(
        array(
            'field' => 'tpresentacion_codigo',
            'label' => 'lang:tpresentacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTPresentacion' => array(
        array(
            'field' => 'tpresentacion_codigo',
            'label' => 'lang:tpresentacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'tpresentacion_descripcion',
            'label' => 'lang:tpresentacion_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'unidad_medida_codigo_costo',
            'label' => 'lang:unidad_medida_codigo_costo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'tpresentacion_cantidad_costo',
            'label' => 'lang:tpresentacion_cantidad_costo',
            'rules' => 'required|decimal|greater_than[0.00] '
        ),
        array(
            'field' => 'tpresentacion_protected',
            'label' => 'lang:tpresentacion_protected',
            'rules' => 'required|is_boolean'
        )
    )
);
