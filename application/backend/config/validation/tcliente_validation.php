<?php

$config['vtipo_cliente'] = array(
    'getTipoCliente' => array(
        array(
            'field' => 'tipo_cliente_codigo',
            'label' => 'lang:tipo_cliente_codigo',
            'rules' => 'required|alpha|max_length[3]'
        )
    ),
    'updTipoCliente' => array(
        array(
            'field' => 'tipo_cliente_codigo',
            'label' => 'lang:tipo_cliente_codigo',
            'rules' => 'required|alpha|max_length[3]'
        ),
        array(
            'field' => 'tipo_cliente_descripcion',
            'label' => 'lang:tipo_cliente_descripcion',
            'rules' => 'required|max_length[120]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTipoCliente' => array(
        array(
            'field' => 'tipo_cliente_codigo',
            'label' => 'lang:tipo_cliente_codigo',
            'rules' => 'required|alpha|max_length[3]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoCliente' => array(
        array(
            'field' => 'tipo_cliente_codigo',
            'label' => 'lang:tipo_cliente_codigo',
            'rules' => 'required|alpha|max_length[3]'
        ),
        array(
            'field' => 'tipo_cliente_descripcion',
            'label' => 'lang:tipo_cliente_descripcion',
            'rules' => 'required|max_length[120]'
        )
    )
);