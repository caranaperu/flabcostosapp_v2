<?php

$config['v_moneda'] = array(
    'getMoneda' => array(
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        )
    ),
    'updMoneda' => array(
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'moneda_descripcion',
            'label' => 'lang:moneda_descripcion',
            'rules' => 'required|max_length[80]'
        ),
        array(
            'field' => 'moneda_simbolo',
            'label' => 'lang:moneda_simbolo',
            'rules' => 'required|max_length[6]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delMoneda' => array(
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addMoneda' => array(
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'moneda_descripcion',
            'label' => 'lang:moneda_descripcion',
            'rules' => 'required|max_length[80]'
        ),
        array(
            'field' => 'moneda_simbolo',
            'label' => 'lang:moneda_simbolo',
            'rules' => 'required|max_length[6]'
        )
    )
);