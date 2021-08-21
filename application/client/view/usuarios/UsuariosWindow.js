/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los usuarios del sistema
 * @version 1.00
 * @since 1.00
 * $Author: aranape@gmail.com $
 * $Date: 2015-08-23 18:01:21 -0500 (dom, 23 ago 2015) $
 * $Rev: 63 $
 */
isc.defineClass("WinUsuariosWindow", "WindowGridListExt");
isc.WinUsuariosWindow.addProperties({
    ID: "winUsuariosWindow",
    title: "Usuarios",
    width: 650,
    height: 300,
    createGridList: function () {
        return isc.ListGrid.create({
            ID: "UsuariosList",
            alternateRecordStyles: true,
            dataSource: mdl_usuarios,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {name: "usuarios_code", width: '15%'},
                {name: "usuarios_nombre_completo", width: '30%'},
                {name: "empresa_razon_social", width: '30%'},
                {name: "usuarios_admin", width: '*'},
                {name: "activo",  width: '*'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            autoFitWidthApproach: 'both'
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});
