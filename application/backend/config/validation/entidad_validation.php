<?php

$config['v_entidad'] = array(
    'getEntidad' => array(
        array(
            'field' => 'entidad_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        )
    ),
    'updEntidad' => array(
        array(
            'field' => 'entidad_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'entidad_razon_social',
            'label' => 'lang:entidad_razon_social',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'entidad_ruc',
            'label' => 'lang:entidad_ruc',
            'rules' => 'required|numeric|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'entidad_direccion',
            'label' => 'lang:entidad_direccion',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'entidad_correo',
            'label' => 'lang:entidad_correo',
            'rules' => 'valid_email|max_length[100]'
        ),
        array(
            'field' => 'entidad_fax',
            'label' => 'lang:entidad_fax',
            'rules' => 'integer|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delEntidad' => array(
        array(
            'field' => 'entidad_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addEntidad' => array(
        array(
            'field' => 'entidad_razon_social',
            'label' => 'lang:entidad_razon_social',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'entidad_ruc',
            'label' => 'lang:entidad_ruc',
            'rules' => 'required|numeric|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'entidad_direccion',
            'label' => 'lang:entidad_direccion',
            'rules' => 'required|max_length[200]'
        ),
        array(
            'field' => 'entidad_correo',
            'label' => 'lang:entidad_correo',
            'rules' => 'valid_email|max_length[100]'
        ),
        array(
            'field' => 'entidad_fax',
            'label' => 'lang:entidad_fax',
            'rules' => 'integer|min_length[7]|max_length[10]'
        )
    )
);