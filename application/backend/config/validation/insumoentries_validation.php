<?php

$config['v_insumoentries'] = array(
    'getInsumoEntries' => array(
        array(
            'field' => 'insumo_entries_id',
            'label' => 'lang:insumo_entries_id',
            'rules' => 'required|integer'
        )
    ),
    'updInsumoEntries' => array(
        array(
            'field' => 'insumo_entries_id',
            'label' => 'lang:insumo_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_entries_fecha',
            'label' => 'lang:insumo_entries_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_entries_qty',
            'label' => 'lang:insumo_entries_qty',
            'rules' => 'required|decimal|greater_than[1.00] '
        ),
        array(
            'field' => 'insumo_entries_value',
            'label' => 'lang:insumo_entries_value',
            'rules' => 'required|decimal|greater_than[0.00]|less_than_equal_to[100.00]'
        )
    ),
    'delInsumoEntries' => array(
        array(
            'field' => 'insumo_entries_id',
            'label' => 'lang:insumo_entries_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer'
        )
    ),
    'addInsumoEntries' => array(
        array(
            'field' => 'insumo_entries_fecha',
            'label' => 'lang:insumo_entries_fecha',
            'rules' => 'required|validDate'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer'
        ),
        array(
            'field' => 'insumo_entries_qty',
            'label' => 'lang:insumo_entries_qty',
            'rules' => 'required|decimal|greater_than[1.00] '
        ),
        array(
            'field' => 'insumo_entries_value',
            'label' => 'lang:insumo_entries_value',
            'rules' => 'required|decimal|greater_than[0.00]|less_than_equal_to[100.00]'
        )
    )
);