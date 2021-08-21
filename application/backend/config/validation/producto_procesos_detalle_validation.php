<?php

$config['v_producto_procesos_detalle'] = [
    'getProductoProcesosDetalle' => [
        [
            'field' => 'producto_procesos_detalle_id',
            'label' => 'lang:producto_procesos_detalle_id',
            'rules' => 'required|integer'
        ]
    ],
    'updProductoProcesosDetalle' => [
        [
            'field' => 'producto_procesos_detalle_id',
            'label' => 'lang:producto_procesos_detalle_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'producto_procesos_id',
            'label' => 'lang:producto_procesos_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'producto_procesos_detalle_porcentaje',
            'label' => 'lang:producto_procesos_detalle_porcentaje',
            'rules' => 'required|decimal|greater_than[0.00] |less_than[100.01]'
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
    'delProductoProcesosDetalle' => [
        [
            'field' => 'producto_procesos_detalle_id',
            'label' => 'lang:producto_procesos_detalle_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        ]
    ],
    'addProductoProcesosDetalle' => [
        [
            'field' => 'producto_procesos_id',
            'label' => 'lang:producto_procesos_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'producto_procesos_detalle_porcentaje',
            'label' => 'lang:producto_procesos_detalle_porcentaje',
            'rules' => 'required|decimal|greater_than[0.00] |less_than[100.01]'
        ],
        [
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        ]
    ]
];
