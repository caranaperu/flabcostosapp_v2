<?php

$config['v_tcostoglobal_entries'] = array(
    'getTipoCostoGlobalEntries' => array(
        array(
            'field' => 'tcosto_global_entries_id',
            'label' => 'lang:tcosto_global_entries_id',
            'rules' => 'required|integer'
        )
    ),
    'updTipoCostoGlobalEntries' => array(
        array(
            'field' => 'tcosto_global_entries_id',
            'label' => 'lang:tcosto_global_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'tcosto_global_entries_fecha_desde',
            'label' => 'lang:tcosto_global_entries_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'tcosto_global_codigo',
            'label' => 'lang:tcosto_global_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'tcosto_global_entries_valor',
            'label' => 'lang:tcosto_global_entries_valor',
            'rules' => 'required|decimal|greater_than[0.00]'
        )
    ),
    'delTipoCostoGlobalEntries' => array(
        array(
            'field' => 'tcosto_global_entries_id',
            'label' => 'lang:tcosto_global_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addTipoCostoGlobalEntries' => array(
        array(
            'field' => 'tcosto_global_entries_fecha_desde',
            'label' => 'lang:tcosto_global_entries_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'tcosto_global_codigo',
            'label' => 'lang:tcosto_global_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|max_length[8]'
        ),
        array(
            'field' => 'tcosto_global_entries_valor',
            'label' => 'lang:tcosto_global_entries_valor',
            'rules' => 'required|decimal|greater_than[0.00]'
        )
    )
);