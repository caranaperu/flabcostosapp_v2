<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para los reportes de procedimientos.
 *
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: reportProcedimientosController.php 312 2013-12-11 17:09:17Z aranape $
 * @history ''
 *
 * $Date: 2013-12-11 12:09:17 -0500 (mié, 11 dic 2013) $
 * $Rev: 312 $
 */
class RptCostosListController extends TSLReportJasperController {

    public function __construct() {
        parent::__construct();
    }

    protected function getReportURI() : string {
        return '/SistemaCostos/cstr_CostosListReport';
    }

    protected function getTmpOutputDirectory() : string {
        return '/var/www/tmp/';
    }

    protected function &getInputReportParamsList() : array {
        $costos_list_id = $this->input->get_post('p_costos_list_id');
        $params = array('p_costos_list_id', 'p_forExcel');
        return $params;
    }

    /**
     * Pagina index para este controlador , maneja todos los casos , lectura, lista
     * etc.
     */
    public function index() {
        // Leera los datos del tipo de contribuyentes por default si no se envia
        // una operacion especifica.
        $op = $_REQUEST['op'];
        if (!isset($op) || $op == 'costoslist') {
            $this->executeReport('jasperadmin', 'jasperadmin', !isset($_REQUEST['format']) ? 'PDF' : $_REQUEST['format']);
        } else {
            $this->outputError('Solicitud de Reporte no conocida');
        }
    }

}
