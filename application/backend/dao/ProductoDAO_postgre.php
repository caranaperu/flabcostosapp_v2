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
        return 'insert into tb_insumo (empresa_id,insumo_tipo,insumo_codigo,insumo_descripcion,'.
                'unidad_medida_codigo_costo,insumo_merma,insumo_precio_mercado,moneda_codigo_costo,activo,usuario) values(' .
        $record->get_empresa_id() . ',\'' .
        $record->get_insumo_tipo() . '\',\'' .
        $record->get_insumo_codigo() . '\',\'' .
        $record->get_insumo_descripcion() . '\',\'' .
        $record->get_unidad_medida_codigo_costo() . '\',' .
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
        // Si se esta solicitando la lista de insumos/productos para los posibles valores a
        // seleccionar para un nuevo item extraemos a que producto principal pertenece.
        // Si este valor existe sera usado para filtrar.
        if ($subOperation == 'fetchForCotizacionDetalle') {
            $insumo_id = $constraints->getFilterField('insumo_id');
            $insumo_descripcion = $constraints->getFilterField('insumo_descripcion');
            $cotizacion_id = $constraints->getFilterField('cotizacion_id');

            $constraints->removeFilterField('cotizacion_id');
            $constraints->removeFilterField('insumo_id');
            $constraints->removeFilterField('insumo_descripcion');

            // Chequeamos paginacion
            $startRow = $constraints->getStartRow();
            $endRow = $constraints->getEndRow();

            // Si no se indica el id del producto principal se busca el item-insumo basado en el
            // insumo_id del item.
            // De lo contrario se buscara todos los insumos/productos posibles segun el tipo de empresa.
            $sql = 'select insumo_id,insumo_codigo,insumo_descripcion,unidad_medida_codigo,unidad_medida_descripcion,'.
                'moneda_simbolo,precio_original,precio_cotizar  ';
            if (isset($insumo_descripcion)) {
                if ($endRow > $startRow) {
                    $sql .= 'from sp_get_productos_for_cotizacion('.$cotizacion_id.',null,\''.$insumo_descripcion.'\','.($endRow - $startRow).', '.$startRow.') ';
                } else {
                    $sql .= 'from sp_get_productos_for_cotizacion('.$cotizacion_id.',null,\''.$insumo_descripcion.'\',null,null) ';
                }
            } else if (!isset($insumo_id)) {
                $sql .= 'from sp_get_productos_for_cotizacion('.$cotizacion_id.',null,null,null,null) ';
            } else {
                if ($endRow > $startRow) {
//                    $sql .= 'from sp_get_productos_for_cotizacion('.$cotizacion_id.','.$insumo_id.',null,\''.(!isset($insumo_descripcion) ? null : $insumo_descripcion).'\',' .($endRow - $startRow).', '.$startRow.') ';
                    $sql .= 'from sp_get_productos_for_cotizacion('.$cotizacion_id.','.$insumo_id.',null,' .($endRow - $startRow).', '.$startRow.') ';
                } else {
                    $sql .= 'from sp_get_productos_for_cotizacion('.$cotizacion_id.','.$insumo_id.',null,null,null) ';
                }
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
                // Mapeamos las virtuales a los campos reales
                $where = str_replace('"unidad_medida_descripcion_ingreso"', 'umi.unidad_medida_descripcion', $where);
                $where = str_replace('"unidad_medida_descripcion_costo"', 'umc.unidad_medida_descripcion', $where);

                $sql .= ' and '.$where;
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

        }
     //   echo $sql;
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
            $sql =  'select empresa_id,insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,'.
                'unidad_medida_codigo_costo,insumo_merma,inusmo_precio_mercado,moneda_codigo_costo,activo,' .
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

        return 'update tb_insumo set empresa_id='.$record->get_empresa_id() .',' .
        'insumo_tipo=\''.$record->get_insumo_tipo().'\','.
        'insumo_codigo=\'' . $record->get_insumo_codigo() . '\','.
        'insumo_descripcion=\'' . $record->get_insumo_descripcion() . '\',' .
        'insumo_merma=' . $record->get_insumo_merma() . ',' .
        'insumo_precio_mercado=' . $record->get_insumo_precio_mercado() . ',' .
        'unidad_medida_codigo_costo=\'' . $record->get_unidad_medida_codigo_costo() . '\',' .
        'moneda_codigo_costo=\'' . $record->get_moneda_codigo_costo() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "insumo_id" = ' . $record->get_insumo_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'select empresa_id,insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,ins.unidad_medida_codigo_costo,'.
                'umc.unidad_medida_descripcion as unidad_medida_descripcion_costo,'.
                'insumo_merma,'.
                 'case when insumo_tipo = \'PR\' then (select fn_get_producto_costo(insumo_id, now()::date)) else -1.00 end as insumo_costo,'.
                'insumo_precio_mercado,moneda_codigo_costo,mn.moneda_descripcion,mn.moneda_simbolo,ins.activo,ins.xmin as "versionId" '.
            'from  tb_insumo ins '.
            'inner join tb_unidad_medida umc on umc.unidad_medida_codigo = ins.unidad_medida_codigo_costo '.
            'inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string
    {
        return 'SELECT currval(\'tb_insumo_insumo_id_seq\')';
    }
}
