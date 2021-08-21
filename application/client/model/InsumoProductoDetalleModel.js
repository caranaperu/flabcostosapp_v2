/**
 * Definicion del modelo para los insumos/productos que pueden seleccionarse como
 * componentes de un principal en una formulacion de producto.
 *
 * Solo se acepta querys no se graba a traves de este modelo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_insumo_producto_detalle",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "insumo_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {name: "insumo_tipo"},
        {
            name: "insumo_codigo",
            title: "Codigo",
        },
        {
            name: "insumo_descripcion",
            title: "Descripcion"
        },
        {name: "empresa_id"},
        {
            name: "empresa_razon_social",
            title: 'Origen'
        },
        {name: "unidad_medida_codigo_costo"},
        {name: "insumo_merma"},
        {name: "insumo_costo"},
        {name: "moneda_simbolo"},
        {
            name: "tcostos_indirecto",
            type: 'boolean',
            getFieldValue: function(r, v, f, fn) {
                return mdl_insumo_producto_detalle._getBooleanFieldValue(v);
            },
            required: true
        }
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        }
    ]
});