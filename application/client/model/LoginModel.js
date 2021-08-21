/**
 * Definicion del modelo para el login del sistema.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape@gmail.com $
 * $Date: 2015-08-23 18:01:21 -0500 (dom, 23 ago 2015) $
 */
isc.RestDataSource.create({
    ID: "mdl_login",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {name: "usuarios_code", title: 'Codigo', required: true, validators: [{type: "regexp", expression: glb_RE_alpha_dash}]},
        {name: "usuarios_password", title: 'Password', required: true},
        {name: "usuarios_admin", title: "Admin", type: 'boolean',  getFieldValue: function (r, v, f, fn) {
                return mdl_login._getBooleanFieldValue(v);
            }},
        {name: "empresa_id", title:'Empresa',required: true,  foreignKey: "mdl_empresa.empresa_id"}
    ],
    addDataURL: glb_dataUrl + 'loginController?op=fetch&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'loginController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function (value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    }
});