isc.defineClass("SystemTreeMenu", "TreeGrid");

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
            if (leaf.menu_codigo === 'smn_entidad') {
                this._controllersList[leaf.menu_codigo].doSetup(true, null);
            } else {
                this._controllersList[leaf.menu_codigo].doSetup(false, null);
            }
        }
    },
    _getController: function (menuId) {
        var controller;

        if (menuId === 'smn_entidad') {
            controller = isc.DefaultController.create({mainWindowClass: undefined, formWindowClass: 'WinEntidadForm'});
        }  else if (menuId === 'smn_unidadmedida') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinUnidadMedidaWindow',
                formWindowClass: 'WinUnidadMedidaForm'
            });
        } else if (menuId === 'smn_umconversion') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinUMConversionWindow',
                formWindowClass: 'WinUMConversionForm'
            });
        } else if (menuId === 'smn_monedas') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinMonedaWindow',
                formWindowClass: 'WinMonedaForm'
            });
        } else if (menuId === 'smn_tinsumo') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinTipoInsumoWindow',
                formWindowClass: 'WinTipoInsumoForm'
            });
        } else if (menuId === 'smn_tcostos') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinTipoCostosWindow',
                formWindowClass: 'WinTipoCostosForm'
            });
        } else if (menuId === 'smn_insumo') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinInsumoWindow',
                formWindowClass: 'WinInsumoForm'
            });
        } else if (menuId === 'smn_producto') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinProductoWindow',
                formWindowClass: 'WinProductoForm'
            });
        } else if (menuId === 'smn_tipocambio') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinTipoCambioWindow',
                formWindowClass: 'WinTipoCambioForm'
            });
        } else if (menuId === 'smn_usuarios') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinUsuariosWindow',
                formWindowClass: 'WinUsuariosForm'
            });
        } else if (menuId === 'smn_perfiles') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinPerfilWindow',
                formWindowClass: 'WinPerfilForm'
            });
        } else if (menuId === 'smn_empresas') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinEmpresaWindow',
                formWindowClass: 'WinEmpresaForm'
            });
        } else if (menuId === 'smn_reglas') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinReglasWindow',
                formWindowClass: 'WinReglasForm'
            });
        } else if (menuId === 'smn_cotizacion') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinCotizacionWindow',
                formWindowClass: 'WinCotizacionForm'
            });
        } else if (menuId === 'smn_tcliente') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinTipoClienteWindow',
                formWindowClass: 'WinTipoClienteForm'
            });
        } else if (menuId === 'smn_clientes') {
            controller = isc.DefaultController.create({
                mainWindowClass: 'WinClienteWindow',
                formWindowClass: 'WinClienteForm'
            });
        }

        return controller;
    }

});
