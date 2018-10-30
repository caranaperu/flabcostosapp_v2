/**
 * Definicion del modelo parra el menu del sistema.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:59:15 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_system_menu",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    autoCacheAllData: true, // Son datos pequeños hay que evitar releer
    separateFolders: true,
    fields: [
        {name: "menu_id", primaryKey: "true"},
        {name: "menu_codigo"},
        {name: "menu_descripcion"},
        {name: "menu_accesstype"},
        {name: "menu_parent_id", foreignKey: "mdl_system_menu.menu_id"},
        {name: "menu_orden"},
        {name: "activo"}
    ],
    fetchDataURL: glb_dataUrl + 'systemMenuController?op=fetch&libid=SmartClient&sys_systemcode=' + glb_systemident,
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]});