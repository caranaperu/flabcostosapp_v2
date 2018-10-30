<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para la la definicion de los
 * datos de las empresas , como nombre,dieccion , etc-
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EmpresaDAO_postgre.php 208 2014-06-23 22:48:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 208 $
 */
class EmpresaDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_empresa where empresa_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /**
         * @var EmpresaModel $record
         */
        $sql = 'insert into tb_empresa (empresa_razon_social,tipo_empresa_codigo,empresa_ruc,empresa_direccion,' .
                'empresa_telefonos,empresa_fax,empresa_correo,activo,usuario) values(' .
                '\'' . $record->get_empresa_razon_social() . '\',' .
                '\'' . $record->get_tipo_empresa_codigo() . '\',' .
                '\'' . $record->get_empresa_ruc() . '\',' .
                '\'' . $record->get_empresa_direccion() . '\',' .
                '\'' . $record->get_empresa_telefonos() . '\',' .
                '\'' . $record->get_empresa_fax() . '\',' .
                '\'' . $record->get_empresa_correo() . '\',' .
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

        if ($subOperation == 'fetchJoined') {
            $sql = $this->_getFecthNormalized();
        }  else {
            // Si la busqueda permite buscar solo activos e inactivos
            $sql = 'select empresa_id,empresa_razon_social,tipo_empresa_codigo,empresa_ruc,empresa_direccion,'.
                'empresa_telefonos,empresa_fax,empresa_correo,activo,xmin as "versionId" from  tb_empresa ep';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where ep.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
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
            $sql .= ' WHERE empresa_id = ' . $code;
        } else {
            $sql =  'select empresa_id,empresa_razon_social,tipo_empresa_codigo,empresa_ruc,empresa_direccion,' .
                'empresa_telefonos,empresa_fax,empresa_correo,activo,xmin as "versionId" from tb_empresa where empresa_id = ' .$code;
        }

        return $sql;
    }

    /**
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  EmpresaModel  */
        $sql = 'update tb_empresa set empresa_razon_social=\'' . $record->get_empresa_razon_social() . '\'' .
                ',empresa_ruc=\'' . $record->get_empresa_ruc() . '\'' .
                ',tipo_empresa_codigo=\'' . $record->get_tipo_empresa_codigo() . '\'' .
                ',empresa_direccion=\'' . $record->get_empresa_direccion() . '\'' .
                ',empresa_telefonos=\'' . $record->get_empresa_telefonos() . '\'' .
                ',empresa_fax=\'' . $record->get_empresa_fax() . '\'' .
                ',empresa_correo=\'' . $record->get_empresa_correo() . '\'' .
                ',"activo"=\'' . $record->getActivo() . '\'' .
                ',"usuario_mod"=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "empresa_id" = \'' . $record->getId() . '\'  and xmin =' . $record->getVersionId();
        return $sql;
    }

    private function _getFecthNormalized() {
        $sql ='select empresa_id,empresa_razon_social,ep.tipo_empresa_codigo,tipo_empresa_descripcion,empresa_ruc,empresa_direccion,' .
            'empresa_telefonos,empresa_fax,empresa_correo,ep.activo,ep.xmin as "versionId" '.
            'from  tb_empresa ep '.
            'inner join tb_tipo_empresa te on te.tipo_empresa_codigo = ep.tipo_empresa_codigo';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) : string {
        return 'SELECT currval(\'tb_empresa_empresa_id_seq\')';
    }

}
