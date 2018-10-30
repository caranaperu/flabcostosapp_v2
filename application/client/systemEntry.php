<html>
<head>
    <meta charset="utf-8">
    <title>CLABS</title>
    <SCRIPT>var isomorphicDir = "../../../common/client/isomorphic/";</SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Core.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Foundation.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Containers.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Grids.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Forms.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_DataBinding.js></SCRIPT>

    <SCRIPT SRC=../../../common/client/isomorphic/skins/EnterpriseBlue/load_skin.js></SCRIPT>

    <SCRIPT SRC=./appConfig.js></SCRIPT>
    <SCRIPT>glb_empresaId = <?php echo $_POST["empresa_id"]; ?>;</SCRIPT>

    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/IControlledCanvas.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/controller/DefaultController.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/DynamicFormExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/WindowBasicFormExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/WindowBasicFormNCExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/WindowGridListExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/TabSetExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/controls/PickTreeExtItem.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/controls/ComboBoxExtItem.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/controls/SelectExtItem.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/controls/DetailGridContainer.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/ds/RestDataSourceExt.js></SCRIPT>


    <SCRIPT SRC=./app/model/SystemMenuModel.js></SCRIPT>
    <SCRIPT SRC=./view/SystemTreeMenu.js></SCRIPT>

    <SCRIPT SRC=./model/LoginModel.js></SCRIPT>

    <SCRIPT SRC=./model/EntidadModel.js></SCRIPT>
    <SCRIPT SRC=./view/entidad/EntidadWindow.js></SCRIPT>

    <SCRIPT SRC=app/model/SistemasModel.js></SCRIPT>
    <SCRIPT SRC=app/model/PerfilModel.js></SCRIPT>
    <SCRIPT SRC=app/model/PerfilDetalleModel.js></SCRIPT>

    <SCRIPT SRC=app/view/PerfilWindow.js></SCRIPT>
    <SCRIPT SRC=app/view/PerfilForm.js></SCRIPT>

    <SCRIPT SRC=./model/UsuarioPerfilModel.js></SCRIPT>

    <SCRIPT SRC=./model/UsuariosModel.js></SCRIPT>
    <SCRIPT SRC=./view/usuarios/UsuariosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/usuarios/UsuariosForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoEmpresaModel.js></SCRIPT>
    <SCRIPT SRC=./model/EmpresaModel.js></SCRIPT>
    <SCRIPT SRC=./view/empresas/EmpresaWindow.js></SCRIPT>
    <SCRIPT SRC=./view/empresas/EmpresaForm.js></SCRIPT>

    <SCRIPT SRC=./model/UnidadMedidaModel.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida/UnidadMedidaWindow.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida/UnidadMedidaForm.js></SCRIPT>

    <SCRIPT SRC=./model/UnidadMedidaConversionModel.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida_conversion/UnidadMedidaConversionWindow.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida_conversion/UnidadMedidaConversionForm.js></SCRIPT>

    <SCRIPT SRC=./model/MonedaModel.js></SCRIPT>
    <SCRIPT SRC=./view/monedas/MonedaWindow.js></SCRIPT>
    <SCRIPT SRC=./view/monedas/MonedaForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoCambioModel.js></SCRIPT>
    <SCRIPT SRC=./view/tipocambio/TipoCambioWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tipocambio/TipoCambioForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoInsumoModel.js></SCRIPT>
    <SCRIPT SRC=./view/tinsumo/TipoInsumoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tinsumo/TipoInsumoForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoCostosModel.js></SCRIPT>
    <SCRIPT SRC=./view/tcostos/TipoCostosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tcostos/TipoCostosForm.js></SCRIPT>

    <SCRIPT SRC=view/insumos/InsumoCostosHistoricosForm.js></SCRIPT>
    <SCRIPT SRC=view/insumos/InsumoUsedByForm.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoCostosHistoricoModel.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoUsedByModel.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoModel.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoProductoDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/insumos/InsumoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/insumos/InsumoForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProductoModel.js></SCRIPT>
    <SCRIPT SRC=./model/ProductoDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoForm.js></SCRIPT>

    <SCRIPT SRC=./model/ReglasModel.js></SCRIPT>
    <SCRIPT SRC=./view/reglas/ReglasWindow.js></SCRIPT>
    <SCRIPT SRC=./view/reglas/ReglasForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoClienteModel.js></SCRIPT>
    <SCRIPT SRC=./view/tcliente/TipoClienteWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tcliente/TipoClienteForm.js></SCRIPT>

    <SCRIPT SRC=./model/ClienteModel.js></SCRIPT>
    <SCRIPT SRC=./view/cliente/ClienteWindow.js></SCRIPT>
    <SCRIPT SRC=./view/cliente/ClienteForm.js></SCRIPT>

    <SCRIPT SRC=view/reports/ReportsOutputWindow.js></SCRIPT>

    <SCRIPT SRC=./model/CotizacionModel.js></SCRIPT>
    <SCRIPT SRC=./model/CotizacionDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./model/ClienteCotizacionModel.js></SCRIPT>
    <SCRIPT SRC=./model/ProductoCotizacionDetalleModel.js></SCRIPT>

    <SCRIPT SRC=./view/cotizacion/CotizacionWindow.js></SCRIPT>
    <SCRIPT SRC=./view/cotizacion/CotizacionForm.js></SCRIPT>

    <SCRIPT SRC=./model/InsumoCostosHistoricosReportModel.js></SCRIPT>
    <SCRIPT SRC=./view/reports/CostosHistoricosReportWindow.js></SCRIPT>


