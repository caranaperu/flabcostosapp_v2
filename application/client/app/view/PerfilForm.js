/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de Perfiles y sus
 * respectivos requisitos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-26 04:55:04 -0500 (mar, 26 ene 2016) $
 * $Rev: 374 $
 */
isc.defineClass("WinPerfilForm", "WindowBasicFormExt");
isc.WinPerfilForm.addProperties({
    ID: "winPerfilForm",
    title: "Mantenimiento de Perfiles",
    joinKeyFields: [{fieldName: 'perfil_id', fieldValue: ''}],
    width: 575,
    height: 210,
    createForm: function (formMode) {

        return isc.DynamicFormExt.create({
            ID: "formPerfiles",
            // longTextEditorThreshold: 500,
            width: '550',
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_perfil,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['sys_systemcode', 'perfil_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'perfil_descripcion',
            fields: [
                {
                    name: "sys_systemcode", editorType: "comboBoxExt", showPending: true,
                    valueField: "sys_systemcode", displayField: "sys_systemcode",
                    optionDataSource: mdl_sistemas, // TODO: podria ser tipo basic para no relleer , ver despues
                    pickListFields: [
                        {name: "sys_systemcode", width: '25%'}, {
                            name: "sistema_descripcion",
                            width: '75%'
                        }],
                    pickListWidth: 260,
                    completeOnTab: true,
              //      width: '20%',
                    changed: function (form, item, value) {
                        formPerfiles.setValue("prm_copyFromPerfil", undefined);
                    }
                },
                {name: "perfil_codigo", type: "text", width: "120", mask: ">AAAAAAAAAAAAAA", showPending: true},
                {name: "perfil_descripcion", length: 120, width: '400', showPending: true},
                // Sera tratado como una sub operacion en el backend
                {
                    name: "prm_copyFromPerfil",
                    title: 'Copiar desde otro perfil',
                    editorType: "comboBoxExt",
                    length: 50,
            //        width: "80%",
                    showPending: true,
                    valueField: "perfil_id",
                    displayField: "perfil_descripcion",
                    optionDataSource: mdl_perfil,
                    pickListFields: [
                        {name: "sys_systemcode", width: '20%'},
                        {
                            name: "perfil_codigo",
                            width: '20%'
                        },
                        {name: "perfil_descripcion", width: '60%'}],
                    pickListWidth: 300,
                    completeOnTab: true,
                    showIf: "formPerfiles.formMode == 'add'",
                    editorProperties: {
                        getPickListFilterCriteria: function () {
                            var systemcode = formPerfiles.getValue("sys_systemcode");
                            return {sys_systemcode: systemcode};
                        }
                    }
                }

            ],
            setupFieldsToAdd: function (fieldsToAdd) {
                this.setValue('prm_copyFromPerfil', undefined);
            }
            //, cellBorder: 1
        });
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            width: 550,
            height: 350,
            sectionTitle: 'Permisos',
            gridProperties: {
                // Importante los treegrid por ahora no paginan , en este caso es irrelevante
                // por tratarse de un arbol de menu cuyos datos nunca son grandes.
                gridType: 'treeGrid',
                ID: 'treegrid_permisos_detail',
                dataSource: 'mdl_perfil_detalle',
                autoFetchData: false,
                loadDataOnDemand: false,
                showOpenIcons: true,
                showCloseIcons: true,
                showDropIcons: false,
                canRemoveRecords: false,
                canAdd: false,
                fetchOperation: 'fetchWithAccess',
                showHeaderContextMenu: false,
                canSort: false,
                fields: [
                    {name: "menu_descripcion"},
                    {
                        name: "perfdet_accleer", canToggle: false, change: function (form, item, value) {
                        var edtRow = treegrid_permisos_detail.getEditRow();
                        // Si es un nodo preguntamos si se desea cambiar ya que se modificara en cascada
                        // a todos los submenus.
                        if (treegrid_permisos_detail.data.isFolder(treegrid_permisos_detail.getRecord(edtRow))) {
                            isc.ask('Al modificar el estado de lectura sobre un menu principal estara concediendo o quitando el acceso total a todos los submenus, luego podra alterar cada submenu individualmente, Realmente desea Modificar?', function (val) {
                                // Si se acepta cambiamos el valor
                                if (val) {
                                    treegrid_permisos_detail.setEditValue(edtRow, 1, value);
                                }
                            });
                            return false;
                        } else {
                            if (!value) {
                                treegrid_permisos_detail.setEditValue(edtRow, 2, false);
                                treegrid_permisos_detail.setEditValue(edtRow, 3, false);
                                treegrid_permisos_detail.setEditValue(edtRow, 4, false);
                                treegrid_permisos_detail.setEditValue(edtRow, 5, false);
                            }
                            return true;
                        }
                    }
                    },
                    // Todos los demas encenderan el de lectura si uno de ellos es activado, ya que si no es posible
                    // leer es obvio que nada podemos hacer.
                    {
                        name: "perfdet_accagregar", canToggle: false, change: function (form, item, value) {
                        if (value) {
                            treegrid_permisos_detail.setEditValue(treegrid_permisos_detail.getEditRow(), 1, true);
                        }
                        return true;
                    }
                    },
                    {
                        name: "perfdet_accactualizar", canToggle: false, change: function (form, item, value) {
                        if (value) {
                            treegrid_permisos_detail.setEditValue(treegrid_permisos_detail.getEditRow(), 1, true);
                        }
                        return true;
                    }
                    },
                    {
                        name: "perfdet_acceliminar", canToggle: false, change: function (form, item, value) {
                        if (value) {
                            treegrid_permisos_detail.setEditValue(treegrid_permisos_detail.getEditRow(), 1, true);
                        }
                        return true;
                    }
                    },
                    {
                        name: "perfdet_accimprimir", canToggle: false, change: function (form, item, value) {
                        if (value) {
                            treegrid_permisos_detail.setEditValue(treegrid_permisos_detail.getEditRow(), 1, true);
                        }
                        return true;
                    }
                    }

                ],
                // Ocultamos los atributos que no sean leer para los root del
                // treegrid (raiz de menu).
                getCellCSSText: function (record, rowNum, colNum) {
                    if (this.data.isFolder(this.getRecord(rowNum)) && colNum > 1) {
                        return "visibility:hidden;";
                    }
                },
                // LLamado siempre luego de un update o add , aqui usado para recargar los datos
                // luego de grabar un menu o submenu.
                editComplete: function (rowNum, colNum, newValues, oldValues, editCompletionEvent, dsResponse) {
                    // Si no hay error
                    if (dsResponse.status >= 0) {
                        // Es un submenu o menu entonces se actualizo desde ese punto hacia abajo por ende debera
                        // refrescarse la lista
                        if (treegrid_permisos_detail.data.isFolder(treegrid_permisos_detail.getRecord(rowNum))) {
                            isc.warn('Dado que se a modificado el acceso a un menu o submenu el arbol de permisos sera recargado , ya que esta opercion ha generado cambios a multiples registros',
                                function (val) {
                                    treegrid_permisos_detail.invalidateCache();
                                });
                        }
                    }
                }


            }
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }

});
