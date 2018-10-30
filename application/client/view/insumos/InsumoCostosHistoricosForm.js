
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
isc.defineClass("InsumoCostosHistoricosForm", "VLayout");
isc.InsumoCostosHistoricosForm.addProperties({
    title: 'Marcas Personales',
    autoCenter: true,
    autoDraw: false,
    autoSize: false,
    height: 400,
    //  width: 870,
    ID: 'InsumoCostosHistoricosFormID',
    infoKey: undefined,
    /**
     * Llamada couando la llave principal indica que ha camado  en este caso
     * lo que hace es limpiar la grilla de resultados.
     */
    onInfoKeyChanged: function(formRecord) {
        // Reseteamos las fechas.
        historyDateForm.setValue("p_date_from",'01/01/2000');
        historyDateForm.setValue("p_date_to",historyDateForm.getField('p_date_to').getDefaultChooserDate());

        historicoInfoLabel.setContents('<span style="font-weight:bold; font-size:16px">' + formRecord.insumo_descripcion + '</span> (' + formRecord.insumo_codigo + ')');
    },
    /**
     * Requerido por TabSetExt cuando necesita refresacar la lista de historicos.
     */
    getInfoMember: function() {
        return this.getMember('historicoList');
    },
    initWidget: function() {
        isc.Label.create({
            ID: 'historicoInfoLabel',
            height: 30,
            padding: 5,
            valign: "center",
            wrap: false,
            contents: undefined}
        );
        isc.DynamicFormExt.create({
            ID: "historyDateForm",
         //   autoSize: true,
            numCols: 4,
            colWidths: ["100","100" ,"100","100"],
            height: 64,
            border:"1px solid grey",
            padding: 5,
            items: [
                {name: "p_date_from", title:'Desde',useTextField: false,type:'date', showPickerIcon: true, width: 100,required: true,
                    defaultValue: '01/01/2000',
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && historyDateForm.getValue('p_date_to')) {
                            if (value.getTime() > historyDateForm.getValue('p_date_to').getTime()) {
                                isc.say('La fecha inicial no puede ser mayor que la final');
                                return false;
                            }
                        }
                        return true;
                    }},
                {name: "p_date_to", title:'Hasta',useTextField: false,type:'date', showPickerIcon: true, width: 100,required: true,
                    change: function (form, item, value, oldValue) {
                        // Verificamos que la fecha seleccionada sea menor que la final.
                        if (value && historyDateForm.getValue('p_date_from')) {
                            if (value.getTime() < historyDateForm.getValue('p_date_from').getTime()) {
                                isc.say('La fecha final no puede ser menor que la inicial');
                                return false;
                            }
                        }
                        return true;
                    }},
                { name: "searchButton", type: "ButtonItem", title: "Filter",width: 100,colSpan: 4,align: 'center',
                    click: function () {
                        historicoList.fetchData(
                            {insumo_id: InsumoCostosHistoricosFormID.infoKey,
                                p_date_from: historyDateForm.getValue("p_date_from").toSerializeableDate(),
                                p_date_to: historyDateForm.getValue("p_date_to").toSerializeableDate()
                            });
                    }
                }
            ]
           // cellBorder: 1

        });
        // Lista de marcas
        isc.ListGrid.create({
            autoDraw: false,
            ID: "historicoList",
            height: 306,
            dataSource: "mdl_insumo_costos_historico",
            fetchOperation: 'fetchForInsumosCostos',
            showHeaderMenuButton: false,
            showHeaderContextMenu: false,
            autoFetchData: false,
            alternateRecordStyles: true,
            dataPageSize: 25,
            canReorderFields: false,
            showFilterEditor: true,
            gridComponents: ["header",  "body",
                             isc.ToolStrip.create({
                                 width: "100%", height: 24,
                                 autoDraw: false,
                                 members: [
                                     isc.ToolStripButton.create({
                                         icon: "[SKIN]/actions/refresh.png",
                                         prompt: "Actualizar lista",
                                         click: function() {
                                             historicoList.invalidateCache();
                                         }
                                     })
                                 ]
                             })],
            fields: [
                {name: "insumo_history_fecha", width: '12%'},
                {name: "tinsumo_descripcion", width: '12%'},
                {name: "tcostos_descripcion", width: '12%'},
                {name: "unidad_medida_descripcion", width: '12%'},
                {name: "insumo_merma", width: '8%', align: 'right'},
                {name: "insumo_precio_mercado", width: '12%', align: 'right'},
                {name: "insumo_costo", width: '12%',align: 'right'},
                {name: "moneda_costo_descripcion", width: '10%'}
            ]
        });

        this.addMember(historicoInfoLabel);
        this.addMember(historyDateForm);
        this.addMember(historicoList);
        this.Super("initWidget", arguments);

        historicoList.filterData({insumo_id: this.infoKey});

    }
});


/**
 * Atributos y funciones de clase que apoyan la creacion de unica unica instancia.
 */
isc.InsumoCostosHistoricosForm.addClassProperties({
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
     * @returns {Object} la instancia del objeto tipo InsumoCostosHistoricosForm
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