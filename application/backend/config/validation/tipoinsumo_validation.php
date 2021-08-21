<?php

$config['v_tinsumo'] = array(
    'getTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        )
    ),
    'updTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'tinsumo_descripcion',
            'label' => 'lang:tinsumo_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'tinsumo_protected',
            'label' => 'lang:tinsumo_protected',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'tinsumo_descripcion',
            'label' => 'lang:tinsumo_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'tinsumo_protected',
            'label' => 'lang:tinsumo_protected',
            'rules' => 'required|is_boolean'
        )
    )
);
