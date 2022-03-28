/**
 * Definicion del modelo para las jefaturas municipales
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("RestDataSourceProceso", "RestDataSourceExt");

isc.RestDataSourceProceso.create({
    ID: "mdl_proceso_costo",
    fields: [
        {name: "costos_list_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText},{type: "lengthRange", max: 60}]
        },
        {name: "costos_list_fecha_desde",title:'Fecha Desde',type: 'date',required: true},
        {name: "costos_list_fecha_hasta",title:'Fecha Hasta',type: 'date',required: true},
        {name: "costos_list_fecha_tcambio",title:'Fecha Tipo Cambio',type: 'date',required: true}
    ],
    // observar que la poeracion add es mapeada a la operacion fetch, ya que es un proceso no una operacion crud que calculara los costos.
    addDataURL: glb_dataUrl + 'costosListController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "add", dataProtocol: "postParams"},
    ]
});