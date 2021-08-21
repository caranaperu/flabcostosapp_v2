<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los items de las listas de costos
 * en realidad ninguna de las funciones ofrecidas es soportada en este caso , yua que los registros
 * son generados via proceso en la base de datos , por ende cumplimos con cumplir con la interface
 * retornando siempre un modelo vacio.
 *
 * @author Carlos Arana
 * @since 17-JUL-2021
 */
class CostosListDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CostosListDetalleDAO", "costos_list_detalle", "msg_costos_list_detalle");
    }

    /**
     * @inheritdoc
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CostosListDetalleModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return new CostosListDetalleModel();
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel especificamente como CostosListDetalleModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return new CostosListDetalleModel();
    }

    /**
     *
     * @return \TSLDataModel especificamente como CostosListDetalleModel
     */
    protected function &getEmptyModel() : \TSLDataModel {
        return new CostosListDetalleModel();
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
        return new CostosListDetalleModel();
    }

}

