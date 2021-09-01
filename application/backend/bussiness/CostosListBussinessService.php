<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de la cabecera de las listas de costos
 *  en este caso solo se soportara la eliminacion , ya que sera generado por un proceso de base de datos
 * y las otras operaciones no sonpermitidas.
 *
 * @author Carlos Arana
 * @since 17-JUL-2021
 */
class CostosListBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CostosListDAO", "costoslist", "msg_costoslist");
    }

    protected function doService(string $action, \TSLIDataTransferObj $dto) : void {
        if ($action == 'fetch' || $action == 'add') {
            $this->fetch($dto);
        } else {
            parent::doService();
        }
    }

            /**
     * No hay operacion add en este caso debido a que es un proceso..
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CostosListModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {

        $model = new CostosListModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CostosListModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        // En realidad en esta tabla nuncva se hara update
        $model = new CostosListModel();
        return $model;
    }

    /**
     *
     * @return \TSLDataModel especificamente como CostosListModel
     */
    protected function &getEmptyModel() : \TSLDataModel {

        $model = new CostosListModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        $model = new CostosListModel();
        $model->set_costos_list_id($dto->getParameterValue('costos_list_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        return $model;
    }

}

