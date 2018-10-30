/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los Atletas y la informacion de resultados del
 * mismo.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-12-03 02:00:56 -0500 (mié, 03 dic 2014) $
 * $Rev: 344 $
 */
isc.defineClass("WinAtletasForm", "WindowBasicFormExt");
isc.WinAtletasForm.addProperties({
    ID: "winAtletasForm",
    title: "Mantenimiento de Atletas",
    autoSize: false,
    width: '800',
    height: '525',
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formAtletas",
            numCols: 4,
            width: '98%',
            fixedColWidths: false,
            padding: 2,
            dataSource: mdl_atletas,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['atletas_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'atletas_apellido_paterno',
            // Para saber si ya puede agregarse la foto o no.
            _canAddPhoto: false,
            // Campo virtual
            _atletas_agno: undefined,
            // Para saber si la ventana para cargar fotos ha sido instanciada
            _uploadFotoWindow: undefined,
            fields: [
                {
                    name: "atletas_foto",
                    title: "",
                    type: "canvas",
                    width: 137,
                    height: 157,
                    canvas: isc.Img.create({
                        width: 135,
                        height: 155,
                        border: "1px solid gray",
                        imageType: "stretch",
                        src: glb_photoUrl + "/user_male.png",
                        setSrc: function (url) {
                            this.Super("setSrc", arguments);
                            // Se preserva el valor para el registro, siempre que no sea un default
                            if (url != glb_photoMaleUrl && url != glb_photoFemaleUrl) {
                                formAtletas.setValue('atletas_url_foto', url);
                                // PARCHE: Ya que cuando se cambia un valor programaticamente este no propaga el changed
                                // me veo forzado a llamar directamente el itemChanged.
                                formAtletas.itemChanged(formAtletas.getField('atletas_url_foto'), url);

                            }
                        }
                    }),
                    rowSpan: 6,
                    click: function () {
                        if (formAtletas.isNewRecord()) {
                            isc.say('El registro debe estar grabado para agregar la foto');
                        } else {
                            // Ventanita de upload , solo se crea una vez
                            if (formAtletas._uploadFotoWindow === undefined) {
                                formAtletas._uploadFotoWindow = isc.WinUploadFoto.create({imgContainer: formAtletas.getField('atletas_foto').canvas});
                                formAtletas._uploadFotoWindow.show();
                            } else {
                                formAtletas._uploadFotoWindow.show();
                            }
                        }
                    }

                },
                {
                    name: "atletas_codigo",
                    type: "text",
                    showPending: true,
                    width: "90"
                },
                {
                    name: "atletas_ap_paterno",
                    title: 'Ap.Paterno',
                    showPending: true,
                    length: 60,
                    width: 200,
                    startRow: true
                },
                {
                    name: "atletas_ap_materno",
                    title: 'Ap.Materno',
                    showPending: true,
                    length: 60,
                    width: 200,
                    startRow: true
                },
                {
                    name: "atletas_nombres",
                    title: 'Nombres',
                    showPending: true,
                    length: 100,
                    width: 250,
                    startRow: true,
                    endRow: true
                },
                {
                    name: "atletas_fecha_nacimiento",
                    useTextField: true,
                    width: 110,
                    showPickerIcon: false,
                    changed: function (form, item, value) {
                        if (isc.isA.Date(value)) {
                            formAtletas._atletas_agno = value.getFullYear();
                        }
                    },
                    endRow: true
                },
                {
                    name: "atletas_nro_documento",
                    showPending: true,
                    length: 15,
                    width: 140
                },
                {
                    name: "paises_codigo",
                    editorType: "comboBoxExt",
                    showPending: true,
                    length: 50,
                    width: "200",
                    valueField: "paises_codigo",
                    displayField: "paises_descripcion",
                    optionDataSource: mdl_paises,
                    pickListFields: [
                        {
                            name: "paises_codigo",
                            width: '20%'
                        },
                        {
                            name: "paises_descripcion",
                            width: '80%'
                        }],
                    pickListWidth: 240,
                    completeOnTab: true,
                    autoFetchData: false,
                    // evita el doble fetch.
                    fetchMissingValues: false,
                    changed: function (form, item, value) {
                        form._setupFields(item.getSelectedRecord());
                    }
                },
                {
                    name: "atletas_nro_pasaporte",
                    showPending: true,
                    length: 15,
                    width: 140,
                    endRow: true
                },
                {
                    name: "atletas_sexo",
                    type: "select",
                    showPending: true,
                    defaultValue: "M",
                    width: 20,
                    endRow: true
                },
                {
                    name: "atletas_separator_01",
                    defaultValue: "Ubicacion/Contacto",
                    type: "section",
                    colSpan: 4,
                    width: "*",
                    canCollapse: false,
                    align: 'center',
                    itemIds: ["atletas_direccion",
                              "atletas_telefono_casa",
                              "atletas_telefono_celular",
                              "atletas_email"]
                },
                {
                    name: "atletas_direccion",
                    showPending: true,
                    type: "text",
                    length: 150,
                    width: "*",
                    colSpan: 4
                },
                {
                    name: "atletas_telefono_casa",
                    showPending: true,
                    length: 13
                },
                {
                    name: "atletas_telefono_celular",
                    showPending: true,
                    length: 13,
                    endRow: true
                },
                {
                    name: "atletas_email",
                    showPending: true,
                    length: 150,
                    width: 250,
                    colSpan: 3,
                    endRow: true
                },
                {
                    name: "atletas_separator_02",
                    defaultValue: "Complementarios",
                    type: "section",
                    colSpan: 4,
                    width: "*",
                    canCollapse: false,
                    align: 'center',
                    itemIds: ["atletas_talla_ropa_buzo",
                              "atletas_talla_ropa_poloshort",
                              "atletas_talla_zapatillas",
                              "atletas_norma_zapatillas",
                              "atletas_observaciones"]
                },
                {
                    name: "atletas_talla_ropa_buzo",
                    showPending: true,
                    length: 3,
                    defaultValue: '??'
                },
                {
                    name: "atletas_talla_ropa_poloshort",
                    showPending: true,
                    length: 3,
                    endRow: true,
                    defaultValue: '??'
                },
                {
                    name: "atletas_talla_zapatillas",
                    showPending: true,
                    length: 3,
                    keyPressFilter: "[0-9.]",
                    textAlign: 'right'
                },
                {
                    name: "atletas_norma_zapatillas",
                    showPending: true,
                    length: 2,
                    defaultValue: '??',
                    endRow: true
                },
                {
                    name: "atletas_observaciones",
                    showPending: true,
                    length: 250,
                    width: "*",
                    colSpan: 4
                },
                // No visible pero parte del registro
                {
                    name: "atletas_url_foto",
                    type: 'hidden'
                }
            ],
            postSetFieldsToEdit: function () {
                var record = this.getValues();

                formAtletas._atletas_agno = record.atletas_agno;

                if (!record.atletas_url_foto || record.atletas_url_foto == '') {
                    if (record.atletas_sexo == 'M') {
                        formAtletas.getField('atletas_foto').canvas.setSrc(glb_photoMaleUrl);
                    } else {
                        formAtletas.getField('atletas_foto').canvas.setSrc(glb_photoFemaleUrl);
                    }
                } else {
                    formAtletas.getField('atletas_foto').canvas.setSrc(record.atletas_url_foto);
                }
            },
            postSaveData: function (mode, record) {
                record.atletas_agno = formAtletas._atletas_agno;
            },
            setEditMode: function (mode) {
                this.Super('setEditMode', arguments);
                // Si se agrega un nuevo registro , ponemos imagen default
                if (mode == 'add') {
                    formAtletas.getField('atletas_foto').canvas.setSrc(glb_photoMaleUrl);
                    formAtletas._canAddPhoto = false;
                } else {
                    formAtletas._canAddPhoto = true;
                    formAtletas._setupFields(null);
                }
            },
            editSelectedData: function (component) {

                this.Super('editSelectedData', arguments);

                var record = component.getSelectedRecord();

                // Aqui forzamos solo a leer un registro justo el que corresponde a la prueba
                // de este registro.
                //
                winAtletasForm.fetchFieldRecord('paises_codigo', {
                    "paises_codigo": record.paises_codigo
                });
            },
            fieldDataFetched: function (formFieldName, record) {
                if (formFieldName === 'paises_codigo') {
                    formAtletas._setupFields(record);
                }
            },
            canCloseWindow: function (mode) {
                if (mode == 'add') {
                    // Lamentablemente se requiere un dialog modal por lo que me veo
                    // obligado a usar el nativo de javascript.
                    var retVal = confirm("EL atleta ha sido grabado , Aceptar si desea agregar la foto y luego presione la imagen, finalmente grabe nuevamente..\n\nDesea agrega la foto del atleta en este momento ?");
                    return !retVal;
                }
                return true;
            },
            _setupFields: function (paisesRecord) {
                if (paisesRecord) {
                    formAtletas.getItem('atletas_ap_materno').setRequired(paisesRecord.paises_use_apm);
                    formAtletas.getItem('atletas_nro_documento').setRequired(paisesRecord.paises_use_docid);

                } else {
                    formAtletas.getItem('atletas_ap_materno').setRequired(true);
                    formAtletas.getItem('atletas_nro_documento').setRequired(true);
                }
                formAtletas.getItem('atletas_ap_materno').validate();
                formAtletas.getItem('atletas_nro_documento').validate();
            }
            //   , cellBorder: 1
        });
    },
    /**
     * Metodo llamado durante de la inicializacion de la clase
     * para si se desea agregar mas tabs a la pantalla principal
     * para esto eso debe hacerse en un override de este metodo.
     *
     * Observese que el TabSet es del tipo TabSetExt el cual soporta el metodo
     * addAditionalTab.
     *
     * @param isc.TabSetExt tabset El tab set principal al cual agregar.
     */
    addAdditionalTabs: function (tabset) {
        tabset.addAdditionalTab({
            ID: 'TabInfoAtletaMarcasForm',
            title: 'Marcas / Resultados',
            paneClass: 'CotizacionCostosHistoricosForm',
            joinField: 'insumo_id'
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});