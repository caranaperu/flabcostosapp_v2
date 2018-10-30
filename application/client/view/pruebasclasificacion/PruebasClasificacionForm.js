/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de la clasificacion
 * de pruebas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:41:53 -0500 (mar, 25 mar 2014) $
 * $Rev: 107 $
 */
isc.defineClass("WinPruebasClasificacionForm", "WindowBasicFormExt");
isc.WinPruebasClasificacionForm.addProperties({
    ID: "winPruebasClasificacionForm",
    title: "Mantenimiento de Clasificacion de Pruebas",
    width: 470, height: 210,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formPruebasClasificacion",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_pruebas_clasificacion,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['pruebas_clasificacion_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'pruebas_clasificacion_descripcion',
            fields: [
                {name: "pruebas_clasificacion_codigo", title: "Codigo", type: "text", showPending: true, width: "80", mask: ">AAAAAAAA"},
                {name: "pruebas_clasificacion_descripcion", title: "Descripcion", showPending: true, length: 120, width: "260"},
                {name: "pruebas_tipo_codigo", title: "Tipo", editorType: "comboBoxExt", showPending: true, length: 80, width: "280",
                    valueField: "pruebas_tipo_codigo", displayField: "pruebas_tipo_descripcion",
                    optionDataSource: mdl_pruebas_tipo,
                    pickListFields: [{name: "pruebas_tipo_codigo", width: '20%'}, {name: "pruebas_tipo_descripcion", width: '80%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    initialSortField: [{property: 'pruebas_tipo_descripcion'}]
//                    pickListProperties: {
//                        showFilterEditor: true,
//                        sortField: "pruebas_tipo_descripcion"
//                    },
                },
                {name: "unidad_medida_codigo", title: "Medida", editorType: "comboBoxExt", showPending: true, length: 80, width: "280",
                    valueField: "unidad_medida_codigo", displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{name: "unidad_medida_codigo", width: '20%'}, {name: "unidad_medida_descripcion", width: '80%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    initialSortField: [{property: 'unidad_medida_descripcion'}]
//                    pickListProperties: {
//                        showFilterEditor: true,
//                        sortField: "unidad_medida_descripcion"
//                    },
                }
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});