<?php

$config['v_tcosto_global'] = array(
    'getTipoCostoGlobal' => array(
        array(
            'field' => 'tcosto_global_codigo',
            'label' => 'lang:tcosto_global_codigo',
            'rules' => 'required|alpha|max_length[8]'
        )
    ),
    'updTipoCostoGlobal' => array(
        array(
            'field' => 'tcosto_global_codigo',
            'label' => 'lang:tcosto_global_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'tcosto_global_descripcion',
            'label' => 'lang:tcosto_global_descripcion',
            'rules' => 'required|max_length[80]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTipoCostoGlobal' => array(
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoCostoGlobal' => array(
        array(
            'field' => 'tcosto_global_codigo',
            'label' => 'lang:tcosto_global_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'tcosto_global_descripcion',
            'label' => 'lang:tcosto_global_descripcion',
            'rules' => 'required|max_length[80]'
        )
    )
);