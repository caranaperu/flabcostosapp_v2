<?php

$config['v_tipocambio'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getTipoCambio' => array(
        array(
            'field' => 'tipo_cambio_id',
            'label' => 'lang:tipo_cambio_id',
            'rules' => 'required|integer'
        )
    ),
    'updTipoCambio' => array(
        array(
            'field' => 'tipo_cambio_id',
            'label' => 'lang:tipo_cambio_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'moneda_codigo_origen',
            'label' => 'lang:moneda_codigo_origen',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'moneda_codigo_destino',
            'label' => 'lang:moneda_codigo_destino',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'tipo_cambio_fecha_desde',
            'label' => 'lang:tipo_cambio_fecha_desde',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'tipo_cambio_fecha_hasta',
            'label' => 'lang:tipo_cambio_fecha_hasta',
            'rules' => 'required|validDate|isFutureOrSame_date[tipo_cambio_fecha_desde]'
        ),
        array(
            'field' => 'tipo_cambio_tasa_compra',
            'label' => 'lang:tipo_cambio_tasa_compra',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'tipo_cambio_tasa_venta',
            'label' => 'lang:tipo_cambio_tasa_venta',
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
    'delTipoCambio' => array(
        array(
            'field' => 'tipo_cambio_id',
            'label' => 'lang:tipo_cambio_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoCambio' => array(
        array(
            'field' => 'moneda_codigo_origen',
            'label' => 'lang:moneda_codigo_origen',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'moneda_codigo_destino',
            'label' => 'lang:moneda_codigo_destino',
            'rules' => 'required|alpha_numeric|max_length[8]'
        ),
        array(
            'field' => 'tipo_cambio_fecha_desde',
            'label' => 'lang:tipo_cambio_fecha_desde',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'tipo_cambio_fecha_hasta',
            'label' => 'lang:tipo_cambio_fecha_hasta',
            'rules' => 'required|validDate|isFutureOrSame_date[tipo_cambio_fecha_desde]'
        ),
        array(
            'field' => 'tipo_cambio_tasa_compra',
            'label' => 'lang:tipo_cambio_tasa_compra',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'tipo_cambio_tasa_venta',
            'label' => 'lang:tipo_cambio_tasa_venta',
            'rules' => 'required|decimal|greater_than[0.00]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean")'
        )
    )
);
