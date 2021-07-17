/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los sub procesos
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 */
isc.defineClass("WinSubProcesosWindow", "WindowGridListExt");
isc.WinSubProcesosWindow.addProperties({
    ID: "winSubProcesosWindow",
    title: "Sub Procesoss",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "SubProcesosList",
            alternateRecordStyles: true,
            dataSource: mdl_subprocesos,
            autoFetchData: true,
            fields: [
                {name: "subprocesos_codigo",  width: '20%'},
                {name: "subprocesos_descripcion",  width: '80%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'subprocesos_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
