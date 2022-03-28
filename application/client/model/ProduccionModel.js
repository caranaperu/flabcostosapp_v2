
isc.defineClass("RestDataSourceProduccion", "RestDataSourceExt");

isc.RestDataSourceProduccion.create({
    /**
     * Definicion del modelo para los ingresos produccion de los modos de aplicacion.
     *
     *
     * @version 1.00
     * @since 1.00
     * $Author: aranape $
     * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
     */
    ID: "mdl_produccion",
    fields: [
        {
            name: "produccion_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {
            name: "produccion_fecha",
            title:"Fecha Ingreso",
            type: 'date',
            align: 'left'
        },
        {
            name: "taplicacion_entries_id",
            title: "Modo Aplicacion",
            foreignKey: "mdl_taplicacion_entries.taplicacion_entries_id",
            required: true
        },
        {
            name: "produccion_qty",
            title: "Cantidad",
            required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 1.00,
                max: 99999999.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        // solo presentacion
        {
            name: "taplicacion_entries_descripcion",
            title: "Modo de Aplicacion"
        }
    ],
    fetchDataURL: glb_dataUrl + 'produccionController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'produccionController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'produccionController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'produccionController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
            dataProtocol: "postParams"
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        }
    ]
});