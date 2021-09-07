--
-- PostgreSQL database dump
--

-- Dumped from database version 12.8 (Ubuntu 12.8-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.8 (Ubuntu 12.8-0ubuntu0.20.04.1)

-- Started on 2021-09-06 21:04:01 -05

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
-- TOC entry 267 (class 1255 OID 18329)
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
p_insumo_id - is del producto a costera
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
-- TOC entry 274 (class 1255 OID 45833)
-- Name: fn_get_producto_costo_total(integer, date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_producto_costo_total(p_insumo_id integer, p_d_fecha date, p_a_fecha date, p_tcambio_fecha date) RETURNS TABLE(r_insumo_descripcion character varying, r_taplicacion_descripcion character varying, r_costo_base numeric, r_costo_agregado numeric, r_costo_total numeric)
    LANGUAGE plpgsql
AS $$
    /**
    Autor : Carlos arana Reategui
    Fecha : 23-07-2021

    Funcion que calcula el costo de un producto en base a todos sus insumos/productos que lo
    componen y los costos globales adicionales.

    PARAMETROS :
    p_insumo_id - is del producto a costear
    p_d_fecha - a partir de que fecha tomara en cuenta para los movimientos de ingreso de litros de productos y los costos globales asociados.
    p_a_fecha - a partir de que fecha tomara en cuenta para los movimientos de ingreso de litros de productos y los costos globales asociados.
    p_tcambio_fecha - Fecha a tomar para los tipos de cambio.

    RETURN:
      un RECORD
      con la siguiente informacion :
               r_insumo_descripcion varchar(60),  La descripcion del producto
                r_taplicacion_descripcion varchar(60), Descripcion del modo de aplicacion
                r_costo_base  numeric,, costo  base derivado de la receta
                r_costo_agregado numeric, , costo agregado derivado de los gastos globales y distribucion de litros producidos
                r_costo_total numeric, el costo total , la suma de los 2 anteriores.

      En caso de error  los valores de costo base  pueden ser
        -1.000 si se requiere tipo de cambio y el mismo no existe definido.
        -2.000 si se requiere conversion de unidades y no existe.
        -3.000 cualquier otro error no contemplado.
         0.000 si no tiene items.
        el costo si todo esta ok.

      En caso de error  los valores de costo agregado pueden ser
        -1.000 si se requiere tipo de cambio y el mismo no existe definido.
        -2.000 si se requiere conversion de unidades y no existe.
        -5.000 si selos movimeintos de produciion para un mismo modo de empleopresenta unidades de medidas diferentes.

    Historia : Creado 22-08-2016
    */
DECLARE     v_costo_total                           numeric(10, 4);
    DECLARE     v_costo_base                      numeric(10, 4);
    DECLARE     v_costo_agregado_total            numeric(10, 4);
    DECLARE     v_tpresentacion_cantidad_costo           numeric(10, 4);
    DECLARE     v_total_litros                    numeric(10, 4);
    DECLARE     v_insumo_id                       int;
    DECLARE     v_insumo_descripcion              varchar(60);
    DECLARE     v_insumo_tipo                     varchar(2);
    DECLARE     v_taplicacion_entries_id          int;
    DECLARE     v_unidad_medida_min               varchar(8);
    DECLARE     v_unidad_medida_max               varchar(8);
    DECLARE     v_unidad_medida_codigo_costo      varchar(8);
    DECLARE     v_tinsumo_codigo                  varchar(15);
    DECLARE     v_unidad_medida_conversion        numeric(12, 5);
    DECLARE     v_taplicacion_descripcion           varchar(60);
    DECLARE      v_moneda_codigo_costo             varchar(8);
    DECLARE     v_tipo_cambio_check               numeric(8, 4);

BEGIN
    -- ----------------------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------------------
    -- Determinamos los costos agregados al costo del producto
    -- ----------------------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------------------

    -- Verificamos que el producto exista y que sea del tipo producto y no insumo, obtenemos su modo de aplicacion
    SELECT
        insumo_id,
        insumo_descripcion,
        insumo_tipo,
        i.taplicacion_entries_id,
        tp. unidad_medida_codigo_costo,
        tpresentacion_cantidad_costo,
        tinsumo_codigo,
        moneda_codigo_costo,
        tae.taplicacion_entries_descripcion
    INTO v_insumo_id,v_insumo_descripcion,v_insumo_tipo,v_taplicacion_entries_id,v_unidad_medida_codigo_costo,v_tpresentacion_cantidad_costo, v_tinsumo_codigo,v_moneda_codigo_costo,v_taplicacion_descripcion
    FROM tb_insumo i
             INNER JOIN tb_taplicacion_entries tae on tae.taplicacion_entries_id = i.taplicacion_entries_id
             INNER JOIN tb_tpresentacion tp on tp.tpresentacion_codigo = i.tpresentacion_codigo
    WHERE insumo_id = p_insumo_id;

    -- Existe el producto?
    IF v_insumo_id IS NULL THEN RAISE 'EL producto (id = %) no existe',p_insumo_id USING ERRCODE = 'restrict_violation'; END IF;

    -- Es del tipo producto?
    IF v_insumo_tipo IS NULL OR v_insumo_tipo != 'PR'
    THEN
        RAISE 'EL insumo % no es un producto , para el calculo de costo final se requiere que lo sea',v_insumo_descripcion USING ERRCODE = 'restrict_violation';
    END IF;


    -- ----------------------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------------------
    -- Determinamos el costo base del producto
    -- ----------------------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------------------
    SELECT fn_get_producto_costo(p_insumo_id, p_tcambio_fecha) INTO v_costo_base;
    -- si en el calculo de los items para el costo base hubo alguno que no encontro tipo de cambio
    -- o conversion requerida retornara 0 -1 o -2 segun el caso.
    IF COALESCE(v_costo_base, 0) > 0
    THEN
        -- Obtenemos el total de litros producidos para un especifico modo de empleo asignado al producto
        -- de la tabla de produccion entre las 2 fechas solicitadas
        SELECT
            SUM(COALESCE(produccion_qty, 0.00)),
            MIN(unidad_medida_codigo),
            MAX(unidad_medida_codigo)
        INTO v_total_litros,v_unidad_medida_min,v_unidad_medida_max
        FROM tb_produccion
        WHERE taplicacion_entries_id = v_taplicacion_entries_id
          AND produccion_fecha BETWEEN p_d_fecha AND p_a_fecha;

        -- Si las unidades de medidas de todos los movimientos de produccion asociados difieren
        --- se coloca en el  costo agregado total -5 para indicar el problema
        IF v_unidad_medida_min != v_unidad_medida_max
        THEN
            v_costo_agregado_total := -5;
        ELSE
            RAISE NOTICE 'CF- v_total_litros %',v_total_litros;
            RAISE NOTICE 'CF- v_um01 %',v_unidad_medida_min;
            RAISE NOTICE 'CF- v_um02 %',v_unidad_medida_max;

            -- Determinamos los costos globales entre las fechas seleccionadas  y normalizados a la moneda de costo del producto.
            SELECT
                SUM(tcosto_global_entries_valor * COALESCE(tipo_cambio, 0.0000)),
                MIN(COALESCE(tipo_cambio, -1.0000))
            INTO v_costo_agregado_total,v_tipo_cambio_check
            FROM (
                     SELECT
                         tcosto_global_entries_valor,
                         (
                             SELECT fn_get_tipo_cambio_conversion(moneda_codigo, v_moneda_codigo_costo, p_tcambio_fecha)
                         ) AS tipo_cambio
                     FROM tb_tcosto_global_entries
                     WHERE tcosto_global_entries_fecha_desde BETWEEN p_d_fecha AND p_a_fecha ) x;

            RAISE NOTICE 'CF- v_costo_agregado_total 00 %',v_costo_agregado_total;
            RAISE NOTICE 'CF- v_tipo_cambio_chk %',v_tipo_cambio_check;

            -- Si no se ha encontrado el tipo de cambio para los costos globales retornamos -1 como costo total agregado
            -- de lo contrario continuamos el proceso.
            IF v_tipo_cambio_check > 0
            THEN

                -- Determinamos el costo agregado por litro
                v_costo_agregado_total := v_costo_agregado_total / v_total_litros;

                -- Calculamos el costo agregado especificamente a la unidad de costo.
                -- para lo cual buscamos la conversion de unidades.
                SELECT fn_get_unidad_medida_conversion(v_unidad_medida_codigo_costo, v_unidad_medida_min) INTO v_unidad_medida_conversion;
                -- Si se ha encontrado o existe conversion entre las unidades solicitadas
                -- continuamos calculando , del lo contrario devolvemos -2
                IF coalesce(v_unidad_medida_conversion,0) > 0
                THEN
                    v_costo_agregado_total := v_costo_agregado_total * (v_tpresentacion_cantidad_costo * v_unidad_medida_conversion);

                    RAISE NOTICE '---------------------------------------------';
                    RAISE NOTICE 'CF- v_unidad_medida_codigo_costo %',v_unidad_medida_codigo_costo;
                    RAISE NOTICE 'CF- v_unidad_medida_min %',v_unidad_medida_min;
                    RAISE NOTICE 'CF- um_conversion %',v_unidad_medida_conversion;
                    RAISE NOTICE 'CF- v_tpresentacion_cantidad_costo %',v_tpresentacion_cantidad_costo;
                    RAISE NOTICE '---------------------------------------------';
                    RAISE NOTICE 'CF- v_costo_agregado_total 02 - tc %',v_costo_agregado_total;

                    v_costo_total := v_costo_base + v_costo_agregado_total;

                ELSE
                    -- No se encontro conversion de unidades
                    v_costo_agregado_total := -2;
                END IF;
            ELSE
                -- Problema de tipo de cambio al calcular el costo agregado
                v_costo_agregado_total := -1;
            END IF;
        END IF;

    END IF; -- El costo base aqui llega con error  desde la subfuncion

    -- Si no hay como calcular el costo total ponemos 0 en la columna
    IF coalesce(v_costo_agregado_total,0) < 0 OR v_costo_base < 0
    THEN
        v_costo_total := 0;
    END IF;

    RETURN QUERY SELECT v_insumo_descripcion,v_taplicacion_descripcion,v_costo_base, v_costo_agregado_total,v_costo_total;
END;
$$;


ALTER FUNCTION public.fn_get_producto_costo_total(p_insumo_id integer, p_d_fecha date, p_a_fecha date, p_tcambio_fecha date) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 18333)
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
    DECLARE v_insumo_tipo character varying(2);



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
                                                               where d2.insumo_id = pd.insumo_id))
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
               -- Si es insumo la unidad de medida de costo sale directamente de la tabla , de lo contrario sale de la presentacion.
               CASE
                   WHEN ins.insumo_tipo = 'IN' THEN
                       ins.unidad_medida_codigo_costo
                   ELSE
                       (SELECT tp.unidad_medida_codigo_costo from tb_tpresentacion tp  where tp.tpresentacion_codigo = ins.tpresentacion_codigo)
                   END as unidad_medida_codigo_costo,
               (select fn_get_producto_detalle_costo_base(p_producto_detalle_id,p_a_fecha)) as insumo_costo,
               tcostos_indirecto
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
        v_tcostos_indirecto
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
    RAISE NOTICE '**************************************************FC_TC ';
    RAISE NOTICE 'v_moneda_codigo_costo %',v_moneda_codigo_costo;
    RAISE NOTICE 'v_moneda_codigo_producto %',v_moneda_codigo_producto;
    RAISE NOTICE 'p_a_fecha %',p_a_fecha;
    RAISE NOTICE '*******************************************************';

    /*
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

        SELECT fn_get_tipo_cambio_conversion(v_moneda_codigo_costo, v_moneda_codigo_producto, p_a_fecha ,TRUE) into v_tipo_cambio_tasa_compra;
        SELECT fn_get_tipo_cambio_conversion(v_moneda_codigo_costo, v_moneda_codigo_producto, p_a_fecha ,FALSE) into v_tipo_cambio_tasa_venta;

    END IF;
    */			--RAISE NOTICE 'v_moneda_codigo_costo %',v_moneda_codigo_costo;
    --RAISE NOTICE 'v_moneda_codigo_producto %',v_moneda_codigo_producto;

    --RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
    --RAISE NOTICE 'v_tipo_cambio_tasa_venta %',v_tipo_cambio_tasa_venta;
    SELECT fn_get_tipo_cambio_conversion(v_moneda_codigo_costo, v_moneda_codigo_producto, p_a_fecha ,TRUE) into v_tipo_cambio_tasa_compra;
    SELECT fn_get_tipo_cambio_conversion(v_moneda_codigo_costo, v_moneda_codigo_producto, p_a_fecha ,FALSE) into v_tipo_cambio_tasa_venta;

    --RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
    --RAISE NOTICE 'v_tipo_cambio_tasa_venta %',v_tipo_cambio_tasa_venta;

-- Si no se ha encotrado tipo de cambio retornamos -1 como costo
    IF v_tipo_cambio_tasa_compra = -1 or v_tipo_cambio_tasa_venta=  -1
    THEN
        v_costo := -1.0000;
    ELSE

        -- Si el producto principal y el insumo son distintos y los costos son directos buscamos la conversiom
        -- de lo contrario simepre sera 1.

        RAISE NOTICE 'product_id / v_unidad_medida_codigo_costo / v_unidad_medida_codigo % % % ',p_producto_detalle_id,v_unidad_medida_codigo_costo,v_unidad_medida_codigo;

        IF v_unidad_medida_codigo_costo != v_unidad_medida_codigo AND v_tcostos_indirecto = FALSE
        THEN
            select unidad_medida_conversion_factor
            into v_unidad_medida_conversion_factor
            from
                tb_unidad_medida_conversion
            where unidad_medida_origen =v_unidad_medida_codigo_costo AND
                    unidad_medida_destino =  v_unidad_medida_codigo ;
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
-- TOC entry 268 (class 1255 OID 18336)
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
BEGIN

    -- Leemos los valoresa trabajar.
    SELECT
        CASE
            WHEN ins.insumo_tipo = 'IN' THEN
                ins.insumo_costo
            ELSE
                (select fn_get_producto_costo(ins.insumo_id, p_a_fecha) )
            END AS insumo_costo
    INTO
        v_insumo_costo
    FROM   tb_producto_detalle pd
               inner join tb_insumo ins  ON ins.insumo_id = pd.insumo_id
--inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
--inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
--left join tb_reglas rg on rg.regla_empresa_origen_id = ins.empresa_id and rg.regla_empresa_destino_id = inso.empresa_id
    WHERE      pd.producto_detalle_id = p_producto_detalle_id;


    RETURN v_insumo_costo;
END;
$$;


