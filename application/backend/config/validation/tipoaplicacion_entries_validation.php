<?php

$config['v_tipoaplicacion_entries'] = array(
    'getTipoAplicacionEntries' => array(
        array(
            'field' => 'taplicacion_entries_id',
            'label' => 'lang:taplicacion_entries_id',
            'rules' => 'required|integer'
        )
    ),
    'updTipoAplicacionEntries' => array(
        array(
            'field' => 'taplicacion_entries_id',
            'label' => 'lang:taplicacion_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'taplicacion_entries_descripcion',
            'label' => 'lang:taplicacion_entries_descripcion',
            'rules' => 'required|max_length[80]'
        )
    ),
    'delTipoAplicacionEntries' => array(
        array(
            'field' => 'taplicacion_entries_id',
            'label' => 'lang:taplicacion_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoAplicacionEntries' => array(
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'taplicacion_entries_descripcion',
            'label' => 'lang:taplicacion_entries_descripcion',
            'rules' => 'required|max_length[80]'
        )
    )
);