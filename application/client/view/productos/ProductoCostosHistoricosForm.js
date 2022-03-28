
/**
 * Clase que crea el pane container para el tab de informacion de costos historicos de un producto..
 * implementa infoKey , onInfoKeyChanged y getInfoMember para que el TabSetExt pueda coordinar los
 * datos a mostrar con la forma principal de ingrreso de datos.
 *
 *
 * $Author: aranape $
 * $Date: 2014-06-24 03:03:08 -0500 (mar, 24 jun 2014) $
 * $Rev: 240 $
 */
isc.defineClass("ProductoCostosHistoricosForm", "VLayout");
isc.ProductoCostosHistoricosForm.addProperties({
    title: 'Costos Historicos',
    autoCenter: true,
    autoDraw: false,
    autoSize: false,
    height: 415,
    //  width: 870,
    ID: 'ProductoCostosHistoricosFormID',
    infoKey: undefined,
    /**
     * Llamada couando la llave principal indica que ha camado  en este caso
     * lo que hace es limpiar la grilla de resultados.
     */
    onInfoKeyChanged: function(formRecord) {
        // Reseteamos las fechas.
        ProductoHistoryDateForm.setValue("p_date_from",'01/01/2000');
        ProductoHistoryDateForm.setValue("p_date_to",ProductoHistoryDateForm.getField('p_date_to').getDefaultChooserDate());

        ProductoHistoricoInfoLabel.setContents('<span style="font-weight:bold; font-size:16px">' + formRecord.insumo_descripcion + '</span> (' + formRecord.insumo_codigo + ')');
    },
    /**
     * Requerido por TabSetExt cuando necesita refresacar la lista de historicos.
     */
    getInfoMember: function() {
        return this.getMember('historicoProductoList');
    },
    initWidget: function() {
        isc.Label.create({
            ID: 'ProductoHistoricoInfoLabel',
            height: 30,
            padding: 5,
            valign: "center",
            wrap: false,
            contents: undefined}
        );
        isc.DynamicFormExt.create({
            ID: "ProductoHistoryDateForm",
         //   autoSize: true,
            numCols: 4,
            colWidths: ["25%","25%" ,"15%","*"],
            height: 64,
            border:"1px solid grey",
            padding: 5,
            items: [
                {name: "p_date_from", title:'Desde',useTextField: false,type:'date', showPickerIcon: true, width: 100,required: true,
                    defaultValue: '01/01/2000',
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && ProductoHistoryDateForm.getValue('p_date_to')) {
                            if (value.getTime() > ProductoHistoryDateForm.getValue('p_date_to').getTime()) {
                                isc.say('La fecha inicial no puede ser mayor que la final');
                                return false;
                            }
                        }
                        return true;
                    }},
                {name: "p_date_to", title:'Hasta',useTextField: false,type:'date', showPickerIcon: true, width: 100,required: true,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && ProductoHistoryDateForm.getValue('p_date_from')) {
                            if (value.getTime() < ProductoHistoryDateForm.getValue('p_date_from').getTime()) {
                                isc.say('La fecha final no puede ser menor que la inicial');
                                return false;
                            }
                        }
                        return true;
                    }},
                { name: "searchButton", type: "ButtonItem", title: "Filter",width: 100,colSpan: 4,align: 'center',
                    click: function () {
                        var p_date_from = ProductoHistoryDateForm.getValue("p_date_from");
                        p_date_from.setHours(0,0,1);

                        var p_date_to = ProductoHistoryDateForm.getValue("p_date_to");
                        p_date_to.setHours(23,59,59);

                        historicoProductoList.fetchData(
                            {insumo_id: ProductoCostosHistoricosFormID.infoKey,
                                p_date_from: p_date_from.toSerializeableDate(),
                                p_date_to: p_date_to.toSerializeableDate()
                            });
                    }
                }
            ]
           // cellBorder: 1

        });
        // Lista de marcas
        isc.ListGrid.create({
            autoDraw: false,
            ID: "historicoProductoList",
            height: 306,
            dataSource: "mdl_producto_costos_historico",
            fetchOperation: 'fetchForProductoCostosHistoricos',
            showHeaderMenuButton: false,
            showHeaderContextMenu: false,
            autoFetchData: false,
            alternateRecordStyles: true,
            dataPageSize: 25,
            canReorderFields: false,
            showFilterEditor: false,
            gridComponents: ["header",  "body",
                             isc.ToolStrip.create({
                                 width: "100%", height: 24,
                                 autoDraw: false,
                                 members: [
                                     isc.ToolStripButton.create({
                                         icon: "[SKIN]/actions/refresh.png",
                                         prompt: "Actualizar lista",
                                         click: function() {
                                             historicoProductoList.invalidateCache();
                                         }
                                     })
                                 ]
                             })],
            fields: [
                {name: "costos_list_detalle_id", hidden: true},
                {name: "costos_list_fecha", width: '15%'},
                {name: "costos_list_descripcion", width: '40%'},
                {name: "moneda_descripcion", width: '10%'},
                {name: "costos_list_detalle_costo_base", width: '11%',format: ",0.00"},
                {name: "costos_list_detalle_costo_agregado", width: '12%',format: ",0.00"},
                {name: "costos_list_detalle_costo_total", width: '12%',format: ",0.00"}
            ],
            getCellCSSText: function(record, rowNum, colNum) {
                if (record.costos_list_detalle_costo_base <=0 ||
                    record.costos_list_detalle_costo_agregado <=0 ||
                    record.costos_list_detalle_costo_total <=0) {
                    return "font-weight:bold; color:red;";
                }
            }
        });

        this.addMember(ProductoHistoricoInfoLabel);
        this.addMember(ProductoHistoryDateForm);
        this.addMember(historicoProductoList);
        this.Super("initWidget", arguments);

        historicoProductoList.filterData({insumo_id: this.infoKey});

    }
});


/**
 * Atributos y funciones de clase que apoyan la creacion de unica unica instancia.
 */
isc.ProductoCostosHistoricosForm.addClassProperties({
    _myInstance: undefined,
    /**
     * Metodo que sirve para determinar si la instancia esta creada on  no.
     * @returns {boolean} true si esta creada
     */
    isCreated: function() {
        if (this._myInstance === undefined)  {
            return false;
        }
        return true;
    },
    /**
     * Retorna la instancia de la ventana , si no existe la crea de lo contrario
     * retorna la instancia creada.
     *
     * Es un override al default create.
     *
     * @returns {Object} la instancia del objeto tipo ProductoCostosHistoricosForm
     */
    create: function(args) {
        if (this._myInstance === undefined) {
            console.log('Paso a crear');
            this._myInstance = this.Super('create',arguments);
        }
        console.log('Retornar la instancia');
        return this._myInstance;
    }

});