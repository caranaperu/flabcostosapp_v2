<html>
<head>
    <meta charset="utf-8">
    <title>Future Labs - Costos</title>
    <SCRIPT>var isomorphicDir = "../../../common/client/isomorphic/";</SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Core.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Foundation.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Containers.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Grids.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Forms.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_DataBinding.js></SCRIPT>

    <SCRIPT SRC=../../../common/client/isomorphic/skins/EnterpriseBlue/load_skin.js></SCRIPT>

    <SCRIPT SRC=./appConfig.js></SCRIPT>

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

    <SCRIPT SRC=view/insumos/InsumoUsedByForm.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoUsedByModel.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoModel.js></SCRIPT>
    <SCRIPT SRC=./model/InsumoProductoDetalleModel.js></SCRIPT>

    <SCRIPT SRC=./view/insumos/InsumoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/insumos/InsumoForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProductoCostosHistoricoModel.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoCostosHistoricosForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProductoModel.js></SCRIPT>
    <SCRIPT SRC=./model/ProductoDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoForm.js></SCRIPT>


    <SCRIPT SRC=view/reports/ReportsOutputWindow.js></SCRIPT>


    <SCRIPT SRC=./view/reports/CostosHistoricosReportWindow.js></SCRIPT>

    <SCRIPT SRC=./model/PresentacionModel.js></SCRIPT>
    <SCRIPT SRC=./view/presentacion/PresentacionWindow.js></SCRIPT>
    <SCRIPT SRC=./view/presentacion/PresentacionForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoCostoGlobalModel.js></SCRIPT>
    <SCRIPT SRC=./view/tcosto_global/TipoCostoGlobalWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tcosto_global/TipoCostoGlobalForm.js></SCRIPT>


    <SCRIPT SRC=./model/TipoCostoGlobalEntriesModel.js></SCRIPT>
    <SCRIPT SRC=./view/tcosto_global_entries/TipoCostoGlobalEntriesWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tcosto_global_entries/TipoCostoGlobalEntriesForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProcesosModel.js></SCRIPT>
    <SCRIPT SRC=./view/procesos/ProcesosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/procesos/ProcesosForm.js></SCRIPT>

    <SCRIPT SRC=./model/SubProcesosModel.js></SCRIPT>
    <SCRIPT SRC=./view/subprocesos/SubProcesosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/subprocesos/SubProcesosForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProductoProcesosModel.js></SCRIPT>
    <SCRIPT SRC=./model/ProductoProcesosDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/producto_procesos/ProductoProcesosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/producto_procesos/ProductoProcesosForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoAplicacionModel.js></SCRIPT>
    <SCRIPT SRC=./model/TipoAplicacionEntriesModel.js></SCRIPT>

    <SCRIPT SRC=./view/taplicacion/TipoAplicacionWindow.js></SCRIPT>
    <SCRIPT SRC=./view/taplicacion/TipoAplicacionForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoAplicacionProcesosModel.js></SCRIPT>
    <SCRIPT SRC=./model/TipoAplicacionProcesosDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/taplicacion_procesos/TipoAplicacionProcesosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/taplicacion_procesos/TipoAplicacionProcesosForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProduccionModel.js></SCRIPT>
    <SCRIPT SRC=./view/produccion/ProduccionWindow.js></SCRIPT>
    <SCRIPT SRC=./view/produccion/ProduccionForm.js></SCRIPT>

    <SCRIPT SRC=./model/CostoProcesoModel.js></SCRIPT>
    <SCRIPT SRC=./view/costos/CostoProcesoWindow.js></SCRIPT>

    <SCRIPT SRC=./model/CostoListModel.js></SCRIPT>
    <SCRIPT SRC=./model/CostoListDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/costos/CostosListWindow.js></SCRIPT>
    <SCRIPT SRC=./view/costos/CostosListForm.js></SCRIPT>
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
