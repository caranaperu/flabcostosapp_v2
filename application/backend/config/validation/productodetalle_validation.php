<?php

$config['v_productodetalle'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getProductoDetalle' => array(
        array(
            'field' => 'producto_detalle_id',
            'label' => 'lang:producto_detalle_id',
            'rules' => 'required|integer'
        )
    ),
    'updProductoDetalle' => array(
        array(
            'field' => 'producto_detalle_id',
            'label' => 'lang:producto_detalle_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_id_origen',
            'label' => 'lang:insumo_id_origen',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'producto_detalle_cantidad',
            'label' => 'lang:producto_detalle_cantidad',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'producto_detalle_valor',
            'label' => 'lang:producto_detalle_valor',
            'rules' => 'required|decimal|greater_than_equal[0.00]'
        ),
        array(
            'field' => 'producto_detalle_merma',
            'label' => 'lang:producto_detalle_merma',
            'rules' => 'required|decimal|greater_than_equal[0.00]'
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
    'delProductoDetalle' => array(
        array(
            'field' => 'producto_detalle_id',
            'label' => 'lang:producto_detalle_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addProductoDetalle' => array(
        array(
            'field' => 'insumo_id_origen',
            'label' => 'lang:insumo_id_origen',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'producto_detalle_cantidad',
            'label' => 'lang:producto_detalle_cantidad',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'producto_detalle_valor',
            'label' => 'lang:producto_detalle_valor',
            'rules' => 'required|decimal|greater_than_equal[0.00]'
        ),
        array(
            'field' => 'producto_detalle_merma',
            'label' => 'lang:producto_detalle_merma',
            'rules' => 'required|decimal|greater_than_equal[0.00]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        )
    )
);