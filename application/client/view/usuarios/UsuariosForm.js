/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los usuarios
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape@gmail.com $
 * $Date: 2015-08-23 18:01:21 -0500 (dom, 23 ago 2015) $
 * $Rev: 63 $
 */
isc.defineClass("WinUsuariosForm", "WindowBasicFormExt");
isc.WinUsuariosForm.addProperties({
    ID: "winUsuariosForm",
    title: "Mantenimiento de Usuarios",
    width: 525, height: 260,
    joinKeyFields: [{fieldName: 'usuarios_id', fieldValue: ''}],
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formUsuarios",
            padding: 2,
            colWidths: [130, "*"],
            fixedColWidths: false,
            dataSource: mdl_usuarios,
            formMode: this.formMode, // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            keyFields: ['usuarios_code'],
            focusInEditFld: 'usuarios_password',
            addOperation:'readAfterSaveJoined',
            updateOperation:'readAfterUpdateJoined',
            fields: [
                {name: "usuarios_code", width: 80, size: 15, showPending: true, endRow: true},
                {name: "usuarios_password", size: 20, width: 150, showPending: true, endRow: true},
                {name: "usuarios_nombre_completo", size: 250, width: 300, showPending: true, endRow: true},
                {
                    name: "empresa_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "empresa_id",
                    displayField: "empresa_razon_social",
                    optionDataSource: mdl_empresa,
                    pickListFields: [{
                        name: "empresa_razon_social"
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'empresa_razon_social'}],
                    startRow: true
                },
                {name: "usuarios_admin", defaultValue: false, showPending: true, endRow: true},
                {name: "activo", defaultValue: true, showPending: true, endRow: true}
            ]
                    //  disableValidation: true
        });
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            width: 500,
            height: 150,
            sectionTitle: 'Asignar Perfiles',
            gridProperties: {
                dataSource: 'mdl_usuario_perfil',
                fetchOperation: 'fetchFull',
                autoFetchData: false,
                fields: [
                    {name: "perfil_id", editorType: "comboBoxExt",
                        valueField: "perfil_id", displayField: "perfil_descripcion",
                        optionDataSource: mdl_perfil, // TODO: podria ser tipo basic para no relleer , ver despues
                        pickListFields: [{name: "perfil_codigo", width: '20%'}, {name: "perfil_descripcion", width: '80%'}],
                        completeOnTab: true,
                        width: '45%',
                        editorProperties: {
                            getPickListFilterCriteria: function () {
                                return {sys_systemcode: glb_systemident};
                            }
                        }
                    },
                    {name: "activo", width: '10%', canToggle: false}
                ]
            }});
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});