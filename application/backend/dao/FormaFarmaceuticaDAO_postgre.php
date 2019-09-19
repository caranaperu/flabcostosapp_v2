<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las formas farmaceuticas
 *
 * @author  $Author: aranape $
 * @since   04-MAR-2019
 * @history ''
 *
 */
class FormaFarmaceuticaDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_ffarmaceutica where ffarmaceutica_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @inheritdoc
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) : string {
        /* @var $record  TipoInsumoModel  */
        return 'insert into tb_ffarmaceutica (ffarmaceutica_codigo,ffarmaceutica_descripcion,ffarmaceutica_protected,'
        . 'activo,usuario) values(\'' .
        $record->get_ffarmaceutica_codigo() . '\',\'' .
        $record->get_ffarmaceutica_descripcion() . '\',' .
        ($record->get_ffarmaceutica_protected() != TRUE ? '0' : '1') . '::boolean,\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';
    }

    /**
     * @inheritdoc
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select ffarmaceutica_codigo,ffarmaceutica_descripcion,ffarmaceutica_protected,activo,xmin as "versionId" from  tb_ffarmaceutica ';

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where "activo"=TRUE ';
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
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation );
    }

    /**
     * @inheritdoc
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, string $subOperation = NULL) : string {
        // el campo ffarmaceutica_protected es mapeado a 1 o 0 dado que la conversion a booleana del php no funcionaria
        // correctamente.
        return 'select ffarmaceutica_codigo,ffarmaceutica_descripcion,case when ffarmaceutica_protected = \'f\' then \'0\' else \'1\' end as ffarmaceutica_protected,activo,' .
                'xmin as "versionId" from tb_ffarmaceutica where ffarmaceutica_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @inheritdoc
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) : string {
        /* @var $record  FormaFarmaceuticaModel  */

        return 'update tb_ffarmaceutica set ffarmaceutica_codigo=\'' . $record->get_ffarmaceutica_codigo() . '\','.
        'ffarmaceutica_descripcion=\'' . $record->get_ffarmaceutica_descripcion() . '\',' .
        'ffarmaceutica_protected=\'' . ($record->get_ffarmaceutica_protected() != TRUE ? '0' : '1') . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "ffarmaceutica_codigo" = \'' . $record->get_ffarmaceutica_codigo() . '\'  and xmin =' . $record->getVersionId();

    }

}
