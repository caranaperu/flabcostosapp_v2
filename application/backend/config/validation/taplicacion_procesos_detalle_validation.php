<?php

$config['v_taplicacion_procesos_detalle'] = [
    'getTipoAplicacionProcesosDetalle' => [
        [
            'field' => 'taplicacion_procesos_detalle_id',
            'label' => 'lang:taplicacion_procesos_detalle_id',
            'rules' => 'required|integer'
        ]
    ],
    'updTipoAplicacionProcesosDetalle' => [
        [
            'field' => 'taplicacion_procesos_detalle_id',
            'label' => 'lang:taplicacion_procesos_detalle_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'taplicacion_procesos_id',
            'label' => 'lang:taplicacion_procesos_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'taplicacion_procesos_detalle_porcentaje',
            'label' => 'lang:taplicacion_procesos_detalle_porcentaje',
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
    'delTipoAplicacionProcesosDetalle' => [
        [
            'field' => 'taplicacion_procesos_detalle_id',
            'label' => 'lang:taplicacion_procesos_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        ]
    ],
    'addTipoAplicacionProcesosDetalle' => [
        [
            'field' => 'taplicacion_procesos_id',
            'label' => 'lang:taplicacion_procesos_id',
            'rules' => 'required|integer'
        ],
        [
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'taplicacion_procesos_detalle_porcentaje',
            'label' => 'lang:taplicacion_procesos_detalle_porcentaje',
            'rules' => 'required|decimal|greater_than[0.00] |less_than[100.01]'
        ],
        [
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        ]
    ]
];
