<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Objeto de Negocios que manipula las acciones directas a los tipos de cambio
     * entre 2 monedas.
     *
     * @author  Carlos Arana Reategui <aranape@gmail.com>
     * @version 0.1
     * @package SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license GPL
     *
     */
    class TipoCambioBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

        function __construct() {
            //    parent::__construct();
            $this->setup("TipoCambioDAO", "tipocambio", "msg_tipocambio");
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel especificamente TipoCambioModel
         */
        protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
            $model = new TipoCambioModel();
            // Leo el id enviado en el DTO
            $model->set_moneda_codigo_origen($dto->getParameterValue('moneda_codigo_origen'));
            $model->set_moneda_codigo_destino($dto->getParameterValue('moneda_codigo_destino'));
            $model->set_tipo_cambio_fecha_desde($dto->getParameterValue('tipo_cambio_fecha_desde'));
            $model->set_tipo_cambio_fecha_hasta($dto->getParameterValue('tipo_cambio_fecha_hasta'));
            $model->set_tipo_cambio_tasa_compra($dto->getParameterValue('tipo_cambio_tasa_compra'));
            $model->set_tipo_cambio_tasa_venta($dto->getParameterValue('tipo_cambio_tasa_venta'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->setUsuario($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel especificamente como TipoCambioModel
         */
        protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
            $model = new TipoCambioModel();
            // Leo el id enviado en el DTO
            $model->set_tipo_cambio_id($dto->getParameterValue('tipo_cambio_id'));
            $model->set_moneda_codigo_origen($dto->getParameterValue('moneda_codigo_origen'));
            $model->set_moneda_codigo_destino($dto->getParameterValue('moneda_codigo_destino'));
            $model->set_tipo_cambio_fecha_desde($dto->getParameterValue('tipo_cambio_fecha_desde'));
            $model->set_tipo_cambio_fecha_hasta($dto->getParameterValue('tipo_cambio_fecha_hasta'));
            $model->set_tipo_cambio_tasa_compra($dto->getParameterValue('tipo_cambio_tasa_compra'));
            $model->set_tipo_cambio_tasa_venta($dto->getParameterValue('tipo_cambio_tasa_venta'));
            
            $model->setVersionId($dto->getParameterValue('versionId'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @return \TSLDataModel especificamente como TipoCambioModel
         */
        protected function &getEmptyModel() : \TSLDataModel {
            $model = new TipoCambioModel();

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel
         */
        protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
            $model = new TipoCambioModel();
            $model->set_tipo_cambio_id($dto->getParameterValue('tipo_cambio_id'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

    }
