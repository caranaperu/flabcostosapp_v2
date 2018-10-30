/**
 * Clase que prepara la ventana para la vista del reporte de records
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2015-02-22 22:10:50 -0500 (dom, 22 feb 2015) $
 * $Rev: 352 $
 */
isc.defineClass("ReportsOutputWindow", "Window");
isc.ReportsOutputWindow.addProperties({
    ID: 'reportsOutputWindow',
    canDragResize: true,
    showFooter: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '970',
    height: '700',
    title: 'Reporte de Records',
    _htmlPane: undefined,
    /**
     * Metodo para cambiar el url que presenta el pane de salida
     * del reporte
     *
     * @param String url , el URL del reporte a presentar
     */
    setNewContents: function (url) {
        this._htmlPane.setContentsURL(url);
    },
    // Inicialiamos los widgets interiores
    initWidget: function () {
        this.Super("initWidget", arguments);
        this._htmlPane = isc.HTMLPane.create({
            //  ID: "reportPane",
            showEdges: false,
            contentsURL: reportsOutputWindow.source,
            contentsType: "page",
            height: '90%'
        })

        // Botones principales del header
        var formButtons = isc.HStack.create({
            membersMargin: 10,
            height: '5%',
            layoutAlign: "center", padding: 5, autoDraw: false,
            align: 'center',
            members: [isc.Button.create({
                    //ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function () {
                        reportsOutputWindow.hide();
                    }
                })
            ]
        });

        var layout = isc.VLayout.create({
            width: '100%',
            height: '*',
            members: [
                this._htmlPane,
                formButtons
            ]
        });

        this.addItem(layout);
    }
});

/**
 * Atributos y funciones de clase que apoyan la creacion de unica unica instancia.
 */
isc.ReportsOutputWindow.addClassProperties({
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
     * En el caso exista y se indique el parametro url se pasa esa url a la instancia
     * para refrescar la ventana , de lo contrario solo devuelve la instancia actual.
     *
     * @param url url del web destino a mostrar en el htmlpane.
     * @returns {Object} la instancia del objeto tipo ReportsOutputWindow
     */
    getInstance: function(url) {
        if (this._myInstance === undefined) {
            this._myInstance = this.create({source: url});
        } else if (url) {
            this._myInstance.setNewContents(url);
        }

        return this._myInstance;
    }
});