<?php

$config['v_cotizacion'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getCotizacion' => array(
        array(
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer'
        )
    ),
    'updCotizacion' => array(
        array(
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'cliente_id',
            'label' => 'lang:cliente_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'cotizacion_es_cliente_real',
            'label' => 'lang:cotizacion_es_cliente_real',
            'rules' => 'is_boolean'
        ),
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'cotizacion_fecha',
            'label' => 'lang:cotizacion_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'cotizacion_numero',
            'label' => 'lang:cotizacion_numero',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'cotizacion_cerrada',
            'label' => 'lang:cotizacion_cerrada',
            'rules' => 'required|is_boolean'
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
    'delCotizacion' => array(
        array(
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addCotizacion' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'cliente_id',
            'label' => 'lang:cliente_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'cotizacion_es_cliente_real',
            'label' => 'lang:cotizacion_es_cliente_real',
            'rules' => 'is_boolean'
        ),
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'cotizacion_fecha',
            'label' => 'lang:cotizacion_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'cotizacion_cerrada',
            'label' => 'lang:cotizacion_cerrada',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        )
    )
);
