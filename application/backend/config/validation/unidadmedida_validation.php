<?php

$config['v_unidadmedida'] = [
    'getUnidadMedida' => [
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ]
    ],
    'updUnidadMedida' => [
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'unidad_medida_descripcion',
            'label' => 'lang:unidad_medida_descripcion',
            'rules' => 'required|max_length[80]'
        ],
        [
            'field' => 'unidad_medida_siglas',
            'label' => 'lang:unidad_medida_siglas',
            'rules' => 'required|max_length[6]'
        ],
        [
            'field' => 'unidad_medida_tipo',
            'label' => 'lang:unidad_medida_tipo',
            'rules' => 'required|max_length[1]'
        ],
        [
            'field' => 'unidad_medida_default',
            'label' => 'lang:unidad_medida_default',
            'rules' => 'required|is_boolean'
        ],
        [
            'field' => 'unidad_medida_protected',
            'label' => 'lang:unidad_medida_protected',
            'rules' => 'required|is_boolean'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        ]
    ],
    'delUnidadMedida' => [
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        ]
    ],
    'addUnidadMedida' => [
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ],
        [
            'field' => 'unidad_medida_descripcion',
            'label' => 'lang:unidad_medida_descripcion',
            'rules' => 'required|max_length[80]'
        ],
        [
            'field' => 'unidad_medida_siglas',
            'label' => 'lang:unidad_medida_siglas',
            'rules' => 'required|max_length[6]'
        ],
        [
            'field' => 'unidad_medida_tipo',
            'label' => 'lang:unidad_medida_tipo',
            'rules' => 'required|max_length[1]'
        ],
        [
            'field' => 'unidad_medida_default',
            'label' => 'lang:unidad_medida_default',
            'rules' => 'required|is_boolean'
        ],
        [
            'field' => 'unidad_medida_protected',
            'label' => 'lang:unidad_medida_protected',
            'rules' => 'required|is_boolean'
        ]
    ]
];
