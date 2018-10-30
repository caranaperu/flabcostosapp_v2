<?php

$config['v_unidadmedida_conversion'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_conversion_id',
            'label' => 'lang:unidad_medida_conversion_id',
            'rules' => 'required|integer'
        )
    ),
    'updUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_conversion_id',
            'label' => 'lang:unidad_medida_conversion_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'unidad_medida_origen',
            'label' => 'lang:unidad_medida_origen',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_destino',
            'label' => 'lang:unidad_medida_destino',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_conversion_factor',
            'label' => 'lang:unidad_medida_conversion_factor',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_conversion_id',
            'label' => 'lang:unidad_medida_conversion_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_origen',
            'label' => 'lang:unidad_medida_origen',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_destino',
            'label' => 'lang:unidad_medida_destino',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_conversion_factor',
            'label' => 'lang:unidad_medida_conversion_factor',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        )
    )
);
