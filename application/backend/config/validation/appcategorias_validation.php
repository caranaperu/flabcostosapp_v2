<?php

$config['v_appcategorias'] = array(
    'getAppCategorias' => array(
        array(
            'field' => 'appcat_codigo',
            'label' => 'lang:appcat_codigo',
            'rules' => 'required|alpha|max_length[3]'
        )
    )

);
