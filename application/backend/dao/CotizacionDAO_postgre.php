<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO para el manejo de la cabecera de cotizacion.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class CotizacionDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
{

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     *
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE)
    {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @{inheritdoc}
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string
    {
        return 'DELETE FROM tb_cotizacion WHERE cotizacion_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  CotizacionModel */
        return 'insert into tb_cotizacion (empresa_id,cliente_id,cotizacion_es_cliente_real,cotizacion_cerrada,cotizacion_numero,moneda_codigo,cotizacion_fecha,'.
        'activo,usuario) values(' .
        $record->get_empresa_id() . ',' .
        $record->get_cliente_id() . ',' .
        ($record->get_cotizacion_es_cliente_real() == true ? 1 : 0). '::boolean,' .
        ($record->get_cotizacion_cerrada() == true ? 1 : 0). '::boolean,' .
        '(select fn_get_cotizacion_next_id()),\'' .
        $record->get_moneda_codigo() . '\',\'' .
        $record->get_cotizacion_fecha() . '\',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {

        if ($subOperation == 'fetchJoined') {
            $sql = $this->_getFecthNormalized();
        } else {
            $sql = 'SELECT cotizacion_id,empresa_id,cliente_id,cotizacion_es_cliente_real,cotizacion_numero,moneda_codigo,cotizacion_fecha,cotizacion_cerrada,activo,xmin AS "versionId" ' .
                'FROM  tb_cotizacion pd ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            // Mapeamos las virtuales a los campos reales
          //  $where = str_replace('"unidad_medida_descripcion_o"', 'um1.unidad_medida_descripcion', $where);

            if ($this->activeSearchOnly == TRUE) {
                $sql .= ' and ' . $where;
            } else {
                $sql .= ' where ' . $where;
            }
        }

        if (isset($constraints)) {
            $orderby = $constraints->getSortFieldsAsString();
            if ($orderby !== NULL) {
                $sql .= ' order by ' . $orderby;
            }
        }

        // Chequeamos paginacion
        $startRow = $constraints->getStartRow();
        $endRow = $constraints->getEndRow();

        if ($endRow > $startRow) {
            $sql .= ' LIMIT ' . ($endRow - $startRow) . ' OFFSET ' . $startRow;
        }

        $sql = str_replace('like', 'ilike', $sql);

        // Si es fetchjoined ajustamos el query
        if ($subOperation == 'fetchJoined') {
            $sql = str_replace('"empresa_id"', 'pd.empresa_id', $sql);
            $sql = str_replace('"cliente_razon_social"', 'coalesce(cliente_razon_social,empresa_razon_social)', $sql);
        }

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string
    {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string
    {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' WHERE cotizacion_id = ' . $code;
        } else {
            $sql =  'SELECT cotizacion_id,empresa_id,cliente_id,cotizacion_es_cliente_real,cotizacion_numero,moneda_codigo,cotizacion_fecha,cotizacion_cerrada,activo,xmin AS "versionId" ' .
            'FROM tb_cotizacion WHERE cotizacion_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  CotizacionModel */
        
        return 'update tb_cotizacion set cotizacion_id=' . $record->get_cotizacion_id() . ',' .
        'empresa_id=' . $record->get_empresa_id() . ',' .
        'cliente_id=' . $record->get_cliente_id() . ',' .
        'cotizacion_es_cliente_real=' . ($record->get_cotizacion_es_cliente_real() == true ? 1 : 0). '::boolean,' .
        'cotizacion_cerrada=' . ($record->get_cotizacion_cerrada() == true ? 1 : 0). '::boolean,' .
        'cotizacion_numero=' . $record->get_cotizacion_numero() . ',' .
        'moneda_codigo=\'' . $record->get_moneda_codigo() . '\',' .
        'cotizacion_fecha=\'' . $record->get_cotizacion_fecha() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "cotizacion_id" = ' . $record->get_cotizacion_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT cotizacion_id,pd.empresa_id,pd.cliente_id,cotizacion_es_cliente_real,cotizacion_cerrada,
                    coalesce(cliente_razon_social,empresa_razon_social) as cliente_razon_social,
                    cotizacion_numero,pd.moneda_codigo,moneda_descripcion,cotizacion_fecha,pd.activo,pd.xmin AS "versionId" 
                FROM  tb_cotizacion pd
                INNER JOIN tb_moneda mon on mon.moneda_codigo = pd.moneda_codigo  
                LEFT JOIN  tb_cliente cl on cl.cliente_id = pd.cliente_id
                LEFT JOIN  tb_empresa em on em.empresa_id = pd.cliente_id ';

        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_cotizacion_cotizacion_id_seq\')';
    }
}