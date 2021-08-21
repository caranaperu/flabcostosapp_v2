
/**
 * Clase que crea la ventana de ingreso de datos basicos para la CostoProceso usuaria
 * del sistema.
 *
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinCostoProcesoForm", "WindowBasicFormExt");

isc.WinCostoProcesoForm.addProperties({
    ID: "winCostoProcesoForm",
    title: "Proceso De Costos",
    width: 565, height: 260,
    canDragResize: true,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formCostoProcesoData",
            numCols: 4,
            //colWidths: ["90", "*"],
            fixedColWidths: false,
            padding: 5,
            errorOrientation: "right",
            validateOnExit: true,
            dataSource: mdl_proceso_costo,
            addOperation: 'fetchProceso', // la operacion add sera mapeada a fetch
            autoFocus: true,
            formMode: null, // parametro de inicializacion, si es null siempre abrira la ventana en openFormMode
            openFormMode: 'add',
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'costos_list_descripcion',
            //disableValidation: true,
            fields: [
                {name: "costos_list_descripcion", showPending: true, width: "300", length: 60, colSpan: 4},
                {name: "costos_list_fecha_desde",
                    useTextField: true,
                    showPending: true,
                    width: 120,
                    showPickerIcon: true,
                    endRow: true,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && formCostoProcesoData.getValue('costos_list_fecha_hasta')) {
                            if (value.getTime() > formCostoProcesoData.getValue('costos_list_fecha_hasta').getTime()) {
                                isc.say('La fecha inicial no puede ser mayor que la final');
                                return false;
                            }
                        }
                        return true;
                    }
                },
                {name: "costos_list_fecha_hasta",
                    useTextField: true,
                    showPending: true,
                    width: 120,
                    showPickerIcon: true,
                    endRow: true,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && formCostoProcesoData.getValue('costos_list_fecha_desde')) {
                            if (value.getTime() < formCostoProcesoData.getValue('costos_list_fecha_desde').getTime()) {
                                isc.say('La fecha final no puede ser menor que la inicial');
                                return false;
                            }
                        }
                        return true;
                    }
                },
                {name: "costos_list_fecha_tcambio",
                    useTextField: true,
                    showPending: true,
                    width: 120,
                    showPickerIcon: true,
                    endRow: true
                }
            ],
            isAllowedToSave: function (values,oldValues) {
                alert("paso");
                isc.say('xxxxxx');

                isc.confirm('Esta seguro de iniciar el proceso ?',
                    function (val) {
                        alert(val);
                       return val;
                    });
                alert("paso 2");

                return true;
            },
            postSaveData: function (mode,record) {
                // dado que en realidad ejecuta un proceso , no debe entrar a modo update sino siempre
                // debe quedar en modo add.
                //formCostoProcesoData.setEditMode('add');
                isc.say('Proceso terminado correctamente');
            },
            // ,cellBorder: 1
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
        this.getFormButton('save').setTitle('Procesar');
    }

});