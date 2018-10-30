<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los insumos.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.2
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        /* @var $record  InsumoModel  */
        return 'insert into tb_insumo (empresa_id,insumo_tipo,insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,unidad_medida_codigo_ingreso,'.
                'unidad_medida_codigo_costo,insumo_merma,insumo_costo,insumo_precio_mercado,moneda_codigo_costo,activo,usuario) values(' .
        $record->get_empresa_id() . ',\'' .
        $record->get_insumo_tipo() . '\',\'' .
        $record->get_insumo_codigo() . '\',\'' .
        $record->get_insumo_descripcion() . '\',\'' .
        $record->get_tinsumo_codigo() . '\',\'' .
        $record->get_tcostos_codigo() . '\',\'' .
        $record->get_unidad_medida_codigo_ingreso() . '\',\'' .
        $record->get_unidad_medida_codigo_costo() . '\',' .
        $record->get_insumo_merma() . ',' .
        $record->get_insumo_costo() . ',' .
        $record->get_insumo_precio_mercado() . ',\'' .
        $record->get_moneda_codigo_costo() . '\',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si se esta solicitando la lista de insumos/productos para los posibles valores a
        // seleccionar para un nuevo item extraemos a que producto principal pertenece.
        // Si este valor existe sera usado para filtrar.

        if ($subOperation == 'fetchForProductoDetalle') {
            $insumo_id_origen = $constraints->getFilterField('insumo_id_origen');
            $insumo_id = $constraints->getFilterField('insumo_id');
            $insumo_descripcion = $constraints->getFilterField('insumo_descripcion');

            $constraints->removeFilterField('insumo_id_origen');
            $constraints->removeFilterField('insumo_id');
            $constraints->removeFilterField('insumo_descripcion');

            // Chequeamos paginacion
            $startRow = $constraints->getStartRow();
            $endRow = $constraints->getEndRow();

            // Si no se indica el id del producto principal se busca el item-insumo basado en el
            // insumo_id del item.
            // De lo contrario se buscara todos los insumos/productos posibles segun el tipo de empresa.
            $sql = 'select empresa_id,empresa_razon_social,insumo_id,insumo_tipo,insumo_codigo,'.
                'insumo_descripcion,unidad_medida_codigo_costo,insumo_merma,insumo_costo,'.
                'insumo_precio_mercado,moneda_simbolo,tcostos_indirecto ';

            if (!isset($insumo_id_origen)) {
                $sql .= 'from sp_get_insumos_for_producto_detalle(null,'.$insumo_id.',null, null, null) ';

            } else {
                if ($endRow > $startRow) {
                    $sql .= 'from sp_get_insumos_for_producto_detalle('.$insumo_id_origen.',null,\''.(!isset($insumo_descripcion) ? null : $insumo_descripcion).'\',' .($endRow - $startRow).', '.$startRow.') ';
                } else {
                    $sql .= 'from sp_get_insumos_for_producto_detalle('.$insumo_id_origen.',null,\''.(!isset($insumo_descripcion) ? null : $insumo_descripcion).'\', null, null) ';
                }
            }

        } else if ($subOperation == 'fetchForInsumosCostos') {
            $insumo_id = $constraints->getFilterField('insumo_id');
            $fecha_desde = $constraints->getFilterField('p_date_from');
            $fecha_hasta = $constraints->getFilterField('p_date_to');

            $constraints->removeFilterField('insumo_id');
            $constraints->removeFilterField('p_date_from');
            $constraints->removeFilterField('p_date_to');

            // Chequeamos paginacion
            $startRow = $constraints->getStartRow();
            $endRow = $constraints->getEndRow();

            $sql = 'select insumo_codigo,insumo_descripcion,insumo_history_fecha,insumo_history_id,
                    tinsumo_descripcion,tcostos_descripcion,unidad_medida_descripcion,insumo_merma,
                    insumo_costo,moneda_costo_descripcion,insumo_precio_mercado ';

            if ($endRow > $startRow) {
                if ($fecha_desde && $fecha_hasta) {
                    $sql .= 'from sp_get_historico_costos_for_insumo ('.$insumo_id.',\''.$fecha_desde.'\',\''.$fecha_hasta.'\','.($endRow - $startRow).', '.$startRow.') ';
                } else {
                    $sql .= 'from sp_get_historico_costos_for_insumo ('.$insumo_id.',null,null,'.($endRow - $startRow).', '.$startRow.') ';
                }
            } else {
                if ($fecha_desde && $fecha_hasta) {
                    $sql .= 'from sp_get_historico_costos_for_insumo ('.$insumo_id.',\''.$fecha_desde.'\',\''.$fecha_hasta.'\',null,null)';
                } else {
                    $sql .= 'from sp_get_historico_costos_for_insumo ('.$insumo_id.',null,null,null,null)';
                }
            }

        } else {
            // Si la busqueda permite buscar solo activos e inactivos
            if ($subOperation == 'fetchJoined') {
                $sql = $this->_getFecthNormalized();
            } else if ($subOperation == 'fetchSimpleList') {
                $sql =  'select empresa_id,insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion from tb_insumo ins ';
            } else if ($subOperation == 'fetchForInsumosUsedBy') {
                $sql =  'SELECT  i.insumo_id,i.insumo_codigo,i.insumo_descripcion,e.empresa_razon_social 
                          FROM tb_producto_detalle ins
                          INNER JOIN tb_insumo i ON i.insumo_id = ins.insumo_id_origen
                          INNER JOIN tb_empresa e on e.empresa_id = i.empresa_id ';
            }else {
                $sql =  'select empresa_id,insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,'.
                    'unidad_medida_codigo_ingreso,unidad_medida_codigo_costo,insumo_merma,insumo_costo,insumo_precio_mercado,moneda_codigo_costo,activo,' .
                    'xmin as "versionId" from tb_insumo ins ';
            }

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where ins."activo"=TRUE ';
            }
            if (isset($constraints)) {
                $where = $constraints->getFilterFieldsAsString();
                if (strlen($where) > 0) {
                    if ($subOperation == 'fetchForInsumosUsedBy') {
                        $where = str_replace('"insumo_id"', 'ins.insumo_id', $where);
                    } else {
                        // Mapeamos las virtuales a los campos reales
                        $where = str_replace('"unidad_medida_descripcion_ingreso"', 'umi.unidad_medida_descripcion', $where);
                        $where = str_replace('"unidad_medida_descripcion_costo"', 'umc.unidad_medida_descripcion', $where);
                    }

                    if ($this->activeSearchOnly == TRUE) {
                        $sql .= ' and '.$where;
                    } else {
                        $sql .= ' where '.$where;
                    }
                }

                $orderby = $constraints->getSortFieldsAsString();
                if ($orderby !== NULL) {
                    $sql .= ' order by '.$orderby;
                }


                // Chequeamos paginacion
                $startRow = $constraints->getStartRow();
                $endRow = $constraints->getEndRow();

                if ($endRow > $startRow) {
                    $sql .= ' LIMIT '.($endRow - $startRow).' OFFSET '.$startRow;
                }

            }


            $sql = str_replace('like', 'ilike', $sql);
        }
        //echo $sql;
        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints , $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' where insumo_id =  \'' . $code . '\'';
        } else {
            $sql =  'select empresa_id,insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,'.
                'unidad_medida_codigo_ingreso,unidad_medida_codigo_costo,insumo_merma,insumo_costo,insumo_precio_mercado,moneda_codigo_costo,activo,' .
                'xmin as "versionId" from tb_insumo where insumo_id =  \'' . $code . '\'';
        }
        return $sql;
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  InsumoModel  */

        return 'update tb_insumo set empresa_id='.$record->get_empresa_id().','.
        'insumo_tipo=\''.$record->get_insumo_tipo().'\','.
        'insumo_codigo=\'' . $record->get_insumo_codigo() . '\','.
        'insumo_descripcion=\'' . $record->get_insumo_descripcion() . '\',' .
        'tinsumo_codigo=\'' . $record->get_tinsumo_codigo() . '\',' .
        'tcostos_codigo=\'' . $record->get_tcostos_codigo() . '\',' .
        'unidad_medida_codigo_ingreso=\'' . $record->get_unidad_medida_codigo_ingreso() . '\',' .
        'unidad_medida_codigo_costo=\'' . $record->get_unidad_medida_codigo_costo() . '\',' .
        'insumo_merma=' . $record->get_insumo_merma() . ',' .
        'insumo_costo=' . $record->get_insumo_costo() . ',' .
        'insumo_precio_mercado=' . $record->get_insumo_precio_mercado() . ',' .
        'moneda_codigo_costo=\'' . $record->get_moneda_codigo_costo() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "insumo_id" = ' . $record->get_insumo_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'select empresa_id,insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,ins.tinsumo_codigo,ti.tinsumo_descripcion,ins.unidad_medida_codigo_ingreso,ins.unidad_medida_codigo_costo,'.
                'umi.unidad_medida_descripcion as unidad_medida_descripcion_ingreso,umc.unidad_medida_descripcion as unidad_medida_descripcion_costo,ins.tcostos_codigo,tcostos_descripcion ,'.
                'tcostos_indirecto,insumo_merma,'.
                 'case when insumo_tipo = \'PR\' then (select fn_get_producto_costo(insumo_id, now()::date)) else insumo_costo end as insumo_costo,'.
                'insumo_precio_mercado,moneda_codigo_costo,mn.moneda_descripcion,mn.moneda_simbolo,ins.activo,ins.xmin as "versionId" '.
            'from  tb_insumo ins '.
            'inner join tb_unidad_medida umi on umi.unidad_medida_codigo = ins.unidad_medida_codigo_ingreso '.
            'inner join tb_unidad_medida umc on umc.unidad_medida_codigo = ins.unidad_medida_codigo_costo '.
            'inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo '.
            'inner join tb_tinsumo ti on ti.tinsumo_codigo = ins.tinsumo_codigo '.
            'inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_insumo_insumo_id_seq\')';
    }
}
