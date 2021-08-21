/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los clientes-
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:43:44 -0500 (dom, 06 abr 2014) $
 * $Rev: 146 $
 */
isc.defineClass("WinClienteWindow", "WindowGridListExt");
isc.WinClienteWindow.addProperties({
    ID: "winClienteWindow",
    title: "Clientes",
    width: 650,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "ClienteList",
            alternateRecordStyles: true,
            dataSource: mdl_cliente,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "cliente_razon_social",
                    width: '35%'
                },
                {
                    name: "cliente_ruc",
                    width: '15%'
                },
                {
                    name: "cliente_direccion",
                    width: '35%'
                },
                {
                    name: "tipo_cliente_descripcion",
                    width: '15s%'
                }
            ],
            initialCriteria: {
                fieldName: "empresa_id",
                operator: "equals",
                value: glb_empresaId
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'cliente_razon_social'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
