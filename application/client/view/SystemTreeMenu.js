isc.defineClass("SystemTreeMenu", "TreeGrid");

var menu =
    {
        "smn_unidadmedida": {windowClass: "WinUnidadMedidaWindow", formClass: 'WinUnidadMedidaForm'},
        "smn_umconversion": {windowClass: "WinUMConversionWindow", formClass: "WinUMConversionForm"},
        "smn_monedas": {windowClass: "WinMonedaWindow", formClass: "WinMonedaForm"},
        "smn_tinsumo": {windowClass: "WinTipoInsumoWindow", formClass: "WinTipoInsumoForm"},
        "smn_tcostos": {windowClass: "WinTipoCostosWindow", formClass: "WinTipoCostosForm"},
        "smn_entidad": {windowClass: undefined, formClass: "WinEntidadForm"},
        "smn_producto": {windowClass: "WinProductoWindow", formClass: "WinProductoForm"},
        "smn_insumo": {windowClass: "WinInsumoWindow", formClass: "WinInsumoForm"},
        "smn_tipocambio": {windowClass: "WinTipoCambioWindow", formClass: "WinTipoCambioForm"},
        "smn_usuarios": {windowClass: "WinUsuariosWindow", formClass: "WinUsuariosForm"},
        "smn_perfiles": {windowClass: "WinPerfilWindow", formClass: "WinPerfilForm"},
        "smn_presentacion": {windowClass: "WinPresentacionWindow", formClass: "WinPresentacionForm"},
        "smn_tcosto_global": {windowClass: "WinTipoCostoGlobalWindow", formClass: "WinTipoCostoGlobalForm"},
        "smn_tcosto_global_entries": {windowClass: "WinTipoCostoGlobalEntriesWindow", formClass: "WinTipoCostoGlobalEntriesForm"},
        "mn_procesos": {windowClass: "WinProcesosWindow", formClass: "WinProcesosForm"},
        "smn_producto_procesos": {windowClass: "WinProductoProcesosWindow", formClass: "WinProductoProcesosForm"},
        "smn_taplicacion": {windowClass: "WinTipoAplicacionWindow", formClass: "WinTipoAplicacionForm"},
        "smn_taplicacion_procesos": {windowClass: "WinTipoAplicacionProcesosWindow", formClass: "WinTipoAplicacionProcesosForm"},
        "smn_produccion": {windowClass: "WinProduccionWindow", formClass: "WinProduccionForm"},
        "smn_costos_proceso": {windowClass: undefined, formClass: "WinCostoProcesoForm"},
        "smn_costos_consulta": {windowClass: "WinCostoListWindow", formClass: "WinCostoListForm"},
    }

isc.SystemTreeMenu.addProperties({
    ID: "mainMenuTree",
    dataSource: mdl_system_menu,
    fetchOperation: 'fetchForUser',
    autoFetchData: true,
    loadDataOnDemand: false,
    width: 520,
    height: 400,
    showOpenIcons: true,
    showCloseIcons: true,
    showDropIcons: true,
    showHeader: false,
    costosHistoricosReport: null,
    fields: [{name: "menu_descripcion"}], // El campo a pintar en el arbol
    _controllersList: {},
    leafClick: function (viewer, leaf, recordNum) {
        if (leaf.menu_codigo === 'smn_costos_historicos') {
            if (this.costosHistoricosReport == null) {
                this.costosHistoricosReport = CostosHistoricosReportWindow.create();
                this.costosHistoricosReport.show();
            } else {
                this.costosHistoricosReport.show();
            }

        } else {
            if (!this._controllersList[leaf.menu_codigo]) {
                this._controllersList[leaf.menu_codigo] = this._getController(leaf.menu_codigo);
            }
            if (leaf.menu_codigo === 'smn_entidad' || leaf.menu_codigo === 'smn_costos_proceso') {
                this._controllersList[leaf.menu_codigo].doSetup(true, null);
            } else {
                this._controllersList[leaf.menu_codigo].doSetup(false, null);
            }
        }
    },
    _getController: function (menuId) {
        var controller;
        if (typeof menu[menuId] !== 'undefined') {
            controller = isc.DefaultController.create({
                mainWindowClass: menu[menuId].windowClass,
                formWindowClass: menu[menuId].formClass
            });
        } else {
            alert("Menu ["+menuId+"] no definido, informar a casa de desarrollo");
        }
        return controller;
    }

});
