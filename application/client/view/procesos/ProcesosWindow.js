/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los procesos
 *
 * @version 1.00
 * @since 20-MAY-2021
 * @Author: Carlos Arana Reategui
 */
isc.defineClass("WinProcesosWindow", "WindowGridListExt");
isc.WinProcesosWindow.addProperties({
    ID: "winProcesosWindow",
    title: "Procesoss",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ProcesosList",
            alternateRecordStyles: true,
            dataSource: mdl_procesos,
            autoFetchData: true,
            fields: [
                {name: "procesos_codigo",  width: '20%'},
                {name: "procesos_descripcion",  width: '80%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'procesos_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
