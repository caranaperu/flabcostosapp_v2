/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de la relacion producto-proceso.
 *
 * @version 1.00
 * @since 26-MAY-2021
 * @Author: Carlos Arana Reategui
 *
 */
isc.defineClass("WinProductoProcesosWindow", "WindowGridListExt");
isc.WinProductoProcesosWindow.addProperties({
    ID: "winProductoProcesosWindow",
    title: "Producto / Procesos",
    width: 500,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ProductoProcesosList",
            alternateRecordStyles: true,
            dataSource: mdl_producto_procesos,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "insumo_descripcion",
                    width: '60%'
                },
                {
                    name: "producto_procesos_fecha_desde",
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
