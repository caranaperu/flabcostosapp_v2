--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12 (Ubuntu 10.12-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 12.7 (Ubuntu 12.7-0ubuntu0.20.04.1)

-- Started on 2021-07-17 04:16:39 -05

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 261 (class 1255 OID 30262)
-- Name: fn_get_cotizacion_next_id(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_cotizacion_next_id() RETURNS integer
    LANGUAGE plpgsql
AS $$

/**
Autor : Carlos arana Reategui
Fecha : 23-08-2016

Funcion que retorna el siguiente numero de cotizacion , garantiza bloqueo y que nunca 2 puedan tomar el mismo numero.

PARAMETROS :
Ninguno

RETURN:
	El siguiente numero de cotizacion.

Historia : Creado 17-10-2016
*/
DECLARE v_next_value integer;

BEGIN

    UPDATE tb_cotizacion_counter set cotizacion_counter_last_id = cotizacion_counter_last_id +1 returning cotizacion_counter_last_id into v_next_value;
    return v_next_value;
END;

$$;


ALTER FUNCTION public.fn_get_cotizacion_next_id() OWNER TO clabsuser;

--
-- TOC entry 275 (class 1255 OID 30263)
-- Name: fn_get_insumo_factor_ajuste(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_insumo_factor_ajuste(p_insumo_id integer, p_a_fecha date) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 16-04-2019

Funcion que calcula el factor de ajuste de un insumo para una determinada fecha

PARAMETROS :
p_insumo_id - id del insumo
p_a_fecha - a que fecha se calculara el factor de ajuste.

RETURN:
	0.000 si no hay movimientos en insumo_entries.
	El factor de ajuste de lo contrario

Historia : Creado 16-09-2019
*/
DECLARE v_insumo_factor_ajuste  numeric(10,2) = 0.00 ;

BEGIN

    -- Calculamos
    SELECT     sum(insumo_entries_qty*insumo_entries_value)/sum(insumo_entries_qty)
    INTO       v_insumo_factor_ajuste
    FROM       tb_insumo_entries
    WHERE      insumo_id = p_insumo_id and insumo_entries_fecha <= p_a_fecha;

    IF v_insumo_factor_ajuste  IS NULL
    THEN
        v_insumo_factor_ajuste := 100;
    END IF;

    RETURN v_insumo_factor_ajuste/100.00;

END;
$$;


ALTER FUNCTION public.fn_get_insumo_factor_ajuste(p_insumo_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 276 (class 1255 OID 30264)
-- Name: fn_get_producto_costo(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_producto_costo(p_insumo_id integer, p_a_fecha date) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 23-08-2016

Funcion que calcula el costo de un producto en base a todos sus insumos/productos que lo
componen.

PARAMETROS :
producto_detalle_id - is del item a procesar
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes).

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	-3.000 cualquier otro error no contemplado.
	 0.000 si no tiene items.
	el costo si todo esta ok.

Historia : Creado 22-08-2016
*/
DECLARE v_costo numeric(10,4);
    DECLARE v_min_costo numeric(10,4);
    DECLARE v_producto_detalle_id integer;

BEGIN

    -- Leemos los valoresa trabajar.
    SELECT SUM(costo),min(costo),min(producto_detalle_id) INTO v_costo,v_min_costo,v_producto_detalle_id
    FROM (
             SELECT
                 (select fn_get_producto_detalle_costo(producto_detalle_id, p_a_fecha) ) as costo,
                 pd.producto_detalle_id
             FROM   tb_insumo ins
                        inner join tb_producto_detalle pd
                                   ON pd.insumo_id_origen = ins.insumo_id
                    --     inner join tb_insumo inso
                    --       ON inso.insumo_id = pd.insumo_id
             WHERE  ins.insumo_id = p_insumo_id
         ) res;

    --RAISE NOTICE 'v_costo %',v_costo;
--RAISE NOTICE 'v_min_costo %',v_min_costo;
--RAISE NOTICE 'v_producto_detalle_id %',v_producto_detalle_id;

-- Si v_producto_detalle_id es null significa que no hay items y el costo es cero.
    IF v_producto_detalle_id IS NULL
    THEN
        v_costo := 0.0000;
    END IF;

    -- si en el calculo de los items hubo alguno que no encontro tipo de cambio
-- o conversion requerida retornara 0 -1 o -2 segun el caso.
    IF coalesce(v_min_costo,0) < 0
    THEN
        v_costo := v_min_costo;
    END IF;

--  Este es un ilogico pero si se diera devovemos 3 indicando que hubo problemas de calculo.
    IF v_costo IS NULL
    THEN
        v_costo := -3;
    END IF;
    RAISE NOTICE 'v_costo %',v_costo;

    RETURN v_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_costo(p_insumo_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 277 (class 1255 OID 30265)
-- Name: fn_get_producto_detalle_costo(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_producto_detalle_costo(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 22-08-2016

Funcion que calcula el costo de un insumo/producto que pertenece a la receta de un producto.

PARAMETROS :
p_producto_detalle_id - is del item a procesar
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes.

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	el costo si todo esta ok.

Historia : Creado 24-08-2016insumo
*/
DECLARE v_costo  numeric(10,4) = 0.00 ;
    DECLARE v_producto_detalle_cantidad numeric(20,10);
    DECLARE v_producto_detalle_merma numeric(10,4);
    DECLARE v_moneda_codigo_producto character varying(8);
    DECLARE v_moneda_codigo_costo character varying(8);
    DECLARE v_producto_detalle_id integer;
    DECLARE v_insumo_id_origen integer;
    DECLARE v_insumo_id integer;
    DECLARE v_tipo_cambio_tasa_compra numeric(8,4);
    DECLARE v_tipo_cambio_tasa_venta numeric(8,4);
    DECLARE v_unidad_medida_codigo_costo character varying(8);
    DECLARE v_unidad_medida_codigo character varying(8);
    DECLARE v_unidad_medida_conversion_factor numeric(12,5);
    DECLARE v_insumo_costo numeric(10,4);
    DECLARE v_tcostos_indirecto boolean;
--DECLARE v_regla_by_costo boolean;
    DECLARE v_insumo_tipo character varying(2);
    DECLARE v_insumo_usa_factor_ajuste boolean;
    DECLARE v_factor_ajuste numeric(10,4);



BEGIN

    -- Leemos los valoresa trabajar.
    SELECT     pd.producto_detalle_id,
               pd.insumo_id,
               ins.insumo_tipo,
               CASE
                   WHEN ins.insumo_tipo = 'IN' THEN
                       CASE WHEN tcostos_indirecto = TRUE
                                THEN
                                -- si es un producto directo se determina el peso sumando el campo cantidad de todos
                                -- los insumos usados por los productos de la empresa que genera el codigo.
                                (pd.producto_detalle_cantidad/(select sum(d2.producto_detalle_cantidad)
                                                               from tb_producto_detalle d2
                                                                        inner join tb_insumo ins2 ON ins2.insumo_id = d2.insumo_id_origen
                                                               where d2.insumo_id = pd.insumo_id and d2.empresa_id = ins2.empresa_id))
                            ELSE
                                pd.producto_detalle_cantidad
                           END
                   ELSE
                       pd.producto_detalle_cantidad
                   END AS producto_detalle_cantidad,
               -- pd.producto_detalle_cantidad,
               pd.producto_detalle_merma,
               ins.moneda_codigo_costo,
               inso.insumo_id,
               inso.moneda_codigo_costo,
               unidad_medida_codigo,
               ins.unidad_medida_codigo_costo,
               (select fn_get_producto_detalle_costo_base(p_producto_detalle_id,p_a_fecha)) as insumo_costo,
               tcostos_indirecto,
               insumo_usa_factor_ajuste
               --rg.regla_by_costo
    INTO       v_producto_detalle_id,
        v_insumo_id,
        v_insumo_tipo,
        v_producto_detalle_cantidad,
        v_producto_detalle_merma,
        v_moneda_codigo_costo,
        v_insumo_id_origen,
        v_moneda_codigo_producto,
        v_unidad_medida_codigo,
        v_unidad_medida_codigo_costo,
        v_insumo_costo,
        v_tcostos_indirecto,
        v_insumo_usa_factor_ajuste
        --v_regla_by_costo
    FROM       tb_producto_detalle pd
                   inner join tb_insumo ins  ON ins.insumo_id = pd.insumo_id
                   inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
                   inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
--left join tb_reglas rg on rg.regla_empresa_origen_id = ins.empresa_id and rg.regla_empresa_destino_id = inso.empresa_id
    WHERE      producto_detalle_id = p_producto_detalle_id;

    IF v_producto_detalle_id  IS NULL
    THEN
        RAISE  'No existe el item solicitado a calcular' USING ERRCODE = 'restrict_violation';
    END IF;

    IF v_insumo_id_origen  IS NULL
    THEN
        RAISE  'No existe el producto principal a calcular' USING ERRCODE = 'restrict_violation';
    END IF;

    -- buscamos que exista el tipo de cambio entre las monedas a la fecha solicitada.
-- de ser la misma moneda el tipo de cambio siempre sera 1,
    IF v_moneda_codigo_costo = v_moneda_codigo_producto
    THEN
        v_tipo_cambio_tasa_compra = 1.00;
        v_tipo_cambio_tasa_venta  = 1.00;
    ELSE
        SELECT tipo_cambio_tasa_compra,
               tipo_cambio_tasa_venta
        INTO   v_tipo_cambio_tasa_compra, v_tipo_cambio_tasa_venta
        FROM   tb_tipo_cambio
        WHERE  moneda_codigo_origen = v_moneda_codigo_costo
          AND moneda_codigo_destino = v_moneda_codigo_producto
          AND p_a_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta;
    END IF;
    --RAISE NOTICE 'v_moneda_codigo_costo %',v_moneda_codigo_costo;
    --RAISE NOTICE 'v_moneda_codigo_producto %',v_moneda_codigo_producto;

    --RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
    --RAISE NOTICE 'v_tipo_cambio_tasa_venta %',v_tipo_cambio_tasa_venta;

-- Si no se ha encotrado tipo de cambio retornamos -1 como costo
    IF v_tipo_cambio_tasa_compra IS NULL or v_tipo_cambio_tasa_venta IS NULL
    THEN
        v_costo := -1.0000;
    ELSE

        -- Si el producto principal y el insumo son distintos y los costos son directos buscamos la conversiom
        -- de lo contrario simepre sera 1.
        IF v_unidad_medida_codigo_costo != v_unidad_medida_codigo AND v_tcostos_indirecto = FALSE
        THEN
            select unidad_medida_conversion_factor
            into v_unidad_medida_conversion_factor
            from
                tb_unidad_medida_conversion
            where unidad_medida_origen = v_unidad_medida_codigo AND
                    unidad_medida_destino = v_unidad_medida_codigo_costo ;
        ELSE
            v_unidad_medida_conversion_factor := 1;
        END IF;
        RAISE NOTICE 'v_producto_detalle_cantidad %',v_producto_detalle_cantidad;
        --RAISE NOTICE 'v_unidad_medida_conversion_factor %',v_unidad_medida_conversion_factor;
        --RAISE NOTICE 'v_producto_detalle_merma %',v_producto_detalle_merma;
        --RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
        --IF v_unidad_medida_conversion_factor IS NULL
        --THEN
        --	RAISE NOTICE 'v_insumo_costo %',v_insumo_costo;
        --	RAISE NOTICE '----------------------------';
        --	RAISE NOTICE '----------------------------';
        --	RAISE NOTICE '----------------------------';
        --	RAISE NOTICE '----------------------------';
        --	RAISE NOTICE '----------------------------';
        --	RAISE NOTICE 'v_tcostos_indirecto %',v_tcostos_indirecto;
        --	RAISE NOTICE 'v_unidad_medida_codigo %',v_unidad_medida_codigo;
        --	RAISE NOTICE 'v_unidad_medida_codigo_costo %',v_unidad_medida_codigo_costo;
        --	RAISE NOTICE 'v_insumo_id_origen %',v_insumo_id_origen;
        --	RAISE NOTICE 'v_insumo_id %',v_insumo_id;
        --	RAISE NOTICE 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        --	RAISE NOTICE 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        --	RAISE NOTICE 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        --	RAISE NOTICE 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        --	RAISE NOTICE 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        --	RAISE NOTICE 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        --END IF;
        -- Si la conversion de medidas no existe retornamos como costo -2
        IF v_unidad_medida_conversion_factor IS NULL
        THEN
            v_costo := -2.0000;
        ELSE
            IF v_insumo_costo >= 0
            THEN

                -- Si la regla es por costo se aplica merma , si es por precio de mercado
                -- no se requiere
                --	IF coalesce(v_regla_by_costo,true) = false
                --	THEN
                --		v_producto_detalle_merma = 0;
                --	END IF;

                -- Determinamos el factor de ajuste si es un insumo y se indica que use factor de ajuste
                -- en cuyo caso ajustamos la cantidad a costear afectandolo por dicho factor.
                IF v_insumo_tipo = 'IN' and v_insumo_usa_factor_ajuste = TRUE
                THEN
                    v_factor_ajuste = fn_get_insumo_factor_ajuste(p_producto_detalle_id,p_a_fecha);
                    v_producto_detalle_cantidad = v_producto_detalle_cantidad*v_factor_ajuste;
                ELSE
                    v_factor_ajuste := 1;
                END IF;

                -- Calculamos tomando en cuenta el % de merma
                IF v_unidad_medida_conversion_factor = 1
                THEN
                    v_costo := (v_producto_detalle_cantidad*(1+v_producto_detalle_merma/100.00000))*v_tipo_cambio_tasa_compra*v_insumo_costo;
                ELSE
                    -- Esto es para ver si se retira todo lo relativo a cambio de unidad ya que parece no ser necesario
                    v_costo := (v_producto_detalle_cantidad*(1+v_producto_detalle_merma/100.00000))*v_unidad_medida_conversion_factor*v_tipo_cambio_tasa_compra*v_insumo_costo;
                END IF;
            ELSE
                v_costo:= v_insumo_costo;
            END IF;
        END IF;
    END IF;



    --RAISE NOTICE 'v_costo %',v_costo;
    -- RAISE NOTICE 'v_insumo_id %',v_insumo_id;
    -- RAISE NOTICE 'v_producto_detalle_id %',v_producto_detalle_id;

    RETURN v_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_detalle_costo(p_producto_detalle_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 278 (class 1255 OID 30268)
-- Name: fn_get_producto_detalle_costo_base(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_producto_detalle_costo_base(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 05-10-2016

Funcion que calcula el costo base en bruto sin conversiones ni ajustes por dif.de cambio o unidad de medida
de un insumo/producto que pertenece a la receta de otro producto.

Se debe indicar que en el caso este item sea producto debera ser el valor calculado de sus insumos.
En el caso que sea un insumo este valor se determinara de la siguiente manera.
1) Si no hay regla de costos entre la empresa que aporta el insumo y la que genera el producto el costos
sera el costo original del insumo.

2) Si hay regla de costos entre las empresas y si la regla indica que el calculo es por costos (regla_by_costo = true)
entonces sera el costo del insumo el costo en bruto. si la regla indica es por precio de mercado (regla_by_costo = false)
entonces se tomara el precio del mercado del insumo.

PARAMETROS :
p_producto_detalle_id - is del item a procesar
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes.

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	el costo si todo esta ok.

Historia : Creado 24-08-2016insumo
*/
DECLARE v_insumo_costo numeric(10,4);
    DECLARE v_empresa_usuaria_id integer;
    DECLARE v_empresa_propietaria_id integer;
    DECLARE v_insumo_merma_venta numeric(10,4);
--DECLARE v_insumo_precio_mercado numeric(10,2);
--DECLARE v_tcostos_indirecto boolean;
--DECLARE v_regla_id integer;
--DECLARE v_regla_by_costo boolean;
--DECLARE v_regla_porcentaje numeric(6,2);
--DECLARE v_tipo_cambio_tasa_compra  numeric(8,4);
BEGIN

    -- Leemos los valoresa trabajar.
    SELECT
        CASE
            WHEN ins.insumo_tipo = 'IN' THEN
                ins.insumo_costo
            ELSE
                (select fn_get_producto_costo(ins.insumo_id, p_a_fecha) )
            END AS insumo_costo,
        ins.insumo_precio_mercado,
        pd.empresa_id, -- empresa usuaria del insumo.
        inso.empresa_id, -- empresa que creeo el producto (propietaria)
        ins.insumo_merma, -- merma de venta del insumo.
        tcostos_indirecto,
        regla_id,
        regla_by_costo,
        regla_porcentaje
    INTO
        v_insumo_costo,
--	   v_insumo_precio_mercado,
        v_empresa_usuaria_id,
        v_empresa_propietaria_id,
        v_insumo_merma_venta--,
--	   v_tcostos_indirecto,
--	   v_regla_id,
--	   v_regla_by_costo,
--	   v_regla_porcentaje
    FROM   tb_producto_detalle pd
               inner join tb_insumo ins  ON ins.insumo_id = pd.insumo_id
               inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
               inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
--left join tb_reglas rg on rg.regla_empresa_origen_id = ins.empresa_id and rg.regla_empresa_destino_id = inso.empresa_id
    WHERE      pd.producto_detalle_id = p_producto_detalle_id;

-- Si la empresa uauria no es propietaria del insumo o producto le aplicamos la merma de venta
    IF v_empresa_usuaria_id != v_empresa_propietaria_id
    THEN
        -- Si la regla es por costo se aplica merma , si es por precio de mercado
        -- no se requiere
        IF v_insumo_merma_venta != 0.0000 and coalesce(v_regla_by_costo,true) = true
        THEN
            v_insumo_costo := v_insumo_costo+(v_insumo_costo*v_insumo_merma_venta/100.000);
        END IF;

        -- Hacemos el ajuste de costo segun la regla entre empresas de existir, siempre que el costo sea positivo
        -- exista regla y el costo sea indirecto.
--	IF v_insumo_costo > 0 and v_regla_id IS NOT NULL and v_tcostos_indirecto = FALSE
--	THEN
--		IF v_regla_by_costo = TRUE
--		THEN
--			v_insumo_costo = v_insumo_costo + (v_insumo_costo*v_regla_porcentaje)/100.00;
--		ELSE
--        --	v_tipo_cambio_tasa_compra = 1.000;
--        --	IF v_insumo_precio_mercado*v_tipo_cambio_tasa_compra - v_insumo_costo <= 00
--        --    THEN
--        --    	RAISE  'El precio de mercado es menor que el costo de %',v_insumo_costo USING ERRCODE = 'restrict_violation';
--        --    END IF;
--
--            v_insumo_costo = v_insumo_costo+(v_insumo_precio_mercado- v_insumo_costo)*v_regla_porcentaje/100.00;--
--
--		END IF;
--
--
--	END IF;
    END IF;

    RETURN v_insumo_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_detalle_costo_base(p_producto_detalle_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 279 (class 1255 OID 30271)
-- Name: fn_get_producto_detalle_costo_old(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_producto_detalle_costo_old(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 22-08-2016

Funcion que calcula el costo de un insumo/producto que pertenece a la receta de un producto.

PARAMETROS :
p_producto_detalle_id - is del item a procesar
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes.

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	el costo si todo esta ok.

Historia : Creado 24-08-2016insumo
*/
DECLARE v_costo  numeric(10,4) = 0.00 ;
    DECLARE v_producto_detalle_cantidad numeric(10,4);
    DECLARE v_producto_detalle_merma numeric(10,4);
    DECLARE v_moneda_codigo_producto character varying(8);
    DECLARE v_moneda_codigo_costo character varying(8);
    DECLARE v_producto_detalle_id integer;
    DECLARE v_insumo_id_origen integer;
    DECLARE v_insumo_id integer;
    DECLARE v_tipo_cambio_tasa_compra numeric(8,4);
    DECLARE v_tipo_cambio_tasa_venta numeric(8,4);
    DECLARE v_unidad_medida_codigo_costo character varying(8);
    DECLARE v_unidad_medida_codigo character varying(8);
    DECLARE v_unidad_medida_conversion_factor numeric(12,5);
    DECLARE v_insumo_costo numeric(10,4);
    DECLARE v_tcostos_indirecto boolean;

BEGIN

    -- Leemos los valoresa trabajar.
    SELECT     pd.producto_detalle_id,
               pd.insumo_id,
               pd.producto_detalle_cantidad,
               pd.producto_detalle_merma,
               ins.moneda_codigo_costo,
               inso.insumo_id,
               inso.moneda_codigo_costo,
               unidad_medida_codigo,
               ins.unidad_medida_codigo_costo,
               --   ins.insumo_costo,
               -- Si es un insumo se tomara como costo el valor de ser indirecto
               -- de lo contrario su costo indicado en tabla.
               -- De ser producto se solicita obviamente el costo de sus componentes.
               CASE
                   WHEN ins.insumo_tipo = 'IN' THEN
                       CASE WHEN tcostos_indirecto = TRUE
                                THEN
                                pd.producto_detalle_valor
                            ELSE
                                ins.insumo_costo
                           END
                   ELSE
                       (select fn_get_producto_costo(pd.insumo_id, p_a_fecha) )
                   END AS insumo_costo,
               tcostos_indirecto
    INTO       v_producto_detalle_id,
        v_insumo_id,
        v_producto_detalle_cantidad,
        v_producto_detalle_merma,
        v_moneda_codigo_costo,
        v_insumo_id_origen,
        v_moneda_codigo_producto,
        v_unidad_medida_codigo,
        v_unidad_medida_codigo_costo,
        v_insumo_costo,
        v_tcostos_indirecto
    FROM       tb_producto_detalle pd
                   inner join tb_insumo ins  ON ins.insumo_id = pd.insumo_id
                   inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
                   inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
    WHERE      producto_detalle_id = p_producto_detalle_id;

    IF v_producto_detalle_id  IS NULL
    THEN
        RAISE  'No existe el item solicitado a calcular' USING ERRCODE = 'restrict_violation';
    END IF;

    IF v_insumo_id_origen  IS NULL
    THEN
        RAISE  'No existe el producto principal a calcular' USING ERRCODE = 'restrict_violation';
    END IF;

    -- buscamos que exista el tipo de cambio entre las monedas a la fecha solicitada.
-- de ser la misma moneda el tipo de cambio siempre sera 1,
    IF v_moneda_codigo_costo = v_moneda_codigo_producto
    THEN
        v_tipo_cambio_tasa_compra = 1.00;
        v_tipo_cambio_tasa_venta  = 1.00;
    ELSE
        SELECT tipo_cambio_tasa_compra,
               tipo_cambio_tasa_venta
        INTO   v_tipo_cambio_tasa_compra, v_tipo_cambio_tasa_venta
        FROM   tb_tipo_cambio
        WHERE  moneda_codigo_origen = v_moneda_codigo_costo
          AND moneda_codigo_destino = v_moneda_codigo_producto
          AND p_a_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta;
    END IF;
    --RAISE NOTICE 'v_moneda_codigo_costo %',v_moneda_codigo_costo;
    --RAISE NOTICE 'v_moneda_codigo_producto %',v_moneda_codigo_producto;

    --RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
    --RAISE NOTICE 'v_tipo_cambio_tasa_venta %',v_tipo_cambio_tasa_venta;

-- Si no se ha encotrado tipo de cambio retornamos -1 como costo
    IF v_tipo_cambio_tasa_compra IS NULL or v_tipo_cambio_tasa_venta IS NULL
    THEN
        v_costo := -1.0000;
    ELSE
        -- Procedemos a buscar la conversion de unidades entre el insumo o producto original y el especificado
        -- en el item a grabar.
--	SELECT unidad_medida_codigo_costo
--		INTO v_unidad_medida_codigo_costo
--	FROM
--		tb_insumo
--	WHERE insumo_id = v_insumo_id_origen;

        -- Si el producto principal y el insumo son distintos y los costos son directos buscamos la conversiom
        -- de lo contrario simepre sera 1.
        IF v_unidad_medida_codigo_costo != v_unidad_medida_codigo AND v_tcostos_indirecto = FALSE
        THEN
            select unidad_medida_conversion_factor
            into v_unidad_medida_conversion_factor
            from
                tb_unidad_medida_conversion
            where unidad_medida_origen = v_unidad_medida_codigo AND
                    unidad_medida_destino = v_unidad_medida_codigo_costo ;
        ELSE
            v_unidad_medida_conversion_factor := 1;
        END IF;
        --RAISE NOTICE 'v_producto_detalle_cantidad %',v_producto_detalle_cantidad;
        --RAISE NOTICE 'v_unidad_medida_conversion_factor %',v_unidad_medida_conversion_factor;
        --RAISE NOTICE 'v_producto_detalle_merma %',v_producto_detalle_merma;
        --RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
        --RAISE NOTICE 'v_insumo_costo %',v_insumo_costo;

        -- Si la conversion de medidas no existe retornamos como costo -2
        IF v_unidad_medida_conversion_factor IS NULL
        THEN
            v_costo := -2.0000;
        ELSE
            IF v_insumo_costo >= 0
            THEN
                -- Calculamos tomando en cuenta el % de merma
                IF v_unidad_medida_conversion_factor = 1
                THEN
                    v_costo := (v_producto_detalle_cantidad*(1+v_producto_detalle_merma/100.00000))*v_tipo_cambio_tasa_compra*v_insumo_costo;
                ELSE
                    -- Esto es para ver si se retira todo lo relativo a cambio de unidad ya que parece no ser necesario
                    v_costo := (v_producto_detalle_cantidad*(1+v_producto_detalle_merma/100.00000))*v_unidad_medida_conversion_factor*v_tipo_cambio_tasa_compra*v_insumo_costo;
                END IF;
            ELSE
                v_costo:= v_insumo_costo;
            END IF;
        END IF;
    END IF;

    --RAISE NOTICE 'v_costo %',v_costo;
    -- RAISE NOTICE 'v_insumo_id %',v_insumo_id;
    -- RAISE NOTICE 'v_producto_detalle_id %',v_producto_detalle_id;

    RETURN v_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_detalle_costo_old(p_producto_detalle_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 280 (class 1255 OID 30274)
-- Name: fn_get_producto_precio(integer, integer, integer, boolean, character varying, date, boolean); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_producto_precio(p_insumo_id integer, p_empresa_id integer, p_cliente_id integer, p_es_cliente_real boolean, p_moneda_codigo character varying, p_a_fecha date, p_use_exceptions boolean) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 29/11/2016

Funcion que calcula el precio de venta de un producto a cotizar de una empresa a otra basado en las reglas estipuladas entre ellas.
Parea esto se determina el precio de venta del producto en la empresa propietaria del mismo y luego se ajusta con la merma de venta
y las reglas entre las empresas participantes.
Para esto se invoca la funcion fn_get_producto_costo() la cual da el costo sin los sobrecostos de mermas y reglas aplicados sobre el
mismo hacia otras empresas.

PARAMETROS :
p_insumo_id - id del insumo o producto a procesar.
p_empresa_id - empresa propietaria del producto y la que cotizara.
p_cliente_id - empresa destino o a la que se va a cotizar.
p_es_cliente_real - Indica si p_cliente_id representa a una empresa del grupo o a un cliente.
p_moneda_codigo - Moneda en la que representar el precio final , hay que recordar que los productos tienen una moneda
	de venta pero puede ser cotizada a otra moneda.
    Si este parametro en null se obtendra el precio a cotizar en moneda de costo del producto y no en
    moneda de cotizacion.
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes).
p_use_exceptions - true si en vez de devolver el codigo de error especificados anteriormente debe mandar excepciones.

RETURN: si p_use_exceptions = TRUE retorna
	-1 si se requiere tipo de cambio y el mismo no existe definido para calcular el costo de un producto.
	-2 si se requiere conversion de unidades y no existe.
	-3 cualquier otro error no contemplado.
	-4 si se requiere tipo de cambio y el mismo no existe definido para calcular el precio de un producto.
	-5 El precio de mercado es menor que el costo.
	 0.000 si no tiene items.
	el precio si todo esta ok.

	si p_use_exceptions = FALSE enviara la excepcion con el mensaje correspondiente.

Historia : Creado 29-11-2016
*/
DECLARE v_tipo_cambio_tasa_compra numeric(8,4);
    DECLARE v_tipo_cambio_tasa_venta numeric(8,4);
    DECLARE v_precio numeric(12,2);
    DECLARE v_insumo_precio_mercado numeric(10,2);
    DECLARE v_insumo_id integer;
    DECLARE v_unidad_medida_codigo_costo character varying(8);
    DECLARE v_moneda_codigo_costo character varying(8);
    DECLARE v_tcostos_indirecto boolean;
    DECLARE v_regla_id integer;
    DECLARE v_regla_by_costo boolean;
    DECLARE v_regla_porcentaje numeric(6,2);
    DECLARE v_insumo_merma numeric(10,4);


BEGIN
    IF p_es_cliente_real = TRUE
    THEN
        SELECT
            ins.insumo_id,
            ins.insumo_precio_mercado as precio,
            ins.unidad_medida_codigo_costo,
            ins.moneda_codigo_costo,
            tcostos_indirecto
        INTO  	v_insumo_id,
            v_precio,
            v_unidad_medida_codigo_costo,
            v_moneda_codigo_costo,
            v_tcostos_indirecto
        FROM tb_insumo ins
                 inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = ins.unidad_medida_codigo_costo
        WHERE ins.empresa_id = p_empresa_id and  ins.insumo_id = p_insumo_id and tcostos_indirecto = false;

        v_insumo_merma := 0.00;
    ELSE
        -- Leemos los valoresa trabajar.
        SELECT
            ins.insumo_id,
            -- obtenemos el costo del producto en la empresa principal.
            CASE
                WHEN ins.insumo_tipo = 'IN' THEN
                    ins.insumo_costo
                ELSE
                    (select fn_get_producto_costo(ins.insumo_id, p_a_fecha) )
                END AS precio,
            ins.insumo_precio_mercado,
            ins.unidad_medida_codigo_costo,
            ins.insumo_merma,
            ins.moneda_codigo_costo,
            tcostos_indirecto,
            regla_id,
            regla_by_costo,
            regla_porcentaje
        INTO  	v_insumo_id,
            v_precio,
            v_insumo_precio_mercado,
            v_unidad_medida_codigo_costo,
            v_insumo_merma,
            v_moneda_codigo_costo,
            v_tcostos_indirecto,
            v_regla_id,
            v_regla_by_costo,
            v_regla_porcentaje
        FROM tb_insumo ins
                 inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = ins.unidad_medida_codigo_costo
            --inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
                 left  join tb_reglas rg on rg.regla_empresa_origen_id = p_empresa_id and rg.regla_empresa_destino_id = p_cliente_id
        WHERE ins.empresa_id = p_empresa_id and  ins.insumo_id = p_insumo_id and tcostos_indirecto = false;

        RAISE NOTICE 'v_precio = %',v_precio;
        RAISE NOTICE 'v_insumo_precio_mercado = %',v_insumo_precio_mercado;
        RAISE NOTICE 'v_tcostos_indirecto = %',v_tcostos_indirecto;
        RAISE NOTICE 'v_moneda_codigo_costo = %',v_moneda_codigo_costo;

    END IF;

    IF v_insumo_id IS NULL
    THEN
        RAISE  'El insumo/Producto no existe o no pertenece a la empresa que cotiza o es un insumo de costo indirecto' USING ERRCODE = 'restrict_violation';
    END IF;

    -- Si no obtenemos el  precio enviamos error.
    IF v_precio IS NULL or v_precio < 0
    THEN
        IF p_use_exceptions = TRUE
        THEN
            IF v_precio = -1
            THEN
                RAISE  'No existe el tipo de cambio para calcular el costo a la fecha solicitada, no se puede cotizar' USING ERRCODE = 'restrict_violation';
            ELSIF v_precio = -2
            THEN
                -- En este caso no se ha tomado en cuenta que se cotize a diferentes unidades , lo dejo por si a futuro se requiere
                RAISE  'No existe conversion de unidads entre la unidad del producto y la unidad de cotizacion' USING ERRCODE = 'restrict_violation';
            ELSIF v_precio = -3
            THEN
                RAISE  'Error durante la determinacion del precio' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            -- Si no se envia excepciones se retorna el valor negativo indicando un error.
            return v_precio;
        END IF;
    END IF;

    IF p_moneda_codigo IS NULL
    THEN
        p_moneda_codigo = v_moneda_codigo_costo;
    END IF;

    -- buscamos que exista el tipo de cambio entre las monedas a la fecha solicitada.
    -- de ser la misma moneda el tipo de cambio siempre sera 1,
    IF v_moneda_codigo_costo = p_moneda_codigo
    THEN
        v_tipo_cambio_tasa_compra = 1.00;
        v_tipo_cambio_tasa_venta  = 1.00;
    ELSE
        SELECT tipo_cambio_tasa_compra,
               tipo_cambio_tasa_venta
        INTO   v_tipo_cambio_tasa_compra, v_tipo_cambio_tasa_venta
        FROM   tb_tipo_cambio
        WHERE  moneda_codigo_origen = v_moneda_codigo_costo
          AND moneda_codigo_destino = p_moneda_codigo
          AND p_a_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta;
    END IF;

    IF v_tipo_cambio_tasa_compra IS NULL or v_tipo_cambio_tasa_venta IS NULL
    THEN
        IF p_use_exceptions = TRUE
        THEN
            RAISE  'No existe el tipo de cambio para calcular el precio a la fecha solicitada, no se puede cotizar' USING ERRCODE = 'restrict_violation';
        ELSE
            return -4;
        END IF;
    END IF;

    RAISE NOTICE 'v_precio_inicial = %',v_precio;

    -- Solo se calcula merma si es que la regla existe y es por costo.
    IF coalesce(v_regla_by_costo,true) = true
    THEN
        -- Se aplica al costo el insumo de merma propia del producto en la venta
        v_precio := (1+v_insumo_merma/100.00)*v_precio;
    END IF;

    --RAISE NOTICE 'v_tipo_cambio_tasa_compra = %',v_tipo_cambio_tasa_compra;
    --RAISE NOTICE 'v_regla_by_costo = %',v_regla_by_costo;
    --RAISE NOTICE 'v_regla_porcentaje = %',v_regla_porcentaje;
    --RAISE NOTICE 'v_insumo_merma = %',v_insumo_merma;
    --RAISE NOTICE 'v_precio = %',v_precio;

    -- Hacemos el ajuste de costo segun la regla entre empresas de existir, siempre que el costo sea positivo
    -- exista regla y el costo sea indirecto.
    IF v_precio > 0 and v_regla_id IS NOT NULL
    THEN
        IF v_regla_by_costo = TRUE
        THEN
            --v_precio = v_precio + (v_precio*v_regla_porcentaje)/100.00;
            v_precio = v_precio + round((v_precio*v_regla_porcentaje)/100.00,2);
            v_precio := v_tipo_cambio_tasa_compra*v_precio;
        ELSE
            v_precio := v_tipo_cambio_tasa_compra*v_precio;

            IF (v_insumo_precio_mercado*v_tipo_cambio_tasa_compra) - v_precio <= 00
            THEN
                IF p_use_exceptions = TRUE
                THEN
                    RAISE  'El precio de mercado es menor que el costo de %',v_precio USING ERRCODE = 'restrict_violation';
                ELSE
                    RETURN -5;
                END IF;
            END IF;
            v_precio = v_precio+(v_insumo_precio_mercado*v_tipo_cambio_tasa_compra - v_precio)*v_regla_porcentaje/100.00;
        END IF;
    ELSE
        v_precio := v_tipo_cambio_tasa_compra*v_precio;
    END IF;

    RAISE NOTICE 'v_precio = %',v_precio;
    RETURN v_precio;
END;
$$;


ALTER FUNCTION public.fn_get_producto_precio(p_insumo_id integer, p_empresa_id integer, p_cliente_id integer, p_es_cliente_real boolean, p_moneda_codigo character varying, p_a_fecha date, p_use_exceptions boolean) OWNER TO clabsuser;

--
-- TOC entry 281 (class 1255 OID 30277)
-- Name: fn_get_producto_precio_old(integer, integer, integer, boolean, character varying, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_producto_precio_old(p_insumo_id integer, p_empresa_id integer, p_cliente_id integer, p_es_cliente_real boolean, p_moneda_codigo character varying, p_a_fecha date) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 29/11/2016

Funcion que calcula el precio de venta de un producto a cotizar de una empresa a otra basado en las reglas estipuladas entre ellas.
Parea esto se determina el precio de venta del producto en la empresa propietaria del mismo y luego se ajusta con la merma de venta
y las reglas entre las empresas participantes.
Para esto se invoca la funcion fn_get_producto_costo() la cual da el costo sin los sobrecostos de mermas y reglas aplicados sobre el
mismo hacia otras empresas.

PARAMETROS :
p_insumo_id - id del insumo o producto a procesar.
p_empresa_id - empresa propietaria del producto y la que cotizara.
p_cliente_id - empresa destino o a la que se va a cotizar.
p_es_cliente_real - Indica si p_cliente_id representa a una empresa del grupo o a un cliente.
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes).

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	-3.000 cualquier otro error no contemplado.
	 0.000 si no tiene items.
	el precio si todo esta ok.

Historia : Creado 29-11-2016
*/
DECLARE v_tipo_cambio_tasa_compra numeric(8,4);
    DECLARE v_tipo_cambio_tasa_venta numeric(8,4);
    DECLARE v_precio numeric(12,2);
    DECLARE v_insumo_id integer;
    DECLARE v_unidad_medida_codigo_costo character varying(8);
    DECLARE v_moneda_codigo_costo character varying(8);
    DECLARE v_tcostos_indirecto boolean;
    DECLARE v_regla_id integer;
    DECLARE v_regla_by_costo boolean;
    DECLARE v_regla_porcentaje numeric(6,2);
    DECLARE v_insumo_merma numeric(10,4);

BEGIN
    IF p_es_cliente_real = TRUE
    THEN
        SELECT
            ins.insumo_id,
            ins.insumo_precio_mercado as precio,
            ins.unidad_medida_codigo_costo,
            ins.moneda_codigo_costo,
            tcostos_indirecto
        INTO  	v_insumo_id,
            v_precio,
            v_unidad_medida_codigo_costo,
            v_moneda_codigo_costo,
            v_tcostos_indirecto
        FROM tb_insumo ins
                 inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = ins.unidad_medida_codigo_costo
        WHERE ins.empresa_id = p_empresa_id and  ins.insumo_id = p_insumo_id and tcostos_indirecto = false;

        v_insumo_merma := 0.00;
    ELSE
        -- Leemos los valoresa trabajar.
        SELECT
            ins.insumo_id,
            -- obtenemos el costo del producto en la empresa principal.
            CASE
                WHEN ins.insumo_tipo = 'IN' THEN
                    CASE WHEN regla_id IS NULL THEN ins.insumo_costo
                         WHEN coalesce(regla_by_costo,true) = false THEN ins.insumo_precio_mercado
                         ELSE
                             ins.insumo_costo
                        END
                ELSE
                    CASE WHEN regla_id IS NULL THEN (select fn_get_producto_costo(ins.insumo_id, p_a_fecha) )
                         WHEN coalesce(regla_by_costo,true) = false THEN ins.insumo_precio_mercado
                         ELSE
                             (select fn_get_producto_costo(ins.insumo_id, p_a_fecha) )
                        END
                END AS precio,
            ins.unidad_medida_codigo_costo,
            ins.insumo_merma,
            ins.moneda_codigo_costo,
            tcostos_indirecto,
            regla_id,
            regla_by_costo,
            regla_porcentaje
        INTO  	v_insumo_id,
            v_precio,
            v_unidad_medida_codigo_costo,
            v_insumo_merma,
            v_moneda_codigo_costo,
            v_tcostos_indirecto,
            v_regla_id,
            v_regla_by_costo,
            v_regla_porcentaje
        FROM tb_insumo ins
                 inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = ins.unidad_medida_codigo_costo
                 left  join tb_reglas rg on rg.regla_empresa_origen_id = p_empresa_id and rg.regla_empresa_destino_id = p_cliente_id
        WHERE ins.empresa_id = p_empresa_id and  ins.insumo_id = p_insumo_id and tcostos_indirecto = false;

        RAISE NOTICE 'v_precio = %',v_precio;
        RAISE NOTICE 'v_tcostos_indirecto = %',v_tcostos_indirecto;
        RAISE NOTICE 'v_moneda_codigo_costo = %',v_moneda_codigo_costo;

    END IF;

    IF v_insumo_id IS NULL
    THEN
        RAISE  'El insumo/Producto no existe o no pertenece a la empresa que cotiza o es un insumo de costo indirecto' USING ERRCODE = 'restrict_violation';
    END IF;

    -- Si no obtenemos el  precio enviamos error.
    IF v_precio IS NULL or v_precio < 0
    THEN
        IF v_precio = -1
        THEN
            RAISE  'No existe el tipo de cambio para calcular el precio a la fecha solicitada, no se puede cotizar' USING ERRCODE = 'restrict_violation';
        ELSIF v_precio = -2
        THEN
            -- En este caso no se ha tomado en cuenta que se cotize a diferentes unidades , lo dejo por si a futuro se requiere
            RAISE  'No existe conversion de unidads entre la unidad del producto y la unidad de cotizacion' USING ERRCODE = 'restrict_violation';
        ELSIF v_precio = -3
        THEN
            RAISE  'Error durante la determinacion del precio' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;

    -- buscamos que exista el tipo de cambio entre las monedas a la fecha solicitada.
    -- de ser la misma moneda el tipo de cambio siempre sera 1,
    IF v_moneda_codigo_costo = p_moneda_codigo
    THEN
        v_tipo_cambio_tasa_compra = 1.00;
        v_tipo_cambio_tasa_venta  = 1.00;
    ELSE
        SELECT tipo_cambio_tasa_compra,
               tipo_cambio_tasa_venta
        INTO   v_tipo_cambio_tasa_compra, v_tipo_cambio_tasa_venta
        FROM   tb_tipo_cambio
        WHERE  moneda_codigo_origen = v_moneda_codigo_costo
          AND moneda_codigo_destino = p_moneda_codigo
          AND p_a_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta;
    END IF;

    IF v_tipo_cambio_tasa_compra IS NULL or v_tipo_cambio_tasa_venta IS NULL
    THEN
        RAISE  'No existe el tipo de cambio a la fecha solicitada, no se puede cotizar' USING ERRCODE = 'restrict_violation';
    END IF;

    -- Solo se calcula merma si es que la regla existe y es por costo.
    IF coalesce(regla_by_costo,true) = true
    THEN
        -- Se aplica al costo el insumo de merma propia del producto en la venta
        v_precio := (1+v_insumo_merma/100.00000)*v_tipo_cambio_tasa_compra*v_precio;
    ELSE
        v_precio := v_tipo_cambio_tasa_compra*v_precio;
    END IF;

    --RAISE NOTICE 'v_tipo_cambio_tasa_compra = %',v_tipo_cambio_tasa_compra;
    --RAISE NOTICE 'v_regla_by_costo = %',v_regla_by_costo;
    --RAISE NOTICE 'v_regla_porcentaje = %',v_regla_porcentaje;
    --RAISE NOTICE 'v_insumo_merma = %',v_insumo_merma;

    -- Hacemos el ajuste de costo segun la regla entre empresas de existir, siempre que el costo sea positivo
    -- exista regla y el costo sea indirecto.
    IF v_precio > 0 and v_regla_id IS NOT NULL
    THEN
        IF v_regla_by_costo = TRUE
        THEN
            v_precio = v_precio + (v_precio*v_regla_porcentaje)/100.00;
        ELSE
            IF v_regla_porcentaje < 0
            THEN
                v_precio = v_precio + (v_precio*v_regla_porcentaje)/100.00;
            ELSE
                v_precio = (v_precio*v_regla_porcentaje)/100.00;
            END IF;
        END IF;
    END IF;
    RETURN v_precio;
END;
$$;


ALTER FUNCTION public.fn_get_producto_precio_old(p_insumo_id integer, p_empresa_id integer, p_cliente_id integer, p_es_cliente_real boolean, p_moneda_codigo character varying, p_a_fecha date) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 30279)
-- Name: sp_asigperfiles_save_record(integer, integer, integer, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION public.sp_asigperfiles_save_record(p_asigperfiles_id integer, p_perfil_id integer, p_usuarios_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de aisgnacion de perfiles.

El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update , de la misma forma el parametro id sera ignorado durante un insert.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_asigperfiles_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 08-10-2013
*/
BEGIN

    IF p_is_update = '1'
    THEN
        UPDATE
            tb_sys_asigperfiles
        SET
            asigperfiles_id=p_asigperfiles_id,
            perfil_id=p_perfil_id,
            usuarios_id=p_usuarios_id,
            activo=p_activo,
            usuario_mod=p_usuario
        WHERE asgper_id = p_asgper_id and xmin =p_version_id ;
        --RAISE NOTICE  'COUNT ID --> %', FOUND;

        IF FOUND THEN
            RETURN 1;
        ELSE
            RETURN null;
        END IF;
    ELSE
        INSERT INTO
            tb_sys_asigperfiles
        (perfil_id,usuarios_id,activo,usuario)
        VALUES(p_perfil_id,
               usuarios_id,
               p_activo,
               p_usuario);

        RETURN 1;

    END IF;
END;
$$;


ALTER FUNCTION public.sp_asigperfiles_save_record(p_asigperfiles_id integer, p_perfil_id integer, p_usuarios_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 286 (class 1255 OID 30280)
-- Name: sp_get_cantidad_insumos_for_producto(integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_cantidad_insumos_for_producto(p_insumo_id integer) RETURNS TABLE(insumo_id integer, insumo_descripcion character varying, unidad_medida_codigo_default character varying, total_cantidad numeric)
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 3-10-2016

Stored procedure que retorna las cantidades normalizadas a la unidad de medida default en cada caso para cada  componentes de un producto


PARAMETROS :
p_insumo_id - id del producto origen para determinar la cantidad de sus  componentes.


RETURN:
	TABLE(
		insumo_id integer,
		insumo_descripcion character varying,
		unidad_medida_codigo_default character varying,
		total_cantidad numeric)
*/
BEGIN


    return QUERY
        select 	res.insumo_id,
                  res.insumo_descripcion,
                  res.unidad_medida_codigo_default,
                  sum(producto_total_cantidad) as total_cantidad
        from sp_get_datos_insumos_for_producto(p_insumo_id) res
        group by
            res.insumo_id,res.insumo_descripcion,res.unidad_medida_codigo_default;

END;
$$;


ALTER FUNCTION public.sp_get_cantidad_insumos_for_producto(p_insumo_id integer) OWNER TO clabsuser;

--
-- TOC entry 287 (class 1255 OID 30281)
-- Name: sp_get_clientes_for_cotizacion(integer, character varying, integer, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_clientes_for_cotizacion(p_empresa_origen_id integer, p_cliente_razon_social character varying, pc_cliente_id integer, pc_es_cliente_real boolean, p_max_results integer, p_offset integer) RETURNS TABLE(cliente_id integer, cliente_razon_social character varying, tipo_empresa_codigo character varying)
    LANGUAGE plpgsql STABLE
AS $_$
/**
Autor : Carlos arana Reategui
Fecha : 28-09-2016

Stored procedure que retorna todos las posibles empresas a las que les puede cotizar la indicada en el parametro,
en el caso que pc_cliente_id este definido se buscara exactamente ese cliente y no la lista, pc_es_cliente_real
debera indicar si se busca en tb_empresa o tb_cliente.

Existen 3 casos diferentes.
Caso 1: Si la empresa es importador podra cotizar a fabrica,distribuidor o sus clientes..
Caso 2: Si la empresa es fabrica podra cotizar a distribuidores o sus clientes.
Caso 3: Si la empresa es distribuidor solo podra cotizar a sus clientes.

PARAMETROS :
p_empresa_origen_id - id de la empresa que cotiza.
p_cliente_razon_social - Si este parametro no es null servira para filtrar los clientes por su nombre.
pc_cliente_id - Si no es null se ignoraran los demas parametros y se buscara exactamente ese cliente ,
	si se buscara en empresas o clientes lo definira pc_es_cliente_real.
pc_es_cliente_real - Indica si pc_cliente_id es un cliente o una empresa.
p_max_results - Entero con el numero maximo de registros a leer
p_offset - entero con el offset de los datos a leer.

si p_max_results y  p_offset  son null , leera todos los registros.

RETURN:
	TABLE(
		cliente_id integer,
		empresa_razon_social character varying,
		tipo_empresa_codigo character varying
	)


Historia : 13-06-2014
*/
DECLARE v_empresa_id integer;
    DECLARE v_tipo_empresa_codigo character varying(3);
    DECLARE v_insumo_tipo character varying(2);
BEGIN
    -- Si pc_cliente_id esta definido solo buscaremos dicho cliente/empresa
    IF pc_cliente_id  IS NOT NULL
    THEN
        IF pc_es_cliente_real = FALSE
        THEN
            return QUERY
                select 	e.empresa_id as cliente_id,
                          e.empresa_razon_social as cliente_razon_social,
                          e.tipo_empresa_codigo
                from  tb_empresa e
                where e.empresa_id = pc_cliente_id;
        ELSE
            return QUERY
                select 	e.cliente_id as cliente_id,
                          e.cliente_razon_social,
                          'CLI'::character varying as tipo_empresa_codigo
                from  tb_cliente e
                where e.cliente_id = pc_cliente_id;
        END IF;
    ELSE
        -- Determinamos el tipo de empresa ara decidir luego que empresas deben ser posibles de cotizar.
        select e.tipo_empresa_codigo
        into v_tipo_empresa_codigo
        from tb_empresa e
        where e.empresa_id = p_empresa_origen_id;

        -- Si no existe la empresa (v_tipo_empresa_codigo sera null) o existe pero no es del tipo soportado.
        IF coalesce(v_tipo_empresa_codigo,'') = '' OR
           v_tipo_empresa_codigo NOT IN('FAB','IMP','DIS')
        THEN
            RAISE 'Debe existir la empresa de origen' USING ERRCODE = 'restrict_violation';
        END IF;

        IF v_tipo_empresa_codigo='IMP'
        THEN
            return QUERY
                EXECUTE format(
                    'select e.empresa_id as cliente_id,
                        e.empresa_razon_social as cliente_razon_social,
                        e.tipo_empresa_codigo
                    from  tb_empresa e
                    where e.empresa_id in (
                        select em.empresa_id from tb_empresa em where em.tipo_empresa_codigo != ''IMP''
                            and em.activo = true
                    )
                    and (case when %2$L IS NOT NULL then e.empresa_razon_social ilike  ''%%%2$s%%'' else TRUE end)
                    UNION ALL
                    select 	e.cliente_id as empresa_id,
                        e.cliente_razon_social,
                        ''CLI'' as tipo_empresa_codigo
                    from  tb_cliente e
                    where e.empresa_id = %1$s
                    and (case when %2$L IS NOT NULL then e.cliente_razon_social ilike  ''%%%2$s%%'' else TRUE end)
                    ORDER BY cliente_razon_social
                    LIMIT COALESCE($1, 1000 ) OFFSET coalesce($2,0);',
                    p_empresa_origen_id,p_cliente_razon_social
                )
                USING p_max_results,p_offset;
        ELSIF v_tipo_empresa_codigo='FAB'
        THEN
            return QUERY
                EXECUTE format(
                    'select e.empresa_id as cliente_id,
                        e.empresa_razon_social as cliente_razon_social,
                        e.tipo_empresa_codigo
                    from  tb_empresa e
                    where e.empresa_id in (
                        select em.empresa_id from tb_empresa em where em.tipo_empresa_codigo != ''IMP''
                            and em.tipo_empresa_codigo != ''FAB''
                            and em.activo = true
                    )
                    and (case when %2$L IS NOT NULL then e.empresa_razon_social ilike  ''%%%2$s%%'' else TRUE end)
                    UNION ALL
                    select 	e.cliente_id as empresa_id,
                        e.cliente_razon_social,
                        ''CLI'' as tipo_empresa_codigo
                    from  tb_cliente e
                    where e.empresa_id = %1$s
                        and (case when %2$L IS NOT NULL then e.cliente_razon_social ilike  ''%%%2$s%%'' else TRUE end)
                    ORDER BY cliente_razon_social
                    LIMIT COALESCE($1, 1000 ) OFFSET coalesce($2,0);',
                    p_empresa_origen_id,p_cliente_razon_social
                )
                USING p_max_results,p_offset;
        ELSIF v_tipo_empresa_codigo='DIS'
        THEN
            return QUERY
                EXECUTE format(
                    'select e.cliente_id as empresa_id,
                        e.cliente_razon_social,
                        ''CLI''::character varying as tipo_empresa_codigo
                    from  tb_cliente e
                    where e.empresa_id = %1$s
                        and (case when %2$L IS NOT NULL then e.cliente_razon_social ilike  ''%%%2$s%%'' else TRUE end)
                    ORDER BY cliente_razon_social
                    LIMIT COALESCE($1, 1000 ) OFFSET coalesce($2,0);',
                    p_empresa_origen_id,p_cliente_razon_social
                )
                USING p_max_results,p_offset;
        END IF;
    END IF;
END;
$_$;


ALTER FUNCTION public.sp_get_clientes_for_cotizacion(p_empresa_origen_id integer, p_cliente_razon_social character varying, pc_cliente_id integer, pc_es_cliente_real boolean, p_max_results integer, p_offset integer) OWNER TO clabsuser;

--
-- TOC entry 290 (class 1255 OID 30284)
-- Name: sp_get_datos_insumos_for_producto(integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_datos_insumos_for_producto(p_insumo_id integer) RETURNS TABLE(insumo_id integer, insumo_descripcion character varying, producto_detalle_cantidad numeric, unidad_medida_codigo character varying, producto_detalle_merma numeric, insumo_tipo character varying, tcostos_indirecto boolean, unidad_medida_codigo_default character varying, unidad_medida_conversion_factor numeric, producto_total_cantidad numeric)
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 3-10-2016

Stored procedure que retorna todos los componentes de un producto , sus cantidades unidad inicial y final de conversion y sus factores
de conversion , debo anotar que aqui se da en detalle los componentes no sumarizados.


PARAMETROS :
p_insumo_id - id del producto origen para determinar sus  componentes.


RETURN:
	TABLE(
		insumo_id integer,
		insumo_descripcion character varying,
		producto_detalle_cantidad numeric,
		unidad_medida_codigo character varying,
		producto_detalle_merma numeric,
		insumo_tipo character varying,
		tcostos_indirecto boolean,
		unidad_medida_codigo_default character varying,
		unidad_medida_conversion_factor numeric,
		producto_total_cantidad  numeric)
*/
DECLARE v_empresa_id integer;
    DECLARE v_insumo_tipo character varying(2);
BEGIN
    -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
    -- y obtenemos ademas el tipo de insumo.
    select i.empresa_id,i.insumo_tipo
    into v_empresa_id,v_insumo_tipo
    from tb_insumo i
             inner join tb_empresa e on e.empresa_id = i.empresa_id
    where i.insumo_id = p_insumo_id;

    -- El id del insumo del header debera ser siempre un producto.
    IF coalesce(v_insumo_tipo,'') != 'PR'
    THEN
        RAISE 'Para la lista de items elegibles se requiere un codigo de producto no de insumo' USING ERRCODE = 'restrict_violation';
    END IF;

    return QUERY
        select

            ins.insumo_id as insumo_id,
            ins.insumo_descripcion as insumo_descripcion,
            pd.producto_detalle_cantidad as producto_detalle_cantidad,
            pd.unidad_medida_codigo as unidad_medida_codigo,
            pd.producto_detalle_merma  as producto_detalle_merma,
            ins.insumo_tipo as insumo_tipo,
            tc.tcostos_indirecto as tcostos_indirecto,
            CASE WHEN um.unidad_medida_codigo = 'NING'
                     THEN 'NING'
                 ELSE
                     um2.unidad_medida_codigo
                END as unida_medida_codigo_default,
            umc.unidad_medida_conversion_factor,
            ROUND(CASE WHEN tc.tcostos_indirecto = TRUE
                           THEN
                           pd.producto_detalle_cantidad
                       ELSE
                           CASE WHEN um2.unidad_medida_codigo IS NULL OR (umc.unidad_medida_conversion_factor IS NULL AND um2.unidad_medida_codigo != um.unidad_medida_codigo)
                                    THEN
                                    -1
                                ELSE
                                    CASE WHEN um2.unidad_medida_codigo != um.unidad_medida_codigo
                                             THEN
                                                 (pd.producto_detalle_cantidad+(pd.producto_detalle_merma*pd.producto_detalle_cantidad/100.0000))*umc.unidad_medida_conversion_factor
                                         ELSE
                                             (pd.producto_detalle_cantidad+(pd.producto_detalle_merma*pd.producto_detalle_cantidad/100.0000))
                                        END
                               END
                      END,4)
                as producto_total_cantidad
        from tb_producto_detalle pd
                 inner join tb_insumo ins on ins.insumo_id = pd.insumo_id
                 inner join tb_tcostos  tc on tc.tcostos_codigo = ins.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = pd.unidad_medida_codigo
                 left  join tb_unidad_medida um2 on um2.unidad_medida_tipo = um.unidad_medida_tipo and um2.unidad_medida_default = true
                 left  join tb_unidad_medida_conversion umc on umc.unidad_medida_origen = pd.unidad_medida_codigo and umc.unidad_medida_destino = um2.unidad_medida_codigo
        where insumo_id_origen = p_insumo_id

        union all

        select
            res.*
        from tb_producto_detalle pd
                 inner join tb_insumo ins on ins.insumo_id = pd.insumo_id
                 inner join sp_get_insumos_for_producto(ins.insumo_id) as res on res.insumo_id = res.insumo_id
        where insumo_id_origen = p_insumo_id and ins.insumo_tipo='PR' and
                ins.empresa_id = v_empresa_id;
END;
$$;


ALTER FUNCTION public.sp_get_datos_insumos_for_producto(p_insumo_id integer) OWNER TO clabsuser;

--
-- TOC entry 291 (class 1255 OID 30285)
-- Name: sp_get_historico_costos_for_insumo(integer, date, date, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_historico_costos_for_insumo(p_insumo_id integer, p_date_from date, p_date_to date, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_codigo character varying, insumo_descripcion character varying, insumo_history_fecha timestamp without time zone, insumo_history_id integer, tinsumo_descripcion character varying, tcostos_descripcion character varying, unidad_medida_descripcion character varying, insumo_merma numeric, insumo_costo numeric, moneda_costo_descripcion character varying, insumo_precio_mercado numeric)
    LANGUAGE plpgsql STABLE
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 29-01-2017

Stored procedure que retorna los costos historicos asociados a un insumo/producto y los datos auxiliartes necesarios
para un reporte o vista.



PARAMETROS :

pc_insumo_id - el id del insumo del cual extraer su historico de costos.
p_date_from - la fecha desde la cual se buscara el historico , a pesar de ser definido como TIMESTAMP
	la busqueda sera realizada solo con la parte de fecha, esto puede cambiar a futuro por eso no se indica como DATE..
p_date_to - la fecha hasta la cual se buscara el historico , a pesar de ser definido como TIMESTAMP
	la busqueda sera realizada solo con la parte de fecha, esto puede cambiar a futuro por eso no se indica como DATE..
p_max_results - Entero con el numero maximo de registros a leer
p_offset - entero con el offset de los datos a leer.

si p_max_results y  p_offset  son null , leera todos los registros.
Si p_date_from o p_date_to son nill se daran valores default.

RETURN:
  RETURNS TABLE (
	  insumo_codigo varchar,
	  insumo_descripcion varchar,
	  insumo_history_fecha timestamp,
	  insumo_history_id integer,
	  tinsumo_descripcion varchar,
	  tcostos_descripcion varchar,
	  unidad_medida_descripcion varchar,
	  insumo_merma numeric,
	  insumo_costo numeric,
	  unidad_medida_codigo_costo varchar,
	  moneda_costo_descripcion varchar,
	  insumo_precio_mercado numeric
  )


Historia : 13-06-2014
*/
DECLARE v_date_from DATE;
    DECLARE v_date_to DATE;

BEGIN
    -- si las fechas de parametros no null se ajustan a 1999 y como maximo la fecha actual.
    IF p_date_from IS NULL
    THEN
        v_date_from := '1999-01-01';
    ELSE
        v_date_from := p_date_from;
    END IF;

    IF p_date_to IS NULL
    THEN
        v_date_to := now();
    ELSE
        v_date_to := p_date_to;
    END IF;

    -- truncamos las fechas hasta el dia , quitamos la parte de la hora.
    v_date_from := date_trunc('day',v_date_from);
    v_date_to := date_trunc('day',v_date_to);

    return QUERY
        select i.insumo_codigo,
               i.insumo_descripcion,
               ih.insumo_history_fecha,
               ih.insumo_history_id,
               case when ih.insumo_tipo != 'PR' then
                        ti.tinsumo_descripcion
                    else 'Producto'
                   end as tinsumo_descripcion,
               case when ih.insumo_tipo != 'PR' then
                        tc.tcostos_descripcion
                    else NULL
                   end as tcostos_descripcion,
               um.unidad_medida_descripcion,
               case when tc.tcostos_indirecto = TRUE then
                        null
                    else ih.insumo_merma
                   end as insumo_merma,
               ih.insumo_costo,
               mo.moneda_descripcion as moneda_costo_descripcion,
               case when  tc.tcostos_indirecto = TRUE then
                        null
                    else ih.insumo_precio_mercado
                   end as insumo_precio_mercado
        from tb_insumo_history ih
                 inner join tb_insumo i on i.insumo_id = ih.insumo_id
                 inner join tb_tinsumo ti on ti.tinsumo_codigo = ih.tinsumo_codigo
                 inner join tb_tcostos tc on tc.tcostos_codigo = ih.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = ih.unidad_medida_codigo_costo
                 inner join tb_moneda mo on mo.moneda_codigo = ih.moneda_codigo_costo
        where ih.insumo_id = p_insumo_id and ih.insumo_history_fecha::date between  v_date_from  and  v_date_to
        order by ih.insumo_id,ih.insumo_history_fecha desc,ih.insumo_history_id desc
        limit COALESCE(p_max_results, 1000000 ) offset coalesce(p_offset,0);

END;
$$;


ALTER FUNCTION public.sp_get_historico_costos_for_insumo(p_insumo_id integer, p_date_from date, p_date_to date, p_max_results integer, p_offset integer) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 30287)
-- Name: sp_get_insumos_for_producto(integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_insumos_for_producto(p_insumo_id integer) RETURNS TABLE(insumo_id integer, insumo_descripcion character varying, producto_detalle_cantidad numeric, unidad_medida_codigo character varying, producto_detalle_merma numeric, insumo_tipo character varying, tcostos_indirecto boolean, unidad_medida_codigo_default character varying, unidad_medida_conversion_factor numeric, producto_total_cantidad numeric)
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 3-10-2016

Stored procedure que retorna todos los componentes de un producto , sus cantidades unidad inicial y final de conversion y sus factores
de conversion , debo anotar que aqui se da en detalle los componentes no sumarizados.


PARAMETROS :
p_insumo_id - id del producto origen para determinar sus  componentes.


RETURN:
	TABLE(
		insumo_id integer,
		insumo_descripcion character varying,
		producto_detalle_cantidad numeric,
		unidad_medida_codigo character varying,
		producto_detalle_merma numeric,
		insumo_tipo character varying,
		tcostos_indirecto boolean,
		unidad_medida_codigo_default character varying,
		unidad_medida_conversion_factor numeric,
		producto_total_cantidad  numeric)
*/
DECLARE v_empresa_id integer;
    DECLARE v_insumo_tipo character varying(2);
BEGIN
    -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
    -- y obtenemos ademas el tipo de insumo.
    select i.empresa_id,i.insumo_tipo
    into v_empresa_id,v_insumo_tipo
    from tb_insumo i
             inner join tb_empresa e on e.empresa_id = i.empresa_id
    where i.insumo_id = p_insumo_id;

    -- El id del insumo del header debera ser siempre un producto.
    IF coalesce(v_insumo_tipo,'') != 'PR'
    THEN
        RAISE 'Para la lista de items elegibles se requiere un codigo de producto no de insumo' USING ERRCODE = 'restrict_violation';
    END IF;

    return QUERY
        select

            ins.insumo_id as insumo_id,
            ins.insumo_descripcion as insumo_descripcion,
            pd.producto_detalle_cantidad as producto_detalle_cantidad,
            pd.unidad_medida_codigo as unidad_medida_codigo,
            pd.producto_detalle_merma  as producto_detalle_merma,
            ins.insumo_tipo as insumo_tipo,
            tc.tcostos_indirecto as tcostos_indirecto,
            CASE WHEN um.unidad_medida_codigo = 'NING'
                     THEN 'NING'
                 ELSE
                     um2.unidad_medida_codigo
                END as unida_medida_codigo_default,
            umc.unidad_medida_conversion_factor,
            ROUND(CASE WHEN tc.tcostos_indirecto = TRUE
                           THEN
                           pd.producto_detalle_cantidad
                       ELSE
                           CASE WHEN um2.unidad_medida_codigo IS NULL OR (umc.unidad_medida_conversion_factor IS NULL AND um2.unidad_medida_codigo != um.unidad_medida_codigo)
                                    THEN
                                    -1
                                ELSE
                                    CASE WHEN um2.unidad_medida_codigo != um.unidad_medida_codigo
                                             THEN
                                                 (pd.producto_detalle_cantidad+(pd.producto_detalle_merma*pd.producto_detalle_cantidad/100.0000))*umc.unidad_medida_conversion_factor
                                         ELSE
                                             (pd.producto_detalle_cantidad+(pd.producto_detalle_merma*pd.producto_detalle_cantidad/100.0000))
                                        END
                               END
                      END,4)
                as producto_total_cantidad
        from tb_producto_detalle pd
                 inner join tb_insumo ins on ins.insumo_id = pd.insumo_id
                 inner join tb_tcostos  tc on tc.tcostos_codigo = ins.tcostos_codigo
                 inner join tb_unidad_medida um on um.unidad_medida_codigo = pd.unidad_medida_codigo
                 left  join tb_unidad_medida um2 on um2.unidad_medida_tipo = um.unidad_medida_tipo and um2.unidad_medida_default = true
                 left  join tb_unidad_medida_conversion umc on umc.unidad_medida_origen = pd.unidad_medida_codigo and umc.unidad_medida_destino = um2.unidad_medida_codigo
        where insumo_id_origen = p_insumo_id

        union all

        select
            res.*
        from tb_producto_detalle pd
                 inner join tb_insumo ins on ins.insumo_id = pd.insumo_id
                 inner join sp_get_insumos_for_producto(ins.insumo_id) as res on res.insumo_id = res.insumo_id
        where insumo_id_origen = p_insumo_id and ins.insumo_tipo='PR' and
                ins.empresa_id = v_empresa_id;
END;
$$;


ALTER FUNCTION public.sp_get_insumos_for_producto(p_insumo_id integer) OWNER TO clabsuser;

--
-- TOC entry 297 (class 1255 OID 30288)
-- Name: sp_get_insumos_for_producto_detalle(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_insumos_for_producto_detalle(p_product_header_id integer, pc_insumo_id integer, p_insumo_descripcion character varying, p_max_results integer, p_offset integer) RETURNS TABLE(empresa_id integer, empresa_razon_social character varying, insumo_id integer, insumo_tipo character varying, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo_costo character varying, insumo_merma numeric, insumo_costo numeric, insumo_precio_mercado numeric, moneda_simbolo character varying, tcostos_indirecto boolean)
    LANGUAGE plpgsql STABLE
AS $_$
/**
Autor : Carlos arana Reategui
Fecha : 28-09-2016

Stored procedure que retorna todos los posibles insumos o productos que pueden ser parte de un detalle
de producto.

En el caso pc_insumo_id no sea null se retornara el insumo/producto que corresponde solo a ese id y se ignoraran
todos los demas parametros.

Existen 4 casos diferentes.
Caso 1: Si la empresa asociada al insumo o producto es importador solo podra ver los que pertenecen a la misma empresa.
Caso 2: Si la empresa asociada al insumo o producto es fabrica podra ver lo de la misma fabrica o importador/res
Caso 3: Si la empresa asociada al insumo o producto es distribuidor podra ver todos los de importador o fabrica.
Caso 4: No es ninguno de los anteriores no retornara nada.

PARAMETROS :
p_product_header_id - id del producto origen o producto de cabecera para el cual buscar insumos/productos posibles del detalle,
	el tipo de insumo siempre debe ser 'PR'.
pc_insumo_id - Si este parametro es definido los demas seran ignorados , si este parametro tiene valor indicara que se requiere
		la lectura especifica de un insumo y los correspondientes datos de salida.
p_insumo_descripcion - Si este parametro esta definido servira de filtro al query para acotar la busqueda por la descripcion
	del insumo/producto.
p_max_results - Entero con el numero maximo de registros a leer
p_offset - entero con el offset de los datos a leer.

si p_max_results y  p_offset  son null , leera todos los registros.

RETURN:
	TABLE(
		empresa_id integer,
		empresa_razon_social character varying,
		insumo_id integer,
		insumo_tipo character varying,
		insumo_codigo character varying,
		insumo_descripcion character varying,
		unidad_medida_codigo_costo character varying,
		insumo_merma numeric,
		insumo_costo numeric,
		moneda_simbolo character varying)


Historia : 13-06-2014
*/
DECLARE v_empresa_id integer;
    DECLARE v_tipo_empresa_codigo character varying(3);
    DECLARE v_insumo_tipo character varying(2);
BEGIN
    IF pc_insumo_id IS NOT NULL
    THEN
        return QUERY
            select ins.empresa_id as empesa_id,
                   e.empresa_razon_social as empresa_razon_social,
                   ins.insumo_id as insumo_id,
                   ins.insumo_tipo as insumo_tipo,
                   ins.insumo_codigo as insumo_codigo,
                   ins.insumo_descripcion as insumo_descripcion,
                   ins.unidad_medida_codigo_costo as unidad_medida_codigo_costo,
                   ins.insumo_merma as insumo_merma,
                   case when ins.insumo_tipo = 'PR'
                            then (select fn_get_producto_costo(ins.insumo_id, now()::date))
                        else ins.insumo_costo
                       end as insumo_costo,
                   ins.insumo_precio_mercado as insumo_precio_mercado,
                   mn.moneda_simbolo as moneda_simbolo,
                   tc.tcostos_indirecto as tcostos_indirecto
            from  tb_insumo ins
                      inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo
                      inner join tb_empresa e on e.empresa_id = ins.empresa_id
                      inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo
            where ins.insumo_id = pc_insumo_id;
    ELSE
        -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
        -- y obtenemos ademas el tipo de empresa.
        select i.empresa_id,tipo_empresa_codigo,i.insumo_tipo
        into v_empresa_id,v_tipo_empresa_codigo,v_insumo_tipo
        from tb_insumo i
                 inner join tb_empresa e on e.empresa_id = i.empresa_id
        where i.insumo_id = p_product_header_id;

        -- El id del insumo del header debera ser siempre un producto.
        IF coalesce(v_insumo_tipo,'') != 'PR'
        THEN
            RAISE 'Para la lista de items elegibles se requiere un codigo de producto no de insumo' USING ERRCODE = 'restrict_violation';
        END IF;

        return QUERY
            EXECUTE
            format(
                    'select ins.empresa_id as empesa_id,
                            e.empresa_razon_social as empresa_razon_social,
                            ins.insumo_id as insumo_id,
                            ins.insumo_tipo as insumo_tipo,
                            ins.insumo_codigo as insumo_codigo,
                            ins.insumo_descripcion as insumo_descripcion,
                            ins.unidad_medida_codigo_costo as unidad_medida_codigo_costo,
                            ins.insumo_merma as insumo_merma,
                            case when ins.insumo_tipo = ''PR''
                                then (select fn_get_producto_costo(ins.insumo_id, now()::date))
                                else ins.insumo_costo
                            end as insumo_costo,
                            ins.insumo_precio_mercado as insumo_precio_mercado,
                            mn.moneda_simbolo as moneda_simbolo,
                            tc.tcostos_indirecto as tcostos_indirecto
                        from  tb_insumo ins
                            inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo
                            inner join tb_empresa e on e.empresa_id = ins.empresa_id
                            inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo
                        where ins.activo = true
                            and ins.insumo_id != %1$s
                            and (case when %2$L=''IMP'' then ins.empresa_id = %3$s
                                when %2$L=''FAB'' then ins.empresa_id IN ((select em.empresa_id from tb_empresa em where tipo_empresa_codigo = ''IMP''
                                                                OR (tipo_empresa_codigo = ''FAB'' and em.empresa_id = %3$s)))
                                when %2$L=''DIS'' then true -- todos lods demas insumos ya quew el distribuidor compra de los demas
                                else null
                                end)
                            and ins.activo = true
                            and ins.insumo_id not in (select pd.insumo_id from tb_producto_detalle pd where pd.insumo_id_origen = %1$s)
                            and (case when %4$L IS NOT NULL then ins.insumo_descripcion ilike  ''%%%4$s%%'' else TRUE end)
                        ORDER BY ins.insumo_descripcion
                        LIMIT COALESCE($1, 1000 ) OFFSET coalesce($2,0)
                    ',p_product_header_id,v_tipo_empresa_codigo,v_empresa_id,p_insumo_descripcion
                )
            USING p_max_results,p_offset;
    END IF;

END;
$_$;


ALTER FUNCTION public.sp_get_insumos_for_producto_detalle(p_product_header_id integer, pc_insumo_id integer, p_insumo_descripcion character varying, p_max_results integer, p_offset integer) OWNER TO clabsuser;

--
-- TOC entry 298 (class 1255 OID 30291)
-- Name: sp_get_insumos_for_producto_detalle_old(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_insumos_for_producto_detalle_old(p_product_header_id integer, p_max_results integer, p_offset integer) RETURNS TABLE(empresa_id integer, empresa_razon_social character varying, insumo_id integer, insumo_tipo character varying, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo_costo character varying, insumo_merma numeric, insumo_costo numeric, insumo_precio_mercado numeric, moneda_simbolo character varying, tcostos_indirecto boolean)
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 28-09-2016

Stored procedure que retorna todos los posibles insumos o productos que pueden ser parte de un detalle
de producto.

Existen 4 casos diferentes.
Caso 1: Si la empresa asociada al insumo o producto es importador solo podra ver los que pertenecen a la misma empresa.
Caso 2: Si la empresa asociada al insumo o producto es fabrica podra ver lo de la misma fabrica o importador/res
Caso 3: Si la empresa asociada al insumo o producto es distribuidor podra ver todos los de importador o fabrica.
Caso 4: No es ninguno de los anteriores no retornara nada.

PARAMETROS :
p_product_header_id - id del producto origen o producto de cabecera para el cual buscar insumos/productos posibles del detalle,
	el tipo de insumo siempre debe ser 'PR'.
p_max_results - Entero con el numero maximo de registros a leer
p_offset - entero con el offset de los datos a leer.

si p_max_results y  p_offset  son null , leera todos los registros.

RETURN:
	TABLE(
		empresa_id integer,
		empresa_razon_social character varying,
		insumo_id integer,
		insumo_tipo character varying,
		insumo_codigo character varying,
		insumo_descripcion character varying,
		unidad_medida_codigo_costo character varying,
		insumo_merma numeric,
		insumo_costo numeric,
		moneda_simbolo character varying)


Historia : 13-06-2014
*/
DECLARE v_empresa_id integer;
    DECLARE v_tipo_empresa_codigo character varying(3);
    DECLARE v_insumo_tipo character varying(2);
BEGIN
    -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
    -- y obtenemos ademas el tipo de empresa.
    select i.empresa_id,tipo_empresa_codigo,i.insumo_tipo
    into v_empresa_id,v_tipo_empresa_codigo,v_insumo_tipo
    from tb_insumo i
             inner join tb_empresa e on e.empresa_id = i.empresa_id
    where i.insumo_id = p_product_header_id;

    -- El id del insumo del header debera ser siempre un producto.
    IF coalesce(v_insumo_tipo,'') != 'PR'
    THEN
        RAISE 'Para la lista de items elegibles se requiere un codigo de producto no de insumo' USING ERRCODE = 'restrict_violation';
    END IF;

    return QUERY
        select
            data.empresa_id,
            data.empresa_razon_social,
            data.insumo_id,
            data.insumo_tipo,
            data.insumo_codigo,
            data.insumo_descripcion,
            data.unidad_medida_codigo_costo,
            data.insumo_merma,
            data.insumo_costo,
            data.insumo_precio_mercado,
            data.moneda_simbolo,
            data.tcostos_indirecto
        from (
                 select 	ins.empresa_id,
                           e.empresa_razon_social,
                           ins.insumo_id,
                           ins.insumo_tipo,
                           ins.insumo_codigo,
                           ins.insumo_descripcion,
                           ins.unidad_medida_codigo_costo,
                           ins.insumo_merma,
                           case when ins.insumo_tipo = 'PR'
                                    then (select fn_get_producto_costo(ins.insumo_id, now()::date))
                                else ins.insumo_costo
                               end as insumo_costo,
                           ins.insumo_precio_mercado,
                           mn.moneda_simbolo,
                           tc.tcostos_indirecto
                 from  tb_insumo ins
                           inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo
                           inner join tb_empresa e on e.empresa_id = ins.empresa_id
                           inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo
                 where ins.activo = true
                   and ins.insumo_id != p_product_header_id
                   and (case when v_tipo_empresa_codigo='IMP' then ins.empresa_id = v_empresa_id
                             when v_tipo_empresa_codigo='FAB' then ins.empresa_id IN ((select em.empresa_id from tb_empresa em where tipo_empresa_codigo = 'IMP'
                                                                                                                                  OR (tipo_empresa_codigo = 'FAB' and em.empresa_id = v_empresa_id)))
                             when v_tipo_empresa_codigo='DIS' then true -- todos lods demas insumos ya quew el distribuidor compra de los demas
                             else null
                     end)
                   and ins.activo = true
                   and ins.insumo_id not in (select pd.insumo_id from tb_producto_detalle pd where pd.insumo_id_origen = p_product_header_id)
                 LIMIT COALESCE(p_max_results, 1000 ) OFFSET coalesce(p_offset,0)
             ) data;

END;
$$;


ALTER FUNCTION public.sp_get_insumos_for_producto_detalle_old(p_product_header_id integer, p_max_results integer, p_offset integer) OWNER TO clabsuser;

--
-- TOC entry 299 (class 1255 OID 30294)
-- Name: sp_get_productos_for_cotizacion(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_productos_for_cotizacion(p_cotizacion_id integer, pc_insumo_id integer, pc_insumo_descripcion character varying, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_id integer, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo character varying, unidad_medida_descripcion character varying, moneda_simbolo character varying, precio_original numeric, precio_cotizar numeric)
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-12-2016

Store que retorna la lista de productos (NO INSUMOS) que una empresa puede cotizar a otra.
En la lista resultado se incopora el precio en moneda original y el precio en valor de
cotizacion (en la moneda en que se cotiza).

PARAMETROS :
p_cotizacion_id - id de la cotizacion para la cual determinar los productos y datos
                  de calculo como fecha de tipo de cambio,moneda , etc.
pc_insumo_id - Si este parametro no es null indica buscar un producto especifico, siempre
               requiere siempre que p_cotizacion_id este indicado ya que los datos de calculo parten de alli.
pc_insumo_descripcion - Si este parametro no es null ignorara cualquier valor indicado por pc_insumo_id
               requiere siempre que p_cotizacion_id este indicado ya que los datos de calculo parten de alli.
p_max_results - Entero con el numero maximo de registros a leer
p_offset - entero con el offset de los datos a leer.

RETURN:
    TABLE (
      insumo_id integer,
      insumo_codigo varchar,
      insumo_descripcion varchar,
      unidad_medida_codigo_costo varchar,
      moneda_simbolo varchar,
      precio_original numeric,
      precio_cotizar numeric
    )

Historia : Creado 03-12-2016
*/
DECLARE v_moneda_codigo character varying(8);
    DECLARE v_empresa_id integer;
    DECLARE v_cotizacion_id integer;
    DECLARE v_cliente_id integer;
    DECLARE v_cotizacion_es_cliente_real boolean;
    DECLARE v_cotizacion_fecha date;


BEGIN

    -- Leemos los valoresa trabajar desde la cotizacion
    SELECT
        c.cotizacion_id,
        c.empresa_id,
        c.cliente_id,
        c.cotizacion_es_cliente_real,
        c.moneda_codigo,
        c.cotizacion_fecha
    INTO
        v_cotizacion_id,
        v_empresa_id,
        v_cliente_id,
        v_cotizacion_es_cliente_real,
        v_moneda_codigo,
        v_cotizacion_fecha
    FROM tb_cotizacion c
    WHERE cotizacion_id =  p_cotizacion_id;

    IF v_cotizacion_id  IS NULL
    THEN
        RAISE  'No existe la cotizacion solicitada' USING ERRCODE = 'restrict_violation';
    END IF;


    -- Leemos los datos de salida

    IF pc_insumo_descripcion IS NOT NULL
    THEN
        return QUERY
            SELECT
                i.insumo_id,
                i.insumo_codigo,
                i.insumo_descripcion,
                i.unidad_medida_codigo_costo,
                u.unidad_medida_descripcion,
                m.moneda_simbolo,
                fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,NULL::character varying,v_cotizacion_fecha,false) as precio_original,
                fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,v_moneda_codigo,v_cotizacion_fecha,false) as precio_cotizar
            FROM tb_insumo i
                     INNER JOIN tb_tcostos t ON t.tcostos_codigo = i.tcostos_codigo
                     INNER JOIN tb_moneda  m ON m.moneda_codigo = i.moneda_codigo_costo
                     INNER JOIN tb_unidad_medida u ON u.unidad_medida_codigo = i.unidad_medida_codigo_costo
            WHERE i.insumo_descripcion ilike ('%' || pc_insumo_descripcion || '%')
              and t.tcostos_indirecto =  FALSE
              and i.insumo_tipo ='PR'
            LIMIT COALESCE(p_max_results, 10000 ) OFFSET coalesce(p_offset,0);

        -- Si se indica el insumo , solo buscamos ese insumo
    ELSIF pc_insumo_id IS NOT NULL
    THEN
        return QUERY
            SELECT
                i.insumo_id,
                i.insumo_codigo,
                i.insumo_descripcion,
                i.unidad_medida_codigo_costo,
                u.unidad_medida_descripcion,
                m.moneda_simbolo,
                fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,NULL::character varying,v_cotizacion_fecha,false) as precio_original,
                fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,v_moneda_codigo,v_cotizacion_fecha,false) as precio_cotizar
            FROM tb_insumo i
                     INNER JOIN tb_tcostos t ON t.tcostos_codigo = i.tcostos_codigo
                     INNER JOIN tb_moneda  m ON m.moneda_codigo = i.moneda_codigo_costo
                     INNER JOIN tb_unidad_medida u ON u.unidad_medida_codigo = i.unidad_medida_codigo_costo
            WHERE i.insumo_id = pc_insumo_id
              and i.insumo_tipo ='PR';
    ELSE
        return QUERY
            SELECT
                i.insumo_id,
                i.insumo_codigo,
                i.insumo_descripcion,
                i.unidad_medida_codigo_costo,
                u.unidad_medida_descripcion,
                m.moneda_simbolo,
                fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,NULL::character varying,v_cotizacion_fecha,false) as precio_original,
                fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,v_moneda_codigo,v_cotizacion_fecha,false) as precio_cotizar
            FROM tb_insumo i
                     INNER JOIN tb_tcostos t ON t.tcostos_codigo = i.tcostos_codigo
                     INNER JOIN tb_moneda  m ON m.moneda_codigo = i.moneda_codigo_costo
                     INNER JOIN tb_unidad_medida u ON u.unidad_medida_codigo = i.unidad_medida_codigo_costo
            WHERE empresa_id = v_empresa_id
              and t.tcostos_indirecto =  FALSE
              and i.insumo_tipo ='PR'
            LIMIT COALESCE(p_max_results, 10000 ) OFFSET coalesce(p_offset,0);
    END IF;
END;
$$;


ALTER FUNCTION public.sp_get_productos_for_cotizacion(p_cotizacion_id integer, pc_insumo_id integer, pc_insumo_descripcion character varying, p_max_results integer, p_offset integer) OWNER TO clabsuser;

--
-- TOC entry 300 (class 1255 OID 30297)
-- Name: sp_get_productos_for_cotizacion_old(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_productos_for_cotizacion_old(p_cotizacion_id integer, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_id integer, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo character varying, unidad_medida_descripcion character varying, moneda_simbolo character varying, precio_original numeric, precio_cotizar numeric)
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-12-2016

Store que retorna la lista de productos (NO INSUMOS) que una empresa puede cotizar a otra.
En la lista resultado se incopora el precio en moneda original y el precio en valor de
cotizacion (en la moneda en que se cotiza).

PARAMETROS :
p_cotizacion_id - id de la cotizacion para la cual determinar los productos.
p_max_results - Entero con el numero maximo de registros a leer
p_offset - entero con el offset de los datos a leer.

RETURN:
    TABLE (
      insumo_id integer,
      insumo_codigo varchar,
      insumo_descripcion varchar,
      unidad_medida_codigo_costo varchar,
      moneda_simbolo varchar,
      precio_original numeric,
      precio_cotizar numeric
    )

Historia : Creado 03-12-2016
*/
DECLARE v_moneda_codigo character varying(8);
    DECLARE v_empresa_id integer;
    DECLARE v_cotizacion_id integer;
    DECLARE v_cliente_id integer;
    DECLARE v_cotizacion_es_cliente_real boolean;
    DECLARE v_cotizacion_fecha date;


BEGIN

    -- Leemos los valoresa trabajar desde la cotizacion
    SELECT
        c.cotizacion_id,
        c.empresa_id,
        c.cliente_id,
        c.cotizacion_es_cliente_real,
        c.moneda_codigo,
        c.cotizacion_fecha
    INTO
        v_cotizacion_id,
        v_empresa_id,
        v_cliente_id,
        v_cotizacion_es_cliente_real,
        v_moneda_codigo,
        v_cotizacion_fecha
    FROM tb_cotizacion c
    WHERE cotizacion_id =  p_cotizacion_id;

    IF v_cotizacion_id  IS NULL
    THEN
        RAISE  'No existe la cotizacion solicitada' USING ERRCODE = 'restrict_violation';
    END IF;


    -- Leemos los datos de salida
    return QUERY
        SELECT
            i.insumo_id,
            i.insumo_codigo,
            i.insumo_descripcion,
            i.unidad_medida_codigo_costo,
            u.unidad_medida_descripcion,
            m.moneda_simbolo,
            fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,NULL::character varying,v_cotizacion_fecha) as precio_original,
            fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,v_moneda_codigo,v_cotizacion_fecha) as precio_cotizar
        FROM tb_insumo i
                 INNER JOIN tb_tcostos t ON t.tcostos_codigo = i.tcostos_codigo
                 INNER JOIN tb_moneda  m ON m.moneda_codigo = i.moneda_codigo_costo
                 INNER JOIN tb_unidad_medida u ON u.unidad_medida_codigo = i.unidad_medida_codigo_costo
        WHERE empresa_id = v_empresa_id
          and t.tcostos_indirecto =  FALSE
          and i.insumo_tipo ='PR'
        LIMIT COALESCE(p_max_results, 10000 ) OFFSET coalesce(p_offset,0);

END;
$$;


ALTER FUNCTION public.sp_get_productos_for_cotizacion_old(p_cotizacion_id integer, p_max_results integer, p_offset integer) OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 30298)
-- Name: sp_insumo_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_insumo_delete_record(p_insumo_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que elimina un isumo o produco eliminando todos las asociaciones a sus clubes,
NO ELIMINA LOS CLUBES SOLO LAS ASOCIASIONES A LOS MISMO.

El parametro p_version_id indica el campo xmin de control para cambios externos .

Esta procedure function devuelve un entero siempre que el delete
	se haya realizado y devuelve null si no se realizo el delete. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el delete se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el delete se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el delete usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select :

	select * from ( select sp_insumo_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 03-02-2014
*/
BEGIN

    -- Verificacion previa que el registro no esta modificado
    --
    -- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
    -- pero dado que es intranscendente no es importante crear una sub transaccion para solo
    -- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
    IF EXISTS (SELECT 1 FROM tb_insumo WHERE insumo_id = p_insumo_id and xmin=p_version_id) THEN
        -- Eliminamos si es que tiene componentes
        DELETE FROM
            tb_producto_detalle
        WHERE insumo_id_origen = p_insumo_id;

        DELETE FROM
            tb_insumo
        WHERE insumo_id = p_insumo_id and xmin=p_version_id;

        -- SI SE PUDO ELIMINAR SE INDICA 1 DE LO CONTRARIO NULL
        -- VER DOCUMENTACION DE LA FUNCION
        IF FOUND THEN
            RETURN 1;
        ELSE
            RETURN null;
        END IF;
    ELSE
        RETURN null;
    END IF;

END;
$$;


ALTER FUNCTION public.sp_insumo_delete_record(p_insumo_id integer, p_usuario_mod character varying, p_version_id integer) OWNER TO clabsuser;

--
-- TOC entry 302 (class 1255 OID 30299)
-- Name: sp_perfil_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION public.sp_perfil_delete_record(p_perfil_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-01-2014

Stored procedure que elimina un perfil de menu eliminando todos los registros de perfil detalle asociados.

El parametro p_version_id indica el campo xmin de control para cambios externos .

Esta procedure function devuelve un entero siempre que el delete
	se haya realizado y devuelve null si no se realizo el delete. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el delete se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el delete se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el delete usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select :

	select * from ( select sp_perfil_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 05-01-2014
*/
BEGIN

    -- Verificacion previa que el registro no esgta modificado
    --
    -- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
    -- pero dado que es intranscendente no es importante crear una sub transaccion para solo
    -- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
    IF EXISTS (SELECT 1 FROM tb_sys_perfil WHERE perfil_id = p_perfil_id and xmin=p_version_id) THEN
        -- Eliminamos
        DELETE FROM
            tb_sys_perfil_detalle
        WHERE perfil_id = p_perfil_id ;

        DELETE FROM
            tb_sys_perfil
        WHERE perfil_id = p_perfil_id and xmin =p_version_id;

        --RAISE NOTICE  'COUNT ID --> %', FOUND;
        -- SI SE PUDO ELIMINAR SE INDICA 1 DE LO CONTRARIO NULL
        -- VER DOCUMENTACION DE LA FUNCION
        IF FOUND THEN
            RETURN 1;
        ELSE
            RETURN null;
        END IF;
    ELSE
        RETURN null;
    END IF;

END;
$$;


ALTER FUNCTION public.sp_perfil_delete_record(p_perfil_id integer, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 303 (class 1255 OID 30300)
-- Name: sp_perfil_detalle_save_record(integer, integer, integer, boolean, boolean, boolean, boolean, boolean, boolean, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION public.sp_perfil_detalle_save_record(p_perfdet_id integer, p_perfil_id integer, p_menu_id integer, p_acc_leer boolean, p_acc_agregar boolean, p_acc_actualizar boolean, p_acc_eliminar boolean, p_acc_imprimir boolean, p_activo boolean, p_usuario character varying, p_version_id integer) RETURNS integer
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-01-2014

Stored procedure que actualiza los registros de un detalle de perfil. Si este registro es un menu o submenu
aplicara los accesos a toda la ruta desde el nivel de este registro a todos los subniveles de menu
por debajo de este. Por ahora solo soporta el acceso de leer para el caso de grabacion multiple
de tal forma que si se indca que se puede leer se dara acceso total a sus hijos y si deniega se retira el acceso
total a dichos hijos.
Si el caso es que es una opcion de un menu o submenu aplicara los cambios de acceso solo a ese registro.

El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update de registro unico.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_perfil_detalle_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 08-10-2013
*/
DECLARE v_isRoot BOOLEAN := 'F';
BEGIN
    -- Si no hay acceso de lectura los demas son desactivados
    IF p_acc_leer = 'F'
    THEN
        p_acc_agregar 	= 'F';
        p_acc_actualizar 	= 'F';
        p_acc_eliminar 	= 'F';
        p_acc_imprimir 	= 'F';

    END IF;

    -- Primero vemos si es un menu o submenu (root de arbol)
    -- PAra esto vemos si algun parent id apunta a este menu , si es asi es un menu
    -- o submenu.
    IF EXISTS (SELECT 1 FROM tb_sys_menu WHERE menu_parent_id = p_menu_id)
    THEN
        v_isRoot := 'T';
        -- Si es root y acceso de lectura es true a todos true
        IF p_acc_leer = 'T'
        THEN
            p_acc_agregar 	= 'T';
            p_acc_actualizar= 'T';
            p_acc_eliminar 	= 'T';
            p_acc_imprimir 	= 'T';

        END IF;
    END IF;

    -- Si es root (menu o submenu) se hace unn update a todas las opciones
    -- debajo del menu o submenu a setear en el perfil.
    IF v_isRoot = 'T'
    THEN
        -- Este metodo es recursivo y existe en otras bases de datos
        -- revisar documentacion de las mismas.
        WITH RECURSIVE rootMenus(menu_id,menu_parent_id)
                           AS (
                SELECT menu_id,menu_parent_id
                FROM tb_sys_menu
                WHERE menu_id = p_menu_id

                UNION ALL

                SELECT
                    r.menu_id,r.menu_parent_id
                FROM tb_sys_menu r, rootMenus as t
                WHERE r.menu_parent_id = t.menu_id
            )

                       -- Update a todo el path a partir de menu o submenu raiz.
        UPDATE tb_sys_perfil_detalle
        SET perfdet_accleer=p_acc_leer,perfdet_accagregar=p_acc_agregar,
            perfdet_accactualizar=p_acc_actualizar,perfdet_accimprimir=p_acc_imprimir,
            perfdet_acceliminar=p_acc_eliminar,
            usuario_mod=p_usuario
        WHERE perfil_id = p_perfil_id-- and xmin=p_version_id
          and menu_id in (
            SELECT menu_id FROM rootMenus
        );

        RAISE NOTICE  'COUNT ID --> %', FOUND;

        IF FOUND THEN
            RETURN 1;
        ELSE
            RETURN null;
        END IF;
    ELSE
        -- UPDATE PARA EL CASO DE UNA OPCION QUE NO ES DE MENU O SUBMENU
        UPDATE tb_sys_perfil_detalle
        SET perfdet_accleer=p_acc_leer,perfdet_accagregar=p_acc_agregar,
            perfdet_accactualizar=p_acc_actualizar,perfdet_accimprimir=p_acc_imprimir,
            perfdet_acceliminar=p_acc_eliminar,
            usuario_mod=p_usuario
        WHERE perfil_id = p_perfil_id
          and menu_id = p_menu_id and xmin=p_version_id;

        RAISE NOTICE  'COUNT ID --> %', FOUND;

        IF FOUND THEN
            RETURN 1;
        ELSE
            RETURN null;
        END IF;

    END IF;
END;
$$;


ALTER FUNCTION public.sp_perfil_detalle_save_record(p_perfdet_id integer, p_perfil_id integer, p_menu_id integer, p_acc_leer boolean, p_acc_agregar boolean, p_acc_actualizar boolean, p_acc_eliminar boolean, p_acc_imprimir boolean, p_activo boolean, p_usuario character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 304 (class 1255 OID 30303)
-- Name: sp_sysperfil_add_record(character varying, character varying, character varying, integer, boolean, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION public.sp_sysperfil_add_record(p_sys_systemcode character varying, p_perfil_codigo character varying, p_perfil_descripcion character varying, p_copyfrom integer, p_activo boolean, p_usuario character varying) RETURNS integer
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 26-09-2013

Stored procedure que agrega o actualiza los registros de personal.
Previo a la grabacion forma el nombre completo del personal.

El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update , de la misma forma el parametro id sera ignorado durante un insert.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_personal_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 26-09-2013
*/

BEGIN

    -- Insertamos primero el header
    INSERT INTO
        tb_sys_perfil
    (sys_systemcode,perfil_codigo,perfil_descripcion,activo,usuario)
    VALUES (p_sys_systemcode,
            p_perfil_codigo,
            p_perfil_descripcion,
            p_activo,
            p_usuario);

    IF (p_copyFrom IS NOT NULL)
    THEN
        -- Verificamos exista el origen de copia
        IF EXISTS (SELECT 1 FROM tb_sys_perfil WHERE sys_systemcode = p_sys_systemcode and perfil_id=p_copyFrom)
        THEN
            -- De sys menu copiamos todas las opciones desabilitadas en el acceso para
            -- crear el perfil default.
            INSERT INTO
                tb_sys_perfil_detalle
            (perfil_id,perfdet_accessdef,perfdet_accleer,perfdet_accagregar,perfdet_accactualizar,perfdet_acceliminar,perfdet_accimprimir,menu_id,activo,usuario)
            SELECT  currval('tb_sys_perfil_id_seq'),perfdet_accessdef,perfdet_accleer,perfdet_accagregar,perfdet_accactualizar,perfdet_acceliminar,perfdet_accimprimir,menu_id,p_activo,p_usuario
            FROM tb_sys_perfil_detalle pd
            WHERE pd.perfil_id=p_copyFrom;
            RETURN 1;

        ELSE
            -- Excepcion de integridad referencial
            RAISE 'El perfil origen para copiar no existe' USING ERRCODE = 'no_data_found';
        END IF;
    ELSE
        -- De sys menu copiamos todas las opciones desabilitadas en el acceso para
        -- crear el perfil default.
        INSERT INTO
            tb_sys_perfil_detalle
        (perfil_id,perfdet_accessdef,perfdet_accleer,perfdet_accagregar,perfdet_accactualizar,perfdet_acceliminar,perfdet_accimprimir,menu_id,activo,usuario)
        SELECT  currval('tb_sys_perfil_id_seq'),null,'N','N','N','N','N',m.menu_id,p_activo,p_usuario
        FROM tb_sys_menu m
        WHERE m.sys_systemcode = p_sys_systemcode
        ORDER BY menu_orden;

        RETURN 1;
    END IF;

END;
$$;


ALTER FUNCTION public.sp_sysperfil_add_record(p_sys_systemcode character varying, p_perfil_codigo character varying, p_perfil_descripcion character varying, p_copyfrom integer, p_activo boolean, p_usuario character varying) OWNER TO atluser;

--
-- TOC entry 305 (class 1255 OID 30306)
-- Name: sptrg_cliente_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_cliente_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$

    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un cliente que tiene cotizaciones,
-- No puede hacerse via foreign key en cotizaciones ya que el campo cliente_id es usado tanto si es cliente
-- (tb_cliente) o empresa asociada (tb_empresa)
--
-- Author :Carlos Arana R
-- Fecha: 30/108/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF EXISTS (select 1 from tb_cotizacion where cliente_id = OLD.cliente_id LIMIT 1)
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'No puede eliminarse una cliente que tiene cotizaciones' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_cliente_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 306 (class 1255 OID 30307)
-- Name: sptrg_cotizacion_detalle_validate_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_cotizacion_detalle_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un item de una cotizacion
-- si la cotizacion esta cerrada.
--
-- Author :Carlos Arana R
-- Fecha: 14/01/2017
-- Version 1.00
-------------------------------------------------------------------------------------------
DECLARE v_cotizacion_cerrada BOOLEAN;

BEGIN
    SELECT
        cotizacion_cerrada
    INTO
        v_cotizacion_cerrada
    FROM tb_cotizacion
    WHERE cotizacion_id = OLD.cotizacion_id;

    IF (TG_OP = 'DELETE') THEN
        IF v_cotizacion_cerrada = TRUE
        THEN
            -- Excepcion
            RAISE 'No puede eliminarse un item de una cotizacion cerrada' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_cotizacion_detalle_validate_delete() OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 30308)
-- Name: sptrg_cotizacion_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_cotizacion_detalle_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que exista la cotizacion, que no este cerrada,
-- que el insumo sea producto , que exista el tipo de cambio para poder grabar los datos.
-- Finalmente lee todos los datos necesarios para completar datos historicos del item que son requeridos.
--
-- Dado que los datos historicos deben coincidir con los del calculo , recalculo por si acaso haya cambios
-- si desde un GUI se dmora en grabar los datos y estos sufren cambios , es muy remoto pero posible.
--
-- Author :Carlos Arana R
-- Fecha: 06/12/2016
-- Version 1.00
-------------------------------------------------------------------------------------------

DECLARE v_empresa_id integer;
    DECLARE v_cliente_id integer;
    DECLARE v_cotizacion_fecha date;
    DECLARE v_cotizacion_es_cliente_real boolean;
    DECLARE v_cotizacion_cerrada boolean;
    DECLARE v_regla_by_costo boolean;
    DECLARE v_regla_porcentaje numeric(6,2);
    DECLARE v_tipo_cambio_tasa_compra numeric(8,4);
    DECLARE v_tipo_cambio_tasa_venta numeric(8,4);
    DECLARE v_moneda_codigo character varying(8);
    DECLARE v_insumo_id integer;
    DECLARE v_moneda_codigo_costo character varying(8);
    DECLARE v_unidad_medida_codigo_costo character varying(8);
    DECLARE v_insumo_tipo character varying(15);
    DECLARE v_insumo_precio_mercado numeric(10,2);
    DECLARE v_insumo_precio numeric(12,2);
    DECLARE v_insumo_precio_original numeric(12,4);
    DECLARE v_insumo_costo_original numeric(12,2);

BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Leemos los datos de la cabecera para post proceso.
        SELECT
            empresa_id,
            cliente_id,
            cotizacion_fecha,
            cotizacion_es_cliente_real,
            cotizacion_cerrada,
            moneda_codigo
        FROM  tb_cotizacion
        INTO
            v_empresa_id,
            v_cliente_id,
            v_cotizacion_fecha,
            v_cotizacion_es_cliente_real,
            v_cotizacion_cerrada,
            v_moneda_codigo
            WHERE cotizacion_id = NEW.cotizacion_id;

        IF v_empresa_id IS NULL
        THEN
            RAISE 'No existe la cotizacion' USING ERRCODE = 'restrict_violation';
        END IF;

        IF v_cotizacion_cerrada	 = TRUE
        THEN
            RAISE 'La cotizacion se encuentra cerrada , no puede agregar o modificar items' USING ERRCODE = 'restrict_violation';
        END IF;

        -- datos del insumo
        SELECT
            insumo_id,
            moneda_codigo_costo,
            insumo_tipo ,
            unidad_medida_codigo_costo,
            insumo_precio_mercado,
            fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,v_moneda_codigo,v_cotizacion_fecha,true) as insumo_precio,
            fn_get_producto_precio(i.insumo_id,v_empresa_id,v_cliente_id,v_cotizacion_es_cliente_real,NULL::character varying,v_cotizacion_fecha,true) as insumo_precio_original,
            fn_get_producto_costo(i.insumo_id,v_cotizacion_fecha) as insumo_costo_original
        FROM tb_insumo i
        INTO
            v_insumo_id,
            v_moneda_codigo_costo,
            v_insumo_tipo ,
            v_unidad_medida_codigo_costo,
            v_insumo_precio_mercado,
            v_insumo_precio,
            v_insumo_precio_original,
            v_insumo_costo_original
            WHERE insumo_id = NEW.insumo_id and empresa_id = v_empresa_id;

        IF v_insumo_id IS NOT NULL
        THEN
            IF v_insumo_tipo != 'PR'
            THEN
                RAISE 'No se puede cotizar un insumo , solo productos' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            RAISE 'El producto a cotizar no existe o no pertenece a la empresa que cotiza' USING ERRCODE = 'restrict_violation';
        END IF;

        -- Leemos la regla en que se baso para guardarla.
        IF v_cotizacion_es_cliente_real = FALSE
        THEN
            SELECT
                regla_by_costo,
                regla_porcentaje
            INTO
                v_regla_by_costo,
                v_regla_porcentaje
            FROM tb_reglas
            WHERE regla_empresa_origen_id = v_empresa_id
              and regla_empresa_destino_id = v_cliente_id;
        ELSE
            v_regla_by_costo = NULL;
            v_regla_porcentaje = NULL;
        END IF;

        -- Leemos el tipo de cambio

        IF v_moneda_codigo_costo != v_moneda_codigo
        THEN
            SELECT
                tipo_cambio_tasa_compra,
                tipo_cambio_tasa_venta
            INTO
                v_tipo_cambio_tasa_compra,
                v_tipo_cambio_tasa_venta
            FROM tb_tipo_cambio
            WHERE v_cotizacion_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta
              AND moneda_codigo_origen  = v_moneda_codigo_costo
              AND moneda_codigo_destino = v_moneda_codigo ;

            IF v_tipo_cambio_tasa_compra IS NULL
            THEN
                RAISE 'No existe el tipo de cambio para el calculo de precios' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            v_tipo_cambio_tasa_compra = 1.00;
            v_tipo_cambio_tasa_venta  = 1.00;
        END IF;

        -- Agregar campos requeridos para log de cotizaciones.
        NEW.log_tipo_cambio_tasa_venta  = v_tipo_cambio_tasa_venta;
        NEW.log_tipo_cambio_tasa_compra = v_tipo_cambio_tasa_compra;
        NEW.log_regla_by_costo = v_regla_by_costo;
        NEW.log_regla_porcentaje = v_regla_porcentaje;
        NEW.log_moneda_codigo_costo = v_moneda_codigo_costo;
        NEW.log_unidad_medida_codigo_costo = v_unidad_medida_codigo_costo;
        NEW.log_insumo_precio_original = v_insumo_precio_original;
        NEW.log_insumo_precio_mercado  = v_insumo_precio_mercado;
        NEW.log_insumo_costo_original = v_insumo_costo_original;

        ----------------------------------------------------------------------------------------------
        -- Recalculamos el total con el valor obtenido en el trigger por si ha cambiado en el medio
        -- para garantizar que los campos log coinciden con el calculo del item de detalle.
        -- --------------------------------------------------------------------------------------------
        NEW.cotizacion_detalle_precio = v_insumo_precio;
        NEW.cotizacion_detalle_total = NEW.cotizacion_detalle_cantidad * v_insumo_precio;

    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_cotizacion_detalle_validate_save() OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 30310)
-- Name: sptrg_cotizacion_producto_history_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_cotizacion_producto_history_log() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que inserta uno o mas  registros al log de la tabla de insumos que
-- para este caso seran solo para productos involucrados en la cotizacion o que son parte
-- de los mismos, los insumos se agregan al history cuando son directamente agregados o modificados.
--
-- Este trigger se dispara solo cuando el campo cotizacion_cerrada es pasado a TRUE osea cuando la
-- cotizacion sea cerrada. Adicionalmente solo durante el update ya que al crearse una cotizacion
-- aun no tiene items.
--
-- Author :Carlos Arana R
-- Fecha: 14/01/2017
-- Version 1.00
-------------------------------------------------------------------------------------------

BEGIN
    IF NEW.cotizacion_cerrada = TRUE
    THEN

        -- grabamos el log del producto principal y todos los que son partes componentes del mismo.
        INSERT INTO
            tb_insumo_history (
            insumo_history_fecha,
            insumo_id,
            insumo_tipo,
            tinsumo_codigo,
            tcostos_codigo,
            unidad_medida_codigo_costo,
            insumo_merma,
            insumo_costo,
            moneda_codigo_costo,
            insumo_precio_mercado,
            insumo_history_origen_id
        )

        SELECT DISTINCT
            NEW.cotizacion_fecha,
            ins.insumo_id,
            ins.insumo_tipo,
            ins.tinsumo_codigo,
            ins.tcostos_codigo,
            ins.unidad_medida_codigo_costo,
            ins.insumo_merma,
            fn_get_producto_costo(ins.insumo_id,NEW.cotizacion_fecha) as insumo_costo,
            ins.moneda_codigo_costo,
            ins.insumo_precio_mercado,
            NEW.cotizacion_id
        FROM tb_insumo ins
        WHERE ins.insumo_id IN (
            -- Los productos de la cotizacion
            SELECT ins.insumo_id
            FROM tb_cotizacion_detalle d
                     INNER JOIN tb_insumo ins ON ins.insumo_id =d.insumo_id
            WHERE d.cotizacion_id = NEW.cotizacion_id AND ins.insumo_tipo='PR'

            UNION  -- solo union para que escogan solo los distintos

            -- Los productos incluidos en la cotizacion
            SELECT ins.insumo_id
            FROM tb_cotizacion_detalle d
                     INNER JOIN tb_insumo ins ON ins.insumo_id IN ( SELECT g.insumo_id FROM sp_get_datos_insumos_for_producto(d.insumo_id) g)
            WHERE d.cotizacion_id = NEW.cotizacion_id AND ins.insumo_tipo='PR'
        );
    END IF;
    RETURN NEW;

END;
$$;


ALTER FUNCTION public.sptrg_cotizacion_producto_history_log() OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 30311)
-- Name: sptrg_cotizacion_validate_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_cotizacion_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar una cotizacion si ya esta
-- cerrada.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF OLD.cotizacion_cerrada = TRUE
        THEN
            -- Excepcion
            RAISE 'No puede eliminarse una cotizacion cerrada' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_cotizacion_validate_delete() OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 30312)
-- Name: sptrg_cotizacion_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_cotizacion_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que al agregarse la cabecera de una cotizzacion exista
-- ya sea la empresa del grupo o el cliente a cotizar, Para discernir esto se consulta el campo
--  'cotizacion_es_cliente_real'
--
-- Author :Carlos Arana R
-- Fecha: 30/10/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
DECLARE rec_changed boolean;

BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE')
    THEN
        -- Verificamos la existencia de la empresa a la que se cotiza, no se puede hacer via foreign key
        -- ya que el campo cliente_id en realidad representa a una empresa del grupo en la tabla tb_empresa
        -- o un cliente en la tabla tb_cliente. Lo discernimos en base al campo 'cotizacion_es_cliente_real'
        IF NEW.cotizacion_es_cliente_real = TRUE
        THEN
            IF NOT EXISTS (select 1 from tb_cliente where cliente_id = NEW.cliente_id)
            THEN
                RAISE 'No existe el cliente indicado' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            IF NOT EXISTS (select 1 from tb_empresa where empresa_id = NEW.cliente_id)
            THEN
                RAISE 'No existe la empresa del grupo indicada' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        IF (TG_OP = 'UPDATE')
        THEN
            IF OLD.cotizacion_cerrada = TRUE
            THEN
                RAISE 'La cotizacion esta cerrada , no puede modificarse' USING ERRCODE = 'restrict_violation';
            END IF;


            IF NEW.cliente_id != OLD.cliente_id OR NEW.cotizacion_numero != OLD.cotizacion_numero OR
               NEW.moneda_codigo != OLD.moneda_codigo OR NEW.cotizacion_fecha != OLD.cotizacion_fecha
            THEN
                rec_changed := TRUE;
            ELSE
                rec_changed := FALSE;
            END IF;

            IF rec_changed = TRUE
            THEN
                IF EXISTS(select 1 from tb_cotizacion_detalle where cotizacion_id = NEW.cotizacion_id LIMIT 1)
                THEN
                    RAISE 'La cotizacion tiene items solo puede cerrarse no modificarse , elimine los items o eliminela' USING ERRCODE = 'restrict_violation';
                END IF;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_cotizacion_validate_save() OWNER TO clabsuser;

--
-- TOC entry 283 (class 1255 OID 30313)
-- Name: sptrg_empresa_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_empresa_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$

    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar una empresa que tiene cotizaciones,
-- No puede hacerse via foreign key en cotizaciones ya que el campo cotizacion_es_cliente_real
--  es usado tanto si es cliente (tb_cliente) o empresa asociada (tb_empresa)
--
-- Author :Carlos Arana R
-- Fecha: 30/108/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF EXISTS (select 1 from tb_cotizacion where cliente_id = OLD.empresa_id LIMIT 1)
        THEN
            RAISE 'No puede eliminarse una empresa que tiene cotizaciones' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_empresa_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 284 (class 1255 OID 30314)
-- Name: sptrg_ffarmaceutica_validate_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_ffarmaceutica_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar una forma farmaceutica que es del sistema
-- osea que el campo ffarmaceutica_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF OLD.ffarmaceutica_protected = TRUE
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'No puede eliminarse una presentacion de sistema' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_ffarmaceutica_validate_delete() OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 30315)
-- Name: sptrg_ffarmaceutica_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_ffarmaceutica_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_ffarmaceutica_codigo character varying(15);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF TG_OP = 'UPDATE'
        THEN
            IF OLD.ffarmaceutica_protected = TRUE
            THEN
                RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT ffarmaceutica_codigo INTO v_ffarmaceutica_codigo FROM tb_ffarmaceutica
        where UPPER(LTRIM(RTRIM(ffarmaceutica_descripcion))) = UPPER(LTRIM(RTRIM(NEW.ffarmaceutica_descripcion)));

        IF NEW.ffarmaceutica_codigo != v_ffarmaceutica_codigo
        THEN
            -- Excepcion no puede usarse el mismo nombre para un insumo
            RAISE 'Ya existe una forma farmaceutica con ese nombre en el codigo [%]',v_ffarmaceutica_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_ffarmaceutica_validate_save() OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 30316)
-- Name: sptrg_insumo_entries_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_insumo_entries_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante una grabacion del registro que el insumo referenciado
-- permita factor de ajuste.
--
-- Author :Carlos Arana R
-- Fecha: 14/04/2019
-- Version 1.00
-------------------------------------------------------------------------------------------

BEGIN
    -- Si el insumo con el factor de ajuste en TRUE no existe enviamos mensaje
    IF NOT EXISTS (SELECT 1 FROM tb_insumo where insumo_id = NEW.insumo_id and insumo_usa_factor_ajuste = TRUE LIMIT 1)
    THEN
        RAISE 'El insumo referenciado no soporta factor de ajuste, no puede grabarse' USING ERRCODE = 'restrict_violation';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_insumo_entries_validate_save() OWNER TO clabsuser;

--
-- TOC entry 294 (class 1255 OID 30317)
-- Name: sptrg_insumo_history_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_insumo_history_log() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que inserta un registro al log de la tabla de insumos cuando lo
-- ingresado es del tipo insumo no producto, para el caso de producto se agregaran solo cuando
-- se cotizen y la cotizacion sea cerrada.
--
-- Author :Carlos Arana R
-- Fecha: 14/01/2017
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF NEW.insumo_tipo = 'IN'
    THEN
        INSERT INTO
            tb_insumo_history (
            insumo_history_fecha,
            insumo_id,
            insumo_tipo,
            tinsumo_codigo,
            tcostos_codigo,
            unidad_medida_codigo_costo,
            insumo_merma,
            insumo_costo,
            moneda_codigo_costo,
            insumo_precio_mercado
        )
        SELECT
            now(),
            NEW.insumo_id,
            NEW.insumo_tipo,
            NEW.tinsumo_codigo,
            NEW.tcostos_codigo,
            NEW.unidad_medida_codigo_costo,
            NEW.insumo_merma,
            NEW.insumo_costo,
            NEW.moneda_codigo_costo,
            NEW.insumo_precio_mercado;
    END IF;
    RETURN NEW;

END;
$$;


ALTER FUNCTION public.sptrg_insumo_history_log() OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 30318)
-- Name: sptrg_insumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_insumo_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_insumo_codigo character varying(15);
    DECLARE v_insumo_tipo character varying(2) := NULL;
    DECLARE v_insumo_descripcion character varying(60);
    DECLARE v_tcostos_indirecto boolean;
    DECLARE v_can_be_changed boolean;

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN

        -- Cuando se trata de un producto ciertos valores siempre deben ser los mismos , por ende
        -- seteamos default. Recordar que para un PRODUCTO ('PR') el costo es calculado
        -- on line por ende no se debe grabar costo.
        IF NEW.insumo_tipo = 'PR'
        THEN
            NEW.tinsumo_codigo = 'NING';
            NEW.tcostos_codigo = 'NING';
            NEW.unidad_medida_codigo_ingreso = 'NING';
            NEW.insumo_costo = NULL;

            -- Se valida si es un producto que indique a que tipo de aplicacion pertenece el mismo , para un insumo
            -- esto es irrelevante.
            if NEW.taplicacion_entries_id ISNULL
            THEN
                RAISE 'Un producto debe indicar a que tipo de aplicacion pertenece' USING ERRCODE = 'restrict_violation';
            END IF;

        ELSE
            -- En el caso que sea un insumo y el tipo de costo es indirecto
            -- la unidad de codigo ingreso y la merma no tienen sentido y son colocados
            -- con los valores neutros.
            SELECT tcostos_indirecto INTO v_tcostos_indirecto
            FROM
                tb_tcostos
            WHERE tcostos_codigo = NEW.tcostos_codigo;

            IF v_tcostos_indirecto = FALSE AND NEW.unidad_medida_codigo_ingreso = 'NING'
            THEN
                RAISE 'Un insumo con costo directo debe especificar la unidad de medida de ingreso' USING ERRCODE = 'restrict_violation';
            END IF;

            IF v_tcostos_indirecto = TRUE
            THEN
                NEW.unidad_medida_codigo_ingreso := 'NING';
                NEW.insumo_merma := 0;
                NEW.insumo_precio_mercado := 0;
            END IF;
        END IF;

        IF NEW.unidad_medida_codigo_costo = 'NING'
        THEN
            RAISE 'La unidad de medida del costo debe estar definida' USING ERRCODE = 'restrict_violation';
        END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT insumo_codigo INTO v_insumo_codigo FROM tb_insumo
        where UPPER(LTRIM(RTRIM(insumo_descripcion))) = UPPER(LTRIM(RTRIM(NEW.insumo_descripcion)));

        IF NEW.insumo_codigo != v_insumo_codigo
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'Ya existe una insumo con ese nombre en el insumo [%]',v_insumo_codigo USING ERRCODE = 'restrict_violation';
        END IF;


        -- Validamos que exista la  conversion entre medidas siempre que sea insumo no producto , ya que los productos
        -- no tienen unidad de ingreso.
        IF NEW.insumo_tipo = 'IN' AND
           NEW.unidad_medida_codigo_ingreso != 'NING' AND NEW.unidad_medida_codigo_costo != 'NING' AND
           NEW.unidad_medida_codigo_ingreso != NEW.unidad_medida_codigo_costo AND
           NOT EXISTS(select 1 from tb_unidad_medida_conversion
                      where unidad_medida_origen = NEW.unidad_medida_codigo_ingreso AND unidad_medida_destino = NEW.unidad_medida_codigo_costo LIMIT 1)
        THEN
            RAISE 'Debera existir la conversion entre las unidades de medidas indicadas [% - %]',NEW.unidad_medida_codigo_ingreso,NEW.unidad_medida_codigo_costo  USING ERRCODE = 'restrict_violation';
        END IF;

        IF TG_OP = 'UPDATE'
        THEN
            -- Validacion si puede modificarse el registro o no dependiendo si el insumo/producto esta cotizado.
            v_can_be_changed := TRUE;

            IF NEW.insumo_tipo = 'IN'
            THEN
                -- busco si este insumo es parte de un producto ya cotizado y de serlo no permito modificaciones   .
                -- Si una cotizacion es de otra empresa es irrelevante .
                IF EXISTS (select 1 from tb_cotizacion_detalle cd
                                             inner join tb_cotizacion c on c.cotizacion_id = cd.cotizacion_id
                           where insumo_id in (
                               SELECT DISTINCT i.insumo_id FROM tb_producto_detalle pd
                                                                    INNER JOIN tb_insumo i ON i.insumo_id = pd.insumo_id_origen
                               WHERE pd.insumo_id = NEW.insumo_id
                           )
                           LIMIT 1)
                THEN
                    v_can_be_changed := FALSE;
                END IF;
            ELSE
                -- busco si este insumo es parte de un producto ya cotizado y de serlo no permito modificaciones
                -- Dado que es un producto se busca si el mismo esta cotizado tambien.
                -- Si una cotizacion es de otra empresa es irrelevante .
                IF EXISTS (select 1 from tb_cotizacion_detalle cd
                                             inner join tb_cotizacion c on c.cotizacion_id = cd.cotizacion_id
                           where insumo_id in (
                               SELECT DISTINCT i.insumo_id FROM tb_producto_detalle pd
                                                                    INNER JOIN tb_insumo i ON i.insumo_id = pd.insumo_id_origen
                               WHERE pd.insumo_id = NEW.insumo_id
                               UNION
                               SELECT NEW.insumo_id
                           )
                           LIMIT 1)
                THEN
                    v_can_be_changed := FALSE;
                END IF;
            END IF;

            -- Si esta cotizado indicamos dependiendo de los campos si puede grabarse los cambios.
            IF v_can_be_changed = FALSE
            THEN
                -- Solo puede cambiarse los campos insumo_merma,insumo_costo,insumo_precio_mercado
                IF OLD.tinsumo_codigo != NEW.tinsumo_codigo OR OLD.tcostos_codigo != NEW.tcostos_codigo OR
                   OLD.unidad_medida_codigo_ingreso !=  NEW.unidad_medida_codigo_ingreso OR
                   OLD.unidad_medida_codigo_costo != NEW.unidad_medida_codigo_costo OR
                   OLD.moneda_codigo_costo != NEW.moneda_codigo_costo
                THEN
                    RAISE 'Un insumo ya cotizado solo puede cambiarse el costo,precio mercado o merma' USING ERRCODE = 'restrict_violation';
                END IF;
            END IF;

            -- Si llega a este punto validamops si se ha cambiado el flag insumo_usa_factor_ajuste
            -- haya sido apagado estando antes prendido , de ser asi debemos eliminar todo los movimientos
            -- de ingreso para el calculo del factor de ajuste del insumo, claro debe ser insumo
            IF NEW.insumo_tipo = 'IN'
            THEN
                IF OLD.insumo_usa_factor_ajuste = TRUE and NEW.insumo_usa_factor_ajuste = FALSE
                THEN
                    DELETE FROM tb_insumo_entries WHERE insumo_id = OLD.insumo_id;
                END IF;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_insumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 309 (class 1255 OID 30321)
-- Name: sptrg_moneda_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_moneda_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_moneda_codigo_s character varying(8);
    DECLARE v_moneda_codigo_d character varying(8);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que no exista otra moneda con las
-- mismas siglas o descripcion.
-- No he usado unique index o constraint ya que prefiero indicar que moneda es la que tiene
-- la sigla o descripcion duplicada. En este caso no habra muchos registros por lo que el impacto
-- es minimo.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- buscamos si existe un codigo que ya tenga las mismas siglas
        SELECT moneda_codigo INTO v_moneda_codigo_s FROM tb_moneda
        where moneda_simbolo = NEW.moneda_simbolo;

        -- buscamos si existe un codigo que ya tenga la misma descripcion
        SELECT moneda_codigo INTO v_moneda_codigo_d FROM tb_moneda
        where UPPER(LTRIM(RTRIM(moneda_descripcion))) = UPPER(LTRIM(RTRIM(NEW.moneda_descripcion)));

        IF NEW.moneda_codigo != v_moneda_codigo_s
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'Las siglas de la moneda existe en otro codigo [%]',v_moneda_codigo_s USING ERRCODE = 'restrict_violation';
        END IF;

        IF NEW.moneda_codigo != v_moneda_codigo_d
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'La descripcion de la moneda existe en otro codigo [%]',v_moneda_codigo_d USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_moneda_validate_save() OWNER TO clabsuser;

--
-- TOC entry 318 (class 1255 OID 102484)
-- Name: sptrg_procesos_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_procesos_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_procesos_codigo character varying(8);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de costo , que no exista un tipo de costo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT procesos_codigo INTO v_procesos_codigo FROM tb_procesos
        where UPPER(LTRIM(RTRIM(procesos_descripcion))) = UPPER(LTRIM(RTRIM(NEW.procesos_descripcion)));

        IF NEW.procesos_codigo != v_procesos_codigo
        THEN
            RAISE 'Ya existe una proceso con ese nombre en el codigo de proceso [%]',v_procesos_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_procesos_validate_save() OWNER TO clabsuser;

--
-- TOC entry 310 (class 1255 OID 30322)
-- Name: sptrg_producto_detalle_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_producto_detalle_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un delete que no sea posible si ya el producto
-- esta cotizado.
--
-- Author :Carlos Arana R
-- Fecha: 03/11/2018
-- Version 1.00
-------------------------------------------------------------------------------------------

BEGIN
    IF (TG_OP = 'DELETE') THEN
        -- Si ya esta cotizado el producto principal no pueden cambiarse un componente del mismo.
        IF EXISTS (SELECT 1 FROM tb_cotizacion_detalle where insumo_id = OLD.insumo_id_origen LIMIT 1)
        THEN
            RAISE 'No puede modificarse la composicion de un producto que ya se encuentra cotizado , cree uno nuevo o elimine las cotizaciones' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_producto_detalle_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 311 (class 1255 OID 30323)
-- Name: sptrg_producto_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_producto_detalle_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que no permite agregar un producto
-- detalle cuyo id es el mismo que el producto principal al cual perteneceria., ni si este item a agregar
-- esta coneniendo a otro que lo contiene.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
DECLARE v_unidad_medida_codigo_costo character varying(8);
    DECLARE v_tcostos_indirecto boolean;
    DECLARE v_insumo_tipo character varying(2) := NULL;

    DECLARE v_empresa_item_id integer;
    DECLARE v_empresa_producto_id integer;

BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.insumo_id = NEW.insumo_id_origen
        THEN
            RAISE 'Un componente no puede ser igual al producto principal' USING ERRCODE = 'restrict_violation';
        END IF;

        -- Si ya esta cotizado el producto principal no pueden cambiarse un componente del mismo.
        IF EXISTS (SELECT 1 FROM tb_cotizacion_detalle where insumo_id = NEW.insumo_id_origen LIMIT 1)
        THEN
            RAISE 'No puede modificarse la composicion de un producto que ya se encuentra cotizado , cree uno nuevo o elimine las cotizaciones' USING ERRCODE = 'restrict_violation';
        END IF;


        --No se puede agregar un producto como item si es que este mismo contiene al producto
        -- principal.
        IF EXISTS(select 1 from tb_producto_detalle where insumo_id_origen = NEW.insumo_id and insumo_id = NEW.insumo_id_origen LIMIT 1)
        THEN
            RAISE 'Este item contiene a este producto lo cual no es posible' USING ERRCODE = 'restrict_violation';
        END IF;

        -- leemos datos para validacion
        SELECT unidad_medida_codigo_costo,insumo_tipo,tcostos_indirecto
        INTO v_unidad_medida_codigo_costo,v_insumo_tipo,v_tcostos_indirecto
        FROM
            tb_insumo ins
                INNER JOIN tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
        WHERE insumo_id = NEW.insumo_id;

        -- Si el tipo de costos del insumo es del tipo INDIRECTO  este debe pertenecer a la empresa a la que pertenece el producto al cual se esta agregando esta
        -- linea de detalle.
        IF v_tcostos_indirecto = TRUE AND TG_OP = 'INSERT'
        THEN
            select empresa_id
            INTO v_empresa_item_id
            FROM
                tb_insumo ins
            where ins.insumo_id = NEW.insumo_id;

            select empresa_id
            INTO v_empresa_producto_id
            FROM
                tb_insumo ins
            where ins.insumo_id = NEW.insumo_id_origen;

            IF v_empresa_item_id != v_empresa_producto_id
            THEN
                RAISE 'Un insumo del tipo indirecto solo puede ser de la misma empresa del producto en proceso' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- si es del yipo insumo validamos el tema del costo indirecto.
        IF v_insumo_tipo = 'IN'
        THEN
            -- En el caso que sea un insumo y el tipo de costo es indirecto
            -- la unidad de codigo ingreso y la merma no tienen sentido y son colocados
            -- con los valores neutros.
            -- Asi mismo si en este caso si el costo es directo la unidad de medida debe estar definida.
            IF v_tcostos_indirecto = FALSE AND NEW.unidad_medida_codigo = 'NING'
            THEN
                RAISE 'Un insumo con costo directo debe especificar la unidad de costeo' USING ERRCODE = 'restrict_violation';
            END IF;

            IF v_tcostos_indirecto = TRUE
            THEN
                NEW.unidad_medida_codigo := 'NING';
                NEW.producto_detalle_merma := 0;
            END IF;
        ELSE
            -- Para el caso de productos la unidad de medida debe estar siempre definida.
            IF NEW.unidad_medida_codigo = 'NING'
            THEN
                RAISE 'Un producto debe especificar la unidad de medida de costeo' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- Validamos que el tipo de unidad del item exista conversion entre medidas siempre que sea insumo no producto , ya que los productos
        -- no tienen unidad de ingreso.

        -- Si las unidades son diferentes y los costos son directos requiere validacion .
        IF v_unidad_medida_codigo_costo != NEW.unidad_medida_codigo AND v_tcostos_indirecto = FALSE
        THEN
            IF NOT EXISTS(
                    select 1
                    from tb_unidad_medida_conversion
                    where unidad_medida_origen = v_unidad_medida_codigo_costo AND
                            unidad_medida_destino = NEW.unidad_medida_codigo LIMIT 1)
            THEN
                RAISE 'No existe conversion entre la unidad de costo y la unidad indicada en el item , indicadas por [% - %]',v_unidad_medida_codigo_costo,NEW.unidad_medida_codigo  USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_producto_detalle_validate_save() OWNER TO clabsuser;

--
-- TOC entry 327 (class 1255 OID 102666)
-- Name: sptrg_producto_procesos_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_producto_procesos_detalle_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que el porcentaje total asignado a
-- todos los procesos asignados no exceda el 100.00% , ni sea menor que 0.
--
-- Author :Carlos Arana R
-- Fecha: 28/05/2021
-- Version 1.00
-------------------------------------------------------------------------------------------

DECLARE v_producto_procesos_detalle_porcentaje_total numeric(6,2);
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN


        -- Leemos total de porcentajes hasta antes de grabar
        SELECT
            sum(producto_procesos_detalle_porcentaje)
        INTO
            v_producto_procesos_detalle_porcentaje_total
        FROM tb_producto_procesos_detalle
        WHERE producto_procesos_id = NEW.producto_procesos_id and procesos_codigo != NEW.procesos_codigo;

        v_producto_procesos_detalle_porcentaje_total := v_producto_procesos_detalle_porcentaje_total+NEW.producto_procesos_detalle_porcentaje ;

        IF v_producto_procesos_detalle_porcentaje_total < 0
        THEN
            RAISE 'El porcentaje total asignado a los procesos no puede ser menor que 0' USING ERRCODE = 'restrict_violation';
        END IF;

        IF v_producto_procesos_detalle_porcentaje_total > 100.00
        THEN
            RAISE 'El porcentaje total asignado a los procesos no puede exceder el 100.00 por ciento' USING ERRCODE = 'restrict_violation';
        END IF;

    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_producto_procesos_detalle_validate_save() OWNER TO postgres;

--
-- TOC entry 328 (class 1255 OID 102668)
-- Name: sptrg_producto_procesos_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_producto_procesos_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que exista que el insumo sea del tipo producto
--
-- Author :Carlos Arana R
-- Fecha: 28/05/2021
-- Version 1.00
-------------------------------------------------------------------------------------------

DECLARE v_insumo_id           integer;
    DECLARE v_insumo_tipo         varchar(2);

BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- datos del insumo
        SELECT insumo_id,
               insumo_tipo
        INTO
            v_insumo_id,
            v_insumo_tipo
        FROM tb_insumo i
        WHERE insumo_id = NEW.insumo_id;-- and empresa_id = v_empresa_id;

        IF v_insumo_id IS NOT NULL
        THEN
            IF v_insumo_tipo != 'PR'
            THEN
                RAISE 'No se puede asignar procesos a un insumo  solo a productos' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            RAISE 'El producto a asociar no existe' USING ERRCODE = 'restrict_violation';
        END IF;

    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_producto_procesos_validate_save() OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 30324)
-- Name: sptrg_reglas_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_reglas_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_tipo_empresa_codigo_origen character varying(3);
    DECLARE v_tipo_empresa_codigo_destino character varying(3);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.regla_empresa_origen_id = NEW.regla_empresa_destino_id
        THEN
            RAISE 'No puede existir una regla de costos en la misma empresa' USING ERRCODE = 'restrict_violation';
        END IF;

        -- Verificamos la jerarquia entre la empresa de origen y la de destino.
        -- Las fabricas pueden tener como origen un importador.
        -- las distribuidoras pueden tener como origen una fabrica o una importadora.
        -- Ninguna otra condicion es permitida.
        select tipo_empresa_codigo INTO v_tipo_empresa_codigo_origen
        FROM tb_empresa where empresa_id = NEW.regla_empresa_origen_id;

        select tipo_empresa_codigo INTO v_tipo_empresa_codigo_destino
        FROM tb_empresa where empresa_id = NEW.regla_empresa_destino_id;

        IF v_tipo_empresa_codigo_origen = 'IMP'
        THEN
            IF v_tipo_empresa_codigo_destino != 'FAB' AND v_tipo_empresa_codigo_destino != 'DIS'
            THEN
                RAISE 'Solo fabrica y distribuidor pueden tener reglas de costos con un importador' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSIF v_tipo_empresa_codigo_origen = 'FAB'
        THEN
            IF v_tipo_empresa_codigo_destino != 'DIS'
            THEN
                RAISE 'Solo distribuidores pueden tener reglas de costos con una fabrica' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSIF v_tipo_empresa_codigo_origen = 'DIS' OR v_tipo_empresa_codigo_destino = 'CLI'
        THEN
            RAISE 'Solo Importadores o Fabricas pueden tener reglas de costos con otras empresas' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_reglas_validate_save() OWNER TO clabsuser;

--
-- TOC entry 326 (class 1255 OID 102494)
-- Name: sptrg_subprocesos_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_subprocesos_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_subprocesos_codigo character varying(8);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el subproceso
-- no exista un subproceso con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT subprocesos_codigo INTO v_subprocesos_codigo FROM tb_subprocesos
        where UPPER(LTRIM(RTRIM(subprocesos_descripcion))) = UPPER(LTRIM(RTRIM(NEW.subprocesos_descripcion)));

        IF NEW.subprocesos_codigo != v_subprocesos_codigo
        THEN
            RAISE 'Ya existe un subproceso con ese nombre en el codigo de subproceso [%]',v_subprocesos_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_subprocesos_validate_save() OWNER TO clabsuser;

--
-- TOC entry 330 (class 1255 OID 102740)
-- Name: sptrg_taplicacion_entries_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_taplicacion_entries_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE
    v_taplicacion_codigo          character varying(8);
    DECLARE v_totentries_repeated int;
-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el subtipos de aplicaciomes
-- no exista otra entrada  con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2021
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT count(taplicacion_codigo)
        INTO v_totentries_repeated
        FROM tb_taplicacion_entries
        where UPPER(LTRIM(RTRIM(taplicacion_entries_descripcion))) = UPPER(LTRIM(RTRIM(NEW.taplicacion_entries_descripcion)))
          AND taplicacion_codigo = NEW.taplicacion_codigo;

        IF (v_totentries_repeated > 0)
        THEN
            RAISE 'Solo puede existir un subtipo con la descripcion  [%]',NEW.taplicacion_entries_descripcion USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_taplicacion_entries_validate_save() OWNER TO clabsuser;

--
-- TOC entry 331 (class 1255 OID 102823)
-- Name: sptrg_taplicacion_procesos_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_taplicacion_procesos_detalle_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que el porcentaje total asignado a
-- todos los procesos asignados no exceda el 100.00% , ni sea menor que 0.
--
-- Author :Carlos Arana R
-- Fecha: 28/05/2021
-- Version 1.00
-------------------------------------------------------------------------------------------

DECLARE v_taplicacion_procesos_detalle_porcentaje_total numeric(6,2);
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN


        -- Leemos total de porcentajes hasta antes de grabar
        SELECT
            sum(taplicacion_procesos_detalle_porcentaje)
        INTO
            v_taplicacion_procesos_detalle_porcentaje_total
        FROM tb_taplicacion_procesos_detalle
        WHERE taplicacion_procesos_id = NEW.taplicacion_procesos_id and procesos_codigo != NEW.procesos_codigo;

        v_taplicacion_procesos_detalle_porcentaje_total := v_taplicacion_procesos_detalle_porcentaje_total+NEW.taplicacion_procesos_detalle_porcentaje ;

        IF v_taplicacion_procesos_detalle_porcentaje_total < 0
        THEN
            RAISE 'El porcentaje total asignado a los procesos no puede ser menor que 0' USING ERRCODE = 'restrict_violation';
        END IF;

        IF v_taplicacion_procesos_detalle_porcentaje_total > 100.00
        THEN
            RAISE 'El porcentaje total asignado a los procesos no puede exceder el 100.00 por ciento' USING ERRCODE = 'restrict_violation';
        END IF;

    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_taplicacion_procesos_detalle_validate_save() OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 102720)
-- Name: sptrg_taplicacion_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_taplicacion_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_taplicacion_codigo character varying(15);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de aplicacion , que no exista un tipo de aplicacion con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 29/06/2021
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT taplicacion_codigo INTO v_taplicacion_codigo FROM tb_taplicacion
        where UPPER(LTRIM(RTRIM(taplicacion_descripcion))) = UPPER(LTRIM(RTRIM(NEW.taplicacion_descripcion)));

        IF NEW.taplicacion_codigo != v_taplicacion_codigo
        THEN
            -- Excepcion no puede usarse el mismo nombre
            RAISE 'Ya existe una tipo de aplicacion con ese nombre en el codigo [%]',v_taplicacion_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_taplicacion_validate_save() OWNER TO clabsuser;

--
-- TOC entry 325 (class 1255 OID 102392)
-- Name: sptrg_tcosto_global_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_tcosto_global_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_tcosto_global_codigo_d character varying(8);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que no exista otra tipo de costo global
-- con la misma descripcion.
-- No he usado unique index o constraint ya que prefiero indicar que tipo de codigo global  es la que tiene
-- la descripcion duplicada. En este caso no habra muchos registros por lo que el impacto
-- es minimo.
--
-- Author :Carlos Arana R
-- Fecha: 10/04/2021
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- buscamos si existe un codigo que ya tenga la misma descripcion
        SELECT tcosto_global_codigo INTO v_tcosto_global_codigo_d FROM tb_tcosto_global
        where UPPER(LTRIM(RTRIM(tcosto_global_descripcion))) = UPPER(LTRIM(RTRIM(NEW.tcosto_global_descripcion)));

        IF NEW.tcosto_global_codigo != v_tcosto_global_codigo_d
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'La descripcion del tipo de costo global existe en otro codigo [%]',v_tcosto_global_codigo_d USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tcosto_global_validate_save() OWNER TO clabsuser;

--
-- TOC entry 313 (class 1255 OID 30325)
-- Name: sptrg_tcostos_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_tcostos_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$

    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de cosoto que es del sistema
-- osea que el campo tcostos_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF OLD.tcostos_protected = TRUE
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'No puede eliminarse un tipo de costos de sistema' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_tcostos_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 288 (class 1255 OID 30326)
-- Name: sptrg_tcostos_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_tcostos_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_tcostos_codigo character varying(5);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de costo , que no exista un tipo de costo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF TG_OP = 'UPDATE'
        THEN
            IF OLD.tcostos_protected = TRUE
            THEN
                RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT tcostos_codigo INTO v_tcostos_codigo FROM tb_tcostos
        where UPPER(LTRIM(RTRIM(tcostos_descripcion))) = UPPER(LTRIM(RTRIM(NEW.tcostos_descripcion)));

        IF NEW.tcostos_codigo != v_tcostos_codigo
        THEN
            RAISE 'Ya existe una tipo de costo con ese nombre en el tipo de costos [%]',v_tcostos_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tcostos_validate_save() OWNER TO clabsuser;

--
-- TOC entry 289 (class 1255 OID 30327)
-- Name: sptrg_tinsumo_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_tinsumo_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de insumo que es del sistema
-- osea que el campo tinsumo_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF OLD.tinsumo_protected = TRUE
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'No puede eliminarse un tipo de insumo de sistema' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_tinsumo_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 314 (class 1255 OID 30328)
-- Name: sptrg_tinsumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_tinsumo_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_tinsumo_codigo character varying(15);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF TG_OP = 'UPDATE'
        THEN
            IF OLD.tinsumo_protected = TRUE
            THEN
                RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT tinsumo_codigo INTO v_tinsumo_codigo FROM tb_tinsumo
        where UPPER(LTRIM(RTRIM(tinsumo_descripcion))) = UPPER(LTRIM(RTRIM(NEW.tinsumo_descripcion)));

        IF NEW.tinsumo_codigo != v_tinsumo_codigo
        THEN
            -- Excepcion no puede usarse el mismo nombre para un insumo
            RAISE 'Ya existe una tipo de insumo con ese nombre en el tipo de insumo [%]',v_tinsumo_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tinsumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 315 (class 1255 OID 30329)
-- Name: sptrg_tipo_cambio_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_tipo_cambio_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$

    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que los valores sean
-- consistentes , por ejemplo el rango de fechas y que las momedas sean diferentes entre
--- otras.
---
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.moneda_codigo_origen = NEW.moneda_codigo_destino
        THEN
            RAISE 'La moneda origen no puede ser la misma que la de destino' USING ERRCODE = 'restrict_violation';
        END IF;

        IF NEW.tipo_cambio_fecha_desde > NEW.tipo_cambio_fecha_hasta
        THEN
            RAISE 'La fecha inicial no puede ser mayor que la fecha final' USING ERRCODE = 'restrict_violation';
        END IF;

        IF TG_OP = 'UPDATE'
        THEN
            -- Validamos que no haya un tipo de cambio entre las fechas indicadas, pero que no sea el mismo
            -- registro al que hacemos update.
            -- Algoritmo , si es tru entonces las fechas se cruzan( start1 <= end2 and start2 <= end1 )
            IF EXISTS( SELECT 1 from tb_tipo_cambio tc
                       where (tc.moneda_codigo_origen = NEW.moneda_codigo_origen and
                              tc.moneda_codigo_destino = NEW.moneda_codigo_destino) and
                               tc.tipo_cambio_fecha_desde <= NEW.tipo_cambio_fecha_hasta and
                               tc.tipo_cambio_fecha_hasta >= NEW.tipo_cambio_fecha_desde and
                               tc.tipo_cambio_id != NEW.tipo_cambio_id)
            THEN
                RAISE 'Ya existe un tipo de cambio en ese rango de fechas' USING ERRCODE = 'restrict_violation';
            END IF;
        ELSE
            -- Validamos que no haya un tipo de cambio entre las fechas indicadas.
            -- Algoritmo , si es tru entonces las fechas se cruzan( start1 <= end2 and start2 <= end1 )
            IF EXISTS( SELECT 1 from tb_tipo_cambio tc
                       where (tc.moneda_codigo_origen = NEW.moneda_codigo_origen and
                              tc.moneda_codigo_destino = NEW.moneda_codigo_destino) and
                               tc.tipo_cambio_fecha_desde <= NEW.tipo_cambio_fecha_hasta and
                               tc.tipo_cambio_fecha_hasta >= NEW.tipo_cambio_fecha_desde)
            THEN
                RAISE 'Ya existe un tipo de cambio en ese rango de fechas' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tipo_cambio_validate_save() OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 30330)
-- Name: sptrg_tpresentacion_validate_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_tpresentacion_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de insumo que es del sistema
-- osea que el campo tpresentacion_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF OLD.tpresentacion_protected = TRUE
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'No puede eliminarse una presentacion de sistema' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_tpresentacion_validate_delete() OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 30331)
-- Name: sptrg_tpresentacion_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sptrg_tpresentacion_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_tpresentacion_codigo character varying(15);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un update que para el tipo
-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF TG_OP = 'UPDATE'
        THEN
            IF OLD.tpresentacion_protected = TRUE
            THEN
                RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT tpresentacion_codigo INTO v_tpresentacion_codigo FROM tb_tpresentacion
        where UPPER(LTRIM(RTRIM(tpresentacion_descripcion))) = UPPER(LTRIM(RTRIM(NEW.tpresentacion_descripcion)));

        IF NEW.tpresentacion_codigo != v_tpresentacion_codigo
        THEN
            -- Excepcion no puede usarse el mismo nombre para un insumo
            RAISE 'Ya existe una presentacion con ese nombre en el codigo [%]',v_tpresentacion_codigo USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tpresentacion_validate_save() OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 30332)
-- Name: sptrg_unidad_medida_conversion_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_unidad_medida_conversion_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_unidad_medida_origen_tipo CHARACTER(1);
    DECLARE v_unidad_medida_destino_tipo CHARACTER(1);

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que los valores sean
-- consistentes , las unidades de medida no deben ser las mismas y asi mismo deben de ser del
-- mismo tipo por ejemplo VOLUMEN.

-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.unidad_medida_origen = NEW.unidad_medida_destino
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'LA unidad de medida origen no puede ser la misma que la de destino' USING ERRCODE = 'restrict_violation';
        END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT unidad_medida_tipo INTO v_unidad_medida_origen_tipo
        FROM tb_unidad_medida
        WHERE unidad_medida_codigo = NEW.unidad_medida_origen;

        SELECT unidad_medida_tipo INTO v_unidad_medida_destino_tipo
        FROM tb_unidad_medida
        WHERE unidad_medida_codigo = NEW.unidad_medida_destino;

        IF v_unidad_medida_origen_tipo != v_unidad_medida_destino_tipo
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'Ambas unidades de medida deben de ser del mismo tipo' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_unidad_medida_conversion_validate_save() OWNER TO clabsuser;

--
-- TOC entry 320 (class 1255 OID 30333)
-- Name: sptrg_unidad_medida_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_unidad_medida_validate_delete() RETURNS trigger
    LANGUAGE plpgsql
AS $$

    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de cosoto que es del sistema
-- osea que el campo tcostos_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'DELETE') THEN
        IF OLD.unidad_medida_protected = TRUE
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'No puede eliminarse una unidad de medida de sistema' USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_unidad_medida_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 321 (class 1255 OID 30334)
-- Name: sptrg_unidad_medida_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_unidad_medida_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_unidad_medida_codigo_s character varying(8);
    DECLARE v_unidad_medida_codigo_d character varying(8);
    DECLARE v_unidad_medida_descripcion character varying(80);
-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que no exista otra undad de media con las
-- mismas siglas o descripcion.
-- No he usado unique index o constraint ya que prefiero indicar que unidad de medida es la que tiene
-- la sigla o descripcion duplicada. En este caso no habra muchos registros por lo que el impacto
-- es minimo.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF TG_OP = 'UPDATE'
        THEN
            IF OLD.unidad_medida_protected = TRUE
            THEN
                RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
            END IF;
        END IF;

        -- buscamos si existe un codigo que ya tenga las mismas siglas
        SELECT unidad_medida_codigo INTO v_unidad_medida_codigo_s FROM tb_unidad_medida
        where unidad_medida_siglas = NEW.unidad_medida_siglas;

        -- buscamos si existe un codigo que ya tenga la misma descripcion
        SELECT unidad_medida_codigo INTO v_unidad_medida_codigo_d FROM tb_unidad_medida
        where UPPER(LTRIM(RTRIM(unidad_medida_descripcion))) = UPPER(LTRIM(RTRIM(NEW.unidad_medida_descripcion)));

        IF NEW.unidad_medida_codigo != v_unidad_medida_codigo_s
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'Las siglas de la unidad de medida existe en otro codigo [%]',v_unidad_medida_codigo_s USING ERRCODE = 'restrict_violation';
        END IF;

        IF NEW.unidad_medida_codigo != v_unidad_medida_codigo_d
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'La descripcion de la unidad de medida existe en otro codigo [%]',v_unidad_medida_codigo_d USING ERRCODE = 'restrict_violation';
        END IF;

        -- Si se ha indicado que sera el default verificamos que no exista otro seteado como tal.
        IF NEW.unidad_medida_default = TRUE
        THEN
            IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' and NEW.unidad_medida_default != OLD.unidad_medida_default)
            THEN
                select unidad_medida_descripcion into v_unidad_medida_descripcion
                from tb_unidad_medida
                where
                        unidad_medida_tipo = NEW.unidad_medida_tipo and
                        unidad_medida_default = true ;

                IF v_unidad_medida_descripcion IS NOT NULL
                THEN
                    RAISE 'Solo una unidad de medida puede ser la default para un tipo como volumen,peso,etc y [%] es actualmente la default',v_unidad_medida_descripcion USING ERRCODE = 'restrict_violation';
                END IF;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_unidad_medida_validate_save() OWNER TO clabsuser;

--
-- TOC entry 322 (class 1255 OID 30335)
-- Name: sptrg_update_log_fields(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_update_log_fields() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que hace update a los campos usuario,fecha_creacion,usuario_mod,
-- fecha_modificacion.
-- Esta funcion es usada para todas las tablas del sistema que tienen dichos campos
-- obviamente debe crearse el trigger para cada caso . por ejemplo :
--
-- DROP TRIGGER tr_tipoDocumento ON tramite.tb_tm_tdocumento;
--
-- CREATE  TRIGGER tr_tipoDocumento
-- BEFORE INSERT OR UPDATE ON tramite.tb_tm_tdocumento
--     FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();
--
-- Author :Carlos Arana R
-- Fecha: 26/08/2013
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.FECHA_CREACION := now();
        IF (NEW.usuario is null) THEN
            NEW.usuario := current_user;
        END IF;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        -- Solo si hay cambio en el registro
        IF (OLD != NEW) THEN
            NEW.fecha_modificacion := now();
            IF (NEW.usuario_mod is null) THEN
                NEW.usuario_mod := current_user;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_update_log_fields() OWNER TO clabsuser;

--
-- TOC entry 323 (class 1255 OID 30336)
-- Name: sptrg_usuario_perfiles_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_usuario_perfiles_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE v_usuario_perfil_id integer;

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que no pueda existir
-- mas de un perfil para el mismo sistema y el mismo usuario.
--
-- Author :Carlos Arana R
-- Fecha: 02/10/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN

        if TG_OP = 'INSERT'
        THEN
            v_usuario_perfil_id = -1;
        ELSE
            v_usuario_perfil_id = NEW.usuario_perfil_id;
        END IF;

        -- Validamos que exista la  conversion entre medidas siempre que sea insumo no producto , ya que los productos
        -- no tienen unidad de ingreso.
        IF EXISTS(select 1 from tb_sys_usuario_perfiles up
                                    inner join tb_sys_perfil sp on sp.perfil_id = up.perfil_id
                  where
                          up.usuarios_id = NEW.usuarios_id and
                          up.usuario_perfil_id != v_usuario_perfil_id and
                          sys_systemcode = (select sys_systemcode from tb_sys_perfil where perfil_id = new.perfil_id)LIMIT 1)
        THEN
            RAISE 'Cada usuario solo puede tener un perfil por sistema' USING ERRCODE = 'restrict_violation';
        END IF;

    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_usuario_perfiles_save() OWNER TO clabsuser;

--
-- TOC entry 324 (class 1255 OID 30337)
-- Name: sptrg_verify_usuario_code_change(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_verify_usuario_code_change() RETURNS trigger
    LANGUAGE plpgsql
AS $$
    -------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no pueda eliminarse un registro de usuario
-- que es referenciada por una tabla con el codigo de usuario usado.
-- En el caso de update no permitira cambios ni en el usuarios_code o el usuarios_nombre_completo
-- si alguna tabla referencia al usuario.
--
-- Author :Carlos Arana R
-- Fecha: 17/08/2015
-- Version 1.00
-------------------------------------------------------------------------------------------
DECLARE v_TABLENAME_ROW RECORD;
    DECLARE v_queryfield CHARACTER VARYING;
    DECLARE v_found integer;

BEGIN

    IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
        -- Verificamos si ha habido cambio de codigo de usuario o nombre o si se trata de un delete
        IF TG_OP = 'DELETE' OR (OLD.usuarios_code <> NEW.usuarios_code OR OLD.usuarios_nombre_completo <> NEW.usuarios_nombre_completo)
        THEN
            -- Busco todas las tablas en el esquema public ya que pertenecen solo al sistema
            FOR v_TABLENAME_ROW IN
                SELECT  table_name
                from information_schema.tables
                where table_Schema = 'public'
                LOOP
                --raise notice '%', v_TABLENAME_ROW.table_name;
                -- Armo sql query de busqueda usando la metadata del postgress
                    v_queryfield := 'SELECT 1
				 FROM
				     pg_catalog.pg_attribute a
				 WHERE
				     a.attnum > 0
				     AND NOT a.attisdropped
				     AND a.attrelid = (
					 SELECT c.oid
					 FROM pg_catalog.pg_class c
					     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
					 WHERE c.relname = ' || quote_literal(v_TABLENAME_ROW.table_name) || ' AND pg_catalog.pg_table_is_visible(c.oid)
				     )
				     AND (a.attname =''usuario'')';

                    -- Ejexuto y verfico que tenga resultados , aqui parto de la idea que siempre
                    -- deben existir los campos usuario y usuario_mod juntos , por eso para hacer la busqueda
                    -- mas rapida lo ejecuto solo buscando el campo usuario
                    EXECUTE v_queryfield;
                    GET DIAGNOSTICS v_found = ROW_COUNT;

                    IF v_found > 0 THEN
                        -- Verifico si en la tabla actual del loop esta usado ya sea en el campo usuario o el campo usuario_mod
                        v_queryfield := 'SELECT 1 FROM ' || v_TABLENAME_ROW.table_name || ' WHERE usuario=' || quote_literal(OLD.usuarios_code)
                                            || ' or usuario_mod=' || quote_literal(OLD.usuarios_code);

                        EXECUTE v_queryfield;
                        GET DIAGNOSTICS v_found = ROW_COUNT;
                        --raise notice 'nueva %',v_found;
                        IF v_found > 0 THEN
                            RAISE 'No puede modificarse o eliminarse el codigo ya que el usuario tiene transacciones' USING ERRCODE = 'restrict_violation';
                        END IF;
                    END IF;
                END LOOP;
        END IF;

    END IF;

    -- Colocamos en mayuscula siempre el codigo de usuario si no ha habido problemas
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        NEW.usuarios_code := UPPER(NEW.usuarios_code);
        RETURN NEW;
    ELSE
        RETURN OLD; -- Para delete siempre se retorna old
    END IF;

END;
$$;


ALTER FUNCTION public.sptrg_verify_usuario_code_change() OWNER TO clabsuser;

SET default_tablespace = '';

--
-- TOC entry 196 (class 1259 OID 30338)
-- Name: ci_sessions; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.ci_sessions (
                                    session_id character varying(40) DEFAULT '0'::character varying NOT NULL,
                                    ip_address character varying(45) DEFAULT '0'::character varying NOT NULL,
                                    user_agent character varying(120) NOT NULL,
                                    last_activity integer DEFAULT 0 NOT NULL,
                                    user_data text NOT NULL
);


ALTER TABLE public.ci_sessions OWNER TO clabsuser;

--
-- TOC entry 197 (class 1259 OID 30347)
-- Name: tb_cliente; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_cliente (
                                   cliente_id integer NOT NULL,
                                   empresa_id integer NOT NULL,
                                   cliente_razon_social character varying(200) NOT NULL,
                                   tipo_cliente_codigo character varying(3) NOT NULL,
                                   cliente_ruc character varying(15) NOT NULL,
                                   cliente_direccion character varying(200) NOT NULL,
                                   cliente_telefonos character varying(60),
                                   cliente_fax character varying(10),
                                   cliente_correo character varying(100),
                                   activo boolean DEFAULT true NOT NULL,
                                   usuario character varying(15) NOT NULL,
                                   fecha_creacion timestamp without time zone NOT NULL,
                                   usuario_mod character varying(15),
                                   fecha_modificacion timestamp without time zone,
                                   CONSTRAINT chk_razon_social_field_len CHECK ((length(rtrim((cliente_razon_social)::text)) > 0))
);


ALTER TABLE public.tb_cliente OWNER TO clabsuser;

--
-- TOC entry 198 (class 1259 OID 30355)
-- Name: tb_cliente_cliente_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_cliente_cliente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_cliente_cliente_id_seq OWNER TO clabsuser;

--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 198
-- Name: tb_cliente_cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_cliente_cliente_id_seq OWNED BY public.tb_cliente.cliente_id;


--
-- TOC entry 199 (class 1259 OID 30357)
-- Name: tb_cotizacion; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_cotizacion (
                                      cotizacion_id integer NOT NULL,
                                      empresa_id integer NOT NULL,
                                      cliente_id integer NOT NULL,
                                      cotizacion_es_cliente_real boolean DEFAULT true NOT NULL,
                                      cotizacion_numero integer NOT NULL,
                                      moneda_codigo character varying(8) NOT NULL,
                                      cotizacion_fecha date NOT NULL,
                                      activo boolean DEFAULT true NOT NULL,
                                      usuario character varying(15) NOT NULL,
                                      fecha_creacion timestamp without time zone NOT NULL,
                                      usuario_mod character varying(15),
                                      fecha_modificacion timestamp without time zone,
                                      cotizacion_cerrada boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tb_cotizacion OWNER TO clabsuser;

--
-- TOC entry 200 (class 1259 OID 30363)
-- Name: tb_cotizacion_cotizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_cotizacion_cotizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_cotizacion_cotizacion_id_seq OWNER TO clabsuser;

--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 200
-- Name: tb_cotizacion_cotizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_cotizacion_cotizacion_id_seq OWNED BY public.tb_cotizacion.cotizacion_id;


--
-- TOC entry 201 (class 1259 OID 30365)
-- Name: tb_cotizacion_counter; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_cotizacion_counter (
    cotizacion_counter_last_id integer NOT NULL
);


ALTER TABLE public.tb_cotizacion_counter OWNER TO clabsuser;

--
-- TOC entry 202 (class 1259 OID 30368)
-- Name: tb_cotizacion_detalle; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_cotizacion_detalle (
                                              cotizacion_detalle_id integer NOT NULL,
                                              cotizacion_id integer NOT NULL,
                                              insumo_id integer NOT NULL,
                                              unidad_medida_codigo character varying(8) NOT NULL,
                                              cotizacion_detalle_cantidad numeric(8,2) NOT NULL,
                                              cotizacion_detalle_precio numeric(10,2) NOT NULL,
                                              cotizacion_detalle_total numeric(12,2) NOT NULL,
                                              activo boolean DEFAULT true NOT NULL,
                                              usuario character varying(15) NOT NULL,
                                              fecha_creacion timestamp without time zone NOT NULL,
                                              usuario_mod character varying(15),
                                              fecha_modificacion timestamp without time zone,
                                              log_regla_by_costo boolean,
                                              log_regla_porcentaje numeric(6,2),
                                              log_tipo_cambio_tasa_compra numeric(8,4) NOT NULL,
                                              log_tipo_cambio_tasa_venta numeric(8,4) NOT NULL,
                                              log_moneda_codigo_costo character varying(8) NOT NULL,
                                              log_unidad_medida_codigo_costo character varying(8) NOT NULL,
                                              log_insumo_precio_original numeric(10,2) NOT NULL,
                                              log_insumo_precio_mercado numeric(10,2) NOT NULL,
                                              log_insumo_costo_original numeric(10,2) NOT NULL
);


ALTER TABLE public.tb_cotizacion_detalle OWNER TO clabsuser;

--
-- TOC entry 203 (class 1259 OID 30372)
-- Name: tb_cotizacion_detalle_cotizacion_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_cotizacion_detalle_cotizacion_detalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_cotizacion_detalle_cotizacion_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 203
-- Name: tb_cotizacion_detalle_cotizacion_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_cotizacion_detalle_cotizacion_detalle_id_seq OWNED BY public.tb_cotizacion_detalle.cotizacion_detalle_id;


--
-- TOC entry 204 (class 1259 OID 30374)
-- Name: tb_empresa; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_empresa (
                                   empresa_id integer NOT NULL,
                                   empresa_razon_social character varying(200) NOT NULL,
                                   tipo_empresa_codigo character varying(3) NOT NULL,
                                   empresa_ruc character varying(15) NOT NULL,
                                   empresa_direccion character varying(200) NOT NULL,
                                   empresa_telefonos character varying(60),
                                   empresa_fax character varying(10),
                                   empresa_correo character varying(100),
                                   activo boolean DEFAULT true NOT NULL,
                                   usuario character varying(15) NOT NULL,
                                   fecha_creacion timestamp without time zone NOT NULL,
                                   usuario_mod character varying(15),
                                   fecha_modificacion timestamp without time zone,
                                   CONSTRAINT chk_razon_social_field_len CHECK ((length(rtrim((empresa_razon_social)::text)) > 0))
);


ALTER TABLE public.tb_empresa OWNER TO clabsuser;

--
-- TOC entry 205 (class 1259 OID 30382)
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_empresa_empresa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_empresa_empresa_id_seq OWNER TO clabsuser;

--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 205
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_empresa_empresa_id_seq OWNED BY public.tb_empresa.empresa_id;


--
-- TOC entry 206 (class 1259 OID 30384)
-- Name: tb_entidad; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_entidad (
                                   entidad_id integer NOT NULL,
                                   entidad_razon_social character varying(200) NOT NULL,
                                   entidad_ruc character varying(15) NOT NULL,
                                   entidad_direccion character varying(200) NOT NULL,
                                   entidad_telefonos character varying(60),
                                   entidad_fax character varying(10),
                                   entidad_correo character varying(100),
                                   activo boolean DEFAULT true NOT NULL,
                                   usuario character varying(15) NOT NULL,
                                   fecha_creacion timestamp without time zone NOT NULL,
                                   usuario_mod character varying(15),
                                   fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_entidad OWNER TO atluser;

--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE tb_entidad; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE public.tb_entidad IS 'Datos generales de la entidad que usa el sistema';


--
-- TOC entry 207 (class 1259 OID 30391)
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE public.tb_entidad_entidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_entidad_entidad_id_seq OWNER TO atluser;

--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_entidad_entidad_id_seq OWNED BY public.tb_entidad.entidad_id;


--
-- TOC entry 208 (class 1259 OID 30393)
-- Name: tb_ffarmaceutica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_ffarmaceutica (
                                         ffarmaceutica_codigo character varying(15) NOT NULL,
                                         ffarmaceutica_descripcion character varying(60) NOT NULL,
                                         ffarmaceutica_protected boolean DEFAULT false NOT NULL,
                                         activo boolean DEFAULT true NOT NULL,
                                         usuario character varying(15) NOT NULL,
                                         fecha_creacion timestamp without time zone NOT NULL,
                                         usuario_mod character varying(15),
                                         fecha_modificacion timestamp without time zone,
                                         CONSTRAINT chk_ffarmaceutica_field_len CHECK (((length(rtrim((ffarmaceutica_codigo)::text)) > 0) AND (length(rtrim((ffarmaceutica_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_ffarmaceutica OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 30399)
-- Name: tb_igv; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_igv (
                               fecha_desde date NOT NULL,
                               fecha_hasta date NOT NULL,
                               igv_valor numeric(4,2) NOT NULL,
                               activo boolean DEFAULT true NOT NULL,
                               usuario character varying(15) NOT NULL,
                               fecha_creacion timestamp without time zone NOT NULL,
                               usuario_mod character varying(15),
                               fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_igv OWNER TO clabsuser;

--
-- TOC entry 210 (class 1259 OID 30403)
-- Name: tb_insumo; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_insumo (
                                  insumo_id integer NOT NULL,
                                  insumo_tipo character varying(2) NOT NULL,
                                  insumo_codigo character varying(15) NOT NULL,
                                  insumo_descripcion character varying(60) NOT NULL,
                                  tinsumo_codigo character varying(15) NOT NULL,
                                  tcostos_codigo character varying(5) NOT NULL,
                                  unidad_medida_codigo_ingreso character varying(8) NOT NULL,
                                  unidad_medida_codigo_costo character varying(8) NOT NULL,
                                  insumo_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
                                  insumo_costo numeric(10,4) DEFAULT 0.00,
                                  moneda_codigo_costo character varying(8) NOT NULL,
                                  activo boolean,
                                  usuario character varying(15),
                                  fecha_creacion timestamp without time zone,
                                  usuario_mod character varying(15),
                                  fecha_modificacion timestamp without time zone,
                                  empresa_id integer DEFAULT 5 NOT NULL,
                                  insumo_precio_mercado numeric(10,2) DEFAULT 0 NOT NULL,
                                  insumo_usa_factor_ajuste boolean,
                                  taplicacion_entries_id integer,
                                  CONSTRAINT chk_insumo_costo CHECK (
                                      CASE
                                          WHEN ((insumo_tipo)::text = 'IN'::text) THEN (insumo_costo IS NOT NULL)
                                          ELSE (insumo_costo = NULL::numeric)
                                          END),
                                  CONSTRAINT chk_insumo_field_len CHECK (((length(rtrim((insumo_codigo)::text)) > 0) AND (length(rtrim((insumo_descripcion)::text)) > 0))),
                                  CONSTRAINT chk_insumo_merma CHECK ((insumo_merma >= 0.00)),
                                  CONSTRAINT chk_insumo_pmercado CHECK ((insumo_precio_mercado >= 0.00)),
                                  CONSTRAINT chk_insumo_tipo CHECK ((((insumo_tipo)::text = 'IN'::text) OR ((insumo_tipo)::text = 'PR'::text)))
);


ALTER TABLE public.tb_insumo OWNER TO clabsuser;

--
-- TOC entry 211 (class 1259 OID 30415)
-- Name: tb_insumo_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_insumo_entries (
                                          insumo_entries_id integer NOT NULL,
                                          insumo_entries_fecha timestamp without time zone NOT NULL,
                                          insumo_id integer NOT NULL,
                                          insumo_entries_qty numeric(10,2) DEFAULT 0.00,
                                          insumo_entries_value numeric(10,4) DEFAULT 0.00,
                                          unidad_medida_codigo_qty character varying(8) DEFAULT 'KILOS'::character varying NOT NULL,
                                          activo boolean,
                                          usuario character varying(15),
                                          fecha_creacion timestamp without time zone,
                                          usuario_mod character varying(15),
                                          fecha_modificacion timestamp without time zone,
                                          CONSTRAINT insumo_entries_qty_check CHECK ((insumo_entries_qty >= (1)::numeric)),
                                          CONSTRAINT insumo_entries_value_check CHECK (((insumo_entries_value > (0)::numeric) AND (insumo_entries_value <= 100.00)))
);


ALTER TABLE public.tb_insumo_entries OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 30423)
-- Name: tb_insumo_entries_insumo_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_insumo_entries_insumo_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_insumo_entries_insumo_entries_id_seq OWNER TO postgres;

--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 212
-- Name: tb_insumo_entries_insumo_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_insumo_entries_insumo_entries_id_seq OWNED BY public.tb_insumo_entries.insumo_entries_id;


--
-- TOC entry 213 (class 1259 OID 30425)
-- Name: tb_insumo_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_insumo_history (
                                          insumo_history_id integer NOT NULL,
                                          insumo_history_fecha timestamp without time zone NOT NULL,
                                          insumo_id integer NOT NULL,
                                          insumo_tipo character varying(2) NOT NULL,
                                          tinsumo_codigo character varying(15) NOT NULL,
                                          tcostos_codigo character varying(5) NOT NULL,
                                          unidad_medida_codigo_costo character varying(8) NOT NULL,
                                          insumo_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
                                          insumo_costo numeric(10,4) DEFAULT 0.00,
                                          moneda_codigo_costo character varying(8) NOT NULL,
                                          insumo_precio_mercado numeric(10,2) DEFAULT 0 NOT NULL,
                                          insumo_history_origen_id integer,
                                          activo boolean,
                                          usuario character varying(15),
                                          fecha_creacion timestamp without time zone,
                                          usuario_mod character varying(15),
                                          fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_insumo_history OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 30431)
-- Name: tb_insumo_history_insumo_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_insumo_history_insumo_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_insumo_history_insumo_history_id_seq OWNER TO postgres;

--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 214
-- Name: tb_insumo_history_insumo_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_insumo_history_insumo_history_id_seq OWNED BY public.tb_insumo_history.insumo_history_id;


--
-- TOC entry 215 (class 1259 OID 30433)
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_insumo_insumo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_insumo_insumo_id_seq OWNER TO clabsuser;

--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 215
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_insumo_insumo_id_seq OWNED BY public.tb_insumo.insumo_id;


--
-- TOC entry 216 (class 1259 OID 30435)
-- Name: tb_moneda; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_moneda (
                                  moneda_codigo character varying(8) NOT NULL,
                                  moneda_simbolo character varying(6) NOT NULL,
                                  moneda_descripcion character varying(80) NOT NULL,
                                  moneda_protected boolean DEFAULT false NOT NULL,
                                  activo boolean DEFAULT true NOT NULL,
                                  usuario character varying(15) NOT NULL,
                                  fecha_creacion timestamp without time zone NOT NULL,
                                  usuario_mod character varying(15),
                                  fecha_modificacion timestamp without time zone,
                                  CONSTRAINT chk_moneda_field_len CHECK (((length(rtrim((moneda_codigo)::text)) > 0) AND (length(rtrim((moneda_simbolo)::text)) > 0) AND (length(rtrim((moneda_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_moneda OWNER TO clabsuser;

--
-- TOC entry 244 (class 1259 OID 102476)
-- Name: tb_procesos; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_procesos (
                                    procesos_codigo character varying(8) NOT NULL,
                                    procesos_descripcion character varying(80) NOT NULL,
                                    activo boolean DEFAULT true NOT NULL,
                                    usuario character varying(15) NOT NULL,
                                    fecha_creacion timestamp without time zone NOT NULL,
                                    usuario_mod character varying(15),
                                    fecha_modificacion timestamp without time zone,
                                    CONSTRAINT chk_procesos_field_len CHECK (((length(rtrim((procesos_codigo)::text)) > 0) AND (length(rtrim((procesos_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_procesos OWNER TO clabsuser;

--
-- TOC entry 260 (class 1259 OID 102873)
-- Name: tb_produccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_produccion (
                                      produccion_id integer NOT NULL,
                                      produccion_fecha date NOT NULL,
                                      taplicacion_entries_id integer NOT NULL,
                                      produccion_qty numeric(10,2) DEFAULT 0.00,
                                      unidad_medida_codigo character varying(8) DEFAULT 'LITROS'::character varying NOT NULL,
                                      activo boolean,
                                      usuario character varying(15),
                                      fecha_creacion timestamp without time zone,
                                      usuario_mod character varying(15),
                                      fecha_modificacion timestamp without time zone,
                                      CONSTRAINT produccion_qty_check CHECK ((produccion_qty >= (1)::numeric))
);


ALTER TABLE public.tb_produccion OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 102871)
-- Name: tb_produccion_produccion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_produccion_produccion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_produccion_produccion_id_seq OWNER TO postgres;

--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 259
-- Name: tb_produccion_produccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_produccion_produccion_id_seq OWNED BY public.tb_produccion.produccion_id;


--
-- TOC entry 217 (class 1259 OID 30441)
-- Name: tb_producto_detalle; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_producto_detalle (
                                            producto_detalle_id integer NOT NULL,
                                            insumo_id_origen integer NOT NULL,
                                            insumo_id integer NOT NULL,
                                            unidad_medida_codigo character varying(8) NOT NULL,
                                            producto_detalle_cantidad numeric(10,4) DEFAULT 0.00 NOT NULL,
                                            producto_detalle_valor numeric(10,4) DEFAULT 0.00 NOT NULL,
                                            producto_detalle_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
                                            activo boolean,
                                            usuario character varying(15),
                                            fecha_creacion timestamp without time zone,
                                            usuario_mod character varying(15),
                                            fecha_modificacion timestamp without time zone,
                                            empresa_id integer NOT NULL,
                                            CONSTRAINT chk_producto_detalle_cantidad CHECK ((producto_detalle_cantidad > 0.00)),
                                            CONSTRAINT chk_producto_detalle_merma CHECK ((producto_detalle_merma >= 0.00))
);


ALTER TABLE public.tb_producto_detalle OWNER TO clabsuser;

--
-- TOC entry 218 (class 1259 OID 30449)
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_producto_detalle_producto_detalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_producto_detalle_producto_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 218
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_producto_detalle_producto_detalle_id_seq OWNED BY public.tb_producto_detalle.producto_detalle_id;


--
-- TOC entry 247 (class 1259 OID 102578)
-- Name: tb_producto_procesos; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_producto_procesos (
                                             producto_procesos_id integer NOT NULL,
                                             insumo_id integer NOT NULL,
                                             producto_procesos_fecha_desde date NOT NULL,
                                             activo boolean,
                                             usuario character varying(15),
                                             fecha_creacion timestamp without time zone,
                                             usuario_mod character varying(15),
                                             fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_producto_procesos OWNER TO clabsuser;

--
-- TOC entry 249 (class 1259 OID 102643)
-- Name: tb_producto_procesos_detalle; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_producto_procesos_detalle (
                                                     producto_procesos_detalle_id integer NOT NULL,
                                                     producto_procesos_id integer NOT NULL,
                                                     procesos_codigo character varying(8) NOT NULL,
                                                     producto_procesos_detalle_porcentaje numeric(6,2) NOT NULL,
                                                     activo boolean,
                                                     usuario character varying(15),
                                                     fecha_creacion timestamp without time zone,
                                                     usuario_mod character varying(15),
                                                     fecha_modificacion timestamp without time zone,
                                                     CONSTRAINT producto_procesos_detalle_porcentaje CHECK (((producto_procesos_detalle_porcentaje > 0.00) AND (producto_procesos_detalle_porcentaje <= 100.00)))
);


ALTER TABLE public.tb_producto_procesos_detalle OWNER TO clabsuser;

--
-- TOC entry 248 (class 1259 OID 102641)
-- Name: tb_producto_procesos_detalle_producto_procesos_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 248
-- Name: tb_producto_procesos_detalle_producto_procesos_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq OWNED BY public.tb_producto_procesos_detalle.producto_procesos_detalle_id;


--
-- TOC entry 246 (class 1259 OID 102576)
-- Name: tb_producto_procesos_producto_procesos_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_producto_procesos_producto_procesos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_producto_procesos_producto_procesos_id_seq OWNER TO clabsuser;

--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 246
-- Name: tb_producto_procesos_producto_procesos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_producto_procesos_producto_procesos_id_seq OWNED BY public.tb_producto_procesos.producto_procesos_id;


--
-- TOC entry 219 (class 1259 OID 30451)
-- Name: tb_reglas; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_reglas (
                                  regla_id integer NOT NULL,
                                  regla_empresa_origen_id integer NOT NULL,
                                  regla_empresa_destino_id integer NOT NULL,
                                  regla_by_costo boolean DEFAULT true NOT NULL,
                                  regla_porcentaje numeric(6,2) NOT NULL,
                                  activo boolean DEFAULT true NOT NULL,
                                  usuario character varying(15) NOT NULL,
                                  fecha_creacion timestamp without time zone NOT NULL,
                                  usuario_mod character varying(15),
                                  fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_reglas OWNER TO clabsuser;

--
-- TOC entry 220 (class 1259 OID 30456)
-- Name: tb_reglas_regla_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_reglas_regla_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_reglas_regla_id_seq OWNER TO clabsuser;

--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 220
-- Name: tb_reglas_regla_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_reglas_regla_id_seq OWNED BY public.tb_reglas.regla_id;


--
-- TOC entry 245 (class 1259 OID 102486)
-- Name: tb_subprocesos; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_subprocesos (
                                       subprocesos_codigo character varying(8) NOT NULL,
                                       subprocesos_descripcion character varying(80) NOT NULL,
                                       activo boolean DEFAULT true NOT NULL,
                                       usuario character varying(15) NOT NULL,
                                       fecha_creacion timestamp without time zone NOT NULL,
                                       usuario_mod character varying(15),
                                       fecha_modificacion timestamp without time zone,
                                       CONSTRAINT chk_subprocesos_field_len CHECK (((length(rtrim((subprocesos_codigo)::text)) > 0) AND (length(rtrim((subprocesos_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_subprocesos OWNER TO clabsuser;

--
-- TOC entry 221 (class 1259 OID 30458)
-- Name: tb_sys_menu; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_sys_menu (
                                    sys_systemcode character varying(10),
                                    menu_id integer NOT NULL,
                                    menu_codigo character varying(30) NOT NULL,
                                    menu_descripcion character varying(100) NOT NULL,
                                    menu_accesstype character(10) NOT NULL,
                                    menu_parent_id integer,
                                    menu_orden integer DEFAULT 0,
                                    activo boolean DEFAULT true NOT NULL,
                                    usuario character varying(15) NOT NULL,
                                    fecha_creacion timestamp without time zone NOT NULL,
                                    usuario_mod character varying(15),
                                    fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_menu OWNER TO atluser;

--
-- TOC entry 222 (class 1259 OID 30463)
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE public.tb_sys_menu_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_sys_menu_menu_id_seq OWNER TO atluser;

--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 222
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_menu_menu_id_seq OWNED BY public.tb_sys_menu.menu_id;


--
-- TOC entry 223 (class 1259 OID 30465)
-- Name: tb_sys_perfil; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_sys_perfil (
                                      perfil_id integer NOT NULL,
                                      sys_systemcode character varying(10) NOT NULL,
                                      perfil_codigo character varying(15) NOT NULL,
                                      perfil_descripcion character varying(120),
                                      activo boolean DEFAULT true NOT NULL,
                                      usuario character varying(15) NOT NULL,
                                      fecha_creacion timestamp without time zone NOT NULL,
                                      usuario_mod character varying(15),
                                      fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_perfil OWNER TO atluser;

--
-- TOC entry 224 (class 1259 OID 30469)
-- Name: tb_sys_perfil_detalle; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_sys_perfil_detalle (
                                              perfdet_id integer NOT NULL,
                                              perfdet_accessdef character varying(10),
                                              perfdet_accleer boolean DEFAULT false NOT NULL,
                                              perfdet_accagregar boolean DEFAULT false NOT NULL,
                                              perfdet_accactualizar boolean DEFAULT false NOT NULL,
                                              perfdet_acceliminar boolean DEFAULT false NOT NULL,
                                              perfdet_accimprimir boolean DEFAULT false NOT NULL,
                                              perfil_id integer,
                                              menu_id integer NOT NULL,
                                              activo boolean DEFAULT true NOT NULL,
                                              usuario character varying(15) NOT NULL,
                                              fecha_creacion timestamp without time zone NOT NULL,
                                              usuario_mod character varying(15),
                                              fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_perfil_detalle OWNER TO atluser;

--
-- TOC entry 225 (class 1259 OID 30478)
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE public.tb_sys_perfil_detalle_perfdet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_sys_perfil_detalle_perfdet_id_seq OWNER TO atluser;

--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 225
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_perfil_detalle_perfdet_id_seq OWNED BY public.tb_sys_perfil_detalle.perfdet_id;


--
-- TOC entry 226 (class 1259 OID 30480)
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE public.tb_sys_perfil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_sys_perfil_id_seq OWNER TO atluser;

--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 226
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_perfil_id_seq OWNED BY public.tb_sys_perfil.perfil_id;


--
-- TOC entry 227 (class 1259 OID 30482)
-- Name: tb_sys_sistemas; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_sys_sistemas (
                                        sys_systemcode character varying(10) NOT NULL,
                                        sistema_descripcion character varying(100) NOT NULL,
                                        activo boolean DEFAULT true NOT NULL,
                                        usuario character varying(15) NOT NULL,
                                        fecha_creacion timestamp without time zone NOT NULL,
                                        usuario_mod character varying(15),
                                        fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_sistemas OWNER TO atluser;

--
-- TOC entry 228 (class 1259 OID 30486)
-- Name: tb_sys_usuario_perfiles; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_sys_usuario_perfiles (
                                                usuario_perfil_id integer NOT NULL,
                                                perfil_id integer NOT NULL,
                                                usuarios_id integer NOT NULL,
                                                activo boolean DEFAULT true NOT NULL,
                                                usuario character varying(15) NOT NULL,
                                                fecha_creacion timestamp without time zone NOT NULL,
                                                usuario_mod character varying(15),
                                                fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_usuario_perfiles OWNER TO atluser;

--
-- TOC entry 229 (class 1259 OID 30490)
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE public.tb_sys_usuario_perfiles_usuario_perfil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNER TO atluser;

--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 229
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNED BY public.tb_sys_usuario_perfiles.usuario_perfil_id;


--
-- TOC entry 252 (class 1259 OID 102712)
-- Name: tb_taplicacion; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_taplicacion (
                                       taplicacion_codigo character varying(15) NOT NULL,
                                       taplicacion_descripcion character varying(60) NOT NULL,
                                       activo boolean DEFAULT true NOT NULL,
                                       usuario character varying(15) NOT NULL,
                                       fecha_creacion timestamp without time zone NOT NULL,
                                       usuario_mod character varying(15),
                                       fecha_modificacion timestamp without time zone,
                                       CONSTRAINT chk_taplicacion_field_len CHECK (((length(rtrim((taplicacion_codigo)::text)) > 0) AND (length(rtrim((taplicacion_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_taplicacion OWNER TO clabsuser;

--
-- TOC entry 254 (class 1259 OID 102761)
-- Name: tb_taplicacion_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_taplicacion_entries (
                                               taplicacion_entries_id integer NOT NULL,
                                               taplicacion_codigo character varying(8) NOT NULL,
                                               taplicacion_entries_descripcion character varying(80) NOT NULL,
                                               activo boolean,
                                               usuario character varying(15),
                                               fecha_creacion timestamp without time zone,
                                               usuario_mod character varying(15),
                                               fecha_modificacion timestamp without time zone,
                                               CONSTRAINT chk_taplicacion_entries_field_len CHECK (((length(rtrim((taplicacion_codigo)::text)) > 0) AND (length(rtrim((taplicacion_entries_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_taplicacion_entries OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 102759)
-- Name: tb_taplicacion_entries_taplicacion_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_taplicacion_entries_taplicacion_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_taplicacion_entries_taplicacion_entries_id_seq OWNER TO postgres;

--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 253
-- Name: tb_taplicacion_entries_taplicacion_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_taplicacion_entries_taplicacion_entries_id_seq OWNED BY public.tb_taplicacion_entries.taplicacion_entries_id;


--
-- TOC entry 256 (class 1259 OID 102787)
-- Name: tb_taplicacion_procesos; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_taplicacion_procesos (
                                                taplicacion_procesos_id integer NOT NULL,
                                                taplicacion_codigo character varying(15) NOT NULL,
                                                taplicacion_procesos_fecha_desde date NOT NULL,
                                                activo boolean,
                                                usuario character varying(15),
                                                fecha_creacion timestamp without time zone,
                                                usuario_mod character varying(15),
                                                fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_taplicacion_procesos OWNER TO clabsuser;

--
-- TOC entry 258 (class 1259 OID 102804)
-- Name: tb_taplicacion_procesos_detalle; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_taplicacion_procesos_detalle (
                                                        taplicacion_procesos_detalle_id integer NOT NULL,
                                                        taplicacion_procesos_id integer NOT NULL,
                                                        procesos_codigo character varying(8) NOT NULL,
                                                        taplicacion_procesos_detalle_porcentaje numeric(6,2) NOT NULL,
                                                        activo boolean,
                                                        usuario character varying(15),
                                                        fecha_creacion timestamp without time zone,
                                                        usuario_mod character varying(15),
                                                        fecha_modificacion timestamp without time zone,
                                                        CONSTRAINT taplicacion_procesos_detalle_porcentaje CHECK (((taplicacion_procesos_detalle_porcentaje > 0.00) AND (taplicacion_procesos_detalle_porcentaje <= 100.00)))
);


ALTER TABLE public.tb_taplicacion_procesos_detalle OWNER TO clabsuser;

--
-- TOC entry 257 (class 1259 OID 102802)
-- Name: tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq OWNER TO clabsuser;

--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 257
-- Name: tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq OWNED BY public.tb_taplicacion_procesos_detalle.taplicacion_procesos_detalle_id;


--
-- TOC entry 255 (class 1259 OID 102785)
-- Name: tb_taplicacion_procesos_taplicacion_procesos_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_taplicacion_procesos_taplicacion_procesos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_taplicacion_procesos_taplicacion_procesos_id_seq OWNER TO clabsuser;

--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 255
-- Name: tb_taplicacion_procesos_taplicacion_procesos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_taplicacion_procesos_taplicacion_procesos_id_seq OWNED BY public.tb_taplicacion_procesos.taplicacion_procesos_id;


--
-- TOC entry 243 (class 1259 OID 102377)
-- Name: tb_tcosto_global; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_tcosto_global (
                                         tcosto_global_codigo character varying(8) NOT NULL,
                                         tcosto_global_descripcion character varying(80) NOT NULL,
                                         tcosto_global_protected boolean DEFAULT false NOT NULL,
                                         activo boolean DEFAULT true NOT NULL,
                                         usuario character varying(15) NOT NULL,
                                         fecha_creacion timestamp without time zone NOT NULL,
                                         usuario_mod character varying(15),
                                         fecha_modificacion timestamp without time zone,
                                         CONSTRAINT chk_tcosto_global_field_len CHECK (((length(rtrim((tcosto_global_codigo)::text)) > 0) AND (length(rtrim((tcosto_global_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tcosto_global OWNER TO clabsuser;

--
-- TOC entry 251 (class 1259 OID 102685)
-- Name: tb_tcosto_global_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_tcosto_global_entries (
                                                 tcosto_global_entries_id integer NOT NULL,
                                                 tcosto_global_codigo character varying(8) NOT NULL,
                                                 tcosto_global_entries_fecha_desde date NOT NULL,
                                                 tcosto_global_entries_valor numeric(12,2) NOT NULL,
                                                 moneda_codigo character varying(8) NOT NULL,
                                                 activo boolean,
                                                 usuario character varying(15),
                                                 fecha_creacion timestamp without time zone,
                                                 usuario_mod character varying(15),
                                                 fecha_modificacion timestamp without time zone,
                                                 CONSTRAINT tcosto_global_entries_valor_check CHECK ((tcosto_global_entries_valor > (0)::numeric))
);


ALTER TABLE public.tb_tcosto_global_entries OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 102683)
-- Name: tb_tcosto_global_entries_tcosto_global_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_tcosto_global_entries_tcosto_global_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_tcosto_global_entries_tcosto_global_entries_id_seq OWNER TO postgres;

--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 250
-- Name: tb_tcosto_global_entries_tcosto_global_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_tcosto_global_entries_tcosto_global_entries_id_seq OWNED BY public.tb_tcosto_global_entries.tcosto_global_entries_id;


--
-- TOC entry 230 (class 1259 OID 30492)
-- Name: tb_tcostos; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_tcostos (
                                   tcostos_codigo character varying(5) NOT NULL,
                                   tcostos_descripcion character varying(60) NOT NULL,
                                   tcostos_protected boolean DEFAULT false NOT NULL,
                                   tcostos_indirecto boolean DEFAULT false NOT NULL,
                                   activo boolean DEFAULT true NOT NULL,
                                   usuario character varying(15) NOT NULL,
                                   fecha_creacion timestamp without time zone NOT NULL,
                                   usuario_mod character varying(15),
                                   fecha_modificacion timestamp without time zone,
                                   CONSTRAINT chk_tcostos_field_len CHECK (((length(rtrim((tcostos_codigo)::text)) > 0) AND (length(rtrim((tcostos_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tcostos OWNER TO clabsuser;

--
-- TOC entry 231 (class 1259 OID 30499)
-- Name: tb_tinsumo; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_tinsumo (
                                   tinsumo_codigo character varying(15) NOT NULL,
                                   tinsumo_descripcion character varying(60) NOT NULL,
                                   tinsumo_protected boolean DEFAULT false NOT NULL,
                                   activo boolean DEFAULT true NOT NULL,
                                   usuario character varying(15) NOT NULL,
                                   fecha_creacion timestamp without time zone NOT NULL,
                                   usuario_mod character varying(15),
                                   fecha_modificacion timestamp without time zone,
                                   CONSTRAINT chk_tinsumo_field_len CHECK (((length(rtrim((tinsumo_codigo)::text)) > 0) AND (length(rtrim((tinsumo_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tinsumo OWNER TO clabsuser;

--
-- TOC entry 232 (class 1259 OID 30505)
-- Name: tb_tipo_cambio; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_tipo_cambio (
                                       tipo_cambio_id integer NOT NULL,
                                       moneda_codigo_origen character varying(8) NOT NULL,
                                       moneda_codigo_destino character varying(8) NOT NULL,
                                       tipo_cambio_fecha_desde date NOT NULL,
                                       tipo_cambio_fecha_hasta date NOT NULL,
                                       tipo_cambio_tasa_compra numeric(8,4) NOT NULL,
                                       tipo_cambio_tasa_venta numeric(8,4) NOT NULL,
                                       activo boolean DEFAULT true NOT NULL,
                                       usuario character varying(15) NOT NULL,
                                       fecha_creacion timestamp without time zone NOT NULL,
                                       usuario_mod character varying(15),
                                       fecha_modificacion timestamp without time zone,
                                       CONSTRAINT ckk_tipo_cambio_tasa_compra CHECK ((tipo_cambio_tasa_compra > 0.00)),
                                       CONSTRAINT ckk_tipo_cambio_tasa_venta CHECK ((tipo_cambio_tasa_venta > 0.00))
);


ALTER TABLE public.tb_tipo_cambio OWNER TO clabsuser;

--
-- TOC entry 233 (class 1259 OID 30511)
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_tipo_cambio_tipo_cambio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_tipo_cambio_tipo_cambio_id_seq OWNER TO clabsuser;

--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 233
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_tipo_cambio_tipo_cambio_id_seq OWNED BY public.tb_tipo_cambio.tipo_cambio_id;


--
-- TOC entry 234 (class 1259 OID 30513)
-- Name: tb_tipo_cliente; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_tipo_cliente (
                                        tipo_cliente_codigo character varying(3) NOT NULL,
                                        tipo_cliente_descripcion character varying(120) NOT NULL,
                                        tipo_cliente_protected boolean DEFAULT false NOT NULL,
                                        activo boolean DEFAULT true NOT NULL,
                                        usuario character varying(15) NOT NULL,
                                        fecha_creacion timestamp without time zone NOT NULL,
                                        usuario_mod character varying(15),
                                        fecha_modificacion timestamp without time zone,
                                        CONSTRAINT chk_tipo_cliente_field_len CHECK (((length(rtrim((tipo_cliente_codigo)::text)) > 0) AND (length(rtrim((tipo_cliente_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tipo_cliente OWNER TO clabsuser;

--
-- TOC entry 235 (class 1259 OID 30519)
-- Name: tb_tipo_empresa; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_tipo_empresa (
                                        tipo_empresa_codigo character varying(3) NOT NULL,
                                        tipo_empresa_descripcion character varying(120) NOT NULL,
                                        tipo_empresa_protected boolean DEFAULT false NOT NULL,
                                        activo boolean DEFAULT true NOT NULL,
                                        usuario character varying(15) NOT NULL,
                                        fecha_creacion timestamp without time zone NOT NULL,
                                        usuario_mod character varying(15),
                                        fecha_modificacion timestamp without time zone,
                                        CONSTRAINT chk_tipo_empresa_field_len CHECK (((length(rtrim((tipo_empresa_codigo)::text)) > 0) AND (length(rtrim((tipo_empresa_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tipo_empresa OWNER TO clabsuser;

--
-- TOC entry 236 (class 1259 OID 30525)
-- Name: tb_tpresentacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_tpresentacion (
                                         tpresentacion_codigo character varying(15) NOT NULL,
                                         tpresentacion_descripcion character varying(60) NOT NULL,
                                         tpresentacion_protected boolean DEFAULT false NOT NULL,
                                         activo boolean DEFAULT true NOT NULL,
                                         usuario character varying(15) NOT NULL,
                                         fecha_creacion timestamp without time zone NOT NULL,
                                         usuario_mod character varying(15),
                                         fecha_modificacion timestamp without time zone,
                                         CONSTRAINT chk_tpresentacion_field_len CHECK (((length(rtrim((tpresentacion_codigo)::text)) > 0) AND (length(rtrim((tpresentacion_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tpresentacion OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 30531)
-- Name: tb_unidad_medida; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_unidad_medida (
                                         unidad_medida_codigo character varying(8) NOT NULL,
                                         unidad_medida_siglas character varying(6) NOT NULL,
                                         unidad_medida_descripcion character varying(80) NOT NULL,
                                         unidad_medida_tipo character(1) NOT NULL,
                                         unidad_medida_protected boolean DEFAULT false NOT NULL,
                                         activo boolean DEFAULT true NOT NULL,
                                         usuario character varying(15) NOT NULL,
                                         fecha_creacion timestamp without time zone NOT NULL,
                                         usuario_mod character varying(15),
                                         fecha_modificacion timestamp without time zone,
                                         unidad_medida_default boolean DEFAULT false NOT NULL,
                                         CONSTRAINT chk_unidad_medida_field_len CHECK (((length(rtrim((unidad_medida_codigo)::text)) > 0) AND (length(rtrim((unidad_medida_siglas)::text)) > 0) AND (length(rtrim((unidad_medida_descripcion)::text)) > 0))),
                                         CONSTRAINT chk_unidad_medida_tipo CHECK ((unidad_medida_tipo = ANY (ARRAY['P'::bpchar, 'V'::bpchar, 'L'::bpchar, 'T'::bpchar])))
);


ALTER TABLE public.tb_unidad_medida OWNER TO clabsuser;

--
-- TOC entry 238 (class 1259 OID 30539)
-- Name: tb_unidad_medida_conversion; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_unidad_medida_conversion (
                                                    unidad_medida_conversion_id integer NOT NULL,
                                                    unidad_medida_origen character varying(8) NOT NULL,
                                                    unidad_medida_destino character varying(8) NOT NULL,
                                                    unidad_medida_conversion_factor numeric(12,5) NOT NULL,
                                                    activo boolean DEFAULT true NOT NULL,
                                                    usuario character varying(15) NOT NULL,
                                                    fecha_creacion timestamp without time zone NOT NULL,
                                                    usuario_mod character varying(15),
                                                    fecha_modificacion timestamp without time zone,
                                                    CONSTRAINT chk_unidad_medida_conversion_factor CHECK ((unidad_medida_conversion_factor > 0.00))
);


ALTER TABLE public.tb_unidad_medida_conversion OWNER TO clabsuser;

--
-- TOC entry 239 (class 1259 OID 30544)
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNER TO clabsuser;

--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 239
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNED BY public.tb_unidad_medida_conversion.unidad_medida_conversion_id;


--
-- TOC entry 240 (class 1259 OID 30546)
-- Name: tb_usuarios; Type: TABLE; Schema: public; Owner: atluser
--

CREATE TABLE public.tb_usuarios (
                                    usuarios_id integer NOT NULL,
                                    usuarios_code character varying(15) NOT NULL,
                                    usuarios_password character varying(20) NOT NULL,
                                    usuarios_nombre_completo character varying(250) NOT NULL,
                                    usuarios_admin boolean DEFAULT false NOT NULL,
                                    activo boolean DEFAULT true NOT NULL,
                                    usuario character varying(15) NOT NULL,
                                    fecha_creacion timestamp without time zone NOT NULL,
                                    usuario_mod character varying(15),
                                    fecha_modificacion time without time zone,
                                    empresa_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tb_usuarios OWNER TO atluser;

--
-- TOC entry 241 (class 1259 OID 30552)
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE public.tb_usuarios_usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_usuarios_usuarios_id_seq OWNER TO atluser;

--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 241
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_usuarios_usuarios_id_seq OWNED BY public.tb_usuarios.usuarios_id;


--
-- TOC entry 242 (class 1259 OID 30554)
-- Name: v_insumo_costo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.v_insumo_costo (
    insumo_costo numeric
);


ALTER TABLE public.v_insumo_costo OWNER TO postgres;

--
-- TOC entry 3100 (class 2604 OID 30560)
-- Name: tb_cliente cliente_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cliente ALTER COLUMN cliente_id SET DEFAULT nextval('public.tb_cliente_cliente_id_seq'::regclass);


--
-- TOC entry 3105 (class 2604 OID 30561)
-- Name: tb_cotizacion cotizacion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion ALTER COLUMN cotizacion_id SET DEFAULT nextval('public.tb_cotizacion_cotizacion_id_seq'::regclass);


--
-- TOC entry 3107 (class 2604 OID 30562)
-- Name: tb_cotizacion_detalle cotizacion_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle ALTER COLUMN cotizacion_detalle_id SET DEFAULT nextval('public.tb_cotizacion_detalle_cotizacion_detalle_id_seq'::regclass);


--
-- TOC entry 3109 (class 2604 OID 30563)
-- Name: tb_empresa empresa_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_empresa ALTER COLUMN empresa_id SET DEFAULT nextval('public.tb_empresa_empresa_id_seq'::regclass);


--
-- TOC entry 3112 (class 2604 OID 30564)
-- Name: tb_entidad entidad_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_entidad ALTER COLUMN entidad_id SET DEFAULT nextval('public.tb_entidad_entidad_id_seq'::regclass);


--
-- TOC entry 3121 (class 2604 OID 30565)
-- Name: tb_insumo insumo_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo ALTER COLUMN insumo_id SET DEFAULT nextval('public.tb_insumo_insumo_id_seq'::regclass);


--
-- TOC entry 3130 (class 2604 OID 30566)
-- Name: tb_insumo_entries insumo_entries_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_entries ALTER COLUMN insumo_entries_id SET DEFAULT nextval('public.tb_insumo_entries_insumo_entries_id_seq'::regclass);


--
-- TOC entry 3136 (class 2604 OID 30567)
-- Name: tb_insumo_history insumo_history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history ALTER COLUMN insumo_history_id SET DEFAULT nextval('public.tb_insumo_history_insumo_history_id_seq'::regclass);


--
-- TOC entry 3215 (class 2604 OID 102876)
-- Name: tb_produccion produccion_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion ALTER COLUMN produccion_id SET DEFAULT nextval('public.tb_produccion_produccion_id_seq'::regclass);


--
-- TOC entry 3143 (class 2604 OID 30568)
-- Name: tb_producto_detalle producto_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle ALTER COLUMN producto_detalle_id SET DEFAULT nextval('public.tb_producto_detalle_producto_detalle_id_seq'::regclass);


--
-- TOC entry 3203 (class 2604 OID 102581)
-- Name: tb_producto_procesos producto_procesos_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos ALTER COLUMN producto_procesos_id SET DEFAULT nextval('public.tb_producto_procesos_producto_procesos_id_seq'::regclass);


--
-- TOC entry 3204 (class 2604 OID 102646)
-- Name: tb_producto_procesos_detalle producto_procesos_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle ALTER COLUMN producto_procesos_detalle_id SET DEFAULT nextval('public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq'::regclass);


--
-- TOC entry 3148 (class 2604 OID 30569)
-- Name: tb_reglas regla_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_reglas ALTER COLUMN regla_id SET DEFAULT nextval('public.tb_reglas_regla_id_seq'::regclass);


--
-- TOC entry 3151 (class 2604 OID 30570)
-- Name: tb_sys_menu menu_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu ALTER COLUMN menu_id SET DEFAULT nextval('public.tb_sys_menu_menu_id_seq'::regclass);


--
-- TOC entry 3153 (class 2604 OID 30571)
-- Name: tb_sys_perfil perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil ALTER COLUMN perfil_id SET DEFAULT nextval('public.tb_sys_perfil_id_seq'::regclass);


--
-- TOC entry 3160 (class 2604 OID 30572)
-- Name: tb_sys_perfil_detalle perfdet_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil_detalle ALTER COLUMN perfdet_id SET DEFAULT nextval('public.tb_sys_perfil_detalle_perfdet_id_seq'::regclass);


--
-- TOC entry 3163 (class 2604 OID 30573)
-- Name: tb_sys_usuario_perfiles usuario_perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles ALTER COLUMN usuario_perfil_id SET DEFAULT nextval('public.tb_sys_usuario_perfiles_usuario_perfil_id_seq'::regclass);


--
-- TOC entry 3210 (class 2604 OID 102764)
-- Name: tb_taplicacion_entries taplicacion_entries_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_taplicacion_entries ALTER COLUMN taplicacion_entries_id SET DEFAULT nextval('public.tb_taplicacion_entries_taplicacion_entries_id_seq'::regclass);


--
-- TOC entry 3212 (class 2604 OID 102790)
-- Name: tb_taplicacion_procesos taplicacion_procesos_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos ALTER COLUMN taplicacion_procesos_id SET DEFAULT nextval('public.tb_taplicacion_procesos_taplicacion_procesos_id_seq'::regclass);


--
-- TOC entry 3213 (class 2604 OID 102807)
-- Name: tb_taplicacion_procesos_detalle taplicacion_procesos_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle ALTER COLUMN taplicacion_procesos_detalle_id SET DEFAULT nextval('public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq'::regclass);


--
-- TOC entry 3206 (class 2604 OID 102688)
-- Name: tb_tcosto_global_entries tcosto_global_entries_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries ALTER COLUMN tcosto_global_entries_id SET DEFAULT nextval('public.tb_tcosto_global_entries_tcosto_global_entries_id_seq'::regclass);


--
-- TOC entry 3172 (class 2604 OID 30574)
-- Name: tb_tipo_cambio tipo_cambio_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio ALTER COLUMN tipo_cambio_id SET DEFAULT nextval('public.tb_tipo_cambio_tipo_cambio_id_seq'::regclass);


--
-- TOC entry 3190 (class 2604 OID 30575)
-- Name: tb_unidad_medida_conversion unidad_medida_conversion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion ALTER COLUMN unidad_medida_conversion_id SET DEFAULT nextval('public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq'::regclass);


--
-- TOC entry 3195 (class 2604 OID 30576)
-- Name: tb_usuarios usuarios_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_usuarios ALTER COLUMN usuarios_id SET DEFAULT nextval('public.tb_usuarios_usuarios_id_seq'::regclass);


--
-- TOC entry 3620 (class 0 OID 30338)
-- Dependencies: 196
-- Data for Name: ci_sessions; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.ci_sessions (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
891c5370f4177c28439a5bbe54c878d2	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.183 Safari/537.36 Vivaldi/1.96.1	1534225221	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
39c677840fb43ff90af39415f23105bb	192.168.0.22	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36	1500195431	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
57a2267aad84d92a67ae9a832ab4d573	172.17.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36 Vivaldi/1.94.10	1512623535
a82f60a0c6c765dc6b68c0092f26901a	192.168.0.2	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.111 Safari/537.36 Vivaldi/1.8.77	1490962349	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
717f58b9d3a21c8c0cc3353ab522ba63	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36 Vivaldi/2.0.13	1539893268	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
cd77e25467358acd7cc962be67766aed	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.121 Safari/537.36 Vivaldi/1.95.1	1517556313	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
ce083e6ec8dbf070367229de0cf7bfec	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.138 Safari/537.36 Vivaldi/1.8.77	1491775852	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
\.


--
-- TOC entry 3621 (class 0 OID 30347)
-- Dependencies: 197
-- Data for Name: tb_cliente; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_cliente (cliente_id, empresa_id, cliente_razon_social, tipo_cliente_codigo, cliente_ruc, cliente_direccion, cliente_telefonos, cliente_fax, cliente_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	7	Cliente 01	VET	10000010000	10				t	ADMIN	2018-11-02 23:25:55.974813	\N	\N
\.


--
-- TOC entry 3623 (class 0 OID 30357)
-- Dependencies: 199
-- Data for Name: tb_cotizacion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_cotizacion (cotizacion_id, empresa_id, cliente_id, cotizacion_es_cliente_real, cotizacion_numero, moneda_codigo, cotizacion_fecha, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, cotizacion_cerrada) FROM stdin;
30	7	7	t	37	USD	2021-05-30	t	ADMIN	2021-05-30 02:17:42.813707	\N	\N	f
31	7	7	t	38	USD	2021-05-26	t	ADMIN	2021-05-30 02:18:42.090742	\N	\N	f
\.


--
-- TOC entry 3625 (class 0 OID 30365)
-- Dependencies: 201
-- Data for Name: tb_cotizacion_counter; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_cotizacion_counter (cotizacion_counter_last_id) FROM stdin;
38
\.


--
-- TOC entry 3626 (class 0 OID 30368)
-- Dependencies: 202
-- Data for Name: tb_cotizacion_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_cotizacion_detalle (cotizacion_detalle_id, cotizacion_id, insumo_id, unidad_medida_codigo, cotizacion_detalle_cantidad, cotizacion_detalle_precio, cotizacion_detalle_total, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, log_regla_by_costo, log_regla_porcentaje, log_tipo_cambio_tasa_compra, log_tipo_cambio_tasa_venta, log_moneda_codigo_costo, log_unidad_medida_codigo_costo, log_insumo_precio_original, log_insumo_precio_mercado, log_insumo_costo_original) FROM stdin;
\.


--
-- TOC entry 3628 (class 0 OID 30374)
-- Dependencies: 204
-- Data for Name: tb_empresa; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_empresa (empresa_id, empresa_razon_social, tipo_empresa_codigo, empresa_ruc, empresa_direccion, empresa_telefonos, empresa_fax, empresa_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	FUTURE LAB S.A.C	IMP	23232232344	Isadora Duncan 345	2756910	2756910	aranape@gmail.com	t	TESTUSER	2016-09-15 02:26:34.750111	ADMIN	2018-11-02 03:28:47.975088
28	FUTURE LAB S.A.C (NOUSAR)	IMP	23232232345	Isadora Duncan 345	2756910	2756910	aranape@gmail.com	t	TESTUSER	2021-05-30 08:18:30.476354	ADMIN	2018-11-02 03:28:47.975088
\.


--
-- TOC entry 3630 (class 0 OID 30384)
-- Dependencies: 206
-- Data for Name: tb_entidad; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_entidad (entidad_id, entidad_razon_social, entidad_ruc, entidad_direccion, entidad_telefonos, entidad_fax, entidad_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	LABODEC S.A	12345654457	Ate	2756910		labodec@gmail.com	t	ADMIN	2016-09-21 02:08:40.288333	ADMIN	2017-02-20 03:59:44.131697
\.


--
-- TOC entry 3632 (class 0 OID 30393)
-- Dependencies: 208
-- Data for Name: tb_ffarmaceutica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_ffarmaceutica (ffarmaceutica_codigo, ffarmaceutica_descripcion, ffarmaceutica_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 3633 (class 0 OID 30399)
-- Dependencies: 209
-- Data for Name: tb_igv; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_igv (fecha_desde, fecha_hasta, igv_valor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
2016-01-01	2021-12-31	18.00	t	admin	2016-12-31 01:39:21.957222	\N	\N
\.


--
-- TOC entry 3634 (class 0 OID 30403)
-- Dependencies: 210
-- Data for Name: tb_insumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_insumo (insumo_id, insumo_tipo, insumo_codigo, insumo_descripcion, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_ingreso, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, empresa_id, insumo_precio_mercado, insumo_usa_factor_ajuste, taplicacion_entries_id) FROM stdin;
51	IN	XXXXX	xxxxxxxxxxxxxxxxx	MOBRA	CVAR	GALON	GALON	3.0000	2.0000	EURO	t	ADMIN	2021-07-04 21:45:56.143997	ADMIN	2021-07-05 01:01:16.052884	7	23.00	t	\N
59	PR	FDFFF	dfgdfgdfgdfg	NING	NING	NING	COMIS	4.0000	\N	EURO	t	ADMIN	2021-07-06 03:18:04.128996	\N	\N	7	4.00	\N	5
58	PR	WWE	qweqwe	NING	NING	NING	GALON	2.0000	\N	USD	t	ADMIN	2021-07-05 02:06:32.046584	ADMIN	2021-07-06 03:19:52.341047	7	2.00	\N	5
\.


--
-- TOC entry 3635 (class 0 OID 30415)
-- Dependencies: 211
-- Data for Name: tb_insumo_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_insumo_entries (insumo_entries_id, insumo_entries_fecha, insumo_id, insumo_entries_qty, insumo_entries_value, unidad_medida_codigo_qty, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 3637 (class 0 OID 30425)
-- Dependencies: 213
-- Data for Name: tb_insumo_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_insumo_history (insumo_history_id, insumo_history_fecha, insumo_id, insumo_tipo, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, insumo_precio_mercado, insumo_history_origen_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
113	2021-07-04 21:45:56.143997	51	IN	MOBRA	CDIR	GALON	3.0000	2.0000	EURO	23.00	\N	\N	clabsuser	2021-07-04 21:45:56.143997	\N	\N
114	2021-07-05 01:01:16.052884	51	IN	MOBRA	CVAR	GALON	3.0000	2.0000	EURO	23.00	\N	\N	clabsuser	2021-07-05 01:01:16.052884	\N	\N
\.


--
-- TOC entry 3640 (class 0 OID 30435)
-- Dependencies: 216
-- Data for Name: tb_moneda; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_moneda (moneda_codigo, moneda_simbolo, moneda_descripcion, moneda_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
JPY	Yen	Yen Japones	f	t	TESTUSER	2016-07-14 00:40:58.095941	\N	\N
EURO	â¬	Euros	t	t	TESTUSER	2016-08-21 23:36:32.726364	TESTUSER	2019-04-02 13:55:58.098127
PEN	S/.	Nuevos Soles	t	t	TESTUSER	2016-07-10 18:16:12.815048	postgres	2019-04-02 13:56:04.124446
USD	$	Dolares	t	t	TESTUSER	2016-07-10 18:20:47.857316	TESTUSER	2019-04-02 13:56:06.660428
\.


--
-- TOC entry 3668 (class 0 OID 102476)
-- Dependencies: 244
-- Data for Name: tb_procesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_procesos (procesos_codigo, procesos_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
LAVADO	Lavado	t	ADMIN	2021-05-20 02:00:54.057776	\N	\N
PRENS	Prensado	t	ADMIN	2021-05-20 02:27:38.088606	\N	\N
AAAA	aaaaaaaaa	t	ADMIN	2021-05-21 02:36:39.180787	\N	\N
AAAAD	sasass	t	ADMIN	2021-05-21 02:37:33.766335	\N	\N
\.


--
-- TOC entry 3684 (class 0 OID 102873)
-- Dependencies: 260
-- Data for Name: tb_produccion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_produccion (produccion_id, produccion_fecha, taplicacion_entries_id, produccion_qty, unidad_medida_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	2021-07-08	17	44.00	LITROS	t	ADMIN	2021-07-16 23:34:54.49224	ADMIN	2021-07-16 23:35:03.394616
8	2021-07-06	5	88.00	LITROS	t	ADMIN	2021-07-17 00:29:02.438257	\N	\N
1	2021-07-21	17	12.00	LITROS	t	ADMIN	2021-07-16 23:20:20.772754	ADMIN	2021-07-17 03:02:10.553949
\.


--
-- TOC entry 3641 (class 0 OID 30441)
-- Dependencies: 217
-- Data for Name: tb_producto_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_producto_detalle (producto_detalle_id, insumo_id_origen, insumo_id, unidad_medida_codigo, producto_detalle_cantidad, producto_detalle_valor, producto_detalle_merma, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, empresa_id) FROM stdin;
\.


--
-- TOC entry 3671 (class 0 OID 102578)
-- Dependencies: 247
-- Data for Name: tb_producto_procesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_producto_procesos (producto_procesos_id, insumo_id, producto_procesos_fecha_desde, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 3673 (class 0 OID 102643)
-- Dependencies: 249
-- Data for Name: tb_producto_procesos_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_producto_procesos_detalle (producto_procesos_detalle_id, producto_procesos_id, procesos_codigo, producto_procesos_detalle_porcentaje, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 3643 (class 0 OID 30451)
-- Dependencies: 219
-- Data for Name: tb_reglas; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_reglas (regla_id, regla_empresa_origen_id, regla_empresa_destino_id, regla_by_costo, regla_porcentaje, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 3669 (class 0 OID 102486)
-- Dependencies: 245
-- Data for Name: tb_subprocesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_subprocesos (subprocesos_codigo, subprocesos_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
QW	qwqww	t	ADMIN	2021-05-21 03:09:43.018131	\N	\N
\.


--
-- TOC entry 3645 (class 0 OID 30458)
-- Dependencies: 221
-- Data for Name: tb_sys_menu; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_menu (sys_systemcode, menu_id, menu_codigo, menu_descripcion, menu_accesstype, menu_parent_id, menu_orden, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	60	smn_tipocambio	Tipo De Cambio	A         	11	165	t	TESTUSER	2016-07-15 03:24:37.087685	\N	\N
labcostos	61	smn_tcostos	Tipo De Costos	A         	11	155	t	TESTUSER	2016-07-19 03:17:27.948919	\N	\N
labcostos	64	smn_empresas	Empresas	A         	56	120	t	TESTUSER	2016-09-15 00:42:19.770493	\N	\N
labcostos	4	mn_menu	Menu	A         	\N	0	t	TESTUSER	2014-01-14 17:51:30.074514	\N	\N
labcostos	11	mn_generales	Datos Generales	A         	4	10	t	TESTUSER	2014-01-14 17:53:10.656624	\N	\N
labcostos	12	smn_entidad	Entidad	A         	11	100	t	TESTUSER	2014-01-14 17:54:38.907518	\N	\N
labcostos	15	smn_unidadmedida	Unidades De Medida	A         	11	130	t	TESTUSER	2014-01-15 23:45:38.848008	\N	\N
labcostos	58	smn_perfiles	Perfiles	A         	56	110	t	TESTUSER	2015-10-04 15:01:00.279735	\N	\N
labcostos	57	smn_usuarios	Usuarios	A         	56	100	t	TESTUSER	2015-10-04 15:00:26.551082	\N	\N
labcostos	56	mn_admin	Administrador	A         	4	5	t	TESTUSER	2015-10-04 14:59:17.331335	\N	\N
labcostos	16	smn_monedas	Monedas	A         	11	140	t	TESTUSER	2014-01-16 04:57:32.87322	\N	\N
labcostos	17	smn_tinsumo	Tipo De Insumos	A         	11	150	t	TESTUSER	2014-01-17 15:35:42.866956	\N	\N
labcostos	21	smn_umconversion	Conversion de Unidades de Medida	A         	11	135	t	TESTUSER	2014-01-17 15:36:35.894364	\N	\N
labcostos	66	smn_reglas	Reglas	A         	56	130	t	TESTUSER	2016-09-30 15:58:37.85865	\N	\N
labcostos	68	smn_tcliente	Tipo Cliente	A         	11	180	t	TESTUSER	2016-10-29 00:57:43.393922	\N	\N
labcostos	70	mn_reportes	Reportes	A         	4	15	t	TESTUSER	2017-01-21 02:09:51.841752	\N	\N
labcostos	72	smn_costos_historicos	Costo Historico	A         	70	10	t	TESTUSER	2017-01-21 02:11:05.133935	\N	\N
labcostos	59	smn_insumo	Insumos	A         	74	160	t	TESTUSER	2014-01-17 15:35:42.866956	\N	\N
labcostos	62	smn_producto	Producto	A         	74	165	t	TESTUSER	2016-08-06 15:02:59.319601	\N	\N
labcostos	69	smn_clientes	Clientes	A         	75	185	t	TESTUSER	2016-10-29 14:51:58.525005	\N	\N
labcostos	67	smn_cotizacion	Cotizacion	A         	75	135	t	TESTUSER	2016-10-18 16:16:32.47756	\N	\N
labcostos	75	mn_cotizacion	Cotizacion	A         	4	14	t	TESTUSER	2018-11-04 23:51:02.758	\N	\N
labcostos	74	mn_productos	Productos	A         	4	12	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	76	smn_presentacion	Presentacion	A         	11	190	t	TESTUSER	2019-03-05 06:54:36.918	\N	\N
labcostos	77	mn_movimientos	Movimientos	A         	4	13	t	TESTUSER	2014-01-14 17:53:10.656624	\N	\N
labcostos	78	smn_insumo_entries	Ingreso Insumos	A         	77	100	t	TESTUSER	2016-10-29 00:57:43.393922	\N	\N
labcostos	80	mn_costo_global	Costos Globales	A         	4	15	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	79	smn_tcosto_global	Tipo Costos Globales	A         	80	100	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	81	smn_tcosto_global_entries	Movimientos Costos Globales	A         	80	110	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	82	mn_procesos	Procesos	A         	4	20	t	TESTUSER	2021-05-20 01:31:19	\N	\N
labcostos	83	smn_procesos	Procesos	A         	82	100	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	84	smn_subprocesos	Sub Procesos	A         	82	100	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	85	smn_producto_procesos	Producto/Procesos	A         	74	120	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	88	mn_taplicacion	Modo Aplicacion	A         	4	20	t	TESTUSER	2021-05-20 01:31:19	\N	\N
labcostos	87	smn_taplicacion_procesos	Modo Aplicacion/Procesos	A         	88	125	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	86	smn_taplicacion	Modos de Aplicacion	A         	88	120	t	TESTUSER	2021-06-30 03:11:24	\N	\N
labcostos	89	mn_produccion	Produccion	A         	4	20	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
\.


--
-- TOC entry 3647 (class 0 OID 30465)
-- Dependencies: 223
-- Data for Name: tb_sys_perfil; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_perfil (perfil_id, sys_systemcode, perfil_codigo, perfil_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
35	labcostos	POWERUSER	Usuario Avanzado	t	ADMIN	2018-11-05 05:41:50.802291	postgres	2018-11-05 05:42:02.737037
34	labcostos	ADMIN	Perfil Administrador	t	ADMIN	2018-11-05 05:10:14.396855	postgres	2018-11-05 07:26:25.060017
\.


--
-- TOC entry 3648 (class 0 OID 30469)
-- Dependencies: 224
-- Data for Name: tb_sys_perfil_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_perfil_detalle (perfdet_id, perfdet_accessdef, perfdet_accleer, perfdet_accagregar, perfdet_accactualizar, perfdet_acceliminar, perfdet_accimprimir, perfil_id, menu_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
965	\N	t	t	t	t	t	35	4	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
966	\N	t	t	t	t	t	35	56	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
967	\N	t	t	t	t	t	35	72	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
968	\N	t	t	t	t	t	35	11	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
969	\N	t	t	t	t	t	35	74	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
970	\N	t	t	t	t	t	35	75	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
971	\N	t	t	t	t	t	35	70	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
972	\N	t	t	t	t	t	35	12	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
973	\N	t	t	t	t	t	35	57	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
974	\N	t	t	t	t	t	35	58	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
975	\N	t	t	t	t	t	35	64	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
976	\N	t	t	t	t	t	35	15	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
977	\N	t	t	t	t	t	35	66	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
978	\N	t	t	t	t	t	35	21	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
979	\N	t	t	t	t	t	35	67	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
980	\N	t	t	t	t	t	35	16	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
981	\N	t	t	t	t	t	35	17	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
982	\N	t	t	t	t	t	35	61	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
983	\N	t	t	t	t	t	35	59	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
984	\N	t	t	t	t	t	35	62	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
985	\N	t	t	t	t	t	35	60	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
986	\N	t	t	t	t	t	35	68	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
987	\N	t	t	t	t	t	35	69	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
988	\N	t	t	t	t	t	35	76	t	ADMIN	2019-03-05 06:55:31.712645	postgres	2019-03-05 06:56:06.54344
989	\N	t	t	t	t	t	34	76	t	ADMIN	2019-03-05 06:56:38.017533	postgres	2019-03-05 06:56:56.228915
990	\N	t	t	t	t	t	34	78	t	ADMIN	2019-04-12 04:54:59.986254	postgres	2019-03-05 06:56:56.228915
991	\N	t	t	t	t	t	35	78	t	ADMIN	2019-04-12 04:55:24.54825	postgres	2019-03-05 06:56:56.228915
992	\N	t	t	t	t	t	34	77	t	ADMIN	2019-04-12 06:08:39.513073	postgres	2019-03-05 06:56:56.228915
993	\N	t	t	t	t	t	35	77	t	ADMIN	2019-04-12 06:09:05.544145	postgres	2019-03-05 06:56:56.228915
942	\N	t	t	t	t	t	34	4	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
943	\N	t	t	t	t	t	34	56	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
944	\N	t	t	t	t	t	34	72	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
945	\N	t	t	t	t	t	34	11	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
946	\N	t	t	t	t	t	34	74	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
947	\N	t	t	t	t	t	34	75	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
948	\N	t	t	t	t	t	34	70	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
949	\N	t	t	t	t	t	34	12	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
950	\N	t	t	t	t	t	34	57	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
951	\N	t	t	t	t	t	34	58	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
952	\N	t	t	t	t	t	34	64	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
953	\N	t	t	t	t	t	34	15	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
954	\N	t	t	t	t	t	34	66	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
955	\N	t	t	t	t	t	34	21	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
956	\N	t	t	t	t	t	34	67	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
957	\N	t	t	t	t	t	34	16	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
958	\N	t	t	t	t	t	34	17	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
959	\N	t	t	t	t	t	34	61	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
960	\N	t	t	t	t	t	34	59	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
961	\N	t	t	t	t	t	34	62	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
962	\N	t	t	t	t	t	34	60	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
963	\N	t	t	t	t	t	34	68	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
964	\N	t	t	t	t	t	34	69	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
994	\N	t	t	t	t	t	35	79	t	ADMIN	2021-05-14 05:44:46.442931	postgres	2019-03-05 06:56:56.228915
995	\N	t	t	t	t	t	34	79	t	ADMIN	2021-05-14 05:45:21.672633	postgres	2019-03-05 06:56:56.228915
998	\N	t	t	t	t	t	34	80	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
999	\N	t	t	t	t	t	35	80	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
1000	\N	t	t	t	t	t	35	81	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
1001	\N	t	t	t	t	t	34	81	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
1002	\N	t	t	t	t	t	35	82	t	ADMIN	2021-05-20 06:56:12.50406	postgres	2019-03-05 06:56:56.228915
1003	\N	t	t	t	t	t	34	82	t	ADMIN	2021-05-20 06:56:59.257063	postgres	2019-03-05 06:56:56.228915
1004	\N	t	t	t	t	t	35	83	t	ADMIN	2021-05-20 06:57:20.04293	postgres	2019-03-05 06:56:56.228915
1005	\N	t	t	t	t	t	34	83	t	ADMIN	2021-05-20 06:57:41.059632	postgres	2019-03-05 06:56:56.228915
1006	\N	t	t	t	t	t	35	84	t	ADMIN	2021-05-21 08:05:39.986468	postgres	2019-03-05 06:56:56.228915
1007	\N	t	t	t	t	t	34	84	t	ADMIN	2021-05-21 08:05:39.986468	postgres	2019-03-05 06:56:56.228915
1008	\N	t	t	t	t	t	35	85	t	ADMIN	2021-05-27 05:24:48.355677	postgres	2019-03-05 06:56:56.228915
1009	\N	t	t	t	t	t	34	85	t	ADMIN	2021-05-27 05:25:20.329855	postgres	2019-03-05 06:56:56.228915
1044	\N	t	t	t	t	t	35	86	t	ADMIN	2021-06-30 08:58:10.742065	postgres	2019-03-05 06:56:56.228915
1045	\N	t	t	t	t	t	34	86	t	ADMIN	2021-06-30 08:58:10.742065	postgres	2019-03-05 06:56:56.228915
1046	\N	t	t	t	t	t	35	87	t	ADMIN	2021-07-08 07:56:44.046801	postgres	2019-03-05 06:56:56.228915
1047	\N	t	t	t	t	t	34	87	t	ADMIN	2021-07-08 07:56:44.046801	postgres	2019-03-05 06:56:56.228915
1048	\N	t	t	t	t	t	35	88	t	ADMIN	2021-07-08 08:01:04.504466	postgres	2019-03-05 06:56:56.228915
1049	\N	t	t	t	t	t	34	88	t	ADMIN	2021-07-08 08:01:04.504466	postgres	2019-03-05 06:56:56.228915
1050	\N	t	t	t	t	t	35	89	t	ADMIN	2021-07-16 08:21:19.629141	postgres	2019-03-05 06:56:56.228915
1051	\N	t	t	t	t	t	34	89	t	ADMIN	2021-07-16 08:21:19.629141	postgres	2019-03-05 06:56:56.228915
\.


--
-- TOC entry 3651 (class 0 OID 30482)
-- Dependencies: 227
-- Data for Name: tb_sys_sistemas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_sistemas (sys_systemcode, sistema_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	Sistema De Costos Laboratorios	t	TESTUSER	2016-07-08 23:47:11.960862	postgres	2016-09-21 01:38:36.399968
\.


--
-- TOC entry 3652 (class 0 OID 30486)
-- Dependencies: 228
-- Data for Name: tb_sys_usuario_perfiles; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_usuario_perfiles (usuario_perfil_id, perfil_id, usuarios_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
27	34	21	t	ADMIN	2018-11-05 05:16:04.885465	\N	\N
28	35	22	t	ADMIN	2018-11-05 05:42:42.652755	\N	\N
\.


--
-- TOC entry 3676 (class 0 OID 102712)
-- Dependencies: 252
-- Data for Name: tb_taplicacion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_taplicacion (taplicacion_codigo, taplicacion_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
FFFF	ffff	t	ADMIN	2021-07-04 03:45:14.353965	\N	\N
XXXXXX	xxx	t	ADMIN	2021-07-02 02:28:23.734123	ADMIN	2021-07-04 04:18:39.584401
\.


--
-- TOC entry 3678 (class 0 OID 102761)
-- Dependencies: 254
-- Data for Name: tb_taplicacion_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_taplicacion_entries (taplicacion_entries_id, taplicacion_codigo, taplicacion_entries_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
5	XXXXXX	test	t	ADMIN	2021-07-02 03:30:22.574365	ADMIN	2021-07-02 04:00:11.007554
17	XXXXXX	test2	t	ADMIN	2021-07-02 04:21:35.679766	\N	\N
\.


--
-- TOC entry 3680 (class 0 OID 102787)
-- Dependencies: 256
-- Data for Name: tb_taplicacion_procesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_taplicacion_procesos (taplicacion_procesos_id, taplicacion_codigo, taplicacion_procesos_fecha_desde, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	XXXXXX	2021-07-08	t	ADMIN	2021-07-08 04:09:35.507845	\N	\N
\.


--
-- TOC entry 3682 (class 0 OID 102804)
-- Dependencies: 258
-- Data for Name: tb_taplicacion_procesos_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_taplicacion_procesos_detalle (taplicacion_procesos_detalle_id, taplicacion_procesos_id, procesos_codigo, taplicacion_procesos_detalle_porcentaje, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	1	LAVADO	12.00	t	ADMIN	2021-07-10 01:31:16.464008	\N	\N
10	1	PRENS	66.00	t	ADMIN	2021-07-10 01:31:52.785433	ADMIN	2021-07-10 01:32:12.087129
13	1	AAAAD	1.00	t	ADMIN	2021-07-10 01:33:56.60345	\N	\N
\.


--
-- TOC entry 3667 (class 0 OID 102377)
-- Dependencies: 243
-- Data for Name: tb_tcosto_global; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tcosto_global (tcosto_global_codigo, tcosto_global_descripcion, tcosto_global_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
GPERSON	Gastos de Personal	f	t	ADMIN	2021-05-16 03:08:34.225147	\N	\N
LUZADM	Luz Administrativa	f	t	ADMIN	2021-05-16 03:09:07.871033	\N	\N
\.


--
-- TOC entry 3675 (class 0 OID 102685)
-- Dependencies: 251
-- Data for Name: tb_tcosto_global_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_tcosto_global_entries (tcosto_global_entries_id, tcosto_global_codigo, tcosto_global_entries_fecha_desde, tcosto_global_entries_valor, moneda_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	LUZADM	2021-06-07	12.00	USD	t	ADMIN	2021-06-12 00:20:14.794277	ADMIN	2021-07-16 23:16:24.248786
\.


--
-- TOC entry 3654 (class 0 OID 30492)
-- Dependencies: 230
-- Data for Name: tb_tcostos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tcostos (tcostos_codigo, tcostos_descripcion, tcostos_protected, tcostos_indirecto, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
CIND	Costo Indirecto	f	t	t	TESTUSER	2016-08-30 20:18:59.46133	ADMIN	2017-02-14 00:47:20.776931
NING	Ninguno	t	f	t	admin	2016-08-30 20:03:40.281843	ADMIN	2017-02-14 00:48:13.45147
CDIR	Costo Directo	f	f	t	TESTUSER	2016-08-30 20:18:08.544862	ADMIN	2017-02-14 01:12:02.164853
CVAR	Costo Variable	f	f	t	ADMIN	2018-11-16 21:20:16.068038	\N	\N
\.


--
-- TOC entry 3655 (class 0 OID 30499)
-- Dependencies: 231
-- Data for Name: tb_tinsumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tinsumo (tinsumo_codigo, tinsumo_descripcion, tinsumo_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
NING	Ninguno	t	t	admin	2016-08-30 17:48:41.042868	\N	\N
MOBRA	Mano De Obra	f	t	TESTUSER	2016-08-30 21:22:19.135911	\N	\N
SOLUCION	Solucion	f	t	PUSER	2016-09-26 22:29:14.474284	\N	\N
SERV	Servicios	f	t	ADMIN	2016-11-29 23:49:45.766442	\N	\N
TRANS	Transporte	f	t	ADMIN	2016-11-29 23:51:15.20716	\N	\N
EQUIP	Equipo	f	t	TESTUSER	2016-08-30 21:22:31.390434	ADMIN	2017-02-14 00:00:40.670564
\.


--
-- TOC entry 3656 (class 0 OID 30505)
-- Dependencies: 232
-- Data for Name: tb_tipo_cambio; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tipo_cambio (tipo_cambio_id, moneda_codigo_origen, moneda_codigo_destino, tipo_cambio_fecha_desde, tipo_cambio_fecha_hasta, tipo_cambio_tasa_compra, tipo_cambio_tasa_venta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	USD	JPY	2016-08-18	2016-08-19	3.0000	3.5000	t	TESTUSER	2016-08-13 15:41:24.405659	TESTUSER	2016-08-13 15:47:08.433642
3	EURO	USD	2016-12-15	2016-12-15	4.0000	4.2000	t	TESTUSER	2016-08-22 15:58:06.566396	ADMIN	2016-12-15 01:05:55.682777
6	USD	EURO	2016-12-15	2016-12-15	0.9000	0.9100	t	TESTUSER	2016-09-01 01:20:07.450926	ADMIN	2016-12-15 01:06:14.767977
10	USD	EURO	2016-12-21	2016-12-21	4.2500	4.2100	t	ADMIN	2016-12-21 22:21:42.120595	\N	\N
12	EURO	USD	2016-12-21	2016-12-21	0.9500	0.9400	t	ADMIN	2016-12-21 22:23:47.148811	\N	\N
13	USD	EURO	2016-12-26	2016-12-26	4.2500	4.2100	t	ADMIN	2016-12-26 14:32:15.132598	\N	\N
14	EURO	USD	2016-12-26	2016-12-26	0.9500	0.9400	t	ADMIN	2016-12-26 14:33:32.727022	\N	\N
4	PEN	USD	2016-09-13	2016-09-13	3.2500	3.3000	t	TESTUSER	2016-08-23 14:31:00.466178	TESTUSER	2016-09-13 01:31:28.473115
15	USD	EURO	2017-01-10	2017-01-14	4.2500	4.2100	t	ADMIN	2017-01-10 01:19:50.376197	ADMIN	2017-01-14 00:07:44.046276
2	USD	JPY	2016-08-22	2017-02-20	3.1000	3.2000	t	TESTUSER	2016-08-22 15:35:06.442191	ADMIN	2017-02-20 23:28:08.789636
19	USD	EURO	2017-02-15	2017-02-22	2.0000	3.0000	t	ADMIN	2017-02-15 04:34:29.168028	ADMIN	2017-02-22 00:47:42.531617
11	PEN	USD	2016-12-21	2017-02-23	3.2400	3.2300	t	ADMIN	2016-12-21 22:22:57.348017	PUSER	2017-02-23 01:45:31.09867
17	EURO	USD	2017-01-10	2017-02-24	0.9000	0.9100	t	ADMIN	2017-01-12 01:44:16.450111	PUSER	2017-02-23 01:45:45.221144
20	USD	PEN	2018-11-02	2018-11-03	4.0000	5.0000	t	ADMIN	2017-02-15 04:35:05.101076	PUSER	2018-11-03 01:39:09.656204
5	PEN	USD	2018-11-02	2018-11-03	3.2400	3.2900	t	TESTUSER	2016-08-24 16:18:47.669771	PUSER	2018-11-03 01:39:17.962467
22	USD	PEN	2018-12-01	2018-12-18	5.0000	4.0000	t	ADMIN	2018-12-02 23:30:41.727382	\N	\N
23	EURO	PEN	2018-12-01	2018-12-19	4.0000	5.0000	t	ADMIN	2018-12-02 23:31:19.33482	\N	\N
24	PEN	EURO	2018-11-28	2018-12-20	5.0000	4.0000	t	ADMIN	2018-12-02 23:32:36.349254	\N	\N
25	USD	PEN	2021-05-30	2021-05-30	2.0000	3.0000	t	ADMIN	2021-05-30 02:01:30.701935	\N	\N
26	USD	PEN	2021-05-26	2021-05-26	2.0000	3.0000	t	ADMIN	2021-05-30 02:02:37.340663	\N	\N
27	EURO	PEN	2021-05-25	2021-05-25	2.0000	4.0000	t	ADMIN	2021-05-30 02:03:23.951801	\N	\N
28	EURO	USD	2021-05-25	2021-05-26	3.0000	3.0000	t	ADMIN	2021-05-30 02:04:10.355076	ADMIN	2021-05-30 02:05:11.335919
29	USD	EURO	2021-05-25	2021-05-26	3.0000	4.0000	t	ADMIN	2021-05-30 02:04:30.26331	ADMIN	2021-05-30 02:05:17.243357
\.


--
-- TOC entry 3658 (class 0 OID 30513)
-- Dependencies: 234
-- Data for Name: tb_tipo_cliente; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tipo_cliente (tipo_cliente_codigo, tipo_cliente_descripcion, tipo_cliente_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
DIS	Distribuidor Externo	f	t	ADMIN	2016-10-29 01:14:35.022862	ADMIN	2016-10-29 01:15:20.899442
VET	Veterinaria	f	t	ADMIN	2016-10-29 01:16:24.303677	\N	\N
\.


--
-- TOC entry 3659 (class 0 OID 30519)
-- Dependencies: 235
-- Data for Name: tb_tipo_empresa; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tipo_empresa (tipo_empresa_codigo, tipo_empresa_descripcion, tipo_empresa_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
IMP	Importador	t	t	TESTUSER	2016-09-14 14:32:00.336057	postgres	2016-09-21 01:40:12.22007
FAB	Fabrica	t	t	TESTUSER	2016-09-14 14:32:18.634844	postgres	2016-09-21 01:40:12.22007
DIS	Distribuidor	t	t	TESTUSER	2016-09-14 14:32:35.783304	postgres	2016-09-21 01:40:12.22007
\.


--
-- TOC entry 3660 (class 0 OID 30525)
-- Dependencies: 236
-- Data for Name: tb_tpresentacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_tpresentacion (tpresentacion_codigo, tpresentacion_descripcion, tpresentacion_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
ASAS	20 ML	f	t	ADMIN	2019-03-05 02:14:05.124691	\N	\N
KKK	aaaaa	f	t	ADMIN	2019-03-05 02:24:46.503932	\N	\N
CDFD	dfdf	f	t	ADMIN	2019-03-05 02:28:56.527649	\N	\N
DSFDSF	sdfsdf	f	t	ADMIN	2019-03-05 02:30:40.074744	\N	\N
SADFDFS	sdfsdfdsfsdf	f	t	ADMIN	2019-03-05 04:08:16.035374	\N	\N
XXXX	ssssss	f	t	ADMIN	2019-03-05 05:47:31.793031	\N	\N
DFRGGH	rtyrtyrty	f	t	ADMIN	2019-03-05 05:48:34.323241	\N	\N
DDD	dddd	f	t	ADMIN	2019-03-05 05:50:20.497681	\N	\N
FFFF	ffff	f	t	ADMIN	2019-03-05 05:50:56.788121	\N	\N
DDDD	dddddddddd	f	t	ADMIN	2019-03-05 14:20:01.991009	\N	\N
ZXZXZX	zxzxzxzxzx	f	t	ADMIN	2019-03-05 14:22:27.246362	\N	\N
HHHHFG	fgfgfgf	f	t	ADMIN	2019-03-05 14:25:17.907556	\N	\N
JHJHJ	hjhjhj	f	t	ADMIN	2019-03-05 14:27:21.396749	\N	\N
SDFSDF	sdfdsfdsf	f	t	ADMIN	2019-03-05 14:28:27.53644	\N	\N
\.


--
-- TOC entry 3661 (class 0 OID 30531)
-- Dependencies: 237
-- Data for Name: tb_unidad_medida; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_unidad_medida (unidad_medida_codigo, unidad_medida_siglas, unidad_medida_descripcion, unidad_medida_tipo, unidad_medida_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, unidad_medida_default) FROM stdin;
GALON	Gls.	Galones	V	f	t	TESTUSER	2016-07-17 15:07:47.744565	TESTUSER	2016-07-18 04:56:08.667067	f
NING	Ning	Ninguna	P	t	t	TESTUSER	2016-08-15 02:29:09.264036	postgres	2016-08-15 02:29:30.986832	f
TONELAD	Ton.	Toneladas	P	f	t	TESTUSER	2016-07-11 17:17:40.095483	ADMIN	2016-10-11 01:38:35.010705	f
KILOS	Kgs.	Kilogramos	P	t	t	TESTUSER	2016-07-09 14:30:43.815942	ADMIN	2017-02-13 23:00:14.941311	t
HHOMBRE	HHOMBR	Hora Hombre	T	t	t	ADMIN	2016-11-29 23:33:52.541501	ADMIN	2017-02-13 23:00:28.304606	t
LITROS	Ltrs.	Litros	V	f	t	TESTUSER	2016-07-09 14:13:29.603714	ADMIN	2017-02-15 02:13:46.093291	t
COMIS	Com.	Comision	T	f	t	ADMIN	2016-11-29 23:48:42.283533	ADMIN	2017-02-20 04:00:21.289677	f
\.


--
-- TOC entry 3662 (class 0 OID 30539)
-- Dependencies: 238
-- Data for Name: tb_unidad_medida_conversion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_unidad_medida_conversion (unidad_medida_conversion_id, unidad_medida_origen, unidad_medida_destino, unidad_medida_conversion_factor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
10	TONELAD	KILOS	1000.00000	t	TESTUSER	2016-07-11 17:18:02.132735	\N	\N
60	GALON	LITROS	3.78540	t	TESTUSER	2016-07-18 04:44:20.861417	TESTUSER	2016-08-27 14:47:27.766392
70	LITROS	GALON	0.26420	t	TESTUSER	2016-07-30 00:33:37.114577	TESTUSER	2016-08-27 14:47:33.986013
24	KILOS	TONELAD	0.00100	t	TESTUSER	2016-07-12 15:58:35.930938	ADMIN	2017-02-14 01:49:05.979355
\.


--
-- TOC entry 3664 (class 0 OID 30546)
-- Dependencies: 240
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_usuarios (usuarios_id, usuarios_code, usuarios_password, usuarios_nombre_completo, usuarios_admin, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, empresa_id) FROM stdin;
21	ADMIN	melivane	Carlos Arana Reategui	t	t	ADMIN	2016-09-21 01:45:30.980176	ADMIN	05:32:21.720294	7
22	PUSER	puser	Soy Power User	f	t	ADMIN	2016-09-21 02:03:18.100401	ADMIN	05:32:27.181272	7
\.


--
-- TOC entry 3666 (class 0 OID 30554)
-- Dependencies: 242
-- Data for Name: v_insumo_costo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.v_insumo_costo (insumo_costo) FROM stdin;
\.


--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 198
-- Name: tb_cliente_cliente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_cliente_cliente_id_seq', 7, true);


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 200
-- Name: tb_cotizacion_cotizacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_cotizacion_cotizacion_id_seq', 31, true);


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 203
-- Name: tb_cotizacion_detalle_cotizacion_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_cotizacion_detalle_cotizacion_detalle_id_seq', 40, true);


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 205
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_empresa_empresa_id_seq', 28, true);


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_entidad_entidad_id_seq', 1, true);


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 212
-- Name: tb_insumo_entries_insumo_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_insumo_entries_insumo_entries_id_seq', 22, true);


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 214
-- Name: tb_insumo_history_insumo_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_insumo_history_insumo_history_id_seq', 114, true);


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 215
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_insumo_insumo_id_seq', 59, true);


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 259
-- Name: tb_produccion_produccion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_produccion_produccion_id_seq', 9, true);


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 218
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_producto_detalle_producto_detalle_id_seq', 53, true);


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 248
-- Name: tb_producto_procesos_detalle_producto_procesos_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq', 25, true);


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 246
-- Name: tb_producto_procesos_producto_procesos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_producto_procesos_producto_procesos_id_seq', 8, true);


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 220
-- Name: tb_reglas_regla_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_reglas_regla_id_seq', 25, true);


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 222
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_menu_menu_id_seq', 89, true);


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 225
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_perfil_detalle_perfdet_id_seq', 1051, true);


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 226
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_perfil_id_seq', 36, true);


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 229
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_usuario_perfiles_usuario_perfil_id_seq', 28, true);


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 253
-- Name: tb_taplicacion_entries_taplicacion_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_taplicacion_entries_taplicacion_entries_id_seq', 19, true);


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 257
-- Name: tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq', 13, true);


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 255
-- Name: tb_taplicacion_procesos_taplicacion_procesos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_taplicacion_procesos_taplicacion_procesos_id_seq', 1, true);


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 250
-- Name: tb_tcosto_global_entries_tcosto_global_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_tcosto_global_entries_tcosto_global_entries_id_seq', 1, true);


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 233
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_tipo_cambio_tipo_cambio_id_seq', 29, true);


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 239
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq', 84, true);


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 241
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_usuarios_usuarios_id_seq', 26, true);


--
-- TOC entry 3226 (class 2606 OID 30578)
-- Name: tb_cliente pk_cliente; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT pk_cliente PRIMARY KEY (cliente_id);


--
-- TOC entry 3230 (class 2606 OID 30580)
-- Name: tb_cotizacion pk_cotizacion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion
    ADD CONSTRAINT pk_cotizacion PRIMARY KEY (cotizacion_id);


--
-- TOC entry 3239 (class 2606 OID 30582)
-- Name: tb_cotizacion_detalle pk_cotizacion_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle
    ADD CONSTRAINT pk_cotizacion_detalle PRIMARY KEY (cotizacion_detalle_id);


--
-- TOC entry 3244 (class 2606 OID 30584)
-- Name: tb_empresa pk_empresa; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_empresa
    ADD CONSTRAINT pk_empresa PRIMARY KEY (empresa_id);


--
-- TOC entry 3246 (class 2606 OID 30586)
-- Name: tb_entidad pk_entidad; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_entidad
    ADD CONSTRAINT pk_entidad PRIMARY KEY (entidad_id);


--
-- TOC entry 3248 (class 2606 OID 30588)
-- Name: tb_ffarmaceutica pk_ffarmaceutica; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_ffarmaceutica
    ADD CONSTRAINT pk_ffarmaceutica PRIMARY KEY (ffarmaceutica_codigo);


--
-- TOC entry 3257 (class 2606 OID 30590)
-- Name: tb_insumo pk_insumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT pk_insumo PRIMARY KEY (insumo_id);


--
-- TOC entry 3263 (class 2606 OID 30592)
-- Name: tb_insumo_entries pk_insumo_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_entries
    ADD CONSTRAINT pk_insumo_entries PRIMARY KEY (insumo_entries_id);


--
-- TOC entry 3270 (class 2606 OID 30594)
-- Name: tb_insumo_history pk_insumo_history; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history
    ADD CONSTRAINT pk_insumo_history PRIMARY KEY (insumo_history_id);


--
-- TOC entry 3287 (class 2606 OID 30596)
-- Name: tb_sys_menu pk_menu; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT pk_menu PRIMARY KEY (menu_id);


--
-- TOC entry 3272 (class 2606 OID 30598)
-- Name: tb_moneda pk_moneda; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_moneda
    ADD CONSTRAINT pk_moneda PRIMARY KEY (moneda_codigo);


--
-- TOC entry 3298 (class 2606 OID 30600)
-- Name: tb_sys_perfil_detalle pk_perfdet_id; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil_detalle
    ADD CONSTRAINT pk_perfdet_id PRIMARY KEY (perfdet_id);


--
-- TOC entry 3333 (class 2606 OID 102482)
-- Name: tb_procesos pk_procesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_procesos
    ADD CONSTRAINT pk_procesos PRIMARY KEY (procesos_codigo);


--
-- TOC entry 3372 (class 2606 OID 102881)
-- Name: tb_produccion pk_produccion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion
    ADD CONSTRAINT pk_produccion PRIMARY KEY (produccion_id);


--
-- TOC entry 3277 (class 2606 OID 30602)
-- Name: tb_producto_detalle pk_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT pk_producto_detalle PRIMARY KEY (producto_detalle_id);


--
-- TOC entry 3338 (class 2606 OID 102583)
-- Name: tb_producto_procesos pk_producto_procesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos
    ADD CONSTRAINT pk_producto_procesos PRIMARY KEY (producto_procesos_id);


--
-- TOC entry 3344 (class 2606 OID 102649)
-- Name: tb_producto_procesos_detalle pk_producto_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT pk_producto_procesos_detalle PRIMARY KEY (producto_procesos_detalle_id);


--
-- TOC entry 3281 (class 2606 OID 30604)
-- Name: tb_reglas pk_reglas; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_reglas
    ADD CONSTRAINT pk_reglas PRIMARY KEY (regla_id);


--
-- TOC entry 3221 (class 2606 OID 30606)
-- Name: ci_sessions pk_sessions; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.ci_sessions
    ADD CONSTRAINT pk_sessions PRIMARY KEY (session_id);


--
-- TOC entry 3300 (class 2606 OID 30608)
-- Name: tb_sys_sistemas pk_sistemas; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_sistemas
    ADD CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode);


--
-- TOC entry 3335 (class 2606 OID 102492)
-- Name: tb_subprocesos pk_subprocesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_subprocesos
    ADD CONSTRAINT pk_subprocesos PRIMARY KEY (subprocesos_codigo);


--
-- TOC entry 3292 (class 2606 OID 30610)
-- Name: tb_sys_perfil pk_sys_perfil; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id);


--
-- TOC entry 3354 (class 2606 OID 102718)
-- Name: tb_taplicacion pk_taplicacion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion
    ADD CONSTRAINT pk_taplicacion PRIMARY KEY (taplicacion_codigo);


--
-- TOC entry 3357 (class 2606 OID 102767)
-- Name: tb_taplicacion_entries pk_taplicacion_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_taplicacion_entries
    ADD CONSTRAINT pk_taplicacion_entries PRIMARY KEY (taplicacion_entries_id);


--
-- TOC entry 3360 (class 2606 OID 102792)
-- Name: tb_taplicacion_procesos pk_taplicacion_procesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos
    ADD CONSTRAINT pk_taplicacion_procesos PRIMARY KEY (taplicacion_procesos_id);


--
-- TOC entry 3366 (class 2606 OID 102810)
-- Name: tb_taplicacion_procesos_detalle pk_taplicacion_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT pk_taplicacion_procesos_detalle PRIMARY KEY (taplicacion_procesos_detalle_id);


--
-- TOC entry 3331 (class 2606 OID 102384)
-- Name: tb_tcosto_global pk_tcosto_global; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tcosto_global
    ADD CONSTRAINT pk_tcosto_global PRIMARY KEY (tcosto_global_codigo);


--
-- TOC entry 3350 (class 2606 OID 102691)
-- Name: tb_tcosto_global_entries pk_tcosto_global_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT pk_tcosto_global_entries PRIMARY KEY (tcosto_global_entries_id);


--
-- TOC entry 3306 (class 2606 OID 30612)
-- Name: tb_tcostos pk_tcostos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tcostos
    ADD CONSTRAINT pk_tcostos PRIMARY KEY (tcostos_codigo);


--
-- TOC entry 3308 (class 2606 OID 30614)
-- Name: tb_tinsumo pk_tinsumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tinsumo
    ADD CONSTRAINT pk_tinsumo PRIMARY KEY (tinsumo_codigo);


--
-- TOC entry 3310 (class 2606 OID 30616)
-- Name: tb_tipo_cambio pk_tipo_cambio; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio
    ADD CONSTRAINT pk_tipo_cambio PRIMARY KEY (tipo_cambio_id);


--
-- TOC entry 3313 (class 2606 OID 30618)
-- Name: tb_tipo_cliente pk_tipo_cliente; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cliente
    ADD CONSTRAINT pk_tipo_cliente PRIMARY KEY (tipo_cliente_codigo);


--
-- TOC entry 3316 (class 2606 OID 30620)
-- Name: tb_tipo_empresa pk_tipo_empresa; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_empresa
    ADD CONSTRAINT pk_tipo_empresa PRIMARY KEY (tipo_empresa_codigo);


--
-- TOC entry 3318 (class 2606 OID 30622)
-- Name: tb_tpresentacion pk_tpresentacion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tpresentacion
    ADD CONSTRAINT pk_tpresentacion PRIMARY KEY (tpresentacion_codigo);


--
-- TOC entry 3323 (class 2606 OID 30624)
-- Name: tb_unidad_medida_conversion pk_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT pk_unidad_conversion PRIMARY KEY (unidad_medida_conversion_id);


--
-- TOC entry 3320 (class 2606 OID 30626)
-- Name: tb_unidad_medida pk_unidad_medida; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida
    ADD CONSTRAINT pk_unidad_medida PRIMARY KEY (unidad_medida_codigo);


--
-- TOC entry 3304 (class 2606 OID 30628)
-- Name: tb_sys_usuario_perfiles pk_usuarioperfiles; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles
    ADD CONSTRAINT pk_usuarioperfiles PRIMARY KEY (usuario_perfil_id);


--
-- TOC entry 3329 (class 2606 OID 30630)
-- Name: tb_usuarios pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_usuarios
    ADD CONSTRAINT pk_usuarios PRIMARY KEY (usuarios_id);


--
-- TOC entry 3289 (class 2606 OID 30632)
-- Name: tb_sys_menu unq_codigomenu; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT unq_codigomenu UNIQUE (menu_codigo);


--
-- TOC entry 3232 (class 2606 OID 30634)
-- Name: tb_cotizacion unq_cotizacion_numero; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion
    ADD CONSTRAINT unq_cotizacion_numero UNIQUE (empresa_id, cotizacion_numero);


--
-- TOC entry 3259 (class 2606 OID 30636)
-- Name: tb_insumo unq_insumo_codigo; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT unq_insumo_codigo UNIQUE (insumo_codigo);


--
-- TOC entry 3294 (class 2606 OID 30638)
-- Name: tb_sys_perfil unq_perfil_syscode_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode, perfil_codigo);


--
-- TOC entry 3296 (class 2606 OID 30640)
-- Name: tb_sys_perfil unq_perfil_syscode_perfil_id; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT unq_perfil_syscode_perfil_id UNIQUE (sys_systemcode, perfil_id);


--
-- TOC entry 3279 (class 2606 OID 30642)
-- Name: tb_producto_detalle unq_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT unq_producto_detalle UNIQUE (insumo_id_origen, insumo_id);


--
-- TOC entry 3346 (class 2606 OID 102651)
-- Name: tb_producto_procesos_detalle unq_producto_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT unq_producto_procesos_detalle UNIQUE (producto_procesos_id, procesos_codigo);


--
-- TOC entry 3340 (class 2606 OID 102585)
-- Name: tb_producto_procesos unq_producto_procesos_insumo_id_fecha; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos
    ADD CONSTRAINT unq_producto_procesos_insumo_id_fecha UNIQUE (insumo_id, producto_procesos_fecha_desde);


--
-- TOC entry 3283 (class 2606 OID 30644)
-- Name: tb_reglas unq_regla; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_reglas
    ADD CONSTRAINT unq_regla UNIQUE (regla_empresa_origen_id, regla_empresa_destino_id);


--
-- TOC entry 3368 (class 2606 OID 102812)
-- Name: tb_taplicacion_procesos_detalle unq_taplicacion_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT unq_taplicacion_procesos_detalle UNIQUE (taplicacion_procesos_id, procesos_codigo);


--
-- TOC entry 3362 (class 2606 OID 102794)
-- Name: tb_taplicacion_procesos unq_taplicacion_procesos_taplicacion_codigo_fecha; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos
    ADD CONSTRAINT unq_taplicacion_procesos_taplicacion_codigo_fecha UNIQUE (taplicacion_codigo, taplicacion_procesos_fecha_desde);


--
-- TOC entry 3352 (class 2606 OID 102706)
-- Name: tb_tcosto_global_entries uq_tcosto_global_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT uq_tcosto_global_entries UNIQUE (tcosto_global_codigo, tcosto_global_entries_fecha_desde);


--
-- TOC entry 3325 (class 2606 OID 30646)
-- Name: tb_unidad_medida_conversion uq_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT uq_unidad_conversion UNIQUE (unidad_medida_origen, unidad_medida_destino);


--
-- TOC entry 3222 (class 1259 OID 30647)
-- Name: fki_cliente_tipo_empresa; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cliente_tipo_empresa ON public.tb_cliente USING btree (tipo_cliente_codigo);


--
-- TOC entry 3233 (class 1259 OID 30648)
-- Name: fki_cotizacion_detalle_cotizacion; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_detalle_cotizacion ON public.tb_cotizacion_detalle USING btree (cotizacion_id);


--
-- TOC entry 3234 (class 1259 OID 30649)
-- Name: fki_cotizacion_detalle_insumo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_detalle_insumo ON public.tb_cotizacion_detalle USING btree (insumo_id);


--
-- TOC entry 3235 (class 1259 OID 30650)
-- Name: fki_cotizacion_detalle_moneda_codigo_costo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_detalle_moneda_codigo_costo ON public.tb_cotizacion_detalle USING btree (log_moneda_codigo_costo);


--
-- TOC entry 3236 (class 1259 OID 30651)
-- Name: fki_cotizacion_detalle_umedida; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_detalle_umedida ON public.tb_cotizacion_detalle USING btree (unidad_medida_codigo);


--
-- TOC entry 3237 (class 1259 OID 30652)
-- Name: fki_cotizacion_detalle_umedida_costo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_detalle_umedida_costo ON public.tb_cotizacion_detalle USING btree (log_unidad_medida_codigo_costo);


--
-- TOC entry 3227 (class 1259 OID 30653)
-- Name: fki_cotizacion_empresa_origen; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_empresa_origen ON public.tb_cotizacion USING btree (empresa_id);


--
-- TOC entry 3228 (class 1259 OID 30654)
-- Name: fki_cotizacion_moneda; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_cotizacion_moneda ON public.tb_cotizacion USING btree (moneda_codigo);


--
-- TOC entry 3240 (class 1259 OID 30655)
-- Name: fki_empresa_tipo_empresa; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_empresa_tipo_empresa ON public.tb_empresa USING btree (tipo_empresa_codigo);


--
-- TOC entry 3249 (class 1259 OID 30656)
-- Name: fki_insumo_empresa; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_empresa ON public.tb_insumo USING btree (empresa_id);


--
-- TOC entry 3260 (class 1259 OID 30657)
-- Name: fki_insumo_entries_insumo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_entries_insumo ON public.tb_insumo_entries USING btree (insumo_id);


--
-- TOC entry 3261 (class 1259 OID 30658)
-- Name: fki_insumo_entries_unidad_medida_qty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_entries_unidad_medida_qty ON public.tb_insumo_entries USING btree (unidad_medida_codigo_qty);


--
-- TOC entry 3264 (class 1259 OID 30659)
-- Name: fki_insumo_history_insumo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_history_insumo ON public.tb_insumo_history USING btree (insumo_id);


--
-- TOC entry 3265 (class 1259 OID 30660)
-- Name: fki_insumo_history_moneda_costo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_history_moneda_costo ON public.tb_insumo_history USING btree (moneda_codigo_costo);


--
-- TOC entry 3266 (class 1259 OID 30661)
-- Name: fki_insumo_history_tcostos; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_history_tcostos ON public.tb_insumo_history USING btree (tcostos_codigo);


--
-- TOC entry 3267 (class 1259 OID 30662)
-- Name: fki_insumo_history_tinsumo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_history_tinsumo ON public.tb_insumo_history USING btree (tinsumo_codigo);


--
-- TOC entry 3268 (class 1259 OID 30663)
-- Name: fki_insumo_history_unidad_medida_costo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_insumo_history_unidad_medida_costo ON public.tb_insumo_history USING btree (unidad_medida_codigo_costo);


--
-- TOC entry 3250 (class 1259 OID 30664)
-- Name: fki_insumo_moneda_costo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_moneda_costo ON public.tb_insumo USING btree (moneda_codigo_costo);


--
-- TOC entry 3251 (class 1259 OID 102781)
-- Name: fki_insumo_taplicacion_entries; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_taplicacion_entries ON public.tb_insumo USING btree (taplicacion_entries_id);


--
-- TOC entry 3252 (class 1259 OID 30665)
-- Name: fki_insumo_tcostos; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_tcostos ON public.tb_insumo USING btree (tcostos_codigo);


--
-- TOC entry 3253 (class 1259 OID 30666)
-- Name: fki_insumo_tinsumo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_tinsumo ON public.tb_insumo USING btree (tinsumo_codigo);


--
-- TOC entry 3254 (class 1259 OID 30667)
-- Name: fki_insumo_unidad_medida_costo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_unidad_medida_costo ON public.tb_insumo USING btree (unidad_medida_codigo_costo);


--
-- TOC entry 3255 (class 1259 OID 30668)
-- Name: fki_insumo_unidad_medida_ingreso; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_unidad_medida_ingreso ON public.tb_insumo USING btree (unidad_medida_codigo_ingreso);


--
-- TOC entry 3284 (class 1259 OID 30669)
-- Name: fki_menu_parent_id; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_menu_parent_id ON public.tb_sys_menu USING btree (menu_parent_id);


--
-- TOC entry 3285 (class 1259 OID 30670)
-- Name: fki_menu_sistemas; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_menu_sistemas ON public.tb_sys_menu USING btree (sys_systemcode);


--
-- TOC entry 3290 (class 1259 OID 30671)
-- Name: fki_perfil_sistema; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_perfil_sistema ON public.tb_sys_perfil USING btree (sys_systemcode);


--
-- TOC entry 3301 (class 1259 OID 30672)
-- Name: fki_perfil_usuario; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_perfil_usuario ON public.tb_sys_usuario_perfiles USING btree (perfil_id);


--
-- TOC entry 3369 (class 1259 OID 102892)
-- Name: fki_produccion_taplicacion_entries; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_produccion_taplicacion_entries ON public.tb_produccion USING btree (taplicacion_entries_id);


--
-- TOC entry 3370 (class 1259 OID 102893)
-- Name: fki_produccion_unidad_medida_qty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_produccion_unidad_medida_qty ON public.tb_produccion USING btree (unidad_medida_codigo);


--
-- TOC entry 3273 (class 1259 OID 30673)
-- Name: fki_producto_detalle_empresa; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_detalle_empresa ON public.tb_producto_detalle USING btree (empresa_id);


--
-- TOC entry 3274 (class 1259 OID 30674)
-- Name: fki_producto_detalle_insumo_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_detalle_insumo_id ON public.tb_producto_detalle USING btree (insumo_id);


--
-- TOC entry 3275 (class 1259 OID 30675)
-- Name: fki_producto_detalle_unidad_medida; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_detalle_unidad_medida ON public.tb_producto_detalle USING btree (unidad_medida_codigo);


--
-- TOC entry 3341 (class 1259 OID 102663)
-- Name: fki_producto_procesos_detalle_procesos_codigo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_procesos_detalle_procesos_codigo ON public.tb_producto_procesos_detalle USING btree (procesos_codigo);


--
-- TOC entry 3342 (class 1259 OID 102662)
-- Name: fki_producto_procesos_detalle_procesos_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_procesos_detalle_procesos_id ON public.tb_producto_procesos_detalle USING btree (producto_procesos_id);


--
-- TOC entry 3336 (class 1259 OID 102591)
-- Name: fki_producto_procesos_insumo_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_procesos_insumo_id ON public.tb_producto_procesos USING btree (insumo_id);


--
-- TOC entry 3355 (class 1259 OID 102773)
-- Name: fki_taplicacion_entries_taplicacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_taplicacion_entries_taplicacion ON public.tb_taplicacion_entries USING btree (taplicacion_codigo);


--
-- TOC entry 3363 (class 1259 OID 102825)
-- Name: fki_taplicacion_procesos_detalle_procesos_codigo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_taplicacion_procesos_detalle_procesos_codigo ON public.tb_taplicacion_procesos_detalle USING btree (procesos_codigo);


--
-- TOC entry 3364 (class 1259 OID 102824)
-- Name: fki_taplicacion_procesos_detalle_procesos_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_taplicacion_procesos_detalle_procesos_id ON public.tb_taplicacion_procesos_detalle USING btree (taplicacion_procesos_id);


--
-- TOC entry 3358 (class 1259 OID 102800)
-- Name: fki_taplicacion_procesos_taplicacion_codigo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_taplicacion_procesos_taplicacion_codigo ON public.tb_taplicacion_procesos USING btree (taplicacion_codigo);


--
-- TOC entry 3347 (class 1259 OID 102703)
-- Name: fki_tcosto_global_entries_moneda; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_tcosto_global_entries_moneda ON public.tb_tcosto_global_entries USING btree (moneda_codigo);


--
-- TOC entry 3348 (class 1259 OID 102702)
-- Name: fki_tcosto_global_entries_tcosto_global; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_tcosto_global_entries_tcosto_global ON public.tb_tcosto_global_entries USING btree (tcosto_global_codigo);


--
-- TOC entry 3321 (class 1259 OID 30676)
-- Name: fki_unidad_conversion_medida_destino; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_unidad_conversion_medida_destino ON public.tb_unidad_medida_conversion USING btree (unidad_medida_destino);


--
-- TOC entry 3326 (class 1259 OID 30677)
-- Name: fki_usuario_empresa; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_usuario_empresa ON public.tb_usuarios USING btree (empresa_id);


--
-- TOC entry 3302 (class 1259 OID 30678)
-- Name: fki_usuarioperfiles; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_usuarioperfiles ON public.tb_sys_usuario_perfiles USING btree (usuarios_id);


--
-- TOC entry 3219 (class 1259 OID 30679)
-- Name: idx_sessions_last_activity; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX idx_sessions_last_activity ON public.ci_sessions USING btree (last_activity);


--
-- TOC entry 3327 (class 1259 OID 30680)
-- Name: idx_unique_usuarios; Type: INDEX; Schema: public; Owner: atluser
--

CREATE UNIQUE INDEX idx_unique_usuarios ON public.tb_usuarios USING btree (upper((usuarios_code)::text));


--
-- TOC entry 3223 (class 1259 OID 30681)
-- Name: idx_unq_cliente_razon_social; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_cliente_razon_social ON public.tb_cliente USING btree (empresa_id, upper((cliente_razon_social)::text));


--
-- TOC entry 3224 (class 1259 OID 30682)
-- Name: idx_unq_cliente_ruc; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_cliente_ruc ON public.tb_cliente USING btree (empresa_id, upper((cliente_ruc)::text));


--
-- TOC entry 3241 (class 1259 OID 30683)
-- Name: idx_unq_empresa_razon_social; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_empresa_razon_social ON public.tb_empresa USING btree (upper((empresa_razon_social)::text));


--
-- TOC entry 3242 (class 1259 OID 30684)
-- Name: idx_unq_empresa_ruc; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_empresa_ruc ON public.tb_empresa USING btree (upper((empresa_ruc)::text));


--
-- TOC entry 3311 (class 1259 OID 30685)
-- Name: idx_unq_tipo_cliente_descripcion; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_tipo_cliente_descripcion ON public.tb_tipo_cliente USING btree (upper((tipo_cliente_descripcion)::text));


--
-- TOC entry 3314 (class 1259 OID 30686)
-- Name: idx_unq_tipo_empresa_descripcion; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_tipo_empresa_descripcion ON public.tb_tipo_empresa USING btree (upper((tipo_empresa_descripcion)::text));


--
-- TOC entry 3373 (class 1259 OID 102894)
-- Name: uq_produccion_taplicacion_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_produccion_taplicacion_fecha ON public.tb_produccion USING btree (taplicacion_entries_id, produccion_fecha);


--
-- TOC entry 3478 (class 2620 OID 30687)
-- Name: tb_usuarios sptrg_verify_usuario_code_change; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER sptrg_verify_usuario_code_change BEFORE INSERT OR DELETE OR UPDATE ON public.tb_usuarios FOR EACH ROW EXECUTE PROCEDURE public.sptrg_verify_usuario_code_change();


--
-- TOC entry 3426 (class 2620 OID 30688)
-- Name: tb_cliente tr_cliente; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cliente BEFORE INSERT OR UPDATE ON public.tb_cliente FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3427 (class 2620 OID 30689)
-- Name: tb_cliente tr_cliente_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cliente_validate_delete BEFORE DELETE ON public.tb_cliente FOR EACH ROW EXECUTE PROCEDURE public.sptrg_cliente_validate_delete();


--
-- TOC entry 3428 (class 2620 OID 30690)
-- Name: tb_cotizacion tr_cotizacion; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion BEFORE INSERT OR UPDATE ON public.tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3432 (class 2620 OID 30691)
-- Name: tb_cotizacion_detalle tr_cotizacion_detalle; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_detalle BEFORE INSERT OR UPDATE ON public.tb_cotizacion_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3433 (class 2620 OID 30692)
-- Name: tb_cotizacion_detalle tr_cotizacion_detalle_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_detalle_validate_delete BEFORE DELETE ON public.tb_cotizacion_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_cotizacion_detalle_validate_delete();


--
-- TOC entry 3434 (class 2620 OID 30693)
-- Name: tb_cotizacion_detalle tr_cotizacion_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_cotizacion_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_cotizacion_detalle_validate_save();


--
-- TOC entry 3429 (class 2620 OID 30694)
-- Name: tb_cotizacion tr_cotizacion_producto_history_log; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_producto_history_log AFTER UPDATE OF cotizacion_cerrada ON public.tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_cotizacion_producto_history_log();


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 3429
-- Name: TRIGGER tr_cotizacion_producto_history_log ON tb_cotizacion; Type: COMMENT; Schema: public; Owner: clabsuser
--

COMMENT ON TRIGGER tr_cotizacion_producto_history_log ON public.tb_cotizacion IS 'Este trigger actualiza los history log de productos comprendidos en la cotizacion.
IMPORTANTE: solo se dispara cuando se cierra la cotizacion osea cuando el campo
cotizacion cerrada es alterado o modificado.
';


--
-- TOC entry 3430 (class 2620 OID 30695)
-- Name: tb_cotizacion tr_cotizacion_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_validate_delete BEFORE DELETE ON public.tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_cotizacion_validate_delete();


--
-- TOC entry 3431 (class 2620 OID 30696)
-- Name: tb_cotizacion tr_cotizacion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_validate_save BEFORE INSERT OR UPDATE OF cliente_id, cotizacion_es_cliente_real ON public.tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_cotizacion_validate_save();


--
-- TOC entry 3435 (class 2620 OID 30697)
-- Name: tb_empresa tr_empresa; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_empresa BEFORE INSERT OR UPDATE ON public.tb_empresa FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3436 (class 2620 OID 30698)
-- Name: tb_empresa tr_empresa_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_empresa_validate_delete BEFORE DELETE ON public.tb_empresa FOR EACH ROW EXECUTE PROCEDURE public.sptrg_empresa_validate_delete();


--
-- TOC entry 3437 (class 2620 OID 30699)
-- Name: tb_entidad tr_entidad; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entidad BEFORE INSERT OR UPDATE ON public.tb_entidad FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3438 (class 2620 OID 30700)
-- Name: tb_ffarmaceutica tr_ffarmaceutica_validate_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_ffarmaceutica_validate_delete BEFORE DELETE ON public.tb_ffarmaceutica FOR EACH ROW EXECUTE PROCEDURE public.sptrg_ffarmaceutica_validate_delete();


--
-- TOC entry 3439 (class 2620 OID 30701)
-- Name: tb_ffarmaceutica tr_ffarmaceutica_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_ffarmaceutica_validate_save BEFORE INSERT OR UPDATE ON public.tb_ffarmaceutica FOR EACH ROW EXECUTE PROCEDURE public.sptrg_ffarmaceutica_validate_save();


--
-- TOC entry 3445 (class 2620 OID 30702)
-- Name: tb_insumo_entries tr_insumo_entries; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_insumo_entries BEFORE INSERT OR UPDATE ON public.tb_insumo_entries FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3446 (class 2620 OID 30703)
-- Name: tb_insumo_entries tr_insumo_entries_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_insumo_entries_validate_save BEFORE INSERT OR UPDATE ON public.tb_insumo_entries FOR EACH ROW EXECUTE PROCEDURE public.sptrg_insumo_entries_validate_save();


--
-- TOC entry 3447 (class 2620 OID 30704)
-- Name: tb_insumo_history tr_insumo_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_insumo_history BEFORE INSERT OR UPDATE ON public.tb_insumo_history FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3442 (class 2620 OID 30705)
-- Name: tb_insumo tr_insumo_history_log; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_history_log AFTER INSERT OR UPDATE OF insumo_tipo, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, insumo_precio_mercado ON public.tb_insumo FOR EACH ROW EXECUTE PROCEDURE public.sptrg_insumo_history_log();


--
-- TOC entry 3443 (class 2620 OID 30706)
-- Name: tb_insumo tr_insumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_validate_save BEFORE INSERT OR UPDATE ON public.tb_insumo FOR EACH ROW EXECUTE PROCEDURE public.sptrg_insumo_validate_save();


--
-- TOC entry 3448 (class 2620 OID 30707)
-- Name: tb_moneda tr_moneda_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_moneda_validate_save BEFORE INSERT OR UPDATE ON public.tb_moneda FOR EACH ROW EXECUTE PROCEDURE public.sptrg_moneda_validate_save();


--
-- TOC entry 3483 (class 2620 OID 102485)
-- Name: tb_procesos tr_procesos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_procesos_validate_save BEFORE INSERT OR UPDATE ON public.tb_procesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_procesos_validate_save();


--
-- TOC entry 3498 (class 2620 OID 102895)
-- Name: tb_produccion tr_produccion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_produccion BEFORE INSERT OR UPDATE ON public.tb_produccion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3450 (class 2620 OID 30708)
-- Name: tb_producto_detalle tr_producto_detalle_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_detalle_validate_delete BEFORE DELETE ON public.tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_producto_detalle_validate_delete();


--
-- TOC entry 3451 (class 2620 OID 30709)
-- Name: tb_producto_detalle tr_producto_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_producto_detalle_validate_save();


--
-- TOC entry 3489 (class 2620 OID 102667)
-- Name: tb_producto_procesos_detalle tr_producto_procesos_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_procesos_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_producto_procesos_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_producto_procesos_detalle_validate_save();


--
-- TOC entry 3487 (class 2620 OID 102669)
-- Name: tb_producto_procesos tr_producto_procesos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_procesos_validate_save BEFORE INSERT OR UPDATE ON public.tb_producto_procesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_producto_procesos_validate_save();


--
-- TOC entry 3453 (class 2620 OID 30710)
-- Name: tb_reglas tr_reglas_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_reglas_validate_save BEFORE INSERT OR UPDATE ON public.tb_reglas FOR EACH ROW EXECUTE PROCEDURE public.sptrg_reglas_validate_save();


--
-- TOC entry 3484 (class 2620 OID 102495)
-- Name: tb_subprocesos tr_subprocesos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_subprocesos_validate_save BEFORE INSERT OR UPDATE ON public.tb_subprocesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_subprocesos_validate_save();


--
-- TOC entry 3455 (class 2620 OID 30711)
-- Name: tb_sys_perfil tr_sys_perfil; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil BEFORE INSERT OR UPDATE ON public.tb_sys_perfil FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3456 (class 2620 OID 30712)
-- Name: tb_sys_perfil_detalle tr_sys_perfil_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil_detalle BEFORE INSERT OR UPDATE ON public.tb_sys_perfil_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3457 (class 2620 OID 30713)
-- Name: tb_sys_sistemas tr_sys_sistemas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_sistemas BEFORE INSERT OR UPDATE ON public.tb_sys_sistemas FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3458 (class 2620 OID 30714)
-- Name: tb_sys_usuario_perfiles tr_sys_usuario_perfiles; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_usuario_perfiles BEFORE INSERT OR UPDATE ON public.tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3493 (class 2620 OID 102774)
-- Name: tb_taplicacion_entries tr_taplicacion_entries_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_taplicacion_entries_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion_entries FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3494 (class 2620 OID 102775)
-- Name: tb_taplicacion_entries tr_taplicacion_entries_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_taplicacion_entries_validate_save BEFORE INSERT OR UPDATE ON public.tb_taplicacion_entries FOR EACH ROW EXECUTE PROCEDURE public.sptrg_taplicacion_entries_validate_save();


--
-- TOC entry 3496 (class 2620 OID 102827)
-- Name: tb_taplicacion_procesos_detalle tr_taplicacion_procesos_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_taplicacion_procesos_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_taplicacion_procesos_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_taplicacion_procesos_detalle_validate_save();


--
-- TOC entry 3491 (class 2620 OID 102721)
-- Name: tb_taplicacion tr_taplicacion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_taplicacion_validate_save BEFORE INSERT OR UPDATE ON public.tb_taplicacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_taplicacion_validate_save();


--
-- TOC entry 3490 (class 2620 OID 102704)
-- Name: tb_tcosto_global_entries tr_tcosto_global_entries_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_tcosto_global_entries_log_fields BEFORE INSERT OR UPDATE ON public.tb_tcosto_global_entries FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3480 (class 2620 OID 102391)
-- Name: tb_tcosto_global tr_tcosto_global_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcosto_global_log_fields BEFORE INSERT OR UPDATE ON public.tb_tcosto_global FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3481 (class 2620 OID 102393)
-- Name: tb_tcosto_global tr_tcosto_global_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcosto_global_validate_save BEFORE INSERT OR UPDATE ON public.tb_tcosto_global FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tcosto_global_validate_save();


--
-- TOC entry 3460 (class 2620 OID 30715)
-- Name: tb_tcostos tr_tcostos_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_delete BEFORE DELETE ON public.tb_tcostos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tcostos_validate_delete();


--
-- TOC entry 3461 (class 2620 OID 30716)
-- Name: tb_tcostos tr_tcostos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_save BEFORE INSERT OR UPDATE ON public.tb_tcostos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tcostos_validate_save();


--
-- TOC entry 3463 (class 2620 OID 30717)
-- Name: tb_tinsumo tr_tinsumo_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_delete BEFORE DELETE ON public.tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tinsumo_validate_delete();


--
-- TOC entry 3464 (class 2620 OID 30718)
-- Name: tb_tinsumo tr_tinsumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_save BEFORE INSERT OR UPDATE ON public.tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tinsumo_validate_save();


--
-- TOC entry 3466 (class 2620 OID 30719)
-- Name: tb_tipo_cambio tr_tipo_cambio; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio BEFORE INSERT OR UPDATE ON public.tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3467 (class 2620 OID 30720)
-- Name: tb_tipo_cambio tr_tipo_cambio_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio_validate_save BEFORE INSERT OR UPDATE ON public.tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tipo_cambio_validate_save();


--
-- TOC entry 3470 (class 2620 OID 30721)
-- Name: tb_tpresentacion tr_tpresentacion_validate_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_tpresentacion_validate_delete BEFORE DELETE ON public.tb_tpresentacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tpresentacion_validate_delete();


--
-- TOC entry 3471 (class 2620 OID 30722)
-- Name: tb_tpresentacion tr_tpresentacion_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_tpresentacion_validate_save BEFORE INSERT OR UPDATE ON public.tb_tpresentacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_tpresentacion_validate_save();


--
-- TOC entry 3476 (class 2620 OID 30723)
-- Name: tb_unidad_medida_conversion tr_unidad_medida_conversion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_conversion_validate_save BEFORE INSERT OR UPDATE ON public.tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_unidad_medida_conversion_validate_save();


--
-- TOC entry 3473 (class 2620 OID 30724)
-- Name: tb_unidad_medida tr_unidad_medida_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_delete BEFORE DELETE ON public.tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE public.sptrg_unidad_medida_validate_delete();


--
-- TOC entry 3474 (class 2620 OID 30725)
-- Name: tb_unidad_medida tr_unidad_medida_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_save BEFORE INSERT OR UPDATE ON public.tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE public.sptrg_unidad_medida_validate_save();


--
-- TOC entry 3440 (class 2620 OID 30738)
-- Name: tb_ffarmaceutica tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_ffarmaceutica FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3441 (class 2620 OID 30736)
-- Name: tb_igv tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_igv FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3444 (class 2620 OID 30731)
-- Name: tb_insumo tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_insumo FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3449 (class 2620 OID 30727)
-- Name: tb_moneda tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_moneda FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3482 (class 2620 OID 102483)
-- Name: tb_procesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_procesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3452 (class 2620 OID 30732)
-- Name: tb_producto_detalle tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3486 (class 2620 OID 102592)
-- Name: tb_producto_procesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_producto_procesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3488 (class 2620 OID 102664)
-- Name: tb_producto_procesos_detalle tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_producto_procesos_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3454 (class 2620 OID 30734)
-- Name: tb_reglas tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_reglas FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3485 (class 2620 OID 102493)
-- Name: tb_subprocesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_subprocesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3492 (class 2620 OID 102719)
-- Name: tb_taplicacion tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3495 (class 2620 OID 102801)
-- Name: tb_taplicacion_procesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion_procesos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3497 (class 2620 OID 102826)
-- Name: tb_taplicacion_procesos_detalle tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion_procesos_detalle FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3462 (class 2620 OID 30730)
-- Name: tb_tcostos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tcostos FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3465 (class 2620 OID 30729)
-- Name: tb_tinsumo tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3468 (class 2620 OID 30735)
-- Name: tb_tipo_cliente tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tipo_cliente FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3469 (class 2620 OID 30733)
-- Name: tb_tipo_empresa tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tipo_empresa FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3472 (class 2620 OID 30737)
-- Name: tb_tpresentacion tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tpresentacion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3475 (class 2620 OID 30726)
-- Name: tb_unidad_medida tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3477 (class 2620 OID 30728)
-- Name: tb_unidad_medida_conversion tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3459 (class 2620 OID 30739)
-- Name: tb_sys_usuario_perfiles tr_usuario_perfiles_save; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuario_perfiles_save BEFORE INSERT OR UPDATE ON public.tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE public.sptrg_usuario_perfiles_save();


--
-- TOC entry 3479 (class 2620 OID 30740)
-- Name: tb_usuarios tr_usuarios; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuarios BEFORE INSERT OR UPDATE ON public.tb_usuarios FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();


--
-- TOC entry 3374 (class 2606 OID 30741)
-- Name: tb_cliente fk_cliente_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT fk_cliente_empresa FOREIGN KEY (empresa_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3375 (class 2606 OID 30746)
-- Name: tb_cliente fk_cliente_tipo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT fk_cliente_tipo_empresa FOREIGN KEY (tipo_cliente_codigo) REFERENCES public.tb_tipo_cliente(tipo_cliente_codigo);


--
-- TOC entry 3378 (class 2606 OID 30751)
-- Name: tb_cotizacion_detalle fk_cotizacion_detalle_cotizacion; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle
    ADD CONSTRAINT fk_cotizacion_detalle_cotizacion FOREIGN KEY (cotizacion_id) REFERENCES public.tb_cotizacion(cotizacion_id) ON DELETE CASCADE;


--
-- TOC entry 3379 (class 2606 OID 30756)
-- Name: tb_cotizacion_detalle fk_cotizacion_detalle_insumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle
    ADD CONSTRAINT fk_cotizacion_detalle_insumo FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3380 (class 2606 OID 30761)
-- Name: tb_cotizacion_detalle fk_cotizacion_detalle_moneda_codigo_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle
    ADD CONSTRAINT fk_cotizacion_detalle_moneda_codigo_costo FOREIGN KEY (log_moneda_codigo_costo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3381 (class 2606 OID 30766)
-- Name: tb_cotizacion_detalle fk_cotizacion_detalle_umedida; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle
    ADD CONSTRAINT fk_cotizacion_detalle_umedida FOREIGN KEY (unidad_medida_codigo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3382 (class 2606 OID 30771)
-- Name: tb_cotizacion_detalle fk_cotizacion_detalle_umedida_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion_detalle
    ADD CONSTRAINT fk_cotizacion_detalle_umedida_costo FOREIGN KEY (log_unidad_medida_codigo_costo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3376 (class 2606 OID 30776)
-- Name: tb_cotizacion fk_cotizacion_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion
    ADD CONSTRAINT fk_cotizacion_empresa FOREIGN KEY (empresa_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3377 (class 2606 OID 30781)
-- Name: tb_cotizacion fk_cotizacion_moneda; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_cotizacion
    ADD CONSTRAINT fk_cotizacion_moneda FOREIGN KEY (moneda_codigo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3383 (class 2606 OID 30786)
-- Name: tb_empresa fk_empresa_tipo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_empresa
    ADD CONSTRAINT fk_empresa_tipo_empresa FOREIGN KEY (tipo_empresa_codigo) REFERENCES public.tb_tipo_empresa(tipo_empresa_codigo);


--
-- TOC entry 3384 (class 2606 OID 30791)
-- Name: tb_insumo fk_insumo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_empresa FOREIGN KEY (empresa_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3391 (class 2606 OID 30796)
-- Name: tb_insumo_entries fk_insumo_entries_insumo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_entries
    ADD CONSTRAINT fk_insumo_entries_insumo FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id) ON DELETE CASCADE;


--
-- TOC entry 3392 (class 2606 OID 30801)
-- Name: tb_insumo_entries fk_insumo_entries_unidad_medida_codigo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_entries
    ADD CONSTRAINT fk_insumo_entries_unidad_medida_codigo FOREIGN KEY (unidad_medida_codigo_qty) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3393 (class 2606 OID 30806)
-- Name: tb_insumo_history fk_insumo_history_insumo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history
    ADD CONSTRAINT fk_insumo_history_insumo FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id) ON DELETE CASCADE;


--
-- TOC entry 3394 (class 2606 OID 30811)
-- Name: tb_insumo_history fk_insumo_history_moneda_costo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history
    ADD CONSTRAINT fk_insumo_history_moneda_costo FOREIGN KEY (moneda_codigo_costo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3395 (class 2606 OID 30816)
-- Name: tb_insumo_history fk_insumo_history_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history
    ADD CONSTRAINT fk_insumo_history_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES public.tb_tcostos(tcostos_codigo);


--
-- TOC entry 3396 (class 2606 OID 30821)
-- Name: tb_insumo_history fk_insumo_history_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history
    ADD CONSTRAINT fk_insumo_history_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES public.tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 3397 (class 2606 OID 30826)
-- Name: tb_insumo_history fk_insumo_history_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_insumo_history
    ADD CONSTRAINT fk_insumo_history_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3385 (class 2606 OID 30831)
-- Name: tb_insumo fk_insumo_moneda_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_moneda_costo FOREIGN KEY (moneda_codigo_costo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3390 (class 2606 OID 102776)
-- Name: tb_insumo fk_insumo_taplicacion_entries; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_taplicacion_entries FOREIGN KEY (taplicacion_entries_id) REFERENCES public.tb_taplicacion_entries(taplicacion_entries_id);


--
-- TOC entry 3386 (class 2606 OID 30836)
-- Name: tb_insumo fk_insumo_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES public.tb_tcostos(tcostos_codigo);


--
-- TOC entry 3387 (class 2606 OID 30841)
-- Name: tb_insumo fk_insumo_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES public.tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 3388 (class 2606 OID 30846)
-- Name: tb_insumo fk_insumo_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3389 (class 2606 OID 30851)
-- Name: tb_insumo fk_insumo_unidad_medida_ingreso; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_unidad_medida_ingreso FOREIGN KEY (unidad_medida_codigo_ingreso) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3404 (class 2606 OID 30856)
-- Name: tb_sys_menu fk_menu_parent; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES public.tb_sys_menu(menu_id);


--
-- TOC entry 3405 (class 2606 OID 30861)
-- Name: tb_sys_menu fk_menu_sistemas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT fk_menu_sistemas FOREIGN KEY (sys_systemcode) REFERENCES public.tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 3410 (class 2606 OID 30866)
-- Name: tb_tipo_cambio fk_moneda_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio
    ADD CONSTRAINT fk_moneda_destino FOREIGN KEY (moneda_codigo_destino) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3411 (class 2606 OID 30871)
-- Name: tb_tipo_cambio fk_moneda_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio
    ADD CONSTRAINT fk_moneda_origen FOREIGN KEY (moneda_codigo_origen) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3407 (class 2606 OID 30876)
-- Name: tb_sys_perfil_detalle fk_perfdet_perfil; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil_detalle
    ADD CONSTRAINT fk_perfdet_perfil FOREIGN KEY (perfil_id) REFERENCES public.tb_sys_perfil(perfil_id);


--
-- TOC entry 3406 (class 2606 OID 30881)
-- Name: tb_sys_perfil fk_perfil_sistema; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode) REFERENCES public.tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 3425 (class 2606 OID 102882)
-- Name: tb_produccion fk_produccion_taplicacion_entries; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion
    ADD CONSTRAINT fk_produccion_taplicacion_entries FOREIGN KEY (taplicacion_entries_id) REFERENCES public.tb_taplicacion_entries(taplicacion_entries_id) ON DELETE CASCADE;


--
-- TOC entry 3424 (class 2606 OID 102887)
-- Name: tb_produccion fk_produccion_unidad_medida_codigo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion
    ADD CONSTRAINT fk_produccion_unidad_medida_codigo FOREIGN KEY (unidad_medida_codigo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3398 (class 2606 OID 30886)
-- Name: tb_producto_detalle fk_producto_detalle_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_empresa FOREIGN KEY (empresa_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3399 (class 2606 OID 30891)
-- Name: tb_producto_detalle fk_producto_detalle_insumo_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_insumo_id FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3400 (class 2606 OID 30896)
-- Name: tb_producto_detalle fk_producto_detalle_insumo_id_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_insumo_id_origen FOREIGN KEY (insumo_id_origen) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3401 (class 2606 OID 30901)
-- Name: tb_producto_detalle fk_producto_detalle_unidad_medida; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_unidad_medida FOREIGN KEY (unidad_medida_codigo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3416 (class 2606 OID 102657)
-- Name: tb_producto_procesos_detalle fk_producto_procesos_detalle_procesos_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT fk_producto_procesos_detalle_procesos_codigo FOREIGN KEY (procesos_codigo) REFERENCES public.tb_procesos(procesos_codigo);


--
-- TOC entry 3417 (class 2606 OID 102671)
-- Name: tb_producto_procesos_detalle fk_producto_procesos_detalle_producto_procesos_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT fk_producto_procesos_detalle_producto_procesos_id FOREIGN KEY (producto_procesos_id) REFERENCES public.tb_producto_procesos(producto_procesos_id) ON DELETE CASCADE;


--
-- TOC entry 3415 (class 2606 OID 102586)
-- Name: tb_producto_procesos fk_producto_procesos_insumo_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos
    ADD CONSTRAINT fk_producto_procesos_insumo_id FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3402 (class 2606 OID 30906)
-- Name: tb_reglas fk_regla_empresa_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_reglas
    ADD CONSTRAINT fk_regla_empresa_destino FOREIGN KEY (regla_empresa_destino_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3403 (class 2606 OID 30911)
-- Name: tb_reglas fk_regla_empresa_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_reglas
    ADD CONSTRAINT fk_regla_empresa_origen FOREIGN KEY (regla_empresa_origen_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3420 (class 2606 OID 102768)
-- Name: tb_taplicacion_entries fk_taplicacion_entries_taplicacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_taplicacion_entries
    ADD CONSTRAINT fk_taplicacion_entries_taplicacion FOREIGN KEY (taplicacion_codigo) REFERENCES public.tb_taplicacion(taplicacion_codigo);


--
-- TOC entry 3423 (class 2606 OID 102818)
-- Name: tb_taplicacion_procesos_detalle fk_taplicacion_procesos_detalle_procesos_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT fk_taplicacion_procesos_detalle_procesos_codigo FOREIGN KEY (procesos_codigo) REFERENCES public.tb_procesos(procesos_codigo);


--
-- TOC entry 3422 (class 2606 OID 102813)
-- Name: tb_taplicacion_procesos_detalle fk_taplicacion_procesos_detalle_taplicacion_procesos_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT fk_taplicacion_procesos_detalle_taplicacion_procesos_id FOREIGN KEY (taplicacion_procesos_id) REFERENCES public.tb_taplicacion_procesos(taplicacion_procesos_id) ON DELETE CASCADE;


--
-- TOC entry 3421 (class 2606 OID 102795)
-- Name: tb_taplicacion_procesos fk_taplicacion_procesos_taplicacion_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos
    ADD CONSTRAINT fk_taplicacion_procesos_taplicacion_codigo FOREIGN KEY (taplicacion_codigo) REFERENCES public.tb_taplicacion(taplicacion_codigo);


--
-- TOC entry 3419 (class 2606 OID 102697)
-- Name: tb_tcosto_global_entries fk_tcosto_global_entries_moneda_codigo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT fk_tcosto_global_entries_moneda_codigo FOREIGN KEY (moneda_codigo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3418 (class 2606 OID 102692)
-- Name: tb_tcosto_global_entries fk_tcosto_global_entries_tcosto_global; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT fk_tcosto_global_entries_tcosto_global FOREIGN KEY (tcosto_global_codigo) REFERENCES public.tb_tcosto_global(tcosto_global_codigo);


--
-- TOC entry 3412 (class 2606 OID 30916)
-- Name: tb_unidad_medida_conversion fk_unidad_conversion_medida_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT fk_unidad_conversion_medida_destino FOREIGN KEY (unidad_medida_destino) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3413 (class 2606 OID 30921)
-- Name: tb_unidad_medida_conversion fk_unidad_conversion_medida_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT fk_unidad_conversion_medida_origen FOREIGN KEY (unidad_medida_origen) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3414 (class 2606 OID 30926)
-- Name: tb_usuarios fk_usuario_empresa; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_usuarios
    ADD CONSTRAINT fk_usuario_empresa FOREIGN KEY (empresa_id) REFERENCES public.tb_empresa(empresa_id);


--
-- TOC entry 3408 (class 2606 OID 30931)
-- Name: tb_sys_usuario_perfiles fk_usuarioperfiles; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles
    ADD CONSTRAINT fk_usuarioperfiles FOREIGN KEY (perfil_id) REFERENCES public.tb_sys_perfil(perfil_id);


--
-- TOC entry 3409 (class 2606 OID 30936)
-- Name: tb_sys_usuario_perfiles fk_usuarioperfiles_usuario; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles
    ADD CONSTRAINT fk_usuarioperfiles_usuario FOREIGN KEY (usuarios_id) REFERENCES public.tb_usuarios(usuarios_id);


-- Completed on 2021-07-17 04:16:39 -05

--
-- PostgreSQL database dump complete
--

