/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los paises.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:28:16 -0500 (mar, 25 mar 2014) $
 * $Rev: 121 $
 */
isc.defineClass("WinCategoriasWindow", "WindowGridListExt");
isc.WinCategoriasWindow.addProperties({
    ID: "winCategoriasWindow",
    title: "Categorias",
    width: 550, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CategoriasList",
            alternateRecordStyles: true,
            dataSource: mdl_categorias,
            autoFetchData: true,
            fields: [
                {name: "categorias_codigo", title: "Codigo", width: '15%'},
                {name: "categorias_descripcion", title: "Nombre", width: '40%'},
                {name: "categorias_edad_inicial", title: "Desde", width: '12%'},
                {name: "categorias_edad_final", title: "Hasta", width: '12%'},
                {name: "categorias_valido_desde", title: "Valida Desde", width: '21%', filterEditorType: "DateItem"}
            ],
            getCellCSSText: function(record, rowNum, colNum) {
                if (this.getFieldName(colNum) === "categorias_codigo") {
                    if (record.categorias_protected === true) {
                        return "font-weight:bold; color:red;";
                    }
                }
            },
            isAllowedToDelete: function() {
                if (this.anySelected() === true) {
                    var record = this.getSelectedRecord();
                    // Si el registro tienen flag de protegido no se permite la grabacacion desde el GUI.
                    if (record.categorias_protected == true) {
                        isc.say('No puede eliminarse el registro debido a que es un regisro del sistema y esta protegido');
                        return false;
                    } else {
                        return true;
                    }
                }
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'categorias_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
