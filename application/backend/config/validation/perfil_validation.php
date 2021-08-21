<?php

    $config['v_perfil'] = [
        // Para la lectura de un contribuyente basado eb su id
        'getPerfil' => [
            [
                'field' => 'perfil_id',
                'label' => 'lang:perfil_id',
                'rules' => 'required|integer'
            ]
        ],
        'updPerfil' => [
            [
                'field' => 'perfil_id',
                'label' => 'lang:perfil_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'sys_systemcode',
                'label' => 'lang:sys_systemcode',
                'rules' => 'required|onlyValidText|max_length[10]'
            ],
            [
                'field' => 'perfil_codigo',
                'label' => 'lang:perfil_codigo',
                'rules' => 'required|onlyValidText|max_length[15]'
            ],
            [
                'field' => 'perfil_descripcion',
                'label' => 'lang:perfil_descripcion',
                'rules' => 'required|onlyValidText|max_length[120]'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer'
            ]
        ],
        'delPerfil' => [
            [
                'field' => 'perfil_id',
                'label' => 'lang:perfil_id',
                'rules' => 'required|integer'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer'
            ]
        ],
        'addPerfil' => [
            [
                'field' => 'sys_systemcode',
                'label' => 'lang:sys_systemcode',
                'rules' => 'required|onlyValidText|max_length[10]'
            ],
            [
                'field' => 'perfil_codigo',
                'label' => 'lang:perfil_codigo',
                'rules' => 'required|onlyValidText|max_length[15]'
            ],
            [
                'field' => 'perfil_descripcion',
                'label' => 'lang:perfil_descripcion',
                'rules' => 'required|onlyValidText|max_length[120]'
            ]
        ]
    ];