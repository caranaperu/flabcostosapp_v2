<?php

$config['v_insumo'] = array(
    'getInsumo' => array(
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        )
    ),
    'updInsumo' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_tipo',
            'label' => 'lang:insumo_tipo',
            'rules' => 'required|alpha_numeric|max_length[2]'
        ),
        array(
            'field' => 'insumo_codigo',
            'label' => 'lang:insumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'insumo_descripcion',
            'label' => 'lang:insumo_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|max_length[5]'
        ),
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'unidad_medida_codigo_ingreso',
            'label' => 'lang:unidad_medida_codigo_ingreso',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_codigo_costo',
            'label' => 'lang:unidad_medida_codigo_costo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'insumo_merma',
            'label' => 'lang:insumo_merma',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ),
        array(
            'field' => 'insumo_costo',
            'label' => 'lang:insumo_costo',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ),
        array(
            'field' => 'insumo_precio_mercado',
            'label' => 'lang:insumo_precio_mercado',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ),
        array(
            'field' => 'moneda_codigo_costo',
            'label' => 'lang:moneda_codigo_costo',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delInsumo' => array(
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addInsumo' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_tipo',
            'label' => 'lang:insumo_tipo',
            'rules' => 'required|alpha_numeric|max_length[2]'
        ),
        array(
            'field' => 'insumo_codigo',
            'label' => 'lang:insumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'insumo_descripcion',
            'label' => 'lang:insumo_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|max_length[5]'
        ),
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'unidad_medida_codigo_ingreso',
            'label' => 'lang:unidad_medida_codigo_ingreso',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_codigo_costo',
            'label' => 'lang:unidad_medida_codigo_costo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'insumo_merma',
            'label' => 'lang:insumo_merma',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ),
        array(
            'field' => 'insumo_costo',
            'label' => 'lang:insumo_costo',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ),
        array(
            'field' => 'insumo_precio_mercado',
            'label' => 'lang:insumo_precio_mercado',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ),
        array(
            'field' => 'moneda_codigo_costo',
            'label' => 'lang:moneda_codigo_costo',
            'rules' => 'required|alpha_numeric|max_length[8]'
        )
    )
);