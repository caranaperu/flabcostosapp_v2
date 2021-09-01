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
    ]
});