ALTER FUNCTION public.fn_get_producto_detalle_costo_base(p_producto_detalle_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 305 (class 1255 OID 45808)
-- Name: fn_get_tipo_cambio_conversion(character varying, character varying, date, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_tipo_cambio_conversion(p_codigo_moneda_origen character varying, p_codigo_moneda_destino character varying, p_tcambio_fecha date, p_is_compra boolean DEFAULT false) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 09-08-2021

Funcion que retorna el tipo de cambio entre una moneda origen y una destino para una determinada fecha

PARAMETROS :
p_codigo_moneda_origen - Codigo de la moneda de origen
p_codigo_moneda_destino - Codigo de la moneda destino
p_tcambio_fecha - A que fecha se solicita el tipo de cambio
 p_is_compra - Si es TRUE se devolvera el tipo de cambio de compra de lo contrario el de venta.

RETURN:
	El tipo de cambio
  -1 si no hay tasa entre las monedas solicitadas o la fecha especificada.

Historia : Creado 09-08-2021
*/
DECLARE
    v_tipo_cambio numeric(8, 4);

BEGIN
    -- Si la moneda de origen es igual a la de destino devolvemos 1 de lo contrario buscamos
    IF p_codigo_moneda_origen != p_codigo_moneda_destino
    THEN
        select case
                   when p_is_compra = TRUE
                       then
                       tipo_cambio_tasa_compra
                   else
                       tipo_cambio_tasa_venta
                   end
        into v_tipo_cambio
        from tb_tipo_cambio
        where moneda_codigo_origen = p_codigo_moneda_origen
          AND moneda_codigo_destino = p_codigo_moneda_destino
          AND p_tcambio_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta;
    ELSE
        v_tipo_cambio := 1.0000;
    END IF;

    -- Si no se ha encontrado conversion retornamos -1
    IF v_tipo_cambio IS NULL
    THEN
        v_tipo_cambio := -1;
    END IF;

    return v_tipo_cambio;
END;

$$;


ALTER FUNCTION public.fn_get_tipo_cambio_conversion(p_codigo_moneda_origen character varying, p_codigo_moneda_destino character varying, p_tcambio_fecha date, p_is_compra boolean) OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 37590)
-- Name: fn_get_unidad_medida_conversion(character varying, character varying); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.fn_get_unidad_medida_conversion(p_unidad_medida_origen character varying, p_unidad_medida_destino character varying) RETURNS numeric
    LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 09-08-2021

Funcion que retorna la conversion entre ambas unidades  o -1 si no existe.

PARAMETROS :
p_unidad_medida_origen - Unidad de medida que se desea convertir
p_unidad_medida_destino - Unidad de medida a la que se desea convertir

RETURN:
	La conversion o
  -1 si no hay conversion entre las unidades de medidas solicitadas

Historia : Creado 09-08-2021
*/
DECLARE
    v_unidad_medida_conversion_factor numeric(12, 5);

BEGIN
    -- Calculamos el costo agregado especificamente a la unidad de costo.
    -- para lo cual buscamos la conversion de unidades.
    IF p_unidad_medida_origen != p_unidad_medida_destino
    THEN
        select unidad_medida_conversion_factor
        into v_unidad_medida_conversion_factor
        from tb_unidad_medida_conversion
        where unidad_medida_origen = p_unidad_medida_origen
          AND Unidad_medida_destino = p_unidad_medida_destino;
    ELSE
        v_unidad_medida_conversion_factor := 1;
    END IF;

    -- Si no se ha encontrado conversion retornamos -1
    IF v_unidad_medida_conversion_factor IS NULL
    THEN
        v_unidad_medida_conversion_factor := -1;
    END IF ;

    return v_unidad_medida_conversion_factor;
END;

$$;


ALTER FUNCTION public.fn_get_unidad_medida_conversion(p_unidad_medida_origen character varying, p_unidad_medida_destino character varying) OWNER TO clabsuser;

--
-- TOC entry 270 (class 1255 OID 18347)
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
-- TOC entry 308 (class 1255 OID 45927)
-- Name: sp_generate_costos_list_for_productos(character varying, date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_generate_costos_list_for_productos(p_list_descripcion character varying, p_d_fecha date, p_a_fecha date, p_tcambio_fecha date) RETURNS boolean
    LANGUAGE plpgsql
AS $$
    /**
    Autor : Carlos arana Reategui
    Fecha : 3-10-2016

    Stored procedureque generra la lista de costos para todos los producstos existentes.
    Generara entradas  en las tablas tb_costos_list y tb_costos_list_detalle

    PARAMETROS :
    p_list_descripcion - Texto que definira el titulo identificatorio  de la lista de costos generada..
    p_d_fecha - a partir de que fecha tomara en cuenta para los movimientos de ingreso de litros de productos y los costos globales asociados.
    p_a_fecha - a partir de que fecha tomara en cuenta para los movimientos de ingreso de litros de productos y los costos globales asociados.
    p_tcambio_fecha - Fecha a tomar para los tipos de cambio.

    RETURN:
      Nada , al terminar generara entradas en las tablas  tb_costos_list y tb_costos_list_detalle.
      En casode error abortara y enviara la excepcion..

    */
DECLARE
    v_sql            varchar;
    v_rec            RECORD;
    v_costo_total    numeric(10, 4);
    v_costo_base     numeric(10, 4);
    v_costo_agregado numeric(10, 4);
    v_save_header    bool := TRUE;
    v_last_header_id int;
BEGIN
    -- Chequeamos la fecha
    IF p_d_fecha > p_a_fecha
    THEN
        RAISE 'El rango de fechas esta mal definido la fecha inicial debe ser siempre menor o igual a la fecha final';
    END IF;

    -- Query que buscara todos los productos existentes y  obtendra los datos necesario para la salida.
    v_sql := 'SELECT insumo_id,insumo_descripcion,moneda_descripcion,taplicacion_entries_descripcion,u.unidad_medida_siglas,tpresentacion_cantidad_costo,insumo_cantidad_costo  FROM tb_insumo i  ' ||
             'inner join tb_moneda m on m.moneda_codigo = i.moneda_codigo_costo ' ||
             'inner join tb_taplicacion_entries a on a.taplicacion_entries_id = i.taplicacion_entries_id  ' ||
             'inner join tb_tpresentacion tp on tp.tpresentacion_codigo = i.tpresentacion_codigo  ' ||
             'inner join tb_unidad_medida  u on u.unidad_medida_codigo = tp.unidad_medida_codigo_costo  ' ||
             ' WHERE insumo_tipo = ''PR'' ;';

    FOR v_rec IN EXECUTE v_sql
        LOOP
            IF v_save_header = TRUE
            THEN
                -- Insertamos la cabecera en tb_costos_list, solo  una vez
                INSERT INTO tb_costos_list (costos_list_descripcion, costos_list_fecha, costos_list_fecha_desde, costos_list_fecha_hasta, costos_list_fecha_tcambio)
                VALUES (p_list_descripcion, NOW(), p_d_fecha, p_a_fecha, p_tcambio_fecha)
                RETURNING costos_list_id INTO v_last_header_id;
                v_save_header := FALSE;
            END IF;

            --  Solicitamos los costos del cproducto.
            SELECT
                fp.r_costo_base,
                fp.r_costo_agregado,
                fp.r_costo_total
            INTO v_costo_base,v_costo_agregado,v_costo_total
            FROM fn_get_producto_costo_total(v_rec.insumo_id, p_d_fecha, p_a_fecha, p_tcambio_fecha) fp;

            -- insertamos los detalles para cada producto en la tabla tb_costos_list_detalle
            INSERT INTO tb_costos_list_detalle (costos_list_id, insumo_id, insumo_descripcion, moneda_descripcion, taplicacion_entries_descripcion, costos_list_detalle_qty_presentacion,
                                                unidad_medida_siglas, costos_list_detalle_costo_base, costos_list_detalle_costo_agregado,
                                                costos_list_detalle_costo_total)
            VALUES (v_last_header_id, v_rec.insumo_id, v_rec.insumo_descripcion, v_rec.moneda_descripcion, v_rec.taplicacion_entries_descripcion, v_rec.tpresentacion_cantidad_costo,
                    v_rec.unidad_medida_siglas, v_costo_base, v_costo_agregado, v_costo_total);
        END LOOP;
    RETURN TRUE;
END;
$$;


ALTER FUNCTION public.sp_generate_costos_list_for_productos(p_list_descripcion character varying, p_d_fecha date, p_a_fecha date, p_tcambio_fecha date) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 18348)
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
-- TOC entry 272 (class 1255 OID 18352)
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
DECLARE v_insumo_tipo character varying(2);
BEGIN
    -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
    -- y obtenemos ademas el tipo de insumo.
    select  i.insumo_tipo
    into v_insumo_tipo
    from tb_insumo i
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
        where insumo_id_origen = p_insumo_id and ins.insumo_tipo='PR' ;
END;
$$;


ALTER FUNCTION public.sp_get_datos_insumos_for_producto(p_insumo_id integer) OWNER TO clabsuser;

--
-- TOC entry 273 (class 1255 OID 18355)
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
DECLARE v_insumo_tipo character varying(2);
BEGIN
    -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
    -- y obtenemos ademas el tipo de insumo.
    select  i.insumo_tipo
    into v_insumo_tipo
    from tb_insumo i
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
        where insumo_id_origen = p_insumo_id and ins.insumo_tipo='PR';
END;
$$;


ALTER FUNCTION public.sp_get_insumos_for_producto(p_insumo_id integer) OWNER TO clabsuser;

--
-- TOC entry 306 (class 1255 OID 45841)
-- Name: sp_get_insumos_for_producto(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_insumos_for_producto(p_d_fecha date, p_a_fecha date, p_tcambio_fecha date) RETURNS TABLE(r_insumo_descripcion character varying, r_taplicacion_descripcion character varying, r_costo_base numeric, r_costo_agregado numeric, r_costo_total numeric)
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
BEGIN
    RETURN QUERY SELECT fn_get_producto_costo_total(61, '01/01/2021', '31/12/2021', '24/07/2021') FROM tb_insumo WHERE insumo_tipo = 'PR';
END;
$$;


ALTER FUNCTION public.sp_get_insumos_for_producto(p_d_fecha date, p_a_fecha date, p_tcambio_fecha date) OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 54167)
-- Name: sp_get_insumos_for_producto_detalle(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sp_get_insumos_for_producto_detalle(p_product_header_id integer, pc_insumo_id integer, p_insumo_descripcion character varying, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_id integer, insumo_tipo character varying, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo_costo character varying, insumo_merma numeric, insumo_costo numeric, insumo_precio_mercado numeric, moneda_simbolo character varying, tcostos_indirecto boolean)
    LANGUAGE plpgsql STABLE
AS $_$
    /**
    Autor : Carlos arana Reategui
    Fecha : 28-09-2016

    Stored procedure que retorna todos los posibles insumos o productos que pueden ser parte de un detalle
    de producto.

    En el caso pc_insumo_id no sea null se retornara el insumo/producto que corresponde solo a ese id y se ignoraran
    todos los demas parametros.


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

DECLARE v_insumo_tipo character varying(2);

BEGIN
    IF pc_insumo_id IS NOT NULL
    THEN
        return QUERY
            select
                ins.insumo_id as insumo_id,
                ins.insumo_tipo as insumo_tipo,
                ins.insumo_codigo as insumo_codigo,
                ins.insumo_descripcion as insumo_descripcion,
                case when ins.insumo_tipo = 'IN'
                         THEN
                         ins.unidad_medida_codigo_costo
                     else
                         (select tp.unidad_medida_codigo_costo from tb_tpresentacion tp where tp.tpresentacion_codigo = ins.tpresentacion_codigo)
                    end as unidad_medida_codigo_costo,
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
                      inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo
            where ins.insumo_id = pc_insumo_id;
    ELSE
        -- Determinamos a que empresa corresponde este producto principal (representado por insumo_id)
        -- y obtenemos ademas el tipo de empresa.
        select i.insumo_tipo
        into v_insumo_tipo
        from tb_insumo i
        where i.insumo_id = p_product_header_id;

        -- El id del insumo del header debera ser siempre un producto.
        IF coalesce(v_insumo_tipo,'') != 'PR'
        THEN
            RAISE 'Para la lista de items elegibles se requiere un codigo de producto no de insumo' USING ERRCODE = 'restrict_violation';
        END IF;

        -- Al ser producto la unidad de medida de costo nace de la presentacion del producto.
        return QUERY
            EXECUTE
            format(
                    'select
                            ins.insumo_id as insumo_id,
                            ins.insumo_tipo as insumo_tipo,
                            ins.insumo_codigo as insumo_codigo,
                            ins.insumo_descripcion as insumo_descripcion,
                            tp.unidad_medida_codigo_costo as unidad_medida_codigo_costo,
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
                            inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo
                            inner join tb_tpresentacion tp on tp.tpresentacion_codigo = ins.tpresentacion_codigo
                        where ins.activo = true
                            and ins.insumo_id != %1$s
                            and  ins.activo = true
                            and ins.insumo_id not in (select pd.insumo_id from tb_producto_detalle pd where pd.insumo_id_origen = %1$s)
                            and (case when %2$L IS NOT NULL then ins.insumo_descripcion ilike  ''%%%2$s%%'' else TRUE end)
                        ORDER BY ins.insumo_descripcion
                        LIMIT COALESCE($1, 1000 ) OFFSET coalesce($2,0)
                    ',p_product_header_id,p_insumo_descripcion
                )
            USING p_max_results,p_offset;
    END IF;

END;
$_$;


ALTER FUNCTION public.sp_get_insumos_for_producto_detalle(p_product_header_id integer, pc_insumo_id integer, p_insumo_descripcion character varying, p_max_results integer, p_offset integer) OWNER TO clabsuser;

--
-- TOC entry 275 (class 1255 OID 18366)
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
-- TOC entry 276 (class 1255 OID 18367)
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
-- TOC entry 277 (class 1255 OID 18368)
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
-- TOC entry 278 (class 1255 OID 18371)
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
-- TOC entry 279 (class 1255 OID 18382)
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
-- TOC entry 280 (class 1255 OID 18383)
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
-- TOC entry 307 (class 1255 OID 18386)
-- Name: sptrg_insumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_insumo_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$
DECLARE
    v_insumo_codigo character varying(15);
    v_tcostos_indirecto BOOLEAN;
    v_tpresentacion_cantidad_costo NUMERIC(10,2);
    v_tpresentacion_descripcion VARCHAR(60);
    v_unidad_medida_codigo_costo VARCHAR(8);


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
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE')
    THEN
        v_unidad_medida_codigo_costo :=  NEW.unidad_medida_codigo_costo;

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
            IF NEW.taplicacion_entries_id ISNULL THEN RAISE 'Un producto debe indicar a que tipo de aplicacion pertenece' USING ERRCODE = 'restrict_violation'; END IF;

            -- Se valida si es un producto que indique a que tipo de presentacion pertenece el mismo , para un insumo
            -- esto es irrelevante.
            IF NEW.tpresentacion_codigo ISNULL THEN RAISE 'Un producto debe indicar su tipo de presentacion' USING ERRCODE = 'restrict_violation'; END IF;

            SELECT
                tpresentacion_descripcion,
                tpresentacion_cantidad_costo,
                unidad_medida_codigo_costo
            INTO v_tpresentacion_descripcion,v_tpresentacion_cantidad_costo,v_unidad_medida_codigo_costo
            FROM tb_tpresentacion
            WHERE tpresentacion_codigo = NEW.tpresentacion_codigo;

            -- Se valida si es un producto que indique a que tipo de aplicacion pertenece el mismo , para un insumo
            -- esto es irrelevante.
            IF COALESCE(v_tpresentacion_cantidad_costo, 0) <= 0.00
            THEN
                RAISE 'La cantidad base del costo  especificada en la presentacion % debe ser mayor que 0.00',v_tpresentacion_descripcion USING ERRCODE = 'restrict_violation';
            END IF;

        ELSE -- En el caso que sea un insumo y el tipo de costo es indirecto
        -- la unidad de codigo ingreso y la merma no tienen sentido y son colocados
        -- con los valores neutros.
            SELECT tcostos_indirecto INTO v_tcostos_indirecto FROM tb_tcostos WHERE tcostos_codigo = NEW.tcostos_codigo;

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

        IF  v_unidad_medida_codigo_costo= 'NING' OR v_unidad_medida_codigo_costo ISNULL  THEN RAISE 'La unidad de medida del costo debe estar definida' USING ERRCODE = 'restrict_violation'; END IF;

        -- Verificamos si alguno con el mismo nombre existe e indicamos el error.
        SELECT insumo_codigo INTO v_insumo_codigo FROM tb_insumo WHERE UPPER(LTRIM(RTRIM(insumo_descripcion))) = UPPER(LTRIM(RTRIM(NEW.insumo_descripcion)));

        IF NEW.insumo_codigo != v_insumo_codigo
        THEN
            -- Excepcion de region con ese nombre existe
            RAISE 'Ya existe una insumo con ese nombre en el insumo [%]',v_insumo_codigo USING ERRCODE = 'restrict_violation';
        END IF;


        -- Validamos que exista la  conversion entre medidas siempre que sea insumo no producto , ya que los productos
        -- no tienen unidad de ingreso.
        IF NEW.insumo_tipo = 'IN' AND NEW.unidad_medida_codigo_ingreso != 'NING' AND NEW.unidad_medida_codigo_costo != 'NING' AND NEW.unidad_medida_codigo_ingreso != NEW.unidad_medida_codigo_costo AND
           NOT EXISTS(SELECT 1 FROM tb_unidad_medida_conversion WHERE unidad_medida_origen = NEW.unidad_medida_codigo_ingreso AND unidad_medida_destino = NEW.unidad_medida_codigo_costo LIMIT 1)
        THEN
            RAISE 'Debera existir la conversion entre las unidades de medidas indicadas [% - %]',NEW.unidad_medida_codigo_ingreso,NEW.unidad_medida_codigo_costo USING ERRCODE = 'restrict_violation';
        END IF;

    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_insumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 281 (class 1255 OID 18389)
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
-- TOC entry 282 (class 1255 OID 18390)
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
-- TOC entry 283 (class 1255 OID 18391)
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
-- TOC entry 310 (class 1255 OID 18392)
-- Name: sptrg_producto_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION public.sptrg_producto_detalle_validate_save() RETURNS trigger
    LANGUAGE plpgsql
AS $$ -------------------------------------------------------------------------------------------
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


BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.insumo_id = NEW.insumo_id_origen
        THEN
            RAISE 'Un componente no puede ser igual al producto principal' USING ERRCODE = 'restrict_violation';
        END IF;


        --No se puede agregar un producto como item si es que este mismo contiene al producto
        -- principal.
        IF EXISTS(select 1 from tb_producto_detalle where insumo_id_origen = NEW.insumo_id and insumo_id = NEW.insumo_id_origen LIMIT 1)
        THEN
            RAISE 'Este item contiene a este producto lo cual no es posible' USING ERRCODE = 'restrict_violation';
        END IF;

        -- leemos datos para validacion
        SELECT
            -- Si es insumo la unifdad de costo sale de el mismo de ser producto sale de la presentacion.
            case when ins.insumo_tipo = 'IN'
                     THEN
                     ins.unidad_medida_codigo_costo
                 ELSE
                     (select tp.unidad_medida_codigo_costo from tb_tpresentacion tp  where tp.tpresentacion_codigo = ins.tpresentacion_codigo)
                END as unidad_medida_codigo_costo,
            insumo_tipo,
            tcostos_indirecto
        INTO v_unidad_medida_codigo_costo,v_insumo_tipo,v_tcostos_indirecto
        FROM
            tb_insumo ins
                INNER JOIN tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
        WHERE insumo_id = NEW.insumo_id;



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
-- TOC entry 284 (class 1255 OID 18393)
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
-- TOC entry 285 (class 1255 OID 18394)
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
-- TOC entry 286 (class 1255 OID 18396)
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
-- TOC entry 287 (class 1255 OID 18397)
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
-- TOC entry 288 (class 1255 OID 18398)
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
-- TOC entry 289 (class 1255 OID 18399)
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
-- TOC entry 290 (class 1255 OID 18400)
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
-- TOC entry 291 (class 1255 OID 18401)
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
-- TOC entry 292 (class 1255 OID 18402)
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
-- TOC entry 293 (class 1255 OID 18403)
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
-- TOC entry 294 (class 1255 OID 18404)
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
-- TOC entry 295 (class 1255 OID 18405)
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
-- TOC entry 296 (class 1255 OID 18406)
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
-- TOC entry 297 (class 1255 OID 18407)
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
-- TOC entry 298 (class 1255 OID 18408)
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
-- TOC entry 299 (class 1255 OID 18409)
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
-- TOC entry 300 (class 1255 OID 18410)
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
-- TOC entry 301 (class 1255 OID 18411)
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
-- TOC entry 302 (class 1255 OID 18412)
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
-- TOC entry 303 (class 1255 OID 18413)
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

SET default_table_access_method = heap;

--
-- TOC entry 202 (class 1259 OID 18414)
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
-- TOC entry 203 (class 1259 OID 18433)
-- Name: tb_costos_list; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_costos_list (
                                       costos_list_id integer NOT NULL,
                                       costos_list_descripcion character varying(60) NOT NULL,
                                       costos_list_fecha timestamp without time zone NOT NULL,
                                       costos_list_fecha_desde date NOT NULL,
                                       costos_list_fecha_hasta date NOT NULL,
                                       costos_list_fecha_tcambio date NOT NULL,
                                       CONSTRAINT chk_costos_list_field_len CHECK ((length(rtrim((costos_list_descripcion)::text)) > 0))
);


ALTER TABLE public.tb_costos_list OWNER TO clabsuser;

--
-- TOC entry 204 (class 1259 OID 18438)
-- Name: tb_costos_list_costos_list_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_costos_list_costos_list_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_costos_list_costos_list_id_seq OWNER TO clabsuser;

--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 204
-- Name: tb_costos_list_costos_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_costos_list_costos_list_id_seq OWNED BY public.tb_costos_list.costos_list_id;


--
-- TOC entry 254 (class 1259 OID 45907)
-- Name: tb_costos_list_detalle; Type: TABLE; Schema: public; Owner: clabsuser
--

CREATE TABLE public.tb_costos_list_detalle (
                                               costos_list_detalle_id integer NOT NULL,
                                               costos_list_id integer NOT NULL,
                                               insumo_id integer NOT NULL,
                                               insumo_descripcion character varying(60) NOT NULL,
                                               moneda_descripcion character varying(80) NOT NULL,
                                               taplicacion_entries_descripcion character varying(80) NOT NULL,
                                               unidad_medida_siglas character varying(8) NOT NULL,
                                               costos_list_detalle_qty_presentacion numeric(10,2) NOT NULL,
                                               costos_list_detalle_costo_base numeric(12,2),
                                               costos_list_detalle_costo_agregado numeric(12,2),
                                               costos_list_detalle_costo_total numeric(12,2)
);


ALTER TABLE public.tb_costos_list_detalle OWNER TO clabsuser;

--
-- TOC entry 253 (class 1259 OID 45905)
-- Name: tb_costos_list_detalle_costos_list_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_costos_list_detalle_costos_list_detalle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_costos_list_detalle_costos_list_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 253
-- Name: tb_costos_list_detalle_costos_list_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_costos_list_detalle_costos_list_detalle_id_seq OWNED BY public.tb_costos_list_detalle.costos_list_detalle_id;


--
-- TOC entry 205 (class 1259 OID 18463)
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
-- TOC entry 206 (class 1259 OID 18471)
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
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 206
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_empresa_empresa_id_seq OWNED BY public.tb_empresa.empresa_id;


--
-- TOC entry 207 (class 1259 OID 18473)
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
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE tb_entidad; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE public.tb_entidad IS 'Datos generales de la entidad que usa el sistema';


--
-- TOC entry 208 (class 1259 OID 18480)
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
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 208
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_entidad_entidad_id_seq OWNED BY public.tb_entidad.entidad_id;


--
-- TOC entry 209 (class 1259 OID 18482)
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
-- TOC entry 210 (class 1259 OID 18492)
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
                                  unidad_medida_codigo_costo character varying(8),
                                  insumo_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
                                  insumo_costo numeric(10,4) DEFAULT 0.00,
                                  moneda_codigo_costo character varying(8) NOT NULL,
                                  activo boolean,
                                  usuario character varying(15),
                                  fecha_creacion timestamp without time zone,
                                  usuario_mod character varying(15),
                                  fecha_modificacion timestamp without time zone,
                                  insumo_precio_mercado numeric(10,2) DEFAULT 0 NOT NULL,
                                  taplicacion_entries_id integer,
                                  insumo_cantidad_costo numeric(10,2) DEFAULT 0,
                                  tpresentacion_codigo character varying(15),
                                  CONSTRAINT chk_insumo_costo CHECK (
                                      CASE
                                          WHEN ((insumo_tipo)::text = 'IN'::text) THEN (insumo_costo IS NOT NULL)
                                          ELSE (insumo_costo = NULL::numeric)
                                          END),
                                  CONSTRAINT chk_insumo_field_len CHECK (((length(rtrim((insumo_codigo)::text)) > 0) AND (length(rtrim((insumo_descripcion)::text)) > 0))),
                                  CONSTRAINT chk_insumo_merma CHECK ((insumo_merma >= 0.00)),
                                  CONSTRAINT chk_insumo_pmercado CHECK ((insumo_precio_mercado >= 0.00)),
                                  CONSTRAINT chk_insumo_tipo CHECK ((((insumo_tipo)::text = 'IN'::text) OR ((insumo_tipo)::text = 'PR'::text))),
                                  CONSTRAINT chk_insumo_tpresentacion_codigo CHECK (
                                      CASE
                                          WHEN ((insumo_tipo)::text = 'PR'::text) THEN (tpresentacion_codigo IS NOT NULL)
                                          ELSE ((tpresentacion_codigo)::text = NULL::text)
                                          END),
                                  CONSTRAINT chk_insumo_unidad_medida_costo CHECK (
                                      CASE
                                          WHEN ((insumo_tipo)::text = 'IN'::text) THEN (unidad_medida_codigo_costo IS NOT NULL)
                                          ELSE ((unidad_medida_codigo_costo)::text = NULL::text)
                                          END)
);


ALTER TABLE public.tb_insumo OWNER TO clabsuser;

--
-- TOC entry 211 (class 1259 OID 18523)
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE public.tb_insumo_insumo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_insumo_insumo_id_seq OWNER TO clabsuser;

--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 211
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_insumo_insumo_id_seq OWNED BY public.tb_insumo.insumo_id;


--
-- TOC entry 212 (class 1259 OID 18525)
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
-- TOC entry 213 (class 1259 OID 18531)
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
-- TOC entry 214 (class 1259 OID 18536)
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
-- TOC entry 215 (class 1259 OID 18542)
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
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 215
-- Name: tb_produccion_produccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_produccion_produccion_id_seq OWNED BY public.tb_produccion.produccion_id;


--
-- TOC entry 216 (class 1259 OID 18544)
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
                                            CONSTRAINT chk_producto_detalle_cantidad CHECK ((producto_detalle_cantidad > 0.00)),
                                            CONSTRAINT chk_producto_detalle_merma CHECK ((producto_detalle_merma >= 0.00))
);


ALTER TABLE public.tb_producto_detalle OWNER TO clabsuser;

--
-- TOC entry 217 (class 1259 OID 18552)
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
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 217
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_producto_detalle_producto_detalle_id_seq OWNED BY public.tb_producto_detalle.producto_detalle_id;


--
-- TOC entry 218 (class 1259 OID 18554)
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
-- TOC entry 219 (class 1259 OID 18557)
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
-- TOC entry 220 (class 1259 OID 18561)
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
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 220
-- Name: tb_producto_procesos_detalle_producto_procesos_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq OWNED BY public.tb_producto_procesos_detalle.producto_procesos_detalle_id;


--
-- TOC entry 221 (class 1259 OID 18563)
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
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 221
-- Name: tb_producto_procesos_producto_procesos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_producto_procesos_producto_procesos_id_seq OWNED BY public.tb_producto_procesos.producto_procesos_id;


--
-- TOC entry 222 (class 1259 OID 18572)
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
-- TOC entry 223 (class 1259 OID 18577)
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
-- TOC entry 224 (class 1259 OID 18582)
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
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 224
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_menu_menu_id_seq OWNED BY public.tb_sys_menu.menu_id;


--
-- TOC entry 225 (class 1259 OID 18584)
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
-- TOC entry 226 (class 1259 OID 18588)
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
-- TOC entry 227 (class 1259 OID 18597)
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
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 227
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_perfil_detalle_perfdet_id_seq OWNED BY public.tb_sys_perfil_detalle.perfdet_id;


--
-- TOC entry 228 (class 1259 OID 18599)
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
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 228
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_perfil_id_seq OWNED BY public.tb_sys_perfil.perfil_id;


--
-- TOC entry 229 (class 1259 OID 18601)
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
-- TOC entry 230 (class 1259 OID 18605)
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
-- TOC entry 231 (class 1259 OID 18609)
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
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 231
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNED BY public.tb_sys_usuario_perfiles.usuario_perfil_id;


--
-- TOC entry 232 (class 1259 OID 18611)
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
-- TOC entry 233 (class 1259 OID 18616)
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
-- TOC entry 234 (class 1259 OID 18620)
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
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 234
-- Name: tb_taplicacion_entries_taplicacion_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_taplicacion_entries_taplicacion_entries_id_seq OWNED BY public.tb_taplicacion_entries.taplicacion_entries_id;


--
-- TOC entry 235 (class 1259 OID 18622)
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
-- TOC entry 236 (class 1259 OID 18625)
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
-- TOC entry 237 (class 1259 OID 18629)
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
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 237
-- Name: tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq OWNED BY public.tb_taplicacion_procesos_detalle.taplicacion_procesos_detalle_id;


--
-- TOC entry 238 (class 1259 OID 18631)
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
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 238
-- Name: tb_taplicacion_procesos_taplicacion_procesos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_taplicacion_procesos_taplicacion_procesos_id_seq OWNED BY public.tb_taplicacion_procesos.taplicacion_procesos_id;


--
-- TOC entry 239 (class 1259 OID 18633)
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
-- TOC entry 240 (class 1259 OID 18639)
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
-- TOC entry 241 (class 1259 OID 18643)
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
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 241
-- Name: tb_tcosto_global_entries_tcosto_global_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_tcosto_global_entries_tcosto_global_entries_id_seq OWNED BY public.tb_tcosto_global_entries.tcosto_global_entries_id;


--
-- TOC entry 242 (class 1259 OID 18645)
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
-- TOC entry 243 (class 1259 OID 18652)
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
-- TOC entry 244 (class 1259 OID 18658)
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
-- TOC entry 245 (class 1259 OID 18664)
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
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 245
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_tipo_cambio_tipo_cambio_id_seq OWNED BY public.tb_tipo_cambio.tipo_cambio_id;


--
-- TOC entry 246 (class 1259 OID 18672)
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
-- TOC entry 247 (class 1259 OID 18678)
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
                                         tpresentacion_cantidad_costo numeric(10,2) NOT NULL,
                                         unidad_medida_codigo_costo character varying(8) NOT NULL,
                                         CONSTRAINT chk_cantidad_costo_field_value CHECK ((tpresentacion_cantidad_costo > (0)::numeric)),
                                         CONSTRAINT chk_tpresentacion_field_len CHECK (((length(rtrim((tpresentacion_codigo)::text)) > 0) AND (length(rtrim((tpresentacion_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tpresentacion OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 18684)
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
-- TOC entry 249 (class 1259 OID 18692)
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
-- TOC entry 250 (class 1259 OID 18697)
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
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 250
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNED BY public.tb_unidad_medida_conversion.unidad_medida_conversion_id;


--
-- TOC entry 251 (class 1259 OID 18699)
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
                                    fecha_modificacion time without time zone
);


ALTER TABLE public.tb_usuarios OWNER TO atluser;

--
-- TOC entry 252 (class 1259 OID 18705)
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
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 252
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE public.tb_usuarios_usuarios_id_seq OWNED BY public.tb_usuarios.usuarios_id;


--
-- TOC entry 3048 (class 2604 OID 18714)
-- Name: tb_costos_list costos_list_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list ALTER COLUMN costos_list_id SET DEFAULT nextval('public.tb_costos_list_costos_list_id_seq'::regclass);


--
-- TOC entry 3146 (class 2604 OID 45910)
-- Name: tb_costos_list_detalle costos_list_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list_detalle ALTER COLUMN costos_list_detalle_id SET DEFAULT nextval('public.tb_costos_list_detalle_costos_list_detalle_id_seq'::regclass);


--
-- TOC entry 3051 (class 2604 OID 18718)
-- Name: tb_empresa empresa_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_empresa ALTER COLUMN empresa_id SET DEFAULT nextval('public.tb_empresa_empresa_id_seq'::regclass);


--
-- TOC entry 3054 (class 2604 OID 18719)
-- Name: tb_entidad entidad_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_entidad ALTER COLUMN entidad_id SET DEFAULT nextval('public.tb_entidad_entidad_id_seq'::regclass);


--
-- TOC entry 3062 (class 2604 OID 18720)
-- Name: tb_insumo insumo_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo ALTER COLUMN insumo_id SET DEFAULT nextval('public.tb_insumo_insumo_id_seq'::regclass);


--
-- TOC entry 3077 (class 2604 OID 18723)
-- Name: tb_produccion produccion_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion ALTER COLUMN produccion_id SET DEFAULT nextval('public.tb_produccion_produccion_id_seq'::regclass);


--
-- TOC entry 3082 (class 2604 OID 18724)
-- Name: tb_producto_detalle producto_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle ALTER COLUMN producto_detalle_id SET DEFAULT nextval('public.tb_producto_detalle_producto_detalle_id_seq'::regclass);


--
-- TOC entry 3085 (class 2604 OID 18725)
-- Name: tb_producto_procesos producto_procesos_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos ALTER COLUMN producto_procesos_id SET DEFAULT nextval('public.tb_producto_procesos_producto_procesos_id_seq'::regclass);


--
-- TOC entry 3086 (class 2604 OID 18726)
-- Name: tb_producto_procesos_detalle producto_procesos_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle ALTER COLUMN producto_procesos_detalle_id SET DEFAULT nextval('public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq'::regclass);


--
-- TOC entry 3092 (class 2604 OID 18728)
-- Name: tb_sys_menu menu_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu ALTER COLUMN menu_id SET DEFAULT nextval('public.tb_sys_menu_menu_id_seq'::regclass);


--
-- TOC entry 3094 (class 2604 OID 18729)
-- Name: tb_sys_perfil perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil ALTER COLUMN perfil_id SET DEFAULT nextval('public.tb_sys_perfil_id_seq'::regclass);


--
-- TOC entry 3101 (class 2604 OID 18730)
-- Name: tb_sys_perfil_detalle perfdet_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil_detalle ALTER COLUMN perfdet_id SET DEFAULT nextval('public.tb_sys_perfil_detalle_perfdet_id_seq'::regclass);


--
-- TOC entry 3104 (class 2604 OID 18731)
-- Name: tb_sys_usuario_perfiles usuario_perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles ALTER COLUMN usuario_perfil_id SET DEFAULT nextval('public.tb_sys_usuario_perfiles_usuario_perfil_id_seq'::regclass);


--
-- TOC entry 3107 (class 2604 OID 18732)
-- Name: tb_taplicacion_entries taplicacion_entries_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_taplicacion_entries ALTER COLUMN taplicacion_entries_id SET DEFAULT nextval('public.tb_taplicacion_entries_taplicacion_entries_id_seq'::regclass);


--
-- TOC entry 3109 (class 2604 OID 18733)
-- Name: tb_taplicacion_procesos taplicacion_procesos_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos ALTER COLUMN taplicacion_procesos_id SET DEFAULT nextval('public.tb_taplicacion_procesos_taplicacion_procesos_id_seq'::regclass);


--
-- TOC entry 3110 (class 2604 OID 18734)
-- Name: tb_taplicacion_procesos_detalle taplicacion_procesos_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle ALTER COLUMN taplicacion_procesos_detalle_id SET DEFAULT nextval('public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq'::regclass);


--
-- TOC entry 3115 (class 2604 OID 18735)
-- Name: tb_tcosto_global_entries tcosto_global_entries_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries ALTER COLUMN tcosto_global_entries_id SET DEFAULT nextval('public.tb_tcosto_global_entries_tcosto_global_entries_id_seq'::regclass);


--
-- TOC entry 3125 (class 2604 OID 18736)
-- Name: tb_tipo_cambio tipo_cambio_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio ALTER COLUMN tipo_cambio_id SET DEFAULT nextval('public.tb_tipo_cambio_tipo_cambio_id_seq'::regclass);


--
-- TOC entry 3141 (class 2604 OID 18737)
-- Name: tb_unidad_medida_conversion unidad_medida_conversion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion ALTER COLUMN unidad_medida_conversion_id SET DEFAULT nextval('public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq'::regclass);


--
-- TOC entry 3145 (class 2604 OID 18738)
-- Name: tb_usuarios usuarios_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_usuarios ALTER COLUMN usuarios_id SET DEFAULT nextval('public.tb_usuarios_usuarios_id_seq'::regclass);


--
-- TOC entry 3490 (class 0 OID 18414)
-- Dependencies: 202
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
-- TOC entry 3491 (class 0 OID 18433)
-- Dependencies: 203
-- Data for Name: tb_costos_list; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_costos_list (costos_list_id, costos_list_descripcion, costos_list_fecha, costos_list_fecha_desde, costos_list_fecha_hasta, costos_list_fecha_tcambio) FROM stdin;
27	Este es un test	2021-08-19 07:40:23.085316	2021-01-01	2021-12-31	2021-07-24
28	Test inicial	2021-08-20 17:20:14.99566	2021-01-01	2021-12-31	2021-07-24
29	dsdasdasdad	2021-08-20 17:28:27.425597	2021-03-01	2021-08-20	2021-07-24
31	sdfsfsdfds	2021-08-20 17:38:08.996206	2021-03-01	2021-08-20	2021-07-24
32	Este es un test	2021-08-20 22:53:08.665393	2021-01-01	2021-12-31	2021-07-24
33	vbvbfgb	2021-08-20 17:53:38.743005	2021-05-03	2021-08-20	2021-07-24
34	fghfgfgh	2021-08-20 18:01:39.031777	2021-05-03	2021-08-20	2021-07-24
35	bfgghfghdfg	2021-08-20 18:03:12.295976	2021-06-07	2021-08-20	2021-07-24
36	rertertertertret	2021-08-20 18:03:29.391576	2021-05-03	2021-08-20	2021-07-24
37	vbbvdfgdfg	2021-08-20 18:06:02.456285	2021-02-09	2021-08-20	2021-07-24
38	bbbbbbbbbbbbbbbbbbbbbbbb	2021-08-20 18:06:36.108958	2021-04-05	2021-08-20	2021-07-24
39	dsfsdffsd	2021-08-20 18:06:57.619844	2021-04-05	2021-08-20	2021-07-30
40	zxzxczxczx	2021-08-20 18:07:40.977189	2021-06-01	2021-08-20	2021-08-26
43	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	2021-08-20 21:04:47.89348	2021-04-05	2021-08-20	2021-07-24
44	asasasasasasasasasasasasasasasasasasasasasasasasasasasasasas	2021-08-20 21:05:38.46699	2021-07-05	2021-08-20	2021-08-20
46	Este es un test	2021-08-21 02:21:19.735669	2021-01-01	2021-12-31	2021-07-24
47	ertertert	2021-08-20 21:21:38.990361	2021-04-12	2021-08-20	2021-07-24
48	Este es un test	2021-08-21 02:23:04.552845	2021-01-01	2021-12-31	2021-07-24
49	fffffffffffffffffffffffffffff	2021-08-20 21:24:02.518295	2021-07-05	2021-08-20	2021-07-24
50	dfferfert	2021-08-21 02:30:53.721853	2021-04-06	2021-08-21	2021-07-24
51	erertertert	2021-08-21 02:31:31.335384	2021-06-07	2021-08-21	2021-07-24
52	dfsfsrfewewr	2021-08-21 02:55:08.092697	2021-03-01	2021-08-21	2021-07-24
53	werwrwer	2021-08-21 02:55:50.444457	2021-05-03	2021-08-21	2021-07-24
54	fghdhdh	2021-08-21 02:57:25.590425	2021-05-04	2021-08-21	2021-07-24
55	tyututyutyu	2021-08-21 03:03:22.725276	2021-04-26	2021-08-21	2021-07-24
56	erteterte	2021-08-21 03:13:41.615001	2021-03-01	2021-08-21	2021-07-24
57	htutyutyu	2021-08-21 03:27:50.321343	2021-05-03	2021-08-21	2021-07-24
58	ytutrutyuty	2021-08-21 03:29:21.138546	2021-02-02	2021-08-21	2021-07-24
59	ertertertret	2021-08-21 03:47:26.513775	2021-08-11	2021-08-18	2021-08-02
60	ert	2021-08-21 03:47:43.107272	2021-08-02	2021-08-09	2021-08-09
61	dfgerterty	2021-08-21 04:12:16.743448	2021-05-04	2021-08-21	2021-07-24
62	eryeryerye	2021-08-21 04:12:44.983852	2021-08-03	2021-08-21	2021-07-24
63	ertertert	2021-08-21 23:41:46.377085	2021-08-10	2021-08-21	2021-08-10
64	rtyrtytyrty	2021-08-22 01:14:32.534534	2021-03-01	2021-08-11	2021-07-24
65	rtyrtytry	2021-08-22 01:15:40.104674	2021-02-02	2021-08-22	2021-07-24
66	rtyrtyrtytry	2021-08-22 01:16:16.290308	2021-05-03	2021-08-22	2021-07-24
67	sdfsdfsa	2021-08-22 14:36:30.738799	2021-08-04	2021-08-22	2021-08-10
68	tyhkjhkjh  hgjg 99999	2021-08-23 02:36:36.716099	2021-08-05	2021-08-09	2021-08-02
69	sadfdsfsd 3299	2021-08-23 02:37:22.102645	2021-08-04	2021-08-23	2021-07-24
70	rttyurtyuty	2021-08-23 15:59:37.074086	2021-03-08	2021-08-23	2021-07-24
71	erwerwerwer	2021-08-23 16:00:13.796942	2021-01-04	2021-08-23	2021-07-24
72	List De Costos Agosto  2021	2021-08-24 02:37:49.635033	2021-05-03	2021-08-24	2021-07-24
73	Lista Especial Enero	2021-08-29 14:54:52.195933	2021-03-02	2021-08-29	2021-07-24
74	Esta es un lista para pruebas	2021-08-29 15:09:41.965746	2021-04-06	2021-08-29	2021-07-24
75	Estes es un nuvo Test	2021-08-29 15:21:27.428734	2021-01-06	2021-08-29	2021-07-24
76	Este es un test 3	2021-08-29 15:26:29.373932	2021-04-06	2021-08-29	2021-07-24
77	rtyrtrtyrtyrty	2021-09-05 19:03:42.703626	2020-12-07	2021-09-05	2021-07-24
78	check 1	2021-09-06 01:14:29.044316	2021-04-05	2021-09-06	2021-07-24
79	ultim o 1	2021-09-06 15:28:54.135774	2021-02-08	2021-09-06	2021-07-24
80	uiou8ouio	2021-09-06 15:46:59.18209	2021-02-01	2021-09-06	2021-09-06
81	tryrty	2021-09-06 19:23:52.803916	2021-04-21	2021-09-06	2021-09-06
\.


--
-- TOC entry 3542 (class 0 OID 45907)
-- Dependencies: 254
-- Data for Name: tb_costos_list_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_costos_list_detalle (costos_list_detalle_id, costos_list_id, insumo_id, insumo_descripcion, moneda_descripcion, taplicacion_entries_descripcion, unidad_medida_siglas, costos_list_detalle_qty_presentacion, costos_list_detalle_costo_base, costos_list_detalle_costo_agregado, costos_list_detalle_costo_total) FROM stdin;
3	27	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
4	27	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
5	28	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
6	28	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
7	29	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
8	29	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
9	31	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
10	31	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
11	32	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
12	32	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
13	33	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
14	33	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
15	34	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
16	34	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
17	35	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
18	35	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
19	36	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
20	36	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
21	37	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
22	37	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
23	38	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
24	38	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
25	39	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
26	39	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
27	40	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
28	40	61	Producto 12	Dolares	test2	ML	100.00	-1.00	\N	0.00
33	43	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
34	43	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
35	44	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
36	44	61	Producto 12	Dolares	test2	ML	100.00	-1.00	\N	0.00
37	46	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
38	46	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
39	47	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
40	47	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
41	48	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
42	48	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
43	49	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
44	49	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
45	50	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
46	50	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
47	51	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
48	51	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
49	52	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
50	52	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
51	53	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
52	53	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
53	54	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
54	54	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
55	55	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
56	55	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
57	56	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
58	56	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
59	57	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
60	57	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
61	58	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
62	58	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
63	59	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
64	59	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
65	60	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
66	60	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
67	61	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
68	61	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
69	62	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
70	62	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
71	63	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
72	63	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
73	64	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
74	64	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
75	65	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
76	65	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
77	66	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
78	66	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
79	67	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
80	67	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
81	68	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
82	68	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
83	69	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	-1.00	0.00
84	69	61	Producto 12	Dolares	test2	ML	100.00	281.01	-1.00	0.00
85	70	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
86	70	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
87	71	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
88	71	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
89	72	62	Producto 2	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
90	72	61	Producto 12	Dolares	test2	ML	100.00	281.01	0.09	281.10
91	73	62	Producto 2 mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm	Dolares	test	Ltrs.	200.00	1020.00	114.54	1134.54
92	73	61	Producto 12 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	Dolares	test2	ML	100.00	281.01	0.09	281.10
93	74	62	Producto 2 mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm	Dolares	Inyectable tipo 2	Ltrs.	200.00	1020.00	114.54	1134.54
94	74	61	Producto 12 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	Dolares	Inyectable tipo 1	ML	100.00	281.01	0.09	281.10
95	75	62	Producto 2 mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm	Dolares	Inyectable tipo 2	Ltrs.	200.00	1020.00	114.54	1134.54
96	75	61	Producto 12 Test	Dolares	Inyectable tipo 1	ML	100.00	281.01	0.09	281.10
97	76	62	Producto 2 Test2	Dolares	Inyectable tipo 2	Ltrs.	200.00	1020.00	114.54	1134.54
98	76	61	Producto 12 Test	Dolares	Inyectable tipo 1	ML	100.00	281.01	0.09	281.10
99	77	64	456456	Euros	Inyectable tipo 1	Gls.	5.00	0.00	\N	\N
100	77	61	Producto 12 Test	Dolares	Inyectable tipo 1	Gls.	100.00	288.73	112.43	401.16
101	77	62	Producto 2 Test2	Dolares	Inyectable tipo 2	ML	100.00	1836.00	0.07	1836.07
102	77	67	fghfghgfh	Dolares	Inyectable tipo 1	ML	0.00	0.00	\N	\N
103	78	64	456456	Euros	Inyectable tipo 1	Gls.	33.00	0.00	\N	\N
104	78	61	Producto 12 Test	Dolares	Inyectable tipo 1	Gls.	33.00	288.73	112.43	401.16
105	78	62	Producto 2 Test2	Dolares	Inyectable tipo 2	ML	120.00	1836.00	0.07	1836.07
106	78	67	fghfghgfh	Dolares	Inyectable tipo 1	ML	120.00	0.00	\N	\N
107	79	64	456456	Euros	Inyectable tipo 1	Gls.	33.00	0.00	\N	\N
108	79	61	Producto 12 Test	Dolares	Inyectable tipo 1	Gls.	33.00	245.63	112.43	358.06
109	79	62	Producto 2 Test2	Dolares	Inyectable tipo 2	ML	120.00	1836.00	0.07	1836.07
110	79	67	fghfghgfh	Dolares	Inyectable tipo 1	ML	120.00	0.00	\N	\N
111	80	64	456456	Euros	Inyectable tipo 1	Gls.	33.00	0.00	\N	\N
112	80	61	Producto 12 Test	Dolares	Inyectable tipo 1	Gls.	33.00	-1.00	\N	0.00
113	80	62	Producto 2 Test2	Dolares	Inyectable tipo 2	ML	120.00	1836.00	-1.00	0.00
114	80	67	fghfghgfh	Dolares	Inyectable tipo 1	ML	120.00	0.00	\N	\N
115	81	64	456456	Euros	Inyectable tipo 1	Gls.	33.00	0.00	\N	\N
116	81	61	Producto 12 Test	Dolares	Inyectable tipo 1	Gls.	33.00	245.63	112.43	358.06
117	81	62	Producto 2 Test2	Dolares	Inyectable tipo 2	ML	120.00	1836.00	0.07	1836.07
118	81	67	fghfghgfh	Dolares	Inyectable tipo 1	ML	120.00	0.00	\N	\N
\.


--
-- TOC entry 3493 (class 0 OID 18463)
-- Dependencies: 205
-- Data for Name: tb_empresa; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_empresa (empresa_id, empresa_razon_social, tipo_empresa_codigo, empresa_ruc, empresa_direccion, empresa_telefonos, empresa_fax, empresa_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	FUTURE LAB S.A.C	IMP	23232232344	Isadora Duncan 345	2756910	2756910	aranape@gmail.com	t	TESTUSER	2016-09-15 02:26:34.750111	ADMIN	2018-11-02 03:28:47.975088
28	FUTURE LAB S.A.C (NOUSAR)	IMP	23232232345	Isadora Duncan 345	2756910	2756910	aranape@gmail.com	t	TESTUSER	2021-05-30 08:18:30.476354	ADMIN	2018-11-02 03:28:47.975088
\.


--
-- TOC entry 3495 (class 0 OID 18473)
-- Dependencies: 207
-- Data for Name: tb_entidad; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_entidad (entidad_id, entidad_razon_social, entidad_ruc, entidad_direccion, entidad_telefonos, entidad_fax, entidad_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	LABODEC S.A	12345654457	Ate	2756910		labodec@gmail.com	t	ADMIN	2016-09-21 02:08:40.288333	ADMIN	2021-09-03 14:47:58.646452
\.


--
-- TOC entry 3497 (class 0 OID 18482)
-- Dependencies: 209
-- Data for Name: tb_ffarmaceutica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_ffarmaceutica (ffarmaceutica_codigo, ffarmaceutica_descripcion, ffarmaceutica_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 3498 (class 0 OID 18492)
-- Dependencies: 210
-- Data for Name: tb_insumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_insumo (insumo_id, insumo_tipo, insumo_codigo, insumo_descripcion, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_ingreso, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, insumo_precio_mercado, taplicacion_entries_id, insumo_cantidad_costo, tpresentacion_codigo) FROM stdin;
60	IN	INSOTRO	Insumo 2	SOLUCION	CDIR	GALON	LITROS	4.0000	12.0000	USD	t	ADMIN	2021-07-24 02:45:30.857028	ADMIN	2021-09-03 14:59:01.436638	12.00	\N	\N	\N
63	IN	XXXX	xxacasdsdf	SOLUCION	CIND	NING	GALON	0.0000	2.0000	USD	t	ADMIN	2021-09-03 15:04:20.549163	\N	\N	0.00	\N	0.00	\N
64	PR	RT	456456	NING	NING	NING	KILOS	4.0000	\N	EURO	t	ADMIN	2021-09-05 03:12:30.402499	ADMIN	2021-09-05 03:12:59.30805	55.00	17	5.00	MLLL
61	PR	PRODUNO	Producto 12 Test	NING	NING	NING	LITROS	2.0000	\N	USD	t	ADMIN	2021-07-24 02:50:06.296024	ADMIN	2021-09-05 03:18:58.682397	12.00	17	100.00	MLLL
62	PR	PRODDOS	Producto 2 Test2	NING	NING	NING	LITROS	2.0000	\N	USD	t	ADMIN	2021-08-15 00:58:18.735091	ADMIN	2021-09-05 03:19:07.142315	13.00	5	100.00	BOTELLA
51	IN	XXXXX	Insumo 1	SOLUCION	CDIR	GALON	GALON	0.0000	20.0000	EURO	t	ADMIN	2021-07-04 21:45:56.143997	ADMIN	2021-09-05 18:31:45.940014	12.00	\N	\N	\N
67	PR	FGHYFGH	fghfghgfh	NING	NING	NING	\N	55.0000	\N	USD	t	ADMIN	2021-09-05 18:49:08.411867	\N	\N	55.00	17	0.00	BOTELLA
\.


--
-- TOC entry 3500 (class 0 OID 18525)
-- Dependencies: 212
-- Data for Name: tb_moneda; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_moneda (moneda_codigo, moneda_simbolo, moneda_descripcion, moneda_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
JPY	Yen	Yen Japones	f	t	TESTUSER	2016-07-14 00:40:58.095941	\N	\N
EURO	â¬	Euros	t	t	TESTUSER	2016-08-21 23:36:32.726364	TESTUSER	2019-04-02 13:55:58.098127
PEN	S/.	Nuevos Soles	t	t	TESTUSER	2016-07-10 18:16:12.815048	postgres	2019-04-02 13:56:04.124446
USD	$	Dolares	t	t	TESTUSER	2016-07-10 18:20:47.857316	TESTUSER	2019-04-02 13:56:06.660428
\.


--
-- TOC entry 3501 (class 0 OID 18531)
-- Dependencies: 213
-- Data for Name: tb_procesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_procesos (procesos_codigo, procesos_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
LAVADO	Lavado	t	ADMIN	2021-05-20 02:00:54.057776	\N	\N
PRENS	Prensado	t	ADMIN	2021-05-20 02:27:38.088606	\N	\N
AAAA	aaaaaaaaa	t	ADMIN	2021-05-21 02:36:39.180787	\N	\N
AAAAD	sasass	t	ADMIN	2021-05-21 02:37:33.766335	\N	\N
\.


--
-- TOC entry 3502 (class 0 OID 18536)
-- Dependencies: 214
-- Data for Name: tb_produccion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_produccion (produccion_id, produccion_fecha, taplicacion_entries_id, produccion_qty, unidad_medida_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
8	2021-07-06	5	88.00	LITROS	t	ADMIN	2021-07-17 00:29:02.438257	postgres	2021-08-13 06:52:06.079145
7	2021-07-08	17	44.00	LITROS	t	ADMIN	2021-07-16 23:34:54.49224	ADMIN	2021-08-13 06:52:52.599707
1	2021-07-21	17	12.00	LITROS	t	ADMIN	2021-07-16 23:20:20.772754	ADMIN	2021-08-13 19:13:14.959492
\.


--
-- TOC entry 3504 (class 0 OID 18544)
-- Dependencies: 216
-- Data for Name: tb_producto_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_producto_detalle (producto_detalle_id, insumo_id_origen, insumo_id, unidad_medida_codigo, producto_detalle_cantidad, producto_detalle_valor, producto_detalle_merma, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
61	61	60	GALON	1.0000	10.0000	2.0000	t	ADMIN	2021-07-28 16:56:05.901349	\N	\N
62	62	60	LITROS	150.0000	12.0000	2.0000	t	ADMIN	2021-08-15 00:58:31.979608	ADMIN	2021-09-03 14:58:21.552538
60	61	51	GALON	3.0000	20.0000	1.0000	t	ADMIN	2021-07-24 02:56:53.306369	ADMIN	2021-09-06 02:36:14.932223
\.


--
-- TOC entry 3506 (class 0 OID 18554)
-- Dependencies: 218
-- Data for Name: tb_producto_procesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_producto_procesos (producto_procesos_id, insumo_id, producto_procesos_fecha_desde, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
9	61	2021-09-02	t	ADMIN	2021-09-02 10:33:44.347816	\N	\N
\.


--
-- TOC entry 3507 (class 0 OID 18557)
-- Dependencies: 219
-- Data for Name: tb_producto_procesos_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_producto_procesos_detalle (producto_procesos_detalle_id, producto_procesos_id, procesos_codigo, producto_procesos_detalle_porcentaje, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
26	9	PRENS	12.00	t	ADMIN	2021-09-02 10:34:12.039508	\N	\N
\.


--
-- TOC entry 3510 (class 0 OID 18572)
-- Dependencies: 222
-- Data for Name: tb_subprocesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_subprocesos (subprocesos_codigo, subprocesos_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
QW	qwqww	t	ADMIN	2021-05-21 03:09:43.018131	\N	\N
\.


--
-- TOC entry 3511 (class 0 OID 18577)
-- Dependencies: 223
-- Data for Name: tb_sys_menu; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_menu (sys_systemcode, menu_id, menu_codigo, menu_descripcion, menu_accesstype, menu_parent_id, menu_orden, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	60	smn_tipocambio	Tipo De Cambio	A         	11	165	t	TESTUSER	2016-07-15 03:24:37.087685	\N	\N
labcostos	61	smn_tcostos	Tipo De Costos	A         	11	155	t	TESTUSER	2016-07-19 03:17:27.948919	\N	\N
labcostos	4	mn_menu	Menu	A         	\N	0	t	TESTUSER	2014-01-14 17:51:30.074514	\N	\N
labcostos	11	mn_generales	Datos Generales	A         	4	10	t	TESTUSER	2014-01-14 17:53:10.656624	\N	\N
labcostos	12	smn_entidad	Entidad	A         	11	100	t	TESTUSER	2014-01-14 17:54:38.907518	\N	\N
labcostos	15	smn_unidadmedida	Unidades De Medida	A         	11	130	t	TESTUSER	2014-01-15 23:45:38.848008	\N	\N
labcostos	58	smn_perfiles	Perfiles	A         	56	110	t	TESTUSER	2015-10-04 15:01:00.279735	\N	\N
labcostos	57	smn_usuarios	Usuarios	A         	56	100	t	TESTUSER	2015-10-04 15:00:26.551082	\N	\N
labcostos	56	mn_admin	Administrador	A         	4	5	t	TESTUSER	2015-10-04 14:59:17.331335	\N	\N
labcostos	16	smn_monedas	Monedas	A         	11	140	t	TESTUSER	2014-01-16 04:57:32.87322	\N	\N
labcostos	21	smn_umconversion	Conversion de Unidades de Medida	A         	11	135	t	TESTUSER	2014-01-17 15:36:35.894364	\N	\N
labcostos	62	smn_producto	Producto	A         	74	165	t	TESTUSER	2016-08-06 15:02:59.319601	\N	\N
labcostos	80	mn_costo_global	Costos Globales	A         	4	15	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	79	smn_tcosto_global	Tipo Costos Globales	A         	80	100	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	81	smn_tcosto_global_entries	Movimientos Costos Globales	A         	80	110	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	88	mn_taplicacion	Modo Aplicacion	A         	4	20	t	TESTUSER	2021-05-20 01:31:19	\N	\N
labcostos	87	smn_taplicacion_procesos	Modo Aplicacion/Procesos	A         	88	125	t	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	86	smn_taplicacion	Modos de Aplicacion	A         	88	120	t	TESTUSER	2021-06-30 03:11:24	\N	\N
labcostos	89	mn_produccion	Produccion	A         	4	20	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	90	mn_costos	Costos	A         	4	20	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	91	smn_costos_proceso	Proceso	A         	90	20	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	92	smn_costos_consulta	Consulta	A         	90	22	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	84	smn_subprocesos	Sub Procesos	A         	82	100	f	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	85	smn_producto_procesos	Producto/Procesos	A         	74	120	f	TESTUSER	2021-05-14 00:41:25	\N	\N
labcostos	64	smn_empresas	Empresas	A         	56	120	f	TESTUSER	2016-09-15 00:42:19.770493	\N	\N
labcostos	93	mn_insumos	Insumos	A         	4	12	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	59	smn_insumo	Insumos	A         	93	160	t	TESTUSER	2014-01-17 15:35:42.866956	\N	\N
labcostos	76	smn_presentacion	Presentaciones	A         	74	10	t	TESTUSER	2019-03-05 06:54:36.918	\N	\N
labcostos	17	smn_tinsumo	Tipo De Insumos	A         	93	150	t	TESTUSER	2014-01-17 15:35:42.866956	\N	\N
labcostos	74	mn_productos	Productos	A         	4	12	t	TESTUSER	2018-11-04 23:49:15.304	\N	\N
labcostos	70	mn_reportes	Reportes	A         	4	15	f	TESTUSER	2017-01-21 02:09:51.841752	\N	\N
labcostos	82	mn_procesos	Procesos de Fabricacion	A         	11	20	t	TESTUSER	2021-05-20 01:31:19	\N	\N
\.


--
-- TOC entry 3513 (class 0 OID 18584)
-- Dependencies: 225
-- Data for Name: tb_sys_perfil; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_perfil (perfil_id, sys_systemcode, perfil_codigo, perfil_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
35	labcostos	POWERUSER	Usuario Avanzado	t	ADMIN	2018-11-05 05:41:50.802291	postgres	2018-11-05 05:42:02.737037
34	labcostos	ADMIN	Perfil Administrador	t	ADMIN	2018-11-05 05:10:14.396855	postgres	2018-11-05 07:26:25.060017
\.


--
-- TOC entry 3514 (class 0 OID 18588)
-- Dependencies: 226
-- Data for Name: tb_sys_perfil_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_perfil_detalle (perfdet_id, perfdet_accessdef, perfdet_accleer, perfdet_accagregar, perfdet_accactualizar, perfdet_acceliminar, perfdet_accimprimir, perfil_id, menu_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
965	\N	t	t	t	t	t	35	4	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
966	\N	t	t	t	t	t	35	56	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
968	\N	t	t	t	t	t	35	11	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
969	\N	t	t	t	t	t	35	74	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
971	\N	t	t	t	t	t	35	70	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
972	\N	t	t	t	t	t	35	12	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
973	\N	t	t	t	t	t	35	57	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
974	\N	t	t	t	t	t	35	58	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
976	\N	t	t	t	t	t	35	15	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
978	\N	t	t	t	t	t	35	21	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
980	\N	t	t	t	t	t	35	16	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
981	\N	t	t	t	t	t	35	17	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
982	\N	t	t	t	t	t	35	61	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
983	\N	t	t	t	t	t	35	59	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
984	\N	t	t	t	t	t	35	62	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
985	\N	t	t	t	t	t	35	60	t	ADMIN	2018-11-05 05:42:20.887645	\N	\N
988	\N	t	t	t	t	t	35	76	t	ADMIN	2019-03-05 06:55:31.712645	postgres	2019-03-05 06:56:06.54344
989	\N	t	t	t	t	t	34	76	t	ADMIN	2019-03-05 06:56:38.017533	postgres	2019-03-05 06:56:56.228915
942	\N	t	t	t	t	t	34	4	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
943	\N	t	t	t	t	t	34	56	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
945	\N	t	t	t	t	t	34	11	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
946	\N	t	t	t	t	t	34	74	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
948	\N	t	t	t	t	t	34	70	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
949	\N	t	t	t	t	t	34	12	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
950	\N	t	t	t	t	t	34	57	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
951	\N	t	t	t	t	t	34	58	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
953	\N	t	t	t	t	t	34	15	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
955	\N	t	t	t	t	t	34	21	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
957	\N	t	t	t	t	t	34	16	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
958	\N	t	t	t	t	t	34	17	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
959	\N	t	t	t	t	t	34	61	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
960	\N	t	t	t	t	t	34	59	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
961	\N	t	t	t	t	t	34	62	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
962	\N	t	t	t	t	t	34	60	t	ADMIN	2018-11-05 05:10:20.612333	\N	\N
994	\N	t	t	t	t	t	35	79	t	ADMIN	2021-05-14 05:44:46.442931	postgres	2019-03-05 06:56:56.228915
995	\N	t	t	t	t	t	34	79	t	ADMIN	2021-05-14 05:45:21.672633	postgres	2019-03-05 06:56:56.228915
998	\N	t	t	t	t	t	34	80	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
999	\N	t	t	t	t	t	35	80	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
1000	\N	t	t	t	t	t	35	81	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
1001	\N	t	t	t	t	t	34	81	t	ADMIN	2021-05-19 05:28:08.560822	postgres	2019-03-05 06:56:56.228915
1002	\N	t	t	t	t	t	35	82	t	ADMIN	2021-05-20 06:56:12.50406	postgres	2019-03-05 06:56:56.228915
1003	\N	t	t	t	t	t	34	82	t	ADMIN	2021-05-20 06:56:59.257063	postgres	2019-03-05 06:56:56.228915
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
1052	\N	t	t	t	t	t	35	90	t	ADMIN	2021-08-20 07:44:07.35412	postgres	2019-03-05 06:56:56.228915
1053	\N	t	t	t	t	t	35	91	t	ADMIN	2021-08-20 07:44:07.35412	postgres	2019-03-05 06:56:56.228915
1054	\N	t	t	t	t	t	34	90	t	ADMIN	2021-08-20 07:44:07.35412	postgres	2019-03-05 06:56:56.228915
1055	\N	t	t	t	t	t	34	91	t	ADMIN	2021-08-20 07:44:07.35412	postgres	2019-03-05 06:56:56.228915
1056	\N	t	t	t	t	t	34	92	t	ADMIN	2021-08-23 19:24:39.190797	postgres	2021-08-23 19:25:20.521876
1057	\N	t	t	t	t	t	35	92	t	ADMIN	2021-08-23 19:24:39.190797	postgres	2021-08-23 19:25:20.521876
1058	\N	t	t	t	t	t	35	93	t	ADMIN	2021-09-03 20:49:02.118009	postgres	2019-03-05 06:56:56.228915
1059	\N	t	t	t	t	t	34	93	t	ADMIN	2021-09-03 20:49:02.118009	postgres	2019-03-05 06:56:56.228915
\.


--
-- TOC entry 3517 (class 0 OID 18601)
-- Dependencies: 229
-- Data for Name: tb_sys_sistemas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_sistemas (sys_systemcode, sistema_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	Sistema De Costos Laboratorios	t	TESTUSER	2016-07-08 23:47:11.960862	postgres	2016-09-21 01:38:36.399968
\.


--
-- TOC entry 3518 (class 0 OID 18605)
-- Dependencies: 230
-- Data for Name: tb_sys_usuario_perfiles; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_sys_usuario_perfiles (usuario_perfil_id, perfil_id, usuarios_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
27	34	21	t	ADMIN	2018-11-05 05:16:04.885465	\N	\N
28	35	22	t	ADMIN	2018-11-05 05:42:42.652755	\N	\N
\.


--
-- TOC entry 3520 (class 0 OID 18611)
-- Dependencies: 232
-- Data for Name: tb_taplicacion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_taplicacion (taplicacion_codigo, taplicacion_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
FFFF	ffff	t	ADMIN	2021-07-04 03:45:14.353965	\N	\N
XXXXXX	xxx	t	ADMIN	2021-07-02 02:28:23.734123	ADMIN	2021-07-04 04:18:39.584401
\.


--
-- TOC entry 3521 (class 0 OID 18616)
-- Dependencies: 233
-- Data for Name: tb_taplicacion_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_taplicacion_entries (taplicacion_entries_id, taplicacion_codigo, taplicacion_entries_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
17	XXXXXX	Inyectable tipo 1	t	ADMIN	2021-07-02 04:21:35.679766	ADMIN	2021-08-29 15:08:34.556369
5	XXXXXX	Inyectable tipo 2	t	ADMIN	2021-07-02 03:30:22.574365	ADMIN	2021-08-29 15:08:53.21809
20	XXXXXX	Inyectable tipo 3	t	ADMIN	2021-08-24 21:21:06.889863	ADMIN	2021-08-29 15:09:05.4062
\.


--
-- TOC entry 3523 (class 0 OID 18622)
-- Dependencies: 235
-- Data for Name: tb_taplicacion_procesos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_taplicacion_procesos (taplicacion_procesos_id, taplicacion_codigo, taplicacion_procesos_fecha_desde, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	XXXXXX	2021-07-08	t	ADMIN	2021-07-08 04:09:35.507845	\N	\N
\.


--
-- TOC entry 3524 (class 0 OID 18625)
-- Dependencies: 236
-- Data for Name: tb_taplicacion_procesos_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_taplicacion_procesos_detalle (taplicacion_procesos_detalle_id, taplicacion_procesos_id, procesos_codigo, taplicacion_procesos_detalle_porcentaje, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	1	LAVADO	12.00	t	ADMIN	2021-07-10 01:31:16.464008	\N	\N
10	1	PRENS	66.00	t	ADMIN	2021-07-10 01:31:52.785433	ADMIN	2021-07-10 01:32:12.087129
13	1	AAAAD	1.00	t	ADMIN	2021-07-10 01:33:56.60345	\N	\N
\.


--
-- TOC entry 3527 (class 0 OID 18633)
-- Dependencies: 239
-- Data for Name: tb_tcosto_global; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tcosto_global (tcosto_global_codigo, tcosto_global_descripcion, tcosto_global_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
GPERSON	Gastos de Personal	f	t	ADMIN	2021-05-16 03:08:34.225147	\N	\N
LUZADM	Luz Administrativa	f	t	ADMIN	2021-05-16 03:09:07.871033	\N	\N
\.


--
-- TOC entry 3528 (class 0 OID 18639)
-- Dependencies: 240
-- Data for Name: tb_tcosto_global_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_tcosto_global_entries (tcosto_global_entries_id, tcosto_global_codigo, tcosto_global_entries_fecha_desde, tcosto_global_entries_valor, moneda_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	LUZADM	2021-07-08	12.00	EURO	t	ADMIN	2021-06-12 00:20:14.794277	ADMIN	2021-08-12 23:50:09.905003
\.


--
-- TOC entry 3530 (class 0 OID 18645)
-- Dependencies: 242
-- Data for Name: tb_tcostos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tcostos (tcostos_codigo, tcostos_descripcion, tcostos_protected, tcostos_indirecto, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
CIND	Costo Indirecto	f	t	t	TESTUSER	2016-08-30 20:18:59.46133	ADMIN	2017-02-14 00:47:20.776931
NING	Ninguno	t	f	t	admin	2016-08-30 20:03:40.281843	ADMIN	2017-02-14 00:48:13.45147
CDIR	Costo Directo	f	f	t	TESTUSER	2016-08-30 20:18:08.544862	ADMIN	2017-02-14 01:12:02.164853
CVAR	Costo Variable	f	f	t	ADMIN	2018-11-16 21:20:16.068038	\N	\N
\.


--
-- TOC entry 3531 (class 0 OID 18652)
-- Dependencies: 243
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
-- TOC entry 3532 (class 0 OID 18658)
-- Dependencies: 244
-- Data for Name: tb_tipo_cambio; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tipo_cambio (tipo_cambio_id, moneda_codigo_origen, moneda_codigo_destino, tipo_cambio_fecha_desde, tipo_cambio_fecha_hasta, tipo_cambio_tasa_compra, tipo_cambio_tasa_venta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	USD	JPY	2016-08-18	2016-08-19	3.0000	3.5000	t	TESTUSER	2016-08-13 15:41:24.405659	TESTUSER	2016-08-13 15:47:08.433642
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
3	EURO	USD	2021-07-24	2021-12-31	4.0000	4.2000	t	TESTUSER	2016-08-22 15:58:06.566396	ADMIN	2021-09-06 19:22:30.411923
\.


--
-- TOC entry 3534 (class 0 OID 18672)
-- Dependencies: 246
-- Data for Name: tb_tipo_empresa; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_tipo_empresa (tipo_empresa_codigo, tipo_empresa_descripcion, tipo_empresa_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
IMP	Importador	t	t	TESTUSER	2016-09-14 14:32:00.336057	postgres	2016-09-21 01:40:12.22007
FAB	Fabrica	t	t	TESTUSER	2016-09-14 14:32:18.634844	postgres	2016-09-21 01:40:12.22007
DIS	Distribuidor	t	t	TESTUSER	2016-09-14 14:32:35.783304	postgres	2016-09-21 01:40:12.22007
\.


--
-- TOC entry 3535 (class 0 OID 18678)
-- Dependencies: 247
-- Data for Name: tb_tpresentacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_tpresentacion (tpresentacion_codigo, tpresentacion_descripcion, tpresentacion_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, tpresentacion_cantidad_costo, unidad_medida_codigo_costo) FROM stdin;
MLLL	tyrturtyu	f	t	ADMIN	2021-09-04 02:30:05.063759	ADMIN	2021-09-04 02:57:20.200517	33.00	GALON
BOTELLA	Botella de 120 ml	f	t	ADMIN	2021-09-05 03:16:42.220653	\N	\N	120.00	ML
\.


--
-- TOC entry 3536 (class 0 OID 18684)
-- Dependencies: 248
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
ML	ML	Mililitros	V	f	t	ADMIN	2021-07-28 16:35:07.058964	\N	\N	f
\.


--
-- TOC entry 3537 (class 0 OID 18692)
-- Dependencies: 249
-- Data for Name: tb_unidad_medida_conversion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY public.tb_unidad_medida_conversion (unidad_medida_conversion_id, unidad_medida_origen, unidad_medida_destino, unidad_medida_conversion_factor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
10	TONELAD	KILOS	1000.00000	t	TESTUSER	2016-07-11 17:18:02.132735	\N	\N
60	GALON	LITROS	3.78540	t	TESTUSER	2016-07-18 04:44:20.861417	TESTUSER	2016-08-27 14:47:27.766392
70	LITROS	GALON	0.26420	t	TESTUSER	2016-07-30 00:33:37.114577	TESTUSER	2016-08-27 14:47:33.986013
24	KILOS	TONELAD	0.00100	t	TESTUSER	2016-07-12 15:58:35.930938	ADMIN	2017-02-14 01:49:05.979355
85	ML	LITROS	0.00100	t	ADMIN	2021-07-28 16:35:39.163867	\N	\N
\.


--
-- TOC entry 3539 (class 0 OID 18699)
-- Dependencies: 251
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY public.tb_usuarios (usuarios_id, usuarios_code, usuarios_password, usuarios_nombre_completo, usuarios_admin, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
21	ADMIN	melivane	Carlos Arana Reategui	t	t	ADMIN	2016-09-21 01:45:30.980176	ADMIN	05:32:21.720294
22	PUSER	puser	Soy Power User	f	t	ADMIN	2016-09-21 02:03:18.100401	ADMIN	05:32:27.181272
\.


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 204
-- Name: tb_costos_list_costos_list_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_costos_list_costos_list_id_seq', 81, true);


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 253
-- Name: tb_costos_list_detalle_costos_list_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_costos_list_detalle_costos_list_detalle_id_seq', 118, true);


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 206
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_empresa_empresa_id_seq', 28, true);


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 208
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_entidad_entidad_id_seq', 1, true);


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 211
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_insumo_insumo_id_seq', 67, true);


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 215
-- Name: tb_produccion_produccion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_produccion_produccion_id_seq', 9, true);


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 217
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_producto_detalle_producto_detalle_id_seq', 62, true);


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 220
-- Name: tb_producto_procesos_detalle_producto_procesos_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_producto_procesos_detalle_producto_procesos_detalle_id_seq', 26, true);


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 221
-- Name: tb_producto_procesos_producto_procesos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_producto_procesos_producto_procesos_id_seq', 9, true);


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 224
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_menu_menu_id_seq', 93, true);


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 227
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_perfil_detalle_perfdet_id_seq', 1059, true);


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 228
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_perfil_id_seq', 36, true);


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 231
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_sys_usuario_perfiles_usuario_perfil_id_seq', 28, true);


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 234
-- Name: tb_taplicacion_entries_taplicacion_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_taplicacion_entries_taplicacion_entries_id_seq', 20, true);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 237
-- Name: tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_taplicacion_procesos_detal_taplicacion_procesos_detalle__seq', 13, true);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 238
-- Name: tb_taplicacion_procesos_taplicacion_procesos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_taplicacion_procesos_taplicacion_procesos_id_seq', 1, true);


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 241
-- Name: tb_tcosto_global_entries_tcosto_global_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_tcosto_global_entries_tcosto_global_entries_id_seq', 1, true);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 245
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_tipo_cambio_tipo_cambio_id_seq', 29, true);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 250
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq', 85, true);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 252
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('public.tb_usuarios_usuarios_id_seq', 27, true);


--
-- TOC entry 3151 (class 2606 OID 18742)
-- Name: tb_costos_list pk_costos_list; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list
    ADD CONSTRAINT pk_costos_list PRIMARY KEY (costos_list_id);


--
-- TOC entry 3271 (class 2606 OID 45912)
-- Name: tb_costos_list_detalle pk_costos_list_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list_detalle
    ADD CONSTRAINT pk_costos_list_detalle PRIMARY KEY (costos_list_detalle_id);


--
-- TOC entry 3158 (class 2606 OID 18750)
-- Name: tb_empresa pk_empresa; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_empresa
    ADD CONSTRAINT pk_empresa PRIMARY KEY (empresa_id);


--
-- TOC entry 3160 (class 2606 OID 18752)
-- Name: tb_entidad pk_entidad; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_entidad
    ADD CONSTRAINT pk_entidad PRIMARY KEY (entidad_id);


--
-- TOC entry 3162 (class 2606 OID 18754)
-- Name: tb_ffarmaceutica pk_ffarmaceutica; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_ffarmaceutica
    ADD CONSTRAINT pk_ffarmaceutica PRIMARY KEY (ffarmaceutica_codigo);


--
-- TOC entry 3170 (class 2606 OID 18756)
-- Name: tb_insumo pk_insumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT pk_insumo PRIMARY KEY (insumo_id);


--
-- TOC entry 3204 (class 2606 OID 18762)
-- Name: tb_sys_menu pk_menu; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT pk_menu PRIMARY KEY (menu_id);


--
-- TOC entry 3174 (class 2606 OID 18764)
-- Name: tb_moneda pk_moneda; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_moneda
    ADD CONSTRAINT pk_moneda PRIMARY KEY (moneda_codigo);


--
-- TOC entry 3215 (class 2606 OID 18766)
-- Name: tb_sys_perfil_detalle pk_perfdet_id; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil_detalle
    ADD CONSTRAINT pk_perfdet_id PRIMARY KEY (perfdet_id);


--
-- TOC entry 3176 (class 2606 OID 18768)
-- Name: tb_procesos pk_procesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_procesos
    ADD CONSTRAINT pk_procesos PRIMARY KEY (procesos_codigo);


--
-- TOC entry 3180 (class 2606 OID 18770)
-- Name: tb_produccion pk_produccion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion
    ADD CONSTRAINT pk_produccion PRIMARY KEY (produccion_id);


--
-- TOC entry 3185 (class 2606 OID 18772)
-- Name: tb_producto_detalle pk_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT pk_producto_detalle PRIMARY KEY (producto_detalle_id);


--
-- TOC entry 3190 (class 2606 OID 18774)
-- Name: tb_producto_procesos pk_producto_procesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos
    ADD CONSTRAINT pk_producto_procesos PRIMARY KEY (producto_procesos_id);


--
-- TOC entry 3196 (class 2606 OID 18776)
-- Name: tb_producto_procesos_detalle pk_producto_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT pk_producto_procesos_detalle PRIMARY KEY (producto_procesos_detalle_id);


--
-- TOC entry 3149 (class 2606 OID 18780)
-- Name: ci_sessions pk_sessions; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.ci_sessions
    ADD CONSTRAINT pk_sessions PRIMARY KEY (session_id);


--
-- TOC entry 3217 (class 2606 OID 18782)
-- Name: tb_sys_sistemas pk_sistemas; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_sistemas
    ADD CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode);


--
-- TOC entry 3200 (class 2606 OID 18784)
-- Name: tb_subprocesos pk_subprocesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_subprocesos
    ADD CONSTRAINT pk_subprocesos PRIMARY KEY (subprocesos_codigo);


--
-- TOC entry 3209 (class 2606 OID 18786)
-- Name: tb_sys_perfil pk_sys_perfil; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id);


--
-- TOC entry 3223 (class 2606 OID 18788)
-- Name: tb_taplicacion pk_taplicacion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion
    ADD CONSTRAINT pk_taplicacion PRIMARY KEY (taplicacion_codigo);


--
-- TOC entry 3226 (class 2606 OID 18790)
-- Name: tb_taplicacion_entries pk_taplicacion_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_taplicacion_entries
    ADD CONSTRAINT pk_taplicacion_entries PRIMARY KEY (taplicacion_entries_id);


--
-- TOC entry 3229 (class 2606 OID 18792)
-- Name: tb_taplicacion_procesos pk_taplicacion_procesos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos
    ADD CONSTRAINT pk_taplicacion_procesos PRIMARY KEY (taplicacion_procesos_id);


--
-- TOC entry 3235 (class 2606 OID 18794)
-- Name: tb_taplicacion_procesos_detalle pk_taplicacion_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT pk_taplicacion_procesos_detalle PRIMARY KEY (taplicacion_procesos_detalle_id);


--
-- TOC entry 3239 (class 2606 OID 18796)
-- Name: tb_tcosto_global pk_tcosto_global; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tcosto_global
    ADD CONSTRAINT pk_tcosto_global PRIMARY KEY (tcosto_global_codigo);


--
-- TOC entry 3243 (class 2606 OID 18798)
-- Name: tb_tcosto_global_entries pk_tcosto_global_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT pk_tcosto_global_entries PRIMARY KEY (tcosto_global_entries_id);


--
-- TOC entry 3247 (class 2606 OID 18800)
-- Name: tb_tcostos pk_tcostos; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tcostos
    ADD CONSTRAINT pk_tcostos PRIMARY KEY (tcostos_codigo);


--
-- TOC entry 3249 (class 2606 OID 18802)
-- Name: tb_tinsumo pk_tinsumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tinsumo
    ADD CONSTRAINT pk_tinsumo PRIMARY KEY (tinsumo_codigo);


--
-- TOC entry 3251 (class 2606 OID 18804)
-- Name: tb_tipo_cambio pk_tipo_cambio; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio
    ADD CONSTRAINT pk_tipo_cambio PRIMARY KEY (tipo_cambio_id);


--
-- TOC entry 3254 (class 2606 OID 18808)
-- Name: tb_tipo_empresa pk_tipo_empresa; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_empresa
    ADD CONSTRAINT pk_tipo_empresa PRIMARY KEY (tipo_empresa_codigo);


--
-- TOC entry 3257 (class 2606 OID 18810)
-- Name: tb_tpresentacion pk_tpresentacion; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tpresentacion
    ADD CONSTRAINT pk_tpresentacion PRIMARY KEY (tpresentacion_codigo);


--
-- TOC entry 3262 (class 2606 OID 18812)
-- Name: tb_unidad_medida_conversion pk_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT pk_unidad_conversion PRIMARY KEY (unidad_medida_conversion_id);


--
-- TOC entry 3259 (class 2606 OID 18814)
-- Name: tb_unidad_medida pk_unidad_medida; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida
    ADD CONSTRAINT pk_unidad_medida PRIMARY KEY (unidad_medida_codigo);


--
-- TOC entry 3221 (class 2606 OID 18816)
-- Name: tb_sys_usuario_perfiles pk_usuarioperfiles; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles
    ADD CONSTRAINT pk_usuarioperfiles PRIMARY KEY (usuario_perfil_id);


--
-- TOC entry 3267 (class 2606 OID 18818)
-- Name: tb_usuarios pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_usuarios
    ADD CONSTRAINT pk_usuarios PRIMARY KEY (usuarios_id);


--
-- TOC entry 3206 (class 2606 OID 18820)
-- Name: tb_sys_menu unq_codigomenu; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT unq_codigomenu UNIQUE (menu_codigo);


--
-- TOC entry 3273 (class 2606 OID 45914)
-- Name: tb_costos_list_detalle unq_costos_list_detalle_insumof; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list_detalle
    ADD CONSTRAINT unq_costos_list_detalle_insumof UNIQUE (costos_list_id, insumo_id);


--
-- TOC entry 3153 (class 2606 OID 45845)
-- Name: tb_costos_list unq_costos_list_fecha_descripcion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list
    ADD CONSTRAINT unq_costos_list_fecha_descripcion UNIQUE (costos_list_fecha, costos_list_descripcion);


--
-- TOC entry 3172 (class 2606 OID 18826)
-- Name: tb_insumo unq_insumo_codigo; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT unq_insumo_codigo UNIQUE (insumo_codigo);


--
-- TOC entry 3211 (class 2606 OID 18828)
-- Name: tb_sys_perfil unq_perfil_syscode_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode, perfil_codigo);


--
-- TOC entry 3213 (class 2606 OID 18830)
-- Name: tb_sys_perfil unq_perfil_syscode_perfil_id; Type: CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT unq_perfil_syscode_perfil_id UNIQUE (sys_systemcode, perfil_id);


--
-- TOC entry 3187 (class 2606 OID 18832)
-- Name: tb_producto_detalle unq_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT unq_producto_detalle UNIQUE (insumo_id_origen, insumo_id);


--
-- TOC entry 3198 (class 2606 OID 18834)
-- Name: tb_producto_procesos_detalle unq_producto_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT unq_producto_procesos_detalle UNIQUE (producto_procesos_id, procesos_codigo);


--
-- TOC entry 3192 (class 2606 OID 18836)
-- Name: tb_producto_procesos unq_producto_procesos_insumo_id_fecha; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos
    ADD CONSTRAINT unq_producto_procesos_insumo_id_fecha UNIQUE (insumo_id, producto_procesos_fecha_desde);


--
-- TOC entry 3237 (class 2606 OID 18840)
-- Name: tb_taplicacion_procesos_detalle unq_taplicacion_procesos_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT unq_taplicacion_procesos_detalle UNIQUE (taplicacion_procesos_id, procesos_codigo);


--
-- TOC entry 3231 (class 2606 OID 18842)
-- Name: tb_taplicacion_procesos unq_taplicacion_procesos_taplicacion_codigo_fecha; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos
    ADD CONSTRAINT unq_taplicacion_procesos_taplicacion_codigo_fecha UNIQUE (taplicacion_codigo, taplicacion_procesos_fecha_desde);


--
-- TOC entry 3245 (class 2606 OID 18844)
-- Name: tb_tcosto_global_entries uq_tcosto_global_entries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT uq_tcosto_global_entries UNIQUE (tcosto_global_codigo, tcosto_global_entries_fecha_desde);


--
-- TOC entry 3264 (class 2606 OID 18846)
-- Name: tb_unidad_medida_conversion uq_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT uq_unidad_conversion UNIQUE (unidad_medida_origen, unidad_medida_destino);


--
-- TOC entry 3268 (class 1259 OID 45926)
-- Name: fki_costos_list_detalle_costos_list; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_costos_list_detalle_costos_list ON public.tb_costos_list_detalle USING btree (costos_list_id);


--
-- TOC entry 3269 (class 1259 OID 45925)
-- Name: fki_costos_list_detalle_insumo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_costos_list_detalle_insumo ON public.tb_costos_list_detalle USING btree (insumo_id);


--
-- TOC entry 3154 (class 1259 OID 18858)
-- Name: fki_empresa_tipo_empresa; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_empresa_tipo_empresa ON public.tb_empresa USING btree (tipo_empresa_codigo);


--
-- TOC entry 3163 (class 1259 OID 18867)
-- Name: fki_insumo_moneda_costo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_moneda_costo ON public.tb_insumo USING btree (moneda_codigo_costo);


--
-- TOC entry 3164 (class 1259 OID 18868)
-- Name: fki_insumo_taplicacion_entries; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_taplicacion_entries ON public.tb_insumo USING btree (taplicacion_entries_id);


--
-- TOC entry 3165 (class 1259 OID 18869)
-- Name: fki_insumo_tcostos; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_tcostos ON public.tb_insumo USING btree (tcostos_codigo);


--
-- TOC entry 3166 (class 1259 OID 18870)
-- Name: fki_insumo_tinsumo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_tinsumo ON public.tb_insumo USING btree (tinsumo_codigo);


--
-- TOC entry 3167 (class 1259 OID 18871)
-- Name: fki_insumo_unidad_medida_costo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_unidad_medida_costo ON public.tb_insumo USING btree (unidad_medida_codigo_costo);


--
-- TOC entry 3168 (class 1259 OID 18872)
-- Name: fki_insumo_unidad_medida_ingreso; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_insumo_unidad_medida_ingreso ON public.tb_insumo USING btree (unidad_medida_codigo_ingreso);


--
-- TOC entry 3201 (class 1259 OID 18873)
-- Name: fki_menu_parent_id; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_menu_parent_id ON public.tb_sys_menu USING btree (menu_parent_id);


--
-- TOC entry 3202 (class 1259 OID 18874)
-- Name: fki_menu_sistemas; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_menu_sistemas ON public.tb_sys_menu USING btree (sys_systemcode);


--
-- TOC entry 3207 (class 1259 OID 18875)
-- Name: fki_perfil_sistema; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_perfil_sistema ON public.tb_sys_perfil USING btree (sys_systemcode);


--
-- TOC entry 3218 (class 1259 OID 18876)
-- Name: fki_perfil_usuario; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_perfil_usuario ON public.tb_sys_usuario_perfiles USING btree (perfil_id);


--
-- TOC entry 3177 (class 1259 OID 18877)
-- Name: fki_produccion_taplicacion_entries; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_produccion_taplicacion_entries ON public.tb_produccion USING btree (taplicacion_entries_id);


--
-- TOC entry 3178 (class 1259 OID 18878)
-- Name: fki_produccion_unidad_medida_qty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_produccion_unidad_medida_qty ON public.tb_produccion USING btree (unidad_medida_codigo);


--
-- TOC entry 3182 (class 1259 OID 18880)
-- Name: fki_producto_detalle_insumo_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_detalle_insumo_id ON public.tb_producto_detalle USING btree (insumo_id);


--
-- TOC entry 3183 (class 1259 OID 18881)
-- Name: fki_producto_detalle_unidad_medida; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_detalle_unidad_medida ON public.tb_producto_detalle USING btree (unidad_medida_codigo);


--
-- TOC entry 3193 (class 1259 OID 18882)
-- Name: fki_producto_procesos_detalle_procesos_codigo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_procesos_detalle_procesos_codigo ON public.tb_producto_procesos_detalle USING btree (procesos_codigo);


--
-- TOC entry 3194 (class 1259 OID 18883)
-- Name: fki_producto_procesos_detalle_procesos_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_procesos_detalle_procesos_id ON public.tb_producto_procesos_detalle USING btree (producto_procesos_id);


--
-- TOC entry 3188 (class 1259 OID 18884)
-- Name: fki_producto_procesos_insumo_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_producto_procesos_insumo_id ON public.tb_producto_procesos USING btree (insumo_id);


--
-- TOC entry 3224 (class 1259 OID 18885)
-- Name: fki_taplicacion_entries_taplicacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_taplicacion_entries_taplicacion ON public.tb_taplicacion_entries USING btree (taplicacion_codigo);


--
-- TOC entry 3232 (class 1259 OID 18886)
-- Name: fki_taplicacion_procesos_detalle_procesos_codigo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_taplicacion_procesos_detalle_procesos_codigo ON public.tb_taplicacion_procesos_detalle USING btree (procesos_codigo);


--
-- TOC entry 3233 (class 1259 OID 18887)
-- Name: fki_taplicacion_procesos_detalle_procesos_id; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_taplicacion_procesos_detalle_procesos_id ON public.tb_taplicacion_procesos_detalle USING btree (taplicacion_procesos_id);


--
-- TOC entry 3227 (class 1259 OID 18888)
-- Name: fki_taplicacion_procesos_taplicacion_codigo; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_taplicacion_procesos_taplicacion_codigo ON public.tb_taplicacion_procesos USING btree (taplicacion_codigo);


--
-- TOC entry 3255 (class 1259 OID 54175)
-- Name: fki_taplicacion_unidad_medida_costo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_taplicacion_unidad_medida_costo ON public.tb_tpresentacion USING btree (unidad_medida_codigo_costo);


--
-- TOC entry 3240 (class 1259 OID 18889)
-- Name: fki_tcosto_global_entries_moneda; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_tcosto_global_entries_moneda ON public.tb_tcosto_global_entries USING btree (moneda_codigo);


--
-- TOC entry 3241 (class 1259 OID 18890)
-- Name: fki_tcosto_global_entries_tcosto_global; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_tcosto_global_entries_tcosto_global ON public.tb_tcosto_global_entries USING btree (tcosto_global_codigo);


--
-- TOC entry 3260 (class 1259 OID 18891)
-- Name: fki_unidad_conversion_medida_destino; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX fki_unidad_conversion_medida_destino ON public.tb_unidad_medida_conversion USING btree (unidad_medida_destino);


--
-- TOC entry 3219 (class 1259 OID 18893)
-- Name: fki_usuarioperfiles; Type: INDEX; Schema: public; Owner: atluser
--

CREATE INDEX fki_usuarioperfiles ON public.tb_sys_usuario_perfiles USING btree (usuarios_id);


--
-- TOC entry 3147 (class 1259 OID 18894)
-- Name: idx_sessions_last_activity; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE INDEX idx_sessions_last_activity ON public.ci_sessions USING btree (last_activity);


--
-- TOC entry 3265 (class 1259 OID 18895)
-- Name: idx_unique_usuarios; Type: INDEX; Schema: public; Owner: atluser
--

CREATE UNIQUE INDEX idx_unique_usuarios ON public.tb_usuarios USING btree (upper((usuarios_code)::text));


--
-- TOC entry 3155 (class 1259 OID 18898)
-- Name: idx_unq_empresa_razon_social; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_empresa_razon_social ON public.tb_empresa USING btree (upper((empresa_razon_social)::text));


--
-- TOC entry 3156 (class 1259 OID 18899)
-- Name: idx_unq_empresa_ruc; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_empresa_ruc ON public.tb_empresa USING btree (upper((empresa_ruc)::text));


--
-- TOC entry 3252 (class 1259 OID 18901)
-- Name: idx_unq_tipo_empresa_descripcion; Type: INDEX; Schema: public; Owner: clabsuser
--

CREATE UNIQUE INDEX idx_unq_tipo_empresa_descripcion ON public.tb_tipo_empresa USING btree (upper((tipo_empresa_descripcion)::text));


--
-- TOC entry 3181 (class 1259 OID 18902)
-- Name: uq_produccion_taplicacion_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_produccion_taplicacion_fecha ON public.tb_produccion USING btree (taplicacion_entries_id, produccion_fecha);


--
-- TOC entry 3362 (class 2620 OID 18903)
-- Name: tb_usuarios sptrg_verify_usuario_code_change; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER sptrg_verify_usuario_code_change BEFORE INSERT OR DELETE OR UPDATE ON public.tb_usuarios FOR EACH ROW EXECUTE FUNCTION public.sptrg_verify_usuario_code_change();


--
-- TOC entry 3309 (class 2620 OID 18915)
-- Name: tb_empresa tr_empresa; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_empresa BEFORE INSERT OR UPDATE ON public.tb_empresa FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3310 (class 2620 OID 18917)
-- Name: tb_entidad tr_entidad; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entidad BEFORE INSERT OR UPDATE ON public.tb_entidad FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3311 (class 2620 OID 18918)
-- Name: tb_ffarmaceutica tr_ffarmaceutica_validate_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_ffarmaceutica_validate_delete BEFORE DELETE ON public.tb_ffarmaceutica FOR EACH ROW EXECUTE FUNCTION public.sptrg_ffarmaceutica_validate_delete();


--
-- TOC entry 3312 (class 2620 OID 18919)
-- Name: tb_ffarmaceutica tr_ffarmaceutica_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_ffarmaceutica_validate_save BEFORE INSERT OR UPDATE ON public.tb_ffarmaceutica FOR EACH ROW EXECUTE FUNCTION public.sptrg_ffarmaceutica_validate_save();


--
-- TOC entry 3314 (class 2620 OID 18924)
-- Name: tb_insumo tr_insumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_validate_save BEFORE INSERT OR UPDATE ON public.tb_insumo FOR EACH ROW EXECUTE FUNCTION public.sptrg_insumo_validate_save();


--
-- TOC entry 3316 (class 2620 OID 18925)
-- Name: tb_moneda tr_moneda_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_moneda_validate_save BEFORE INSERT OR UPDATE ON public.tb_moneda FOR EACH ROW EXECUTE FUNCTION public.sptrg_moneda_validate_save();


--
-- TOC entry 3318 (class 2620 OID 18926)
-- Name: tb_procesos tr_procesos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_procesos_validate_save BEFORE INSERT OR UPDATE ON public.tb_procesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_procesos_validate_save();


--
-- TOC entry 3320 (class 2620 OID 18927)
-- Name: tb_produccion tr_produccion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_produccion BEFORE INSERT OR UPDATE ON public.tb_produccion FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3321 (class 2620 OID 18928)
-- Name: tb_producto_detalle tr_producto_detalle_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_detalle_validate_delete BEFORE DELETE ON public.tb_producto_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_producto_detalle_validate_delete();


--
-- TOC entry 3322 (class 2620 OID 18929)
-- Name: tb_producto_detalle tr_producto_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_producto_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_producto_detalle_validate_save();


--
-- TOC entry 3326 (class 2620 OID 18930)
-- Name: tb_producto_procesos_detalle tr_producto_procesos_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_procesos_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_producto_procesos_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_producto_procesos_detalle_validate_save();


--
-- TOC entry 3324 (class 2620 OID 18931)
-- Name: tb_producto_procesos tr_producto_procesos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_procesos_validate_save BEFORE INSERT OR UPDATE ON public.tb_producto_procesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_producto_procesos_validate_save();


--
-- TOC entry 3328 (class 2620 OID 18933)
-- Name: tb_subprocesos tr_subprocesos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_subprocesos_validate_save BEFORE INSERT OR UPDATE ON public.tb_subprocesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_subprocesos_validate_save();


--
-- TOC entry 3330 (class 2620 OID 18934)
-- Name: tb_sys_perfil tr_sys_perfil; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil BEFORE INSERT OR UPDATE ON public.tb_sys_perfil FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3331 (class 2620 OID 18935)
-- Name: tb_sys_perfil_detalle tr_sys_perfil_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil_detalle BEFORE INSERT OR UPDATE ON public.tb_sys_perfil_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3332 (class 2620 OID 18936)
-- Name: tb_sys_sistemas tr_sys_sistemas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_sistemas BEFORE INSERT OR UPDATE ON public.tb_sys_sistemas FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3333 (class 2620 OID 18937)
-- Name: tb_sys_usuario_perfiles tr_sys_usuario_perfiles; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_usuario_perfiles BEFORE INSERT OR UPDATE ON public.tb_sys_usuario_perfiles FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3337 (class 2620 OID 18938)
-- Name: tb_taplicacion_entries tr_taplicacion_entries_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_taplicacion_entries_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion_entries FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3338 (class 2620 OID 18939)
-- Name: tb_taplicacion_entries tr_taplicacion_entries_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_taplicacion_entries_validate_save BEFORE INSERT OR UPDATE ON public.tb_taplicacion_entries FOR EACH ROW EXECUTE FUNCTION public.sptrg_taplicacion_entries_validate_save();


--
-- TOC entry 3340 (class 2620 OID 18940)
-- Name: tb_taplicacion_procesos_detalle tr_taplicacion_procesos_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_taplicacion_procesos_detalle_validate_save BEFORE INSERT OR UPDATE ON public.tb_taplicacion_procesos_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_taplicacion_procesos_detalle_validate_save();


--
-- TOC entry 3335 (class 2620 OID 18941)
-- Name: tb_taplicacion tr_taplicacion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_taplicacion_validate_save BEFORE INSERT OR UPDATE ON public.tb_taplicacion FOR EACH ROW EXECUTE FUNCTION public.sptrg_taplicacion_validate_save();


--
-- TOC entry 3344 (class 2620 OID 18942)
-- Name: tb_tcosto_global_entries tr_tcosto_global_entries_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_tcosto_global_entries_log_fields BEFORE INSERT OR UPDATE ON public.tb_tcosto_global_entries FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3342 (class 2620 OID 18943)
-- Name: tb_tcosto_global tr_tcosto_global_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcosto_global_log_fields BEFORE INSERT OR UPDATE ON public.tb_tcosto_global FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3343 (class 2620 OID 18944)
-- Name: tb_tcosto_global tr_tcosto_global_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcosto_global_validate_save BEFORE INSERT OR UPDATE ON public.tb_tcosto_global FOR EACH ROW EXECUTE FUNCTION public.sptrg_tcosto_global_validate_save();


--
-- TOC entry 3345 (class 2620 OID 18945)
-- Name: tb_tcostos tr_tcostos_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_delete BEFORE DELETE ON public.tb_tcostos FOR EACH ROW EXECUTE FUNCTION public.sptrg_tcostos_validate_delete();


--
-- TOC entry 3346 (class 2620 OID 18946)
-- Name: tb_tcostos tr_tcostos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_save BEFORE INSERT OR UPDATE ON public.tb_tcostos FOR EACH ROW EXECUTE FUNCTION public.sptrg_tcostos_validate_save();


--
-- TOC entry 3348 (class 2620 OID 18947)
-- Name: tb_tinsumo tr_tinsumo_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_delete BEFORE DELETE ON public.tb_tinsumo FOR EACH ROW EXECUTE FUNCTION public.sptrg_tinsumo_validate_delete();


--
-- TOC entry 3349 (class 2620 OID 18948)
-- Name: tb_tinsumo tr_tinsumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_save BEFORE INSERT OR UPDATE ON public.tb_tinsumo FOR EACH ROW EXECUTE FUNCTION public.sptrg_tinsumo_validate_save();


--
-- TOC entry 3351 (class 2620 OID 18949)
-- Name: tb_tipo_cambio tr_tipo_cambio; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio BEFORE INSERT OR UPDATE ON public.tb_tipo_cambio FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3352 (class 2620 OID 18950)
-- Name: tb_tipo_cambio tr_tipo_cambio_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio_validate_save BEFORE INSERT OR UPDATE ON public.tb_tipo_cambio FOR EACH ROW EXECUTE FUNCTION public.sptrg_tipo_cambio_validate_save();


--
-- TOC entry 3354 (class 2620 OID 18951)
-- Name: tb_tpresentacion tr_tpresentacion_validate_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_tpresentacion_validate_delete BEFORE DELETE ON public.tb_tpresentacion FOR EACH ROW EXECUTE FUNCTION public.sptrg_tpresentacion_validate_delete();


--
-- TOC entry 3355 (class 2620 OID 18952)
-- Name: tb_tpresentacion tr_tpresentacion_validate_save; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_tpresentacion_validate_save BEFORE INSERT OR UPDATE ON public.tb_tpresentacion FOR EACH ROW EXECUTE FUNCTION public.sptrg_tpresentacion_validate_save();


--
-- TOC entry 3360 (class 2620 OID 18953)
-- Name: tb_unidad_medida_conversion tr_unidad_medida_conversion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_conversion_validate_save BEFORE INSERT OR UPDATE ON public.tb_unidad_medida_conversion FOR EACH ROW EXECUTE FUNCTION public.sptrg_unidad_medida_conversion_validate_save();


--
-- TOC entry 3357 (class 2620 OID 18954)
-- Name: tb_unidad_medida tr_unidad_medida_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_delete BEFORE DELETE ON public.tb_unidad_medida FOR EACH ROW EXECUTE FUNCTION public.sptrg_unidad_medida_validate_delete();


--
-- TOC entry 3358 (class 2620 OID 18955)
-- Name: tb_unidad_medida tr_unidad_medida_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_save BEFORE INSERT OR UPDATE ON public.tb_unidad_medida FOR EACH ROW EXECUTE FUNCTION public.sptrg_unidad_medida_validate_save();


--
-- TOC entry 3313 (class 2620 OID 18956)
-- Name: tb_ffarmaceutica tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_ffarmaceutica FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3315 (class 2620 OID 18958)
-- Name: tb_insumo tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_insumo FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3317 (class 2620 OID 18959)
-- Name: tb_moneda tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_moneda FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3319 (class 2620 OID 18960)
-- Name: tb_procesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_procesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3323 (class 2620 OID 18961)
-- Name: tb_producto_detalle tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_producto_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3325 (class 2620 OID 18962)
-- Name: tb_producto_procesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_producto_procesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3327 (class 2620 OID 18963)
-- Name: tb_producto_procesos_detalle tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_producto_procesos_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3329 (class 2620 OID 18965)
-- Name: tb_subprocesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_subprocesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3336 (class 2620 OID 18966)
-- Name: tb_taplicacion tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3339 (class 2620 OID 18967)
-- Name: tb_taplicacion_procesos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion_procesos FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3341 (class 2620 OID 18968)
-- Name: tb_taplicacion_procesos_detalle tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_taplicacion_procesos_detalle FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3347 (class 2620 OID 18969)
-- Name: tb_tcostos tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tcostos FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3350 (class 2620 OID 18970)
-- Name: tb_tinsumo tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tinsumo FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3353 (class 2620 OID 18972)
-- Name: tb_tipo_empresa tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tipo_empresa FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3356 (class 2620 OID 18973)
-- Name: tb_tpresentacion tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_tpresentacion FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3359 (class 2620 OID 18974)
-- Name: tb_unidad_medida tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_unidad_medida FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3361 (class 2620 OID 18975)
-- Name: tb_unidad_medida_conversion tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON public.tb_unidad_medida_conversion FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3334 (class 2620 OID 18976)
-- Name: tb_sys_usuario_perfiles tr_usuario_perfiles_save; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuario_perfiles_save BEFORE INSERT OR UPDATE ON public.tb_sys_usuario_perfiles FOR EACH ROW EXECUTE FUNCTION public.sptrg_usuario_perfiles_save();


--
-- TOC entry 3363 (class 2620 OID 18977)
-- Name: tb_usuarios tr_usuarios; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuarios BEFORE INSERT OR UPDATE ON public.tb_usuarios FOR EACH ROW EXECUTE FUNCTION public.sptrg_update_log_fields();


--
-- TOC entry 3307 (class 2606 OID 45915)
-- Name: tb_costos_list_detalle fk_costos_list_detalle_costos_list; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list_detalle
    ADD CONSTRAINT fk_costos_list_detalle_costos_list FOREIGN KEY (costos_list_id) REFERENCES public.tb_costos_list(costos_list_id) ON DELETE CASCADE;


--
-- TOC entry 3308 (class 2606 OID 45920)
-- Name: tb_costos_list_detalle fk_costos_list_detalle_insumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_costos_list_detalle
    ADD CONSTRAINT fk_costos_list_detalle_insumo FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3274 (class 2606 OID 19038)
-- Name: tb_empresa fk_empresa_tipo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_empresa
    ADD CONSTRAINT fk_empresa_tipo_empresa FOREIGN KEY (tipo_empresa_codigo) REFERENCES public.tb_tipo_empresa(tipo_empresa_codigo);


--
-- TOC entry 3275 (class 2606 OID 19083)
-- Name: tb_insumo fk_insumo_moneda_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_moneda_costo FOREIGN KEY (moneda_codigo_costo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3276 (class 2606 OID 19088)
-- Name: tb_insumo fk_insumo_taplicacion_entries; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_taplicacion_entries FOREIGN KEY (taplicacion_entries_id) REFERENCES public.tb_taplicacion_entries(taplicacion_entries_id);


--
-- TOC entry 3277 (class 2606 OID 19093)
-- Name: tb_insumo fk_insumo_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES public.tb_tcostos(tcostos_codigo);


--
-- TOC entry 3278 (class 2606 OID 19098)
-- Name: tb_insumo fk_insumo_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES public.tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 3281 (class 2606 OID 62334)
-- Name: tb_insumo fk_insumo_tpresentacion_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_tpresentacion_codigo FOREIGN KEY (tpresentacion_codigo) REFERENCES public.tb_tpresentacion(tpresentacion_codigo);


--
-- TOC entry 3279 (class 2606 OID 19103)
-- Name: tb_insumo fk_insumo_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3280 (class 2606 OID 19108)
-- Name: tb_insumo fk_insumo_unidad_medida_ingreso; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_insumo
    ADD CONSTRAINT fk_insumo_unidad_medida_ingreso FOREIGN KEY (unidad_medida_codigo_ingreso) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3290 (class 2606 OID 19113)
-- Name: tb_sys_menu fk_menu_parent; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES public.tb_sys_menu(menu_id);


--
-- TOC entry 3291 (class 2606 OID 19118)
-- Name: tb_sys_menu fk_menu_sistemas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_menu
    ADD CONSTRAINT fk_menu_sistemas FOREIGN KEY (sys_systemcode) REFERENCES public.tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 3302 (class 2606 OID 19123)
-- Name: tb_tipo_cambio fk_moneda_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio
    ADD CONSTRAINT fk_moneda_destino FOREIGN KEY (moneda_codigo_destino) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3303 (class 2606 OID 19128)
-- Name: tb_tipo_cambio fk_moneda_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_tipo_cambio
    ADD CONSTRAINT fk_moneda_origen FOREIGN KEY (moneda_codigo_origen) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3293 (class 2606 OID 19133)
-- Name: tb_sys_perfil_detalle fk_perfdet_perfil; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil_detalle
    ADD CONSTRAINT fk_perfdet_perfil FOREIGN KEY (perfil_id) REFERENCES public.tb_sys_perfil(perfil_id);


--
-- TOC entry 3292 (class 2606 OID 19138)
-- Name: tb_sys_perfil fk_perfil_sistema; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_perfil
    ADD CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode) REFERENCES public.tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 3282 (class 2606 OID 19143)
-- Name: tb_produccion fk_produccion_taplicacion_entries; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion
    ADD CONSTRAINT fk_produccion_taplicacion_entries FOREIGN KEY (taplicacion_entries_id) REFERENCES public.tb_taplicacion_entries(taplicacion_entries_id) ON DELETE CASCADE;


--
-- TOC entry 3283 (class 2606 OID 19148)
-- Name: tb_produccion fk_produccion_unidad_medida_codigo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_produccion
    ADD CONSTRAINT fk_produccion_unidad_medida_codigo FOREIGN KEY (unidad_medida_codigo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3284 (class 2606 OID 19158)
-- Name: tb_producto_detalle fk_producto_detalle_insumo_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_insumo_id FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3285 (class 2606 OID 19163)
-- Name: tb_producto_detalle fk_producto_detalle_insumo_id_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_insumo_id_origen FOREIGN KEY (insumo_id_origen) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3286 (class 2606 OID 19168)
-- Name: tb_producto_detalle fk_producto_detalle_unidad_medida; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_detalle
    ADD CONSTRAINT fk_producto_detalle_unidad_medida FOREIGN KEY (unidad_medida_codigo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3288 (class 2606 OID 19173)
-- Name: tb_producto_procesos_detalle fk_producto_procesos_detalle_procesos_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT fk_producto_procesos_detalle_procesos_codigo FOREIGN KEY (procesos_codigo) REFERENCES public.tb_procesos(procesos_codigo);


--
-- TOC entry 3289 (class 2606 OID 19178)
-- Name: tb_producto_procesos_detalle fk_producto_procesos_detalle_producto_procesos_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos_detalle
    ADD CONSTRAINT fk_producto_procesos_detalle_producto_procesos_id FOREIGN KEY (producto_procesos_id) REFERENCES public.tb_producto_procesos(producto_procesos_id) ON DELETE CASCADE;


--
-- TOC entry 3287 (class 2606 OID 19183)
-- Name: tb_producto_procesos fk_producto_procesos_insumo_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_producto_procesos
    ADD CONSTRAINT fk_producto_procesos_insumo_id FOREIGN KEY (insumo_id) REFERENCES public.tb_insumo(insumo_id);


--
-- TOC entry 3296 (class 2606 OID 19198)
-- Name: tb_taplicacion_entries fk_taplicacion_entries_taplicacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_taplicacion_entries
    ADD CONSTRAINT fk_taplicacion_entries_taplicacion FOREIGN KEY (taplicacion_codigo) REFERENCES public.tb_taplicacion(taplicacion_codigo);


--
-- TOC entry 3298 (class 2606 OID 19203)
-- Name: tb_taplicacion_procesos_detalle fk_taplicacion_procesos_detalle_procesos_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT fk_taplicacion_procesos_detalle_procesos_codigo FOREIGN KEY (procesos_codigo) REFERENCES public.tb_procesos(procesos_codigo);


--
-- TOC entry 3299 (class 2606 OID 19208)
-- Name: tb_taplicacion_procesos_detalle fk_taplicacion_procesos_detalle_taplicacion_procesos_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos_detalle
    ADD CONSTRAINT fk_taplicacion_procesos_detalle_taplicacion_procesos_id FOREIGN KEY (taplicacion_procesos_id) REFERENCES public.tb_taplicacion_procesos(taplicacion_procesos_id) ON DELETE CASCADE;


--
-- TOC entry 3297 (class 2606 OID 19213)
-- Name: tb_taplicacion_procesos fk_taplicacion_procesos_taplicacion_codigo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_taplicacion_procesos
    ADD CONSTRAINT fk_taplicacion_procesos_taplicacion_codigo FOREIGN KEY (taplicacion_codigo) REFERENCES public.tb_taplicacion(taplicacion_codigo);


--
-- TOC entry 3300 (class 2606 OID 19218)
-- Name: tb_tcosto_global_entries fk_tcosto_global_entries_moneda_codigo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT fk_tcosto_global_entries_moneda_codigo FOREIGN KEY (moneda_codigo) REFERENCES public.tb_moneda(moneda_codigo);


--
-- TOC entry 3301 (class 2606 OID 19223)
-- Name: tb_tcosto_global_entries fk_tcosto_global_entries_tcosto_global; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tcosto_global_entries
    ADD CONSTRAINT fk_tcosto_global_entries_tcosto_global FOREIGN KEY (tcosto_global_codigo) REFERENCES public.tb_tcosto_global(tcosto_global_codigo);


--
-- TOC entry 3304 (class 2606 OID 54170)
-- Name: tb_tpresentacion fk_tpresentacion_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tpresentacion
    ADD CONSTRAINT fk_tpresentacion_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3305 (class 2606 OID 19228)
-- Name: tb_unidad_medida_conversion fk_unidad_conversion_medida_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT fk_unidad_conversion_medida_destino FOREIGN KEY (unidad_medida_destino) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3306 (class 2606 OID 19233)
-- Name: tb_unidad_medida_conversion fk_unidad_conversion_medida_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY public.tb_unidad_medida_conversion
    ADD CONSTRAINT fk_unidad_conversion_medida_origen FOREIGN KEY (unidad_medida_origen) REFERENCES public.tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 3294 (class 2606 OID 19243)
-- Name: tb_sys_usuario_perfiles fk_usuarioperfiles; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles
    ADD CONSTRAINT fk_usuarioperfiles FOREIGN KEY (perfil_id) REFERENCES public.tb_sys_perfil(perfil_id);


--
-- TOC entry 3295 (class 2606 OID 19248)
-- Name: tb_sys_usuario_perfiles fk_usuarioperfiles_usuario; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY public.tb_sys_usuario_perfiles
    ADD CONSTRAINT fk_usuarioperfiles_usuario FOREIGN KEY (usuarios_id) REFERENCES public.tb_usuarios(usuarios_id);


-- Completed on 2021-09-06 21:04:01 -05

--
-- PostgreSQL database dump complete
--

