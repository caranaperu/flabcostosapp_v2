/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los registros de Personals.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinPerfilWindow", "WindowGridListExt");
isc.WinPerfilWindow.addProperties({
    ID: "winPerfilWindow",
    title: "Perfiles",
    width: 650, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "PerfilList",
            alternateRecordStyles: true,
            dataSource: mdl_perfil,
            autoFetchData: true,
            dataPageSize: 40,
            // Estos 2 permiten que solo se lea lo que el tamaño de la pagina indica
            drawAheadRatio: 1,
            drawAllMaxCells: 0,
            fields: [
                {name: "sys_systemcode", editorType: "comboBoxExt",
                    valueField: "sys_systemcode",
                    displayField: "sys_systemcode",
                    optionDataSource: mdl_sistemas, // TODO: podria ser tipo basic para no relleer , ver despues
                    pickListFields: [{name: "sys_systemcode", width: '25%'}, {name: "sistema_descripcion", width: '75%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    width: '20%'
                },
                {name: "perfil_codigo", width: '15%'},
                {name: "perfil_descripcion", width: '65%'}],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            autoFitWidthApproach: 'both',
            fetchOperation: 'fetchFull'
                    //  filterLocalData: false
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
