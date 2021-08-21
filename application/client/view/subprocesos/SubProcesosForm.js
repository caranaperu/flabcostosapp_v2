/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los subprocesos
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 * 
 */
isc.defineClass("WinSubProcesosForm", "WindowBasicFormExt");
isc.WinSubProcesosForm.addProperties({
    ID: "winSubProcesosForm",
    title: "Mantenimiento de Sub Procesos",
    width: 470, height: 180,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formSubProcesos",
            numCols: 2,
            colWidths: ["120", "*"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_subprocesos,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['subprocesos_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'subprocesos_descripcion',
            fields: [
                {name: "subprocesos_codigo", type: "text", showPending: true, width: "90", mask: ">LLLLLLLL"},
                {name: "subprocesos_descripcion", showPending: true, length: 120, width: "260"}
            ]
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});