<?php

$config['v_tcostos'] = array(
    'getTCostos' => array(
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcosots_codigo',
            'rules' => 'required|alpha_numeric|max_length[5]'
        )
    ),
    'updTCostos' => array(
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|max_length[5]'
        ),
        array(
            'field' => 'tcostos_descripcion',
            'label' => 'lang:tcostos_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'tcostos_protected',
            'label' => 'lang:tcostos_protected',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'tcostos_indirecto',
            'label' => 'lang:tinsumo_indirecto',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTCostos' => array(
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|max_length[5]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTCostos' => array(
              array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|max_length[5]'
        ),
        array(
            'field' => 'tcostos_descripcion',
            'label' => 'lang:tcostos_descripcion',
            'rules' => 'required|max_length[60]'
        ),
        array(
            'field' => 'tcostos_protected',
            'label' => 'lang:tcostos_protected',
            'rules' => 'required|is_boolean'
        ),
        array(
            'field' => 'tcostos_indirecto',
            'label' => 'lang:tinsumo_indirecto',
            'rules' => 'required|is_boolean'
        )
    )
);
