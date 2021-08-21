<?php

$config['v_produccion'] = array(
    'getProduccion' => array(
        array(
            'field' => 'produccion_id',
            'label' => 'lang:produccion_id',
            'rules' => 'required|integer'
        )
    ),
    'updProduccion' => array(
        array(
            'field' => 'produccion_id',
            'label' => 'lang:produccion_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'produccion_fecha',
            'label' => 'lang:produccion_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'taplicacion_entries_id',
            'label' => 'lang:taplicacion_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'produccion_qty',
            'label' => 'lang:produccion_qty',
            'rules' => 'required|decimal|greater_than[1.00] '
        )
    ),
    'delProduccion' => array(
        array(
            'field' => 'produccion_id',
            'label' => 'lang:produccion_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addProduccion' => array(
        array(
            'field' => 'produccion_fecha',
            'label' => 'lang:produccion_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'taplicacion_entries_id',
            'label' => 'lang:taplicacion_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'produccion_qty',
            'label' => 'lang:produccion_qty',
            'rules' => 'required|decimal|greater_than[1.00] '
        )
    )
);