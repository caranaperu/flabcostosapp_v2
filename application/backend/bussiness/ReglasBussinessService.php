<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Objeto de Negocios que manipula las acciones directas a los reglas
     *  de los costos entre 2 empresas, tales como listar , agregar , eliminar , etc.
     *
     * @author  $Author: aranape $
     * @since   01-10-2016
     */
    class ReglasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

        function __construct() {
            //    parent::__construct();
            $this->setup("ReglasDAO", "reglas", "msg_reglas");
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel especificamente como ReglasModel
         */
        protected function &getModelToAdd(\TSLIDataTransferObj $dto) : \TSLDataModel {
            $model = new ReglasModel();
            // Leo el id enviado en el DTO
            $model->set_regla_empresa_origen_id($dto->getParameterValue('regla_empresa_origen_id'));
            $model->set_regla_empresa_destino_id($dto->getParameterValue('regla_empresa_destino_id'));
            $model->set_regla_by_costo(($dto->getParameterValue('regla_by_costo') == 'true' ? true : false));
            $model->set_regla_porcentaje($dto->getParameterValue('regla_porcentaje'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->setUsuario($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel especificamente como ReglasModel
         */
        protected function &getModelToUpdate(\TSLIDataTransferObj $dto) : \TSLDataModel {
            $model = new ReglasModel();
            // Leo el id enviado en el DTO
            $model->set_regla_id($dto->getParameterValue('regla_id'));
            $model->set_regla_empresa_origen_id($dto->getParameterValue('regla_empresa_origen_id'));
            $model->set_regla_empresa_destino_id($dto->getParameterValue('regla_empresa_destino_id'));
            $model->set_regla_by_costo(($dto->getParameterValue('regla_by_costo') == 'true' ? true : false));
            $model->set_regla_porcentaje($dto->getParameterValue('regla_porcentaje'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @return \TSLDataModel especificamente como ReglasModel
         */
        protected function &getEmptyModel() : \TSLDataModel {
            $model = new ReglasModel();

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel
         */
        protected function &getModelToDelete(\TSLIDataTransferObj $dto) : \TSLDataModel {
            $model = new ReglasModel();
            $model->set_regla_id($dto->getParameterValue('regla_id'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

    }
