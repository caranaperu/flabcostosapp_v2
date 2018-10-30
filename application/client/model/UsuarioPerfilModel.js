/**
 * Definicion del modelo para la asignacion de personal , esta deriva
 * del modelo basico de personal ya que  los registros de esta tabla no seran usados
 * nunca en forma directa por ende se le carga con la informacion basica de personal , la misma que podra
 * ignorarse de ser necesario para lo cual  bastara con tomar los datos especificos definidos
 * directamente en este modelo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-01-11 04:42:27 -0500 (sáb, 11 ene 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_usuario_perfil",
    showPrompt: true,
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "usuario_perfil_id", primaryKey: "true"},
        {name: "usuarios_id", required: true, hidden: true},
        {name: "perfil_id", title: 'Perfil', required: true/*, multiple: true*/, foreignKey: "mdl_perfil.perfil_id"},
        {name: "activo", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_usuario_perfil._getBooleanFieldValue(v);
            }}
    ],
    fetchDataURL: glb_dataUrl + 'usuariosPerfilController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'usuariosPerfilController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'usuariosPerfilController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'usuariosPerfilController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    /**
     * Dado que cuando se esita en grilla no se pasan todos los valores
     * y estos se conservan en _oldValues , copiamos todos los
     * de oldValues a la data a transmitir siempre que oldvalues este
     * este definida , lo cual sucede solo para el update.
     */
    transformRequest: function(dsRequest) {
        var data = this.Super("transformRequest", arguments);
        if (dsRequest.operationType == 'add' || dsRequest.operationType == 'update') {
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
            return data;
        } else {
            return data;
        }
    }
});