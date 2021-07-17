/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de la relacion tipo aplicacion-proceso.
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
isc.defineClass("WinTipoAplicacionProcesosWindow", "WindowGridListExt");
isc.WinTipoAplicacionProcesosWindow.addProperties({
    ID: "winTipoAplicacionProcesosWindow",
    title: "Modo Aplicacion / Procesos",
    width: 500,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoAplicacionProcesosList",
            alternateRecordStyles: true,
            dataSource: mdl_taplicacion_procesos,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "taplicacion_descripcion",
                    width: '60%'
                },
                {
                    name: "taplicacion_procesos_fecha_desde",
                    width: '40%',
                    filterEditorProperties: {
                        operator: "greaterThan",
                        editorType: 'date'
                    }
                }
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
