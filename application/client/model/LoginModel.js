/**
 * Definicion del modelo para el login del sistema.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape@gmail.com $
 * $Date: 2015-08-23 18:01:21 -0500 (dom, 23 ago 2015) $
 */
isc.defineClass("RestDataSourceLogin", "RestDataSourceExt");

isc.RestDataSourceLogin.create({
    ID: "mdl_login",
    fields: [
        {name: "usuarios_code", title: 'Codigo', required: true, validators: [{type: "regexp", expression: glb_RE_alpha_dash}]},
        {name: "usuarios_password", title: 'Password', required: true},
        {name: "usuarios_admin", title: "Admin", type: 'boolean',  getFieldValue: function (r, v, f, fn) {
                return mdl_login._getBooleanFieldValue(v);
            }}
    ],
    addDataURL: glb_dataUrl + 'loginController?op=fetch&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'loginController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});