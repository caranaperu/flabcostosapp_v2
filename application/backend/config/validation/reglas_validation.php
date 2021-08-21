<?php

    $config['v_reglas'] = [
        'getReglas' => [
            [
                'field' => 'regla_id',
                'label' => 'lang:regla_id',
                'rules' => 'required|integer'
            ]
        ],
        'updReglas' => [
            [
                'field' => 'regla_id',
                'label' => 'lang:regla_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'regla_empresa_origen_id',
                'label' => 'lang:regla_empresa_origen_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'regla_empresa_destino_id',
                'label' => 'lang:regla_empresa_destino_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'regla_by_costo',
                'label' => 'lang:regla_by_costo',
                'rules' => 'required|is_boolean'
            ],
            [
                'field' => 'regla_porcentaje',
                'label' => 'lang:regla_porcentaje',
                'rules' => 'required|decimal|less_than[100.00]'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer'
            ]
        ],
        'delReglas' => [
            [
                'field' => 'regla_id',
                'label' => 'lang:regla_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer'
            ]
        ],
        'addReglas' => [
            [
                'field' => 'regla_empresa_origen_id',
                'label' => 'lang:regla_empresa_origen_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'regla_empresa_destino_id',
                'label' => 'lang:regla_empresa_destino_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'regla_by_costo',
                'label' => 'lang:regla_by_costo',
                'rules' => 'required|is_boolean'
            ],
            [
                'field' => 'regla_porcentaje',
                'label' => 'lang:regla_porcentaje',
                'rules' => 'required|decimal|less_than[100.00]'
            ]
        ]
    ];