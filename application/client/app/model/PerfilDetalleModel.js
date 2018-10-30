/**
 * Definicion del modelo visual para el ingreso / modificacion
 * del detalle de los perfiles , para efectos de grabacion solo se requieren
 * perfdet_id,perfil_codigo,perfdet_accessdef los demas son para efectos
 * de apoyo a la edicion.
 *
 * Observese el mapeo para los booleanos
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.RestDataSource.create({
    ID: "mdl_perfil_detalle",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
   // disableQueuing: true,
    //  cacheAllData : true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "perfdet_id", title: "id", type: 'integer', primaryKey: "true", canEdit: "false", required: true},
        {name: "perfil_id", title: "perfil_id", required: true},
        {name: "perfdet_accessdef", title: "Permisos"},
        {name: "perfdet_accleer", title: "Leer", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_perfil_detalle._getBooleanFieldValue(v);
            }},
        {name: "perfdet_accagregar", title: "Agregar", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_perfil_detalle._getBooleanFieldValue(v);
            }},
        {name: "perfdet_accactualizar", title: "Actualizar", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_perfil_detalle._getBooleanFieldValue(v);
            }},
        {name: "perfdet_acceliminar", title: "Eliminar", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_perfil_detalle._getBooleanFieldValue(v);
            }},
        {name: "perfdet_accimprimir", title: "Imprimir", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_perfil_detalle._getBooleanFieldValue(v);
            }},
        {name: "menu_id", canEdit: false},
        {name: "menu_descripcion", title: "Opcion", canEdit: false, required: true},
        {name: "menu_accesstype", canEdit: false},
        {name: "menu_parent_id", canEdit: false, foreignKey: "mdl_perfil_detalle.menu_id", rootValue: "0"}
    ],
    fetchDataURL: glb_dataUrl + 'perfilDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'perfilDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'perfilDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'perfilDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"}
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function( value) {
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true') {
            return false;
        } else {
            return true;
        }

    },
    /**
     * Dado que cuando se edita en grilla no se pasan todos los valores
     * y estos se conservan en _oldValues , copiamos todos los
     * de oldValues a la data a transmitir siempre que oldvalues este
     * este definida , lo cual sucede solo para el update.
     */
    transformRequest: function(dsRequest) {
        if (dsRequest.operationType === 'add' || dsRequest.operationType === 'update') {
            var data = dsRequest.data;
            //  var data = isc.addProperties({}, dsRequest.data);
            // Solo para los valores que se encuentran en oldValues de no existir
            // se deja como esta.
            for (var fieldName in dsRequest.oldValues) {
                if (data[fieldName] === undefined) {
                    data[fieldName] = dsRequest.oldValues[fieldName];
                }
                else if (data[fieldName] === null) {
                    data[fieldName] = '';
                }
            }
        }
        return this.Super("transformRequest", arguments);

    },
    /**
     * Seteamos datos necesarios para la parte visual que no son parte del modelo
     * retornado tras un add o update ya que dicos campos no son parte del registro
     * fisico.
     */
    transformResponse: function(dsResponse, dsRequest, data) {
        var dsResponse = this.Super("transformResponse", arguments);
        // Para el update se setea el parent id y la descripcion del menu ya que el update
        // solo retorna los valores sobre el registro de item de perfil no
        // los datos requeridos para la parte visual.
        if (dsRequest.operationType === 'update' && data.response.status >= 0 && dsResponse.data[0] !== null) {
            dsResponse.data[0].menu_parent_id = dsRequest.data.menu_parent_id;
            dsResponse.data[0].menu_descripcion = dsRequest.data.menu_descripcion;
        }
        return dsResponse;
    }
});