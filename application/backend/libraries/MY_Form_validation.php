<?php

class MY_Form_validation extends CI_Form_validation {

    /**
     * Solo permite numeros y punto decimal
     *
     * @access public
     *
     * @param string $value valor a verificar
     *
     * @return bool true or false
     */
    public function decimal( $value) : bool {
        $regx = '/^[-+]?[0-9]*\.?[0-9]*$/';
        if (!preg_match($regx, $value)) {
            return FALSE;
        }

        return TRUE;
    }

    /**
     * Solo permite letras,numeros,blnacos,underscores, guiones,slashes
     * pero no debe empezar en nada que no sea letra o numero.
     *
     * @access public
     *
     * @param string $value valor a verificar
     *
     * @return bool true or false
     */
    public function onlyValidText(string $value) : bool {
        $regx = "/^[A-Za-z0-9][A-Za-z0-9 ._\/-ÁÉÍÓÚáéíóuñÑ]*[A-Za-z0-9.]$/";
        if (!preg_match($regx, $value)) {
            return FALSE;
        }

        return TRUE;
    }

    /*
     * verfica si una fecha es valida
     *
     * @param string $date
     * @param bool $verifyNull si es true se verificara de lo contrario se asumira correcto
     * @return bool true o false
     */

    public function validDate(string $date, bool $verifyNull = TRUE) : bool {
        // casos raros primero
        if (is_null($date) || $date === 'null') {
            if ($verifyNull) {
                return false;
            } else {
                return true;
            }
        }
        // Cambio de metodo para verificar la fecha ya que en 32 bts strtotime
        // no puede con fechas del siglo pasado.
        $date = date_create($date);

        $y = date_format($date, 'Y');
        $m = date_format($date, 'm');
        $d = date_format($date, 'd');

        // TODO: Verificar en 64 bits aunque sea por curiosidad
        //        $t = strtotime($date);
        //        if ($t == '0') {
        //            return false;
        //        }

        //        $m = date('m', $t);
        //        $d = date('d', $t);
        //        $y = date('Y', $t);
        return checkdate($m, $d, $y);
    }

    /**
     * Verfica como correcto si el campo esta en blanco o la
     * fecha es correcta.
     * Es para los casos en que la fecha no es requerida pero si
     * tiene algun valor debe ser una fecha valida.
     *
     * @param string $date
     *
     * @return bool true o false
     */
    public function validDateOrEmpty(string $date) : bool {
        // si la fecha esta vacia o la fecha esta en null
        // indicamos correcto.
        if (is_null($date) || strlen($date) == 0 || $date === 'null') {
            return true;
        }

        return $this->validDate($date);
    }

    /**
     * Para validar url del tipo http://www.domain como
     * minimo , requiere que se ponga el protocolo.
     *
     * @param string $url la direccion URL a validar
     *
     * @return bool true si es ok , false de lo contrario
     */
    public function validateURL(string $url) : bool {
        $regex = "((https?|ftp)\:\/\/)?"; // SCHEME
        $regex .= "([a-z0-9+!*(),;?&=\$_.-]+(\:[a-z0-9+!*(),;?&=\$_.-]+)?@)?"; // User and Pass
        $regex .= "([a-z0-9-.]*)\.([a-z]{2,3})"; // Host or IP
        $regex .= "(\:[0-9]{2,5})?"; // Port
        $regex .= "(\/([a-z0-9+\$_-]\.?)+)*\/?"; // Path
        $regex .= "(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?"; // GET Query
        $regex .= "(#[a-z_.-][a-z0-9+\$_.-]*)?"; // Anchor

        if (!preg_match("/^$regex$/", $url)) {
            return FALSE;
        }

        return TRUE;
    }

    /**
     * Greather than , verifica si el campo es mayor que el campo enviado
     * en fied.
     *
     * @access    public
     *
     * @param string  $str con el valor numerico a chequear
     * @param string $field con el nombre del campo con el que se va a chequear
     *
     * @return    bool
     */
    public function greater_than_field(string $str, string $field) : bool {
        if (!isset($_POST[$field])) {
            return FALSE;
        }

        $checkValue = $_POST[$field];

        if (!is_numeric($str) || !is_numeric($checkValue)) {
            return FALSE;
        }

        return $str > $checkValue;
    }

    /*
     * Less than , verifica si el campo es menor  que el campo enviado
     * en fied.
     *
     * @access	public
     *
     * @param string $str con el valor numerico a chequear
     * @param string $field con el nombre del campo con el que se va a chequear
     * @return	bool
     */

    public function less_than_field(string $str,string $field) : bool {
        if (!isset($_POST[$field])) {
            return FALSE;
        }

        $checkValue = $_POST[$field];

        if (!is_numeric($str) || !is_numeric($checkValue)) {
            return FALSE;
        }

        return $str < $checkValue;
    }

    /**
     * Verifica si un campo fecha es mayor a otro.
     *
     * @param string  $str la fecha contiene a fecha a cehquear si esta en el futuro.
     * @param string $field El nombre del campo que contiene la fecha limite superior.
     *
     * @return bool
     */
    public function isFuture_date(string $str, string $field) : bool {
        if (!isset($_POST[$field])) {
            return FALSE;
        }

        $checkValue = strtotime($_POST[$field]);
        $otherDate = strtotime($str);
        if ($checkValue == '0' || $otherDate == '0') {
            return FALSE;
        }

        return $otherDate > $checkValue;
    }

    /**
     * Verifica si un campo fecha es mayor o igual  a otro.
     *
     * @param string $str la fecha contiene a fecha a cehquear si esta en el futuro.
     * @param string $field El nombre del campo que contiene la fecha limite superior.
     *
     * @return bool
     */
    public function isFutureOrSame_date(string $str, string $field) : bool {
        if (!isset($_POST[$field])) {
            return FALSE;
        }

        $checkValue = strtotime($_POST[$field]);
        $otherDate = strtotime($str);
        if ($checkValue == '0' || $otherDate == '0') {
            return FALSE;
        }

        return $otherDate >= $checkValue;
    }

    /**
     * Verifica si el campo es valido , siempre que otro campo
     * representado por el parametro este en true.
     *
     * @param mixed $field
     *
     * @return boolean true si es valido
     *
     */
    public function dependsOnBoolean($field) : bool {
        if (isset($field)) {
            if ($field != FALSE) {
                return true;
            }
        }

        return false;
    }

    /**
     * Verifica si un campo es mayor o igual  a otro.
     *
     * @param string  $str el numero a validar.
     * @param string $min el minimo numero admisible.
     *
     * @return boolean
     */
    public function greater_than_equal($str, $min) : bool {
        if (!is_numeric($str)) {
            return FALSE;
        }

        return $str >= $min;
    }

    /**
     * Verifica si es booleano , el problema de is_bool es que no verifica
     * en el caso el parametro no sea string, en este caso 0 y 1 no se tomaran
     * como booleanos.
     *
     * @access public
     *
     * @param mixed $value valor a verificar
     *
     * @return bool true or false
     */
    function is_boolean($value) : bool{
        if ($value == true || $value == TRUE || $value == 'true' || $value == 'TRUE' ||
        $value == false || $value == FALSE || $value == 'false' || $value == 'FALSE' ) {
            return true;
        }
        return false;
    }

}