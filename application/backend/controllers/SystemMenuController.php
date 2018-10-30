<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para la lista de elementos jerarquicos que componen el menudel sistena.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: systemMenuController.php 7 2014-02-11 23:55:54Z aranape $
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class SystemMenuController extends app\common\controller\TSLAppDefaultController {

    public function __construct() {
        parent::__construct();
    }

    private function fetchSystemMenu() {
        try {
            // Determino si existe una sub operacion que para este caso estan
            // implementadas
            $operationId = $this->input->get_post('_operationId');
            if (isset($operationId) && is_string($operationId)) {
                $this->DTO->setSubOperationId($operationId);

                // Para el caso de la operacion de menu por usuario pondremos en el filtor
                // campos de la sesion.
                if ($operationId == 'fetchForUser') {
                    $this->DTO->getConstraints()->addFilterField('usuario_id', $this->getUserId());
                    $this->DTO->getConstraints()->addFilterField('empresa_id', $this->getSessionData('empresa_id'));
                }
            }

            // Ir al Bussiness Object
            $systemMenuService = new SystemMenuBussinessService();

            $constraints = &$this->DTO->getConstraints();

            // Procesamos los constraints
            $this->getConstraintProcessor()->process($_REQUEST, $constraints);

            $systemMenuService->executeService('list', $this->DTO);
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
            $this->fetchSystemMenu();
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
