<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para la la definicion de los
 * datos de los clientes , como nombre,dieccion , etc-
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EmpresaDAO_postgre.php 208 2014-06-23 22:48:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 208 $
 */
class ClienteDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_cliente where cliente_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /**
         * @var ClienteModel $record
         */
        $sql = 'insert into tb_cliente (empresa_id,cliente_razon_social,tipo_cliente_codigo,cliente_ruc,cliente_direccion,' .
                'cliente_telefonos,cliente_fax,cliente_correo,activo,usuario) values(' .
                 $record->get_empresa_id() . ',' .
                '\'' . $record->get_cliente_razon_social() . '\',' .
                '\'' . $record->get_tipo_cliente_codigo() . '\',' .
                '\'' . $record->get_cliente_ruc() . '\',' .
                '\'' . $record->get_cliente_direccion() . '\',' .
                '\'' . $record->get_cliente_telefonos() . '\',' .
                '\'' . $record->get_cliente_fax() . '\',' .
                '\'' . $record->get_cliente_correo() . '\',' .
                '\'' . $record->getActivo() . '\',\'' . $record->getUsuario() . '\')';
        return $sql;
    }

    /**
     * Siempre debe devolver un de haber mas de uno , la data habria
     * sido manipulada externamente.
     *
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        $startRow = 0;
        $endRow = 0;
        $orderby = NULL;

        if ($subOperation == 'fetchForCotizacion') {
            $empresa_id = $constraints->getFilterField('empresa_id');
            $cliente_razon_social = $constraints->getFilterField('cliente_razon_social');
            $constraints->removeFilterField('insumo_descripcion');
            $constraints->removeFilterField('empresa_id');

            // Chequeamos paginacion
            if (isset($constraints)) {
                $startRow = $constraints->getStartRow();
                $endRow = $constraints->getEndRow();
            }

            $sql = 'SELECT cliente_id,cliente_razon_social,tipo_empresa_codigo ';

            if (!isset($empresa_id)) {
                $cliente_id = $constraints->getFilterField('cliente_id');
                $cotizacion_es_cliente_real = $constraints->getFilterField('cotizacion_es_cliente_real');

                $sql .= 'from sp_get_clientes_for_cotizacion(null,null,'.$cliente_id.','.$cotizacion_es_cliente_real.',null,null)';
            } else {
                // Si la busqueda permite buscar solo activos e inactivos
                if ($endRow > $startRow) {
                    $sql .= 'from sp_get_clientes_for_cotizacion('.$empresa_id.',\''.(!isset($cliente_razon_social) ? null : $cliente_razon_social).'\',NULL,NULL,'.($endRow - $startRow).', '.$startRow.')';
                } else {
                    $sql .= 'from sp_get_clientes_for_cotizacion('.$empresa_id.',\''.(!isset($cliente_razon_social) ? null : $cliente_razon_social).'\', NULL, NULL,NULL,NULL)';
                }
            }
        } else {
            if ($subOperation == 'fetchJoined') {
                $sql = $this->_getFecthNormalized();
            } else {
                // Si la busqueda permite buscar solo activos e inactivos
                $sql = 'select empresa_id,cliente_id,cliente_razon_social,tipo_cliente_codigo,cliente_ruc,cliente_direccion,'.'cliente_telefonos,cliente_fax,cliente_correo,activo,xmin as "versionId" from  tb_cliente ep';
            }

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where ep.activo=TRUE ';
            }


            if (isset($constraints)) {
                $where = $constraints->getFilterFieldsAsString();

                if (strlen($where) > 0) {
                    if ($this->activeSearchOnly == TRUE) {
                        $sql .= ' and '.$where;
                    } else {
                        $sql .= ' where '.$where;
                    }
                }

                // Order by
                $orderby = $constraints->getSortFieldsAsString();
                if ($orderby !== NULL) {
                    $sql .= ' order by '.$orderby;
                }

                // Chequeamos paginacion
                $startRow = $constraints->getStartRow();
                $endRow = $constraints->getEndRow();
            }



            if ($endRow > $startRow) {
                $sql .= ' LIMIT '.($endRow - $startRow).' OFFSET '.$startRow;
            }
            $sql = str_replace('like', 'ilike', $sql);
        }

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQuery($id, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' WHERE cliente_id = ' . $code;
        } else {
            $sql =  'select empresa_id,cliente_id,cliente_razon_social,tipo_cliente_codigo,cliente_ruc,cliente_direccion,' .
                'cliente_telefonos,cliente_fax,cliente_correo,activo,xmin as "versionId" from tb_cliente where cliente_id = ' .$code;
        }

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  ClienteModel  */
        $sql = 'update tb_cliente set empresa_id='.$record->get_empresa_id().
                ',cliente_razon_social=\'' . $record->get_cliente_razon_social() . '\'' .
                ',cliente_ruc=\'' . $record->get_cliente_ruc() . '\'' .
                ',tipo_cliente_codigo=\'' . $record->get_tipo_cliente_codigo() . '\'' .
                ',cliente_direccion=\'' . $record->get_cliente_direccion() . '\'' .
                ',cliente_telefonos=\'' . $record->get_cliente_telefonos() . '\'' .
                ',cliente_fax=\'' . $record->get_cliente_fax() . '\'' .
                ',cliente_correo=\'' . $record->get_cliente_correo() . '\'' .
                ',"activo"=\'' . $record->getActivo() . '\'' .
                ',"usuario_mod"=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "cliente_id" = \'' . $record->getId() . '\'  and xmin =' . $record->getVersionId();
        return $sql;
    }

    private function _getFecthNormalized() {
        $sql ='select empresa_id,cliente_id,cliente_razon_social,ep.tipo_cliente_codigo,tipo_cliente_descripcion,cliente_ruc,cliente_direccion,' .
            'cliente_telefonos,cliente_fax,cliente_correo,ep.activo,ep.xmin as "versionId" '.
            'from  tb_cliente ep '.
            'inner join tb_tipo_cliente te on te.tipo_cliente_codigo = ep.tipo_cliente_codigo';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string {
        return 'SELECT currval(\'tb_cliente_cliente_id_seq\')';
    }

}
