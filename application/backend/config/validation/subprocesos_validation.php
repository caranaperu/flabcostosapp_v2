<?php

$config['v_subprocesos'] = array(
    'getSubProcesos' => array(
        array(
            'field' => 'subprocesos_codigo',
            'label' => 'lang:subprocesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        )
    ),
    'updSubProcesos' => array(
        array(
            'field' => 'subprocesos_codigo',
            'label' => 'lang:subprocesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'subprocesos_descripcion',
            'label' => 'lang:subprocesos_descripcion',
            'rules' => 'required|max_length[80]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delSubProcesos' => array(
        array(
            'field' => 'subprocesos_codigo',
            'label' => 'lang:subprocesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addSubProcesos' => array(
        array(
            'field' => 'subprocesos_codigo',
            'label' => 'lang:subprocesos_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'subprocesos_descripcion',
            'label' => 'lang:subprocesos_descripcion',
            'rules' => 'required|max_length[80]'
        )
    )
);