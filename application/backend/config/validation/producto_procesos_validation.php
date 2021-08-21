<?php

$config['v_producto_procesos'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getProductoProcesos' => array(
        array(
            'field' => 'producto_procesos_id',
            'label' => 'lang:producto_procesos_id',
            'label' => 'lang:producto_procesos_id',
            'rules' => 'required|integer'
        )
    ),
    'updProductoProcesos' => array(
        array(
            'field' => 'producto_procesos_id',
            'label' => 'lang:producto_procesos_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'producto_procesos_fecha_desde',
            'label' => 'lang:producto_procesos_fecha_desde',
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
    'delProductoProcesos' => array(
        array(
            'field' => 'producto_procesos_id',
            'label' => 'lang:producto_procesos_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addProductoProcesos' => array(
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'producto_procesos_fecha_desde',
            'label' => 'lang:producto_procesos_fecha_desde',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_boolean'
        )
    )
);
