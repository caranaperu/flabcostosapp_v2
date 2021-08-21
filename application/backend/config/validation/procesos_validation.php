<?php

$config['v_procesos'] = array(
    'getProcesos' => array(
        array(
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        )
    ),
    'updProcesos' => array(
        array(
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'procesos_descripcion',
            'label' => 'lang:procesos_descripcion',
            'rules' => 'required|max_length[80]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delProcesos' => array(
        array(
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addProcesos' => array(
        array(
            'field' => 'procesos_codigo',
            'label' => 'lang:procesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'procesos_descripcion',
            'label' => 'lang:procesos_descripcion',
            'rules' => 'required|max_length[80]'
        )
    )
);