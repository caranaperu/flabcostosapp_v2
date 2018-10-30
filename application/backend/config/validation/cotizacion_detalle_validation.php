<?php

$config['v_cotizacion_detalle'] = [
    'getCotizacionDetalle' => [
        [
            'field' => 'cotizacion_detalle_id',
            'label' => 'lang:cotizacion_detalle_id',
            'rules' => 'required|integer'
        ]
    ],
    'updCotizacionDetalle' => [
        [
            'field' => 'cotizacion_detalle_id',
            'label' => 'lang:cotizacion_detalle_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'cotizacion_detalle_cantidad',
            'label' => 'lang:cotizacion_detalle_cantidad',
            'rules' => 'required|decimal|greater_than_equal[0.01] '
        ],
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'cotizacion_detalle_precio',
            'label' => 'lang:cotizacion_detalle_precio',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ],
        [
            'field' => 'cotizacion_detalle_total',
            'label' => 'lang:cotizacion_detalle_total',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ],
        [
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        ]
    ],
    'delCotizacionDetalle' => [
        [
            'field' => 'cotizacion_detalle_id',
            'label' => 'lang:cotizacion_detalle_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        ]
    ],
    'addCotizacionDetalle' => [
        [
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'cotizacion_detalle_cantidad',
            'label' => 'lang:cotizacion_detalle_cantidad',
            'rules' => 'required|decimal|greater_than_equal[0.01] '
        ],
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'cotizacion_detalle_precio',
            'label' => 'lang:cotizacion_detalle_precio',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ],
        [
            'field' => 'cotizacion_detalle_total',
            'label' => 'lang:cotizacion_detalle_total',
            'rules' => 'required|decimal|greater_than_equal[0.00] '
        ],
        [
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        ]
    ]
];
