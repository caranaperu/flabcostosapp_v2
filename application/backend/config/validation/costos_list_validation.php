<?php

$config['v_costos_list'] = array(
    'delCostosList' => array(
        array(
            'field' => 'costos_list_id',
            'label' => 'lang:costos_list_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'fetchCostosList' => array(
        array(
            'field' => 'costos_list_descripcion',
            'label' => 'lang:costos_list_descripcion',
            'rules' => 'required|alpha|max_length[60]'
        ),
        array(
            'field' => 'costos_list_fecha_desde',
            'label' => 'lang:costos_list_fecha_desde',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'costos_list_fecha_hasta',
            'label' => 'lang:costos_list_fecha_hasta',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'costos_list_fecha_tcambio',
            'label' => 'lang:costos_list_fecha_tcambio',
            'rules' => 'required|validDate'
        )
    )
);
