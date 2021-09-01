/**
 * Definicion del modelo para la cabecera de las listas de coostos
 *
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2021-08-23 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.RestDataSource.create({
    ID: "mdl_costos_list",
    dataFormat: "json",
    jsonPrefix: '',
    jsonSuffix: '',
    fields: [
        {name: "costos_list_id", title: "id", primaryKey: "true", required: true},
        {name: "costos_list_descripcion", title: "Descripcion", required: true},
        {name: "costos_list_fecha_desde",title:'Fecha Desde',type: 'date',required: true},
        {name: "costos_list_fecha_hasta",title:'Fecha Hasta',type: 'date',required: true},
        {name: "costos_list_fecha_tcambio",title:'Fecha Tipo Cambio',type: 'date',required: true},
        {name: "costos_list_fecha",title:'Fecha Costos',type: 'datetime',required: true}
    ],
    // observar que la poeracion add es mapeada a la operacion fetch, ya que es un proceso no una operacion crud que calculara los costos.
    fetchDataURL: glb_dataUrl + 'costosListController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
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