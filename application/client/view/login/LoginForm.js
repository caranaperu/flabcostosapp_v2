
/**
 * Clase que crea la ventana de login
 *
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinLoginForm", "WindowBasicFormExt");

isc.WinLoginForm.addProperties({
    ID: "winLoginForm",
    title: "Ingreso al Sistema",
    width: 320, height: 180,
    canDragResize: true,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formLogin",
            padding: 5,
            errorOrientation: "right",
            validateOnExit: true,
            dataSource: mdl_login,
            autoFocus: true,
            formMode: 'add', // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'usuarios_code',
            //disableValidation: true,
            fields: [
                {name: "usuarios_code", width: 150, size: 15, endRow: true},
                {name: "usuarios_password", size: 20, width: 160, type: "password",endRow: true}
            ],
            postSaveData: function(formMode,data)  {
                window.location = glb_dataUrl + 'systemEntryController?op=fetch&libid=SmartClient';
            }
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
        this.getFormButton('save').setTitle('Ingresar');
        this.getFormButton('exit').hide();
    }

});