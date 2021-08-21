<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO para el manejo de la cabecera de la relacion tipo aplicacion-procesos
 *
 * @version 1.00
 * @since 25-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
class TipoAplicacionProcesosDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_taplicacion_procesos WHERE taplicacion_procesos_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string
    {
        /* @var $record  TipoAplicacionProcesosModel */
        return 'insert into tb_taplicacion_procesos (taplicacion_codigo,taplicacion_procesos_fecha_desde,activo,usuario) values(\'' .
        $record->get_taplicacion_codigo() . '\',\'' .
        $record->get_taplicacion_procesos_fecha_desde() . '\',\'' .
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
            $sql = 'SELECT taplicacion_procesos_id,taplicacion_codigo,taplicacion_procesos_fecha_desde,activo,xmin AS "versionId" ' .
                'FROM  tb_taplicacion_procesos pd ';
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
     /*   if ($subOperation == 'fetchJoined') {
            $sql = str_replace('"empresa_id"', 'pd.empresa_id', $sql);
        }
*/
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
            $sql .= ' WHERE taplicacion_procesos_id = ' . $code;
        } else {
            $sql =  'SELECT taplicacion_procesos_id,taplicacion_codigo,taplicacion_procesos_fecha_desde,activo,xmin AS "versionId" ' .
            'FROM tb_taplicacion_procesos WHERE taplicacion_procesos_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string
    {

        /* @var $record  TipoAplicacionProcesosModel */
        
        return 'update tb_taplicacion_procesos set taplicacion_procesos_id=' . $record->get_taplicacion_procesos_id() . ',' .
        'taplicacion_codigo=\'' . $record->get_taplicacion_codigo() . '\',' .
        'taplicacion_procesos_fecha_desde=\'' . $record->get_taplicacion_procesos_fecha_desde() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "taplicacion_procesos_id" = ' . $record->get_taplicacion_procesos_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT taplicacion_procesos_id,pd.taplicacion_codigo,i.taplicacion_descripcion,taplicacion_procesos_fecha_desde,pd.activo,pd.xmin AS "versionId" 
                FROM  tb_taplicacion_procesos pd
                LEFT JOIN  tb_taplicacion i on i.taplicacion_codigo = pd.taplicacion_codigo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_taplicacion_procesos_taplicacion_procesos_id_seq\')';
    }
}