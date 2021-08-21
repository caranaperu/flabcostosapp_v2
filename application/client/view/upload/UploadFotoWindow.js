/**
 * Clase que define una pequeña ventana que se utiliza para cargar las imagenes
 * al servidor.
 * Requiere saver el contenedro final de  la imagen usabdo el atributo imgContainer
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-29 23:58:26 -0500 (mar, 29 jul 2014) $
 * $Rev: 325 $
 */
isc.defineClass("WinUploadFoto", "Window");

isc.WinUploadFoto.addProperties({
    title: 'Cargar Foto',
    isModal: true,
    autoSize: true,
    showFooter: true,
    autoCenter: true,
    autoDraw: false,
    /**
     * @public
     * Contendra la referencial al contenedor de imagen donde colocarse
     * la imagen obtenida.
     *
     * @property {isc.Img} referencia al contenedor de la imagen
     */
    imgContainer: undefined,
    show: function() {
        this.Super("show", arguments);

        // Se pone el progress bar en porcentaje 0 y se inicializa el mensaje
        var progressBar = this.items[0].getField('pbFotoAdvance').canvas;
        progressBar.setPercentDone(0);
        this.setStatus('Indique algun archivo');
    },
    /**
     * @private
     * Metodo privado que se encarga de cargar la imagen al servidor.
     * Debera estar seteado el atributo imgContainer ya que al cargar la imagen
     * correctamente colocara el resultado en dicho container.
     *
     * El servidor debera tener un controller uploadFotoController el cual debera
     * retornar la respuesta de la siguiente manera.
     *
     * En caso de error :
     * {"sucess": "false","pe":[{"msg": "Error xxxxxxxxxx"}]}
     *
     * En caso de exito :
     * {"sucess": "true","data":[{imageUrl: "un url valido"}]}
     *
     */
    _doUpload: function() {
        var me = this;
        var uploadForm = me.items[0];
        var filesItem = uploadForm.getField('edtFotoSelect');
        var progressBar = uploadForm.getField('pbFotoAdvance').canvas;

        var _file = document.getElementById(filesItem.__tagId);

        progressBar.setPercentDone(0);

        if (_file.files.length === 0) {
            me.setStatus('Indique algun archivo');
            return;
        }

        if (_file.files[0].type.match(/image.*/)) {
            var data = new FormData();
            data.append('selectedImageFile', _file.files[0]);

            var request = new XMLHttpRequest();

            request.onreadystatechange = function() {
                if (request.readyState == 4) {
                    try {
                        var resp = JSON.parse(request.response);
                        if (resp.success == "false") {
                            me.setStatus(resp.pe[0].msg);
                        } else {
                            _file.value = '';
                            me.imgContainer.setSrc(resp.data.imageUrl);
                            me.setStatus('Cargado correctamente');
                            me.hide();
                        }
                    } catch (e) {
                        me.setStatus('Error de mensaje de retorno...');
                    }

                }
            };

            request.upload.addEventListener('progress', function(e) {
                var loadedPercent = parseInt(e.loaded / e.total * 100);
                progressBar.setPercentDone(loadedPercent);
            }, false);

            request.open('POST', glb_dataUrl + 'uploadFotoController');
            request.send(data);
        }
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
        var me = this;

        var form = isc.DynamicForm.create({
            ID: "uploadFotoForm",
            numCols: 2,
            width: 350,
            fields: [
                {name: 'edtFotoSelect', title: 'Foto', type: 'upload',
                    changed: function(form, item, value) {
                        me.setStatus('');
                    }},
                {name: 'pbFotoAdvance', showTitle: false, type: 'canvas', colSpan: 2,
                    width: '100%', endRow: true,
                    canvas: isc.Progressbar.create({
                        width: 346, height: 16
                    })
                }
            ]
        });
        var buttons = isc.HStack.create({
            height: 24,
            layoutAlign: "center", autoDraw: false,
            align: 'center',
            members: [isc.Button.create({
                    ID: "btnFotoDoLoad",
                    width: '100',
                    autoDraw: false,
                    title: "Cargar",
                    click: function(form, item) {
                        me._doUpload();
                    }
                }),
                isc.Button.create({
                    ID: "btnFotoExit",
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function(form, item) {
                        me.hide();
                    }
                })
            ]
        });

        this.addItem(form);
        this.addItem(buttons);
    }
});