/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los procesos
 *
 * @version 1.00
 * @since 17-MAY-2021
 * @Author: Carlos Arana Reategui
 * 
 */
isc.defineClass("WinProcesosForm", "WindowBasicFormExt");
isc.WinProcesosForm.addProperties({
    ID: "winProcesosForm",
    title: "Mantenimiento de Procesos",
    width: 470, height: 180,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formProcesos",
            numCols: 2,
            colWidths: ["120", "*"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_procesos,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['procesos_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'procesos_descripcion',
            fields: [
                {name: "procesos_codigo", type: "text", showPending: true, width: "90", mask: ">LLLLLLLL"},
                {name: "procesos_descripcion", showPending: true, length: 120, width: "260"}
            ]
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});