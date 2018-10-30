<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para el login/logout del sistema , crea la sesion y pone data en la misma
 * requerida para procesamientos posteriores.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: entrenadoresController.php 54 2014-03-02 05:45:36Z aranape $
 *
 * $Date: 2014-03-02 00:45:36 -0500 (dom, 02 mar 2014) $
 * $Rev: 54 $
 */
class LoginController extends app\common\controller\TSLAppDefaultController {

    public function __construct() {
        parent::__construct();
    }


    private function checkLogin() {

        try {
            if ($this->validateInputData($this->DTO, 'login', 'login_validation', 'v_login', 'checkLogin') === TRUE) {

                $constraints = &$this->DTO->getConstraints();
                $this->getConstraintProcessor()->process($_REQUEST, $constraints);

                // Ir al Bussiness Object
                $loginService = new LoginBussinessService();
                $loginService->executeService('read', $this->DTO);
                if ($this->DTO->getOutMessage()) {
                    return $this->DTO->getOutMessage()->isSuccess();
                } else {
                    return false;
                }
            }
            return false;
        } catch (Throwable $ex) {
            $outMessage = &$this->DTO->getOutMessage();
            // TODO: Internacionalizar.
            $processError = new TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
            return false;
        }
    }


    /**
     * Pagina index para este controlador , maneja todos los casos , lectura, lista
     * etc.
     */
    public function index() {
        // Algunas librerias envia el texto null en casos de campos sin datos lo ponemos a NULL
        $this->parseParameters(['usuarios_']);
        // ya que podria no haberse enviado y estar no definido
        $this->fixParameter('usuarios_code', 'null', NULL);

        // Leera los datos del tipo de contribuyentes por default si no se envia
        // una operacion especifica.
        $op = $_REQUEST['op'];
        if (!isset($op) || $op == 'fetch') {
            // Si la suboperacion es read o no esta definida y se ha definido la pk se busca un registro unico
            // de lo contrario se busca en forma de resultset
            $this->DTO->setOperation(TSLIDataTransferObj::OP_READ);
            $this->DTO->setSubOperationId('checkLogin');
            if ($this->checkLogin() == true) {
                $model = $this->DTO->getOutMessage()->getResultData();

                $this->setSessionData('empresa_id',$model->get_empresa_id());
                $this->setSessionData('usuario_id',$model->get_usuarios_id());
                $this->setSessionData('usuario_code',$model->get_usuarios_code());
                $this->setSessionData('usuario_name',$model->get_usuarios_nombre_completo());
                $this->setSessionData('isLoggedIn',true);

            } else {
                $this->unsetSessionData('empresa_id');
                $this->unsetSessionData('usuario_id');
                $this->unsetSessionData('usuario_code');
                $this->unsetSessionData('usuario_name');
                $this->unsetSessionData('isLoggedIn');
            }
        } else if ($op == 'del') {
            $this->session->sess_destroy();
            $this->DTO->getOutMessage()->setSuccess(true);
        } else {
            $outMessage = &$this->DTO->getOutMessage();
            // TODO: Internacionalizar.
            $processError = new TSLProcessErrorMessage(70000, 'Operacion No Conocida', null);
            $outMessage->addProcessError($processError);
        }

        // Envia los resultados a traves del DTO
        $data['data'] = &$this->responseProcessor->process($this->DTO);
        $this->load->view($this->getView(), $data);

    }

}