</head>
<body></body>
<SCRIPT>

    isc.VLayout.create({
        width: "100%",
        height: "100%",
        members: [
            isc.ToolStrip.create({
                overflow: "hidden",
                width: "100%",
                autoDraw: false,
                members: [
                    isc.Label.create({
                        contents: '<?php echo $_POST["curDate"]; ?>',
                        autoDraw: false,
                        width: 100
                    }),
                    isc.Label.create({
                        contents: "<b>Sistema de Laboratorio - Costos</b>",
                        align: "center",
                        autoDraw: false,
                        width: '*'
                    }),

                    isc.ToolStripButton.create({
                        ID: "logoutButton",
                        icon: "[ISOMORPHIC]/../assets/images/logout.png",
                        autoDraw: false,
                        canHover: true,
                        showHover: true,
                        prompt: '<b>Salir del Sistema</b>',
                        click: function() {
                            isc.ask('Esta seguro de salir del sistema ?',
                                function (val) {
                                    if (val == true) {
                                        var datasource = DataSource.getDataSource('mdl_login');
                                        datasource.removeData({},function(dsResponse, data, dsRequest) {
                                            window.location.replace(glb_mainUrl );
                                        });
                                    }
                                });
                        }
                    }),
                    isc.Label.create({
                        contents: '<?php echo $_POST["usuario_name"]; ?>',
                        wrap: false,
                        autoDraw: false
                    })
                ]
            }),
            isc.HLayout.create({
                width: "100%",
                height: "100%",
                autoDraw: false,
                members: [
                    isc.SectionStack.create({
                        ID: "sectionStack",
                        align: "left",
                        showResizeBar: true,
                        visibilityMode: "multiple",
                        width: "15%",
                        height: "100%",
                        border: "1px solid blue",
                        autoDraw: false,
                        sections: [
                            {
                                title: "Opciones",
                                expanded: true,
                                canCollapse: true,
                                items: [
                                    isc.SystemTreeMenu.create()
                                ]
                            },
                            {
                                title: "Preferidos",
                                expanded: true,
                                canCollapse: true
                            }
                        ]
                    }),
                    isc.VLayout.create({
                        width: "90%",
                        autoDraw: false,
                        members: [
                            isc.Label.create({
                                contents: "Details",
                                align: "center",
                                overflow: "hidden",
                                height: "70%",
                                border: "1px solid blue",
                                autoDraw: false
                            })
                        ]
                    })
                ]
            })
        ]
    });


</SCRIPT>
</html>
