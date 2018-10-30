<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para la la lista de sistemas de una aplicacion
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: sistemasController.php 397 2014-01-11 09:25:18Z aranape $
 *
 * $Date: 2014-01-11 04:25:18 -0500 (sáb, 11 ene 2014) $
 * $Rev: 397 $
 */
class SistemasController extends app\common\controller\TSLAppDefaultController {

    public function __construct() {
        parent::__construct();
    }

    private function fetchSistemas() {
        try {
            // Determino si existe una sub operacion que para este caso estan
            // implementadas
            $operationId = $this->input->get_post('_operationId');
            if (isset($operationId) && is_string($operationId)) {
                $this->DTO->setSubOperationId($operationId);
            }

            // Ir al Bussiness Object
            $sistemasService = new SistemasBussinessService();

            //$constraints = &$this->DTO->getConstraints();

            // Procesamos los constraints
           // $this->getConstraintProcessor()->process($_REQUEST);

            $sistemasService->executeService('list', $this->DTO);
        } catch (Throwable $ex) {
            $outMessage = &$this->DTO->getOutMessage();
            // TODO: Internacionalizar.
            $processError = new TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }
    }

    /**
     * Pagina index para este controlador , maneja todos los casos , lectura, lista
     * etc.
     */
    public function index() {
        // Se setea el usuario
        $this->DTO->setSessionUser($this->getUserCode());

        // Leera los datos del tipo de contribuyentes por default si no se envia
        // una operacion especifica.
        $op = $_REQUEST['op'];
        if (!isset($op) || $op == 'fetch') {
            $this->DTO->setOperation(TSLIDataTransferObj::OP_FETCH);
            $this->fetchSistemas();
        } else {
            $outMessage = &$this->DTO->getOutMessage();
            // TODO: Internacionalizar.
            $processError = new TSLProcessErrorMessage(70000, 'Operacion No Conocida', null);
            $outMessage->addProcessError($processError);
        }

        // Envia los resultados a traves del DTO
        //$this->responseProcessor->process($this->DTO);
        $data['data'] = &$this->responseProcessor->process($this->DTO);
        $this->load->view($this->getView(), $data);
    }

}
