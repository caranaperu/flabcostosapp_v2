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
class RptHistoricoCostosController extends TSLReportKoolReportController {

    public function __construct() {
        parent::__construct();
    }


    protected function &getInputReportParamsList() : array {
        $params = array("from_date"=>$_REQUEST['from_date'],
                        "to_date"=>$_REQUEST['to_date'],
                        "insumo_id"=>$_REQUEST['insumo_id'],
                        "PARAM_toScreen"=>$_REQUEST['PARAM_toScreen'],
                        "PARAM_toExcel"=>$_REQUEST['PARAM_toExcel']
            );
        return $params;
    }

    /**
     * Pagina index para este controlador , maneja todos los casos , lectura, lista
     * etc.
     */
    public function index() {
        // Leera los datos del tipo dhttps://www.youtube.com/watch?v=K-KiKmE5Q-8e contribuyentes por default si no se envia
        // una operacion especifica.
        $op = $_REQUEST['op'];
        if (!isset($op) || $op == 'op_list_historico_costos') {
            $this->executeReport('', '', '');
        } else {
            $this->outputError('Solicitud de Reporte no conocida');
        }
    }

    protected function doReport(array $input_params, array $report_params) : bool {

        require_once dirname(__FILE__)."/../../views/reports/kr/FLabHistoricoCostosReport.php";

        $params = array(
            "from_date"=>$input_params['from_date'],
            "to_date"=>$input_params['to_date'],
            "insumo_id"=>$input_params['insumo_id'],
            "PARAM_toScreen"=>$report_params['PARAM_toScreen'],
            "PARAM_toExcel"=>$report_params['PARAM_toExcel']
        );

        $flabHistoricoCostosReport = new FLabHistoricoCostosReport($params);
        if (!isset($params["PARAM_toExcel"])) {
            $flabHistoricoCostosReport->run()->render("FLabHistoricoCostosReport");
        } else {
            ob_start();
            $flabHistoricoCostosReport->run();
            ob_clean();
            $flabHistoricoCostosReport->exportToExcel(array('dataStores'=>array('sql_historico_costos_detail')))
                ->toBrowser("HistoricoCostosReport.xlsx");

        }
        return true;
    }
}
