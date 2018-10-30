
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
isc.defineClass("InsumoUsedByForm", "VLayout");
isc.InsumoUsedByForm.addProperties({
    title: 'Usado Por',
    autoCenter: true,
    autoDraw: false,
    autoSize: false,
    height: 400,
    //  width: 870,
    ID: 'InsumoUsedByFormID',
    infoKey: undefined,
    /**
     * Llamada couando la llave principal indica que ha camado  en este caso
     * lo que hace es limpiar la grilla de resultados.
     */
    onInfoKeyChanged: function(formRecord) {
        usedByInfoLabel.setContents('<span style="font-weight:bold; font-size:16px">' + formRecord.insumo_descripcion + '</span> (' + formRecord.insumo_codigo + ')');
    },
    /**
     * Requerido por TabSetExt cuando necesita refresacar la lista de historicos.
     */
    getInfoMember: function() {
        return this.getMember('usedByList');
    },
    initWidget: function() {
        isc.Label.create({
            ID: 'usedByInfoLabel',
            height: 30,
            padding: 5,
            valign: "center",
            wrap: false,
            contents: undefined}
        );
        // Lista de marcas
        isc.ListGrid.create({
            autoDraw: false,
            ID: "usedByList",
            height: 370,
            dataSource: "mdl_insumo_used_by",
            fetchOperation: 'fetchForInsumosUsedBy',
            textMatchStyle: 'exact',
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
                                             usedByList.invalidateCache();
                                         }
                                     })
                                 ]
                             })],
            fields: [
                {name: "insumo_codigo", width: '15%'},
                {name: "insumo_descripcion", width: '45%'},
                {name: "empresa_razon_social", width: '40%'}
            ]
        });

        this.addMember(usedByInfoLabel);
        this.addMember(usedByList);
        this.Super("initWidget", arguments);

        usedByList.filterData({insumo_id: this.infoKey});

    }
});


/**
 * Atributos y funciones de clase que apoyan la creacion de unica unica instancia.
 */
isc.InsumoUsedByForm.addClassProperties({
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
     * @returns {Object} la instancia del objeto tipo InsumoUsedByForm
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