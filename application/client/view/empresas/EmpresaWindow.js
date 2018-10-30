/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las monedas
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:43:44 -0500 (dom, 06 abr 2014) $
 * $Rev: 146 $
 */
isc.defineClass("WinEmpresaWindow", "WindowGridListExt");
isc.WinEmpresaWindow.addProperties({
    ID: "winEmpresaWindow",
    title: "Empresas",
    width: 650,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "EmpresaList",
            alternateRecordStyles: true,
            dataSource: mdl_empresa,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "empresa_razon_social",
                    width: '35%'
                },
                {
                    name: "empresa_ruc",
                    width: '15%'
                },
                {
                    name: "empresa_direccion",
                    width: '35%'
                },
                {
                    name: "tipo_empresa_descripcion",
                    width: '15s%'
                }
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'empresa_razon_social'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
