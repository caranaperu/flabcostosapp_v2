<?php

$config['v_taplicacion_procesos'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getTipoAplicacionProcesos' => array(
        array(
            'field' => 'taplicacion_procesos_id',
            'label' => 'lang:taplicacion_procesos_id',
            'rules' => 'required|integer'
        )
    ),
    'updTipoAplicacionProcesos' => array(
        array(
            'field' => 'taplicacion_procesos_id',
            'label' => 'lang:taplicacion_procesos_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'taplicacion_procesos_fecha_desde',
            'label' => 'lang:taplicacion_procesos_fecha_desde',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'delTipoAplicacionProcesos' => array(
        array(
            'field' => 'taplicacion_procesos_id',
            'label' => 'lang:taplicacion_procesos_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoAplicacionProcesos' => array(
        array(
            'field' => 'taplicacion_codigo',
            'label' => 'lang:taplicacion_codigo',
            'rules' => 'required|alpha_numeric|max_length[15]'
        ),
        array(
            'field' => 'taplicacion_procesos_fecha_desde',
            'label' => 'lang:taplicacion_procesos_fecha_desde',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        )
    )
);
