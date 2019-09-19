
/**
 * Clase que crea el pane container para el tab de informacion de los ingresos de un insumo que afectan
 * el calculo del valor de ajuste
 *
 *
 * $Author: aranape $
 * $Date: 2014-06-24 03:03:08 -0500 (mar, 24 jun 2014) $
 * $Rev: 240 $
 */
isc.defineClass("InsumoEntriesAssocForm", "VLayout");
isc.InsumoEntriesAssocForm.addProperties({
    title: 'Usado Por',
    autoCenter: true,
    autoDraw: false,
    autoSize: false,
    height: 410,
    //  width: 870,
    ID: 'InsumoEntriesAssocFormID',
    infoKey: undefined,
    /**
     * Llamada couando la llave principal indica que ha camado  en este caso
     * lo que hace es limpiar la grilla de resultados.
     */
    onInfoKeyChanged: function(formRecord) {
        InsumoEntriesInfoLabel.setContents('<span style="font-weight:bold; font-size:16px">' + formRecord.insumo_descripcion + '</span> (' + formRecord.insumo_codigo + ')');
    },
    /**
     * Requerido por TabSetExt cuando necesita refresacar la lista de historicos.
     */
    getInfoMember: function() {
        return this.getMember('usedByList');
    },
    initWidget: function() {
        isc.Label.create({
            ID: 'InsumoEntriesInfoLabel',
            height: 30,
            padding: 5,
            valign: "center",
            wrap: false,
            contents: undefined}
        );
        // Lista de marcas
        isc.ListGrid.create({
            autoDraw: false,
            ID: "insumoEntriesAssocList",
            height: 370,
            dataSource: "mdl_insumo_entries_assoc",
            fetchOperation: 'fetchForInsumosEntriesAssoc',
            textMatchStyle: 'exact',
            showHeaderMenuButton: false,
            showHeaderContextMenu: false,
            autoFetchData: false,
            alternateRecordStyles: true,
            dataPageSize: 25,
            canReorderFields: false,
            canSort: false,
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
                                             insumoEntriesAssocList.invalidateCache();
                                         }
                                     })
                                 ]
                             })],
            fields: [
                {name: "insumo_entries_fecha", width: '15%'},
                {name: "insumo_entries_qty", width: '30%'},
                {name: "insumo_entries_value", width: '30%'},
                {name: "insumo_factor_ajuste", width: '25%'}
            ]
        });

        this.addMember(InsumoEntriesInfoLabel);
        this.addMember(insumoEntriesAssocList);
        this.Super("initWidget", arguments);

        insumoEntriesAssocList.filterData({insumo_id: this.infoKey});

    }
});


/**
 * Atributos y funciones de clase que apoyan la creacion de unica unica instancia.
 */
isc.InsumoEntriesAssocForm.addClassProperties({
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
     * @returns {Object} la instancia del objeto tipo InsumoEntriesAssocForm
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