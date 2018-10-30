<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios para el manejo del menu del sistema, basicamente
 * no efectua tarea adicional alguna, por ahora ya que solo implementa
 * el fetch.
 *
 * @author $Author: aranape $
 * @version $Id: SystemMenuBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class SystemMenuBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("SystemMenuDAO", "systemMenu", "msg_menu");
    }



    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return NULL;
    }

    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return NULL;
    }

    protected function &getEmptyModel() : \TSLDataModel {
        $model =  new \SystemMenuModel();
        return $model;
    }

    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return NULL;
    }

}
