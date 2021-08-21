isc.RestDataSource.create({
    /**
     * Definicion del modelo para los ingresos de cada entrada de valor para cada tipo de costo global valido
     * desde una determinada fecha.
     *
     * @version 1.00
     * @since 17-MAY-2021
     * @Author: Carlos Arana Reategui
     */
    ID: "mdl_tcosto_global_entries",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    showPrompt: true,
    fields: [
        {
            name: "tcosto_global_entries_id",
            title: "Id",
            primaryKey: "true",
            required: true
        },
        {
            name: "tcosto_global_entries_fecha_desde",
            title: "Fecha Desde",
            type: 'date',
            align: 'left',
            required: true
        },
        {
            name: "tcosto_global_codigo",
            title: "Tipo Costo Global",
            foreignKey: "mdl_tcosto_global.tcosto_global_codigo",
            required: true
        },
        {
            name: "tcosto_global_entries_valor",
            title: "Valor",
            required: true,
            type: 'double',
            format: "0.00",
            validators: [{
                type: 'floatRange',
                min: 1.00,
                max: 1000000000.00
            }, {
                type: "floatPrecision",
                precision: 2
            }]
        },
        {name: "moneda_codigo", title: 'Codigo', foreignKey: "mdl_moneda.moneda_codigo", required: true},
        // Solo visualizacion
        {name: "moneda_descripcion", title: "Descripcion"},
        {
            name: "tcosto_global_descripcion",
            title: "Tipo Costo Global"
        }
    ],
    fetchDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoCostoGlobalEntriesController?op=del&libid=SmartClient',
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
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function(dsRequest) {
        var data = this.Super("transformRequest", arguments);
        // Si esxiste criteria y se define que proviene de un advanced filter y la operacion es fetch,
        // construimos un objeto JSON serializado como texto para que el lado servidor lo interprete correctamente.
        if (data.criteria && data._constructor == "AdvancedCriteria" && data._operationType == 'fetch') {
            var advFilter = {};
            advFilter.operator = data.operator;
            advFilter.criteria = data.criteria;

            // Borramos datos originales que no son necesario ya que  seran trasladados al objeto JSON
            delete data.operator;
            delete data.criteria;
            delete data._constructor;

            // Creamos el objeto json como string para pasarlo al rest
            // finalmente se coloca como data del request para que siga su proceso estandard.
            var jsonCriteria = isc.JSON.encode(advFilter, {prettyPrint: false});
            if (jsonCriteria) {
                //console.log(jsonCriteria);
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});