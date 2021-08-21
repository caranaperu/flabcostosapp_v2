<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones a los datos
 * basicos de la entidad usuaria del producto.
 *
 * @author $Author: aranape $
 * @version $Id: EntidadBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class LoginBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("UsuariosDAO", "login", "msg_login");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como UsuariosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como UsuariosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosModel();
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como UsuariosModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        $model = new UsuariosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new UsuariosModel();
        return $model;
    }

}

