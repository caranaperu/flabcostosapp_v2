<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los productos que no es mas
 * que un registro de insumos pero con menos datos requeridos..
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.2
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ProductoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @inheritdoc
     */
    protected function getDeleteRecordQuery($id, int $versionId) : string {
        return 'select * from ( select sp_insumo_delete_record(' . $id . ',null,' . $versionId . ')  as updins) as ans where updins is not null';

    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  ProductoModel  */
        return 'insert into tb_insumo (insumo_tipo,insumo_codigo,insumo_descripcion,taplicacion_entries_id,tpresentacion_codigo,'.
                'insumo_merma,insumo_precio_mercado,moneda_codigo_costo,activo,usuario) values(' .
        '\'' .
        $record->get_insumo_tipo() . '\',\'' .
        $record->get_insumo_codigo() . '\',\'' .
        $record->get_insumo_descripcion() . '\',' .
        $record->get_taplicacion_entries_id() . ',\'' .
        $record->get_tpresentacion_codigo() . '\',' .
        $record->get_insumo_merma() . ',' .
        $record->get_insumo_precio_mercado() . ',\'' .
        $record->get_moneda_codigo_costo() . '\',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {

        if ($subOperation == 'fetchProductoForSimpleList') {
            $sql = 'select insumo_id,insumo_codigo,insumo_descripcion from tb_insumo where insumo_tipo = \'PR\' and activo = TRUE';

            $where = $constraints->getFilterFieldsAsString();
            if (strlen($where) > 0) {
                $sql .= ' and '.$where;
            }

        } else {
            // Si la busqueda permite buscar solo activos e inactivos
            $sql = $this->_getFecthNormalized();

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where ins."activo"=TRUE ';
            }

            $where = $constraints->getFilterFieldsAsString();
            if (strlen($where) > 0) {
                $sql .= ' and '.$where;
            }
        }


        if (isset($constraints)) {
            $orderby = $constraints->getSortFieldsAsString();
            if ($orderby !== NULL) {
                $sql .= ' order by '.$orderby;
            }
        }


        // Chequeamos paginacion
        $startRow = $constraints->getStartRow();
        $endRow = $constraints->getEndRow();

        if ($endRow > $startRow) {
            $sql .= ' LIMIT '.($endRow - $startRow).' OFFSET '.$startRow;
        }
        $sql = str_replace('like', 'ilike', $sql);

       // echo $sql;
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL,string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' where insumo_id =  \'' . $code . '\'';
        } else {
            $sql =  'select insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,taplicacion_entries_id,tpresentacion_codigo,'.
                'insumo_merma,insumo_precio_mercado,moneda_codigo_costo,activo,' .
                'xmin as "versionId" from tb_insumo where insumo_id =  \'' . $code . '\'';
        }
        return $sql;
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  ProductoModel  */

        return 'update tb_insumo set insumo_tipo=\''.$record->get_insumo_tipo().'\','.
        'insumo_codigo=\'' . $record->get_insumo_codigo() . '\','.
        'insumo_descripcion=\'' . $record->get_insumo_descripcion() . '\',' .
        'taplicacion_entries_id=' . $record->get_taplicacion_entries_id() . ',' .
        'tpresentacion_codigo=\'' . $record->get_tpresentacion_codigo() . '\',' .
        'insumo_merma=' . $record->get_insumo_merma() . ',' .
        'insumo_precio_mercado=' . $record->get_insumo_precio_mercado() . ',' .
        'moneda_codigo_costo=\'' . $record->get_moneda_codigo_costo() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "insumo_id" = ' . $record->get_insumo_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'select insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,te.taplicacion_entries_id as taplicacion_entries_id,'.
                'ins.tpresentacion_codigo,tpresentacion_descripcion,te.taplicacion_entries_descripcion,'.
                'insumo_merma,'.
                 'case when insumo_tipo = \'PR\' then (select fn_get_producto_costo(insumo_id, now()::date)) else -1.00 end as insumo_costo,'.
                'insumo_precio_mercado,tp.tpresentacion_cantidad_costo,moneda_codigo_costo,mn.moneda_descripcion,mn.moneda_simbolo,ins.activo,ins.xmin as "versionId" '.
            'from  tb_insumo ins '.
            'inner join tb_tpresentacion tp on tp.tpresentacion_codigo = ins.tpresentacion_codigo '.
            'inner join tb_taplicacion_entries te on te.taplicacion_entries_id = ins.taplicacion_entries_id '.
            'inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_insumo_insumo_id_seq\')';
    }
}
