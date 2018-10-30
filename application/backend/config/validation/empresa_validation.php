<?php

$config['v_empresa'] = array(
    'getEmpresa' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        )
    ),
    'updEmpresa' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'empresa_razon_social',
            'label' => 'lang:empresa_razon_social',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|max_length[3]'
        ),
        array(
            'field' => 'empresa_ruc',
            'label' => 'lang:empresa_ruc',
            'rules' => 'required|numeric|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'empresa_direccion',
            'label' => 'lang:empresa_direccion',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'empresa_correo',
            'label' => 'lang:empresa_correo',
            'rules' => 'valid_email|max_length[100]'
        ),
        array(
            'field' => 'empresa_fax',
            'label' => 'lang:empresa_fax',
            'rules' => 'integer|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delEmpresa' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addEmpresa' => array(
        array(
            'field' => 'empresa_razon_social',
            'label' => 'lang:empresa_razon_social',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|max_length[3]'
        ),
        array(
            'field' => 'empresa_ruc',
            'label' => 'lang:empresa_ruc',
            'rules' => 'required|numeric|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'empresa_direccion',
            'label' => 'lang:empresa_direccion',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'empresa_correo',
            'label' => 'lang:empresa_correo',
            'rules' => 'valid_email|max_length[100]'
        ),
        array(
            'field' => 'empresa_fax',
            'label' => 'lang:empresa_fax',
            'rules' => 'integer|min_length[7]|max_length[10]'
        )
    )
);
