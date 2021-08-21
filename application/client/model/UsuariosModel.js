/**
 * Definicion del modelo para las marcas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape@gmail.com $
 * $Date: 2015-08-23 18:01:21 -0500 (dom, 23 ago 2015) $
 */
isc.defineClass("RestDataSourceUsuarios", "RestDataSourceExt");

isc.RestDataSourceUsuarios.create({
    ID: "mdl_usuarios",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {name: "usuarios_id", primaryKey: "true"},
        {name: "usuarios_code", title: 'Codigo', required: true, validators: [{type: "regexp", expression: glb_RE_alpha_dash}]},
        {name: "usuarios_password", title: 'Password', required: true},
        {name: "usuarios_nombre_completo", title: "Nombre Completo", required: true, validators: [{type: "regexp", expression: glb_RE_onlyValidText}]},
        {name: "usuarios_admin", title: "Admin", type: 'boolean',  getFieldValue: function (r, v, f, fn) {
                return mdl_usuarios._getBooleanFieldValue(v);
            }},

        {name: "activo", title: "Activo", type: 'boolean',  getFieldValue: function (r, v, f, fn) {
                return mdl_usuarios._getBooleanFieldValue(v);
            }},
        {name: "empresa_id", title:'Empresa',required: true,  foreignKey: "mdl_empresa.empresa_id"},
        // virtual
        {name: "empresa_razon_social", title:'Empresa'}

    ],
    fetchDataURL: glb_dataUrl + 'usuariosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'usuariosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'usuariosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'usuariosController?op=del&libid=SmartClient'
});