/**
 * Lugar donde se definien las variables de configuracion de la aplicacion
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:30:48 -0500 (dom, 24 ene 2016) $
 */


/**
 * @cfg {String} glb_DataUrl
 * Define el directorio base para llamar a las operaciones de
 * datos.
 */
var glb_dataUrl = '/flabcostosapp_v2/index.php/';

/**
 * @cfg {String} glb_mainUrl
 * Define el directorio base de la aplicacion
 */
var glb_mainUrl = '/flabcostosapp_v2/';

/**
 * @cfg {int} glb_empresaId
 * Define la empresa sobre la que esta logeado el usuario
 * debe ser seteada al iniciarse el sistema luego del login.
 */
var glb_empresaId;

/**
 * @cfg {String} glb_photoUrl
 * Define el directorio base donde se colocan las fotos de los atletas
 */
var glb_photoUrl = '../../photos';

/**
 * @cfg {String} glb_photoMaleUrlurl
 * default para la imagen de foto default de varon
 */
var glb_photoMaleUrl = glb_photoUrl + "/user_male.png";
/**
 * @cfg {String} glb_photoFemaleUrl
 * @cfg {String} glb_photoMaleUrlurl
 * default para la imagen de foto default de varon
 */
var glb_photoFemaleUrl = glb_photoUrl + "/user_female.png";

// Para marcaidaciones

/**
 * @cfg {String} glb_RE_onlyValidText
 * Define la expresion regular para marcaidaciones de texto marcaido
 */
var glb_RE_onlyValidText = '^[A-Za-z0-9][A-Za-z0-9 ._\/-ÁÉÍÓÚáéíóuñÑ]*[A-Za-z0-9.]$';

/**
 * @cfg {String} glb_RE_onlyValidText
 * Define la expresion regular para marcaidaciones de texto marcaido
 */
var glb_RE_onlyValidTextWithComma = '^[A-Za-z0-9][A-Za-z0-9 ._\/-ÁÉÍÓÚáéíóuñÑ,]*[A-Za-z0-9.]$';

/**
 * @cfg {String} glb_MSK_phone
 * Define la mascara para los telefonos del sistema
 */
var glb_MSK_phone = '##########';

/* @cfg {String} glb_defaultDateFormat
 * Define el formato default de input date
 */
var glb_defaultInputDateFormat = 'DMY';


/* @cfg {String} glb_RE_url
 * Define la expresion regular para verificar URL
 */
var glb_RE_url = "^(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*$";

/* @cfg {String} glb_RE_email
 * Define la expresion regular para verificar email
 */
var glb_RE_email = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)";

/* @cfg {String} glb_RE_alpha_dash
 * Define la expresion regular para verificar alfanumerico , guion bajo y guion
 */
var glb_RE_alpha_dash = "^[a-zA-Z0-9]+[_-]*[a-zA-Z0-9]+$";

/* @cfg {String} glb_systemident
 * Define a que sistema pertenece este config
 */
var glb_systemident = 'labcostos';

/* @cfg {String} glb_reportServerUrl
 * Define el url basico del  sevidor de reportes
 */
var glb_reportServerUrl = 'http://192.168.18.30:8080/jasperserver';

var glb_reportServerUser = 'flabscarana';
var glb_reportServerPsw = 'flabs202106';


Date.setShortDisplayFormat("toEuropeanShortDate");
Date.setShortDatetimeDisplayFormat("toEuropeanShortDatetime");
Date.setInputFormat("DMY");
