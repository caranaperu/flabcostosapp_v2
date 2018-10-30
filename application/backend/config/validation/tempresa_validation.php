<?php

$config['vtipo_empresa'] = array(
    'getTipoEmpresa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|max_length[3]'
        )
    ),
    'updTipoEmpresa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|max_length[3]'
        ),
        array(
            'field' => 'tipo_empresa_descripcion',
            'label' => 'lang:tipo_empresa_descripcion',
            'rules' => 'required|max_length[120]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTipoEmpresa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|max_length[3]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoEmpresa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|max_length[3]'
        ),
        array(
            'field' => 'tipo_empresa_descripcion',
            'label' => 'lang:tipo_empresa_descripcion',
            'rules' => 'required|max_length[120]'
        )
    )
);