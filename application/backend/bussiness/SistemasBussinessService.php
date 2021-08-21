<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios para el manejo de los sitemas que comonen la aplicacion
 * no efectua tarea adicional alguna, por ahora ya que solo implementa
 * el fetch.
 *
 * @author $Author: aranape $
 * @version $Id: SistemasBussinessService.php 401 2014-01-11 09:27:41Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-01-11 04:27:41 -0500 (sáb, 11 ene 2014) $
 * $Rev: 401 $
 */
class SistemasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("app\\common\\dao\\impl\\TSLAppSistemasDAO", "sistemas", "msg_sistemas");
    }



    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return NULL;
    }

    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return NULL;
    }

    protected function &getEmptyModel() : \TSLDataModel {
        $model =  new app\common\model\impl\TSLAppSistemasModel();
        return $model;
    }

    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return NULL;
    }

}

