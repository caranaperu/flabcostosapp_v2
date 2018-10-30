--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.15
-- Dumped by pg_dump version 9.3.16
-- Started on 2017-02-23 02:08:16 PET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1 (class 3079 OID 11829)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2562 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 109557)
-- Name: pldbgapi; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;


--
-- TOC entry 2563 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pldbgapi; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';


SET search_path = public, pg_catalog;

--
-- TOC entry 253 (class 1255 OID 100645)
-- Name: fn_get_cotizacion_next_id(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_cotizacion_next_id() RETURNS integer
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
-- TOC entry 287 (class 1255 OID 109595)
-- Name: fn_get_producto_costo(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_costo(p_insumo_id integer, p_a_fecha date) RETURNS numeric
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
-- TOC entry 283 (class 1255 OID 109596)
-- Name: fn_get_producto_detalle_costo(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_detalle_costo(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
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
  DECLARE v_regla_by_costo boolean;


BEGIN

  -- Leemos los valoresa trabajar.
  SELECT     pd.producto_detalle_id,
    pd.insumo_id,
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
    rg.regla_by_costo
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
    v_tcostos_indirecto,
    v_regla_by_costo
  FROM       tb_producto_detalle pd
    inner join tb_insumo ins  ON ins.insumo_id = pd.insumo_id
    inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
    inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
    left join tb_reglas rg on rg.regla_empresa_origen_id = ins.empresa_id and rg.regla_empresa_destino_id = inso.empresa_id
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
-- TOC entry 282 (class 1255 OID 109600)
-- Name: fn_get_producto_detalle_costo_base(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_detalle_costo_base(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
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
  DECLARE v_insumo_precio_mercado numeric(10,2);
  DECLARE v_tcostos_indirecto boolean;
  DECLARE v_regla_id integer;
  DECLARE v_regla_by_costo boolean;
  DECLARE v_regla_porcentaje numeric(6,2);
  DECLARE v_tipo_cambio_tasa_compra  numeric(8,4);
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
    v_insumo_precio_mercado,
    v_empresa_usuaria_id,
    v_empresa_propietaria_id,
    v_insumo_merma_venta,
    v_tcostos_indirecto,
    v_regla_id,
    v_regla_by_costo,
    v_regla_porcentaje
  FROM   tb_producto_detalle pd
    inner join tb_insumo ins  ON ins.insumo_id = pd.insumo_id
    inner join tb_insumo inso ON inso.insumo_id = pd.insumo_id_origen
    inner join tb_tcostos tc ON tc.tcostos_codigo = ins.tcostos_codigo
    left join tb_reglas rg on rg.regla_empresa_origen_id = ins.empresa_id and rg.regla_empresa_destino_id = inso.empresa_id
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
    IF v_insumo_costo > 0 and v_regla_id IS NOT NULL and v_tcostos_indirecto = FALSE
    THEN
      IF v_regla_by_costo = TRUE
      THEN
        v_insumo_costo = v_insumo_costo + (v_insumo_costo*v_regla_porcentaje)/100.00;
      ELSE
        --	v_tipo_cambio_tasa_compra = 1.000;
        --	IF v_insumo_precio_mercado*v_tipo_cambio_tasa_compra - v_insumo_costo <= 00
        --    THEN
        --    	RAISE  'El precio de mercado es menor que el costo de %',v_insumo_costo USING ERRCODE = 'restrict_violation';
        --    END IF;

        v_insumo_costo = v_insumo_costo+(v_insumo_precio_mercado- v_insumo_costo)*v_regla_porcentaje/100.00;

      END IF;


    END IF;
  END IF;

  RETURN v_insumo_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_detalle_costo_base(p_producto_detalle_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 281 (class 1255 OID 92253)
-- Name: fn_get_producto_detalle_costo_old(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_detalle_costo_old(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
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
-- TOC entry 301 (class 1255 OID 262833)
-- Name: fn_get_producto_precio(integer, integer, integer, boolean, character varying, date, boolean); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_precio(p_insumo_id integer, p_empresa_id integer, p_cliente_id integer, p_es_cliente_real boolean, p_moneda_codigo character varying, p_a_fecha date, p_use_exceptions boolean) RETURNS numeric
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
-- TOC entry 258 (class 1255 OID 109484)
-- Name: fn_get_producto_precio_old(integer, integer, integer, boolean, character varying, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_producto_precio_old(p_insumo_id integer, p_empresa_id integer, p_cliente_id integer, p_es_cliente_real boolean, p_moneda_codigo character varying, p_a_fecha date) RETURNS numeric
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
-- TOC entry 240 (class 1255 OID 58417)
-- Name: sp_asigperfiles_save_record(integer, integer, integer, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_asigperfiles_save_record(p_asigperfiles_id integer, p_perfil_id integer, p_usuarios_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
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
-- TOC entry 252 (class 1255 OID 100640)
-- Name: sp_get_cantidad_insumos_for_producto(integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_cantidad_insumos_for_producto(p_insumo_id integer) RETURNS TABLE(insumo_id integer, insumo_descripcion character varying, unidad_medida_codigo_default character varying, total_cantidad numeric)
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
-- TOC entry 286 (class 1255 OID 101225)
-- Name: sp_get_clientes_for_cotizacion(integer, character varying, integer, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_clientes_for_cotizacion(p_empresa_origen_id integer, p_cliente_razon_social character varying, pc_cliente_id integer, pc_es_cliente_real boolean, p_max_results integer, p_offset integer) RETURNS TABLE(cliente_id integer, cliente_razon_social character varying, tipo_empresa_codigo character varying)
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
-- TOC entry 285 (class 1255 OID 100639)
-- Name: sp_get_datos_insumos_for_producto(integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_datos_insumos_for_producto(p_insumo_id integer) RETURNS TABLE(insumo_id integer, insumo_descripcion character varying, producto_detalle_cantidad numeric, unidad_medida_codigo character varying, producto_detalle_merma numeric, insumo_tipo character varying, tcostos_indirecto boolean, unidad_medida_codigo_default character varying, unidad_medida_conversion_factor numeric, producto_total_cantidad numeric)
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
-- TOC entry 298 (class 1255 OID 254645)
-- Name: sp_get_historico_costos_for_insumo(integer, date, date, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_get_historico_costos_for_insumo(p_insumo_id integer, p_date_from date, p_date_to date, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_codigo character varying, insumo_descripcion character varying, insumo_history_fecha timestamp without time zone, insumo_history_id integer, tinsumo_descripcion character varying, tcostos_descripcion character varying, unidad_medida_descripcion character varying, insumo_merma numeric, insumo_costo numeric, moneda_costo_descripcion character varying, insumo_precio_mercado numeric)
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
-- TOC entry 290 (class 1255 OID 100637)
-- Name: sp_get_insumos_for_producto(integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_insumos_for_producto(p_insumo_id integer) RETURNS TABLE(insumo_id integer, insumo_descripcion character varying, producto_detalle_cantidad numeric, unidad_medida_codigo character varying, producto_detalle_merma numeric, insumo_tipo character varying, tcostos_indirecto boolean, unidad_medida_codigo_default character varying, unidad_medida_conversion_factor numeric, producto_total_cantidad numeric)
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
-- TOC entry 256 (class 1255 OID 101230)
-- Name: sp_get_insumos_for_producto_detalle(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_insumos_for_producto_detalle(p_product_header_id integer, pc_insumo_id integer, p_insumo_descripcion character varying, p_max_results integer, p_offset integer) RETURNS TABLE(empresa_id integer, empresa_razon_social character varying, insumo_id integer, insumo_tipo character varying, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo_costo character varying, insumo_merma numeric, insumo_costo numeric, insumo_precio_mercado numeric, moneda_simbolo character varying, tcostos_indirecto boolean)
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
-- TOC entry 255 (class 1255 OID 101145)
-- Name: sp_get_insumos_for_producto_detalle_old(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_insumos_for_producto_detalle_old(p_product_header_id integer, p_max_results integer, p_offset integer) RETURNS TABLE(empresa_id integer, empresa_razon_social character varying, insumo_id integer, insumo_tipo character varying, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo_costo character varying, insumo_merma numeric, insumo_costo numeric, insumo_precio_mercado numeric, moneda_simbolo character varying, tcostos_indirecto boolean)
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
-- TOC entry 300 (class 1255 OID 109739)
-- Name: sp_get_productos_for_cotizacion(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_get_productos_for_cotizacion(p_cotizacion_id integer, pc_insumo_id integer, pc_insumo_descripcion character varying, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_id integer, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo character varying, unidad_medida_descripcion character varying, moneda_simbolo character varying, precio_original numeric, precio_cotizar numeric)
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
-- TOC entry 288 (class 1255 OID 109698)
-- Name: sp_get_productos_for_cotizacion_old(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_get_productos_for_cotizacion_old(p_cotizacion_id integer, p_max_results integer, p_offset integer) RETURNS TABLE(insumo_id integer, insumo_codigo character varying, insumo_descripcion character varying, unidad_medida_codigo character varying, unidad_medida_descripcion character varying, moneda_simbolo character varying, precio_original numeric, precio_cotizar numeric)
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
-- TOC entry 280 (class 1255 OID 84061)
-- Name: sp_insumo_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_insumo_delete_record(p_insumo_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
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
-- TOC entry 241 (class 1255 OID 58453)
-- Name: sp_perfil_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_perfil_delete_record(p_perfil_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
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
-- TOC entry 238 (class 1255 OID 58454)
-- Name: sp_perfil_detalle_save_record(integer, integer, integer, boolean, boolean, boolean, boolean, boolean, boolean, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_perfil_detalle_save_record(p_perfdet_id integer, p_perfil_id integer, p_menu_id integer, p_acc_leer boolean, p_acc_agregar boolean, p_acc_actualizar boolean, p_acc_eliminar boolean, p_acc_imprimir boolean, p_activo boolean, p_usuario character varying, p_version_id integer) RETURNS integer
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
-- TOC entry 242 (class 1255 OID 58480)
-- Name: sp_sysperfil_add_record(character varying, character varying, character varying, integer, boolean, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_sysperfil_add_record(p_sys_systemcode character varying, p_perfil_codigo character varying, p_perfil_descripcion character varying, p_copyfrom integer, p_activo boolean, p_usuario character varying) RETURNS integer
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
-- TOC entry 294 (class 1255 OID 101054)
-- Name: sptrg_cliente_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_cliente_validate_delete() RETURNS trigger
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
-- TOC entry 299 (class 1255 OID 246554)
-- Name: sptrg_cotizacion_detalle_validate_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_cotizacion_detalle_validate_delete() RETURNS trigger
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
-- TOC entry 292 (class 1255 OID 109695)
-- Name: sptrg_cotizacion_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_cotizacion_detalle_validate_save() RETURNS trigger
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
-- TOC entry 297 (class 1255 OID 246549)
-- Name: sptrg_cotizacion_producto_history_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_cotizacion_producto_history_log() RETURNS trigger
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
-- TOC entry 295 (class 1255 OID 110323)
-- Name: sptrg_cotizacion_validate_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_cotizacion_validate_delete() RETURNS trigger
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
-- TOC entry 254 (class 1255 OID 101052)
-- Name: sptrg_cotizacion_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_cotizacion_validate_save() RETURNS trigger
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
-- TOC entry 267 (class 1255 OID 101055)
-- Name: sptrg_empresa_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_empresa_validate_delete() RETURNS trigger
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
-- TOC entry 296 (class 1255 OID 246537)
-- Name: sptrg_insumo_history_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_insumo_history_log() RETURNS trigger
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
-- TOC entry 302 (class 1255 OID 59436)
-- Name: sptrg_insumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_insumo_validate_save() RETURNS trigger
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
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_insumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 246 (class 1255 OID 59408)
-- Name: sptrg_moneda_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_moneda_validate_save() RETURNS trigger
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
-- TOC entry 291 (class 1255 OID 75870)
-- Name: sptrg_producto_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_producto_detalle_validate_save() RETURNS trigger
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
-- TOC entry 284 (class 1255 OID 100541)
-- Name: sptrg_reglas_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_reglas_validate_save() RETURNS trigger
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
-- TOC entry 247 (class 1255 OID 75920)
-- Name: sptrg_tcostos_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tcostos_validate_delete() RETURNS trigger
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
-- TOC entry 249 (class 1255 OID 59493)
-- Name: sptrg_tcostos_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tcostos_validate_save() RETURNS trigger
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
-- TOC entry 293 (class 1255 OID 75922)
-- Name: sptrg_tinsumo_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tinsumo_validate_delete() RETURNS trigger
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
-- TOC entry 289 (class 1255 OID 59257)
-- Name: sptrg_tinsumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tinsumo_validate_save() RETURNS trigger
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
-- TOC entry 248 (class 1255 OID 59481)
-- Name: sptrg_tipo_cambio_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_tipo_cambio_validate_save() RETURNS trigger
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
-- TOC entry 239 (class 1255 OID 59370)
-- Name: sptrg_unidad_medida_conversion_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_unidad_medida_conversion_validate_save() RETURNS trigger
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
-- TOC entry 245 (class 1255 OID 75961)
-- Name: sptrg_unidad_medida_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_unidad_medida_validate_delete() RETURNS trigger
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
-- TOC entry 250 (class 1255 OID 59400)
-- Name: sptrg_unidad_medida_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_unidad_medida_validate_save() RETURNS trigger
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
-- TOC entry 243 (class 1255 OID 58511)
-- Name: sptrg_update_log_fields(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_update_log_fields() RETURNS trigger
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
-- TOC entry 251 (class 1255 OID 100553)
-- Name: sptrg_usuario_perfiles_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_usuario_perfiles_save() RETURNS trigger
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
-- TOC entry 244 (class 1255 OID 58512)
-- Name: sptrg_verify_usuario_code_change(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_verify_usuario_code_change() RETURNS trigger
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

SET default_with_oids = false;

--
-- TOC entry 206 (class 1259 OID 92399)
-- Name: ci_sessions; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE ci_sessions (
  session_id character varying(40) DEFAULT '0'::character varying NOT NULL,
  ip_address character varying(45) DEFAULT '0'::character varying NOT NULL,
  user_agent character varying(120) NOT NULL,
  last_activity integer DEFAULT 0 NOT NULL,
  user_data text NOT NULL
);


ALTER TABLE public.ci_sessions OWNER TO clabsuser;

--
-- TOC entry 212 (class 1259 OID 100956)
-- Name: tb_cliente; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_cliente (
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
-- TOC entry 211 (class 1259 OID 100954)
-- Name: tb_cliente_cliente_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_cliente_cliente_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_cliente_cliente_id_seq OWNER TO clabsuser;

--
-- TOC entry 2564 (class 0 OID 0)
-- Dependencies: 211
-- Name: tb_cliente_cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_cliente_cliente_id_seq OWNED BY tb_cliente.cliente_id;


--
-- TOC entry 214 (class 1259 OID 101028)
-- Name: tb_cotizacion; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_cotizacion (
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
-- TOC entry 213 (class 1259 OID 101026)
-- Name: tb_cotizacion_cotizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_cotizacion_cotizacion_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_cotizacion_cotizacion_id_seq OWNER TO clabsuser;

--
-- TOC entry 2565 (class 0 OID 0)
-- Dependencies: 213
-- Name: tb_cotizacion_cotizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_cotizacion_cotizacion_id_seq OWNED BY tb_cotizacion.cotizacion_id;


--
-- TOC entry 209 (class 1259 OID 100641)
-- Name: tb_cotizacion_counter; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_cotizacion_counter (
  cotizacion_counter_last_id integer NOT NULL
);


ALTER TABLE public.tb_cotizacion_counter OWNER TO clabsuser;

--
-- TOC entry 222 (class 1259 OID 109776)
-- Name: tb_cotizacion_detalle; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_cotizacion_detalle (
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
-- TOC entry 221 (class 1259 OID 109774)
-- Name: tb_cotizacion_detalle_cotizacion_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_cotizacion_detalle_cotizacion_detalle_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_cotizacion_detalle_cotizacion_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 2566 (class 0 OID 0)
-- Dependencies: 221
-- Name: tb_cotizacion_detalle_cotizacion_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_cotizacion_detalle_cotizacion_detalle_id_seq OWNED BY tb_cotizacion_detalle.cotizacion_detalle_id;


--
-- TOC entry 205 (class 1259 OID 92358)
-- Name: tb_empresa; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_empresa (
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
-- TOC entry 204 (class 1259 OID 92356)
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_empresa_empresa_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_empresa_empresa_id_seq OWNER TO clabsuser;

--
-- TOC entry 2567 (class 0 OID 0)
-- Dependencies: 204
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_empresa_empresa_id_seq OWNED BY tb_empresa.empresa_id;


--
-- TOC entry 203 (class 1259 OID 92328)
-- Name: tb_entidad; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_entidad (
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
-- TOC entry 2568 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE tb_entidad; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE tb_entidad IS 'Datos generales de la entidad que usa el sistema';


--
-- TOC entry 202 (class 1259 OID 92326)
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_entidad_entidad_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_entidad_entidad_id_seq OWNER TO atluser;

--
-- TOC entry 2569 (class 0 OID 0)
-- Dependencies: 202
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_entidad_entidad_id_seq OWNED BY tb_entidad.entidad_id;


--
-- TOC entry 223 (class 1259 OID 110317)
-- Name: tb_igv; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_igv (
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
-- TOC entry 198 (class 1259 OID 84160)
-- Name: tb_insumo; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_insumo (
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
-- TOC entry 225 (class 1259 OID 246561)
-- Name: tb_insumo_history; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE tb_insumo_history (
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
-- TOC entry 224 (class 1259 OID 246559)
-- Name: tb_insumo_history_insumo_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tb_insumo_history_insumo_history_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_insumo_history_insumo_history_id_seq OWNER TO postgres;

--
-- TOC entry 2570 (class 0 OID 0)
-- Dependencies: 224
-- Name: tb_insumo_history_insumo_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tb_insumo_history_insumo_history_id_seq OWNED BY tb_insumo_history.insumo_history_id;


--
-- TOC entry 197 (class 1259 OID 84158)
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_insumo_insumo_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_insumo_insumo_id_seq OWNER TO clabsuser;

--
-- TOC entry 2571 (class 0 OID 0)
-- Dependencies: 197
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_insumo_insumo_id_seq OWNED BY tb_insumo.insumo_id;


--
-- TOC entry 190 (class 1259 OID 59242)
-- Name: tb_moneda; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_moneda (
  moneda_codigo character varying(8) NOT NULL,
  moneda_simbolo character varying(6) NOT NULL,
  moneda_descripcion character varying(80) NOT NULL,
  moneda_protected boolean DEFAULT false NOT NULL,
  activo boolean DEFAULT true NOT NULL,
  usuario character varying(15) NOT NULL,
  fecha_creacion timestamp without time zone NOT NULL,
  usuario_mod character varying(15),
  fecha_modificacion timestamp without time zone,
  CONSTRAINT chk_moneda_field_len CHECK ((((length(rtrim((moneda_codigo)::text)) > 0) AND (length(rtrim((moneda_simbolo)::text)) > 0)) AND (length(rtrim((moneda_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_moneda OWNER TO clabsuser;

--
-- TOC entry 200 (class 1259 OID 84303)
-- Name: tb_producto_detalle; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_producto_detalle (
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
-- TOC entry 199 (class 1259 OID 84301)
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_producto_detalle_producto_detalle_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_producto_detalle_producto_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 2572 (class 0 OID 0)
-- Dependencies: 199
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_producto_detalle_producto_detalle_id_seq OWNED BY tb_producto_detalle.producto_detalle_id;


--
-- TOC entry 208 (class 1259 OID 100520)
-- Name: tb_reglas; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_reglas (
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
-- TOC entry 207 (class 1259 OID 100518)
-- Name: tb_reglas_regla_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_reglas_regla_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_reglas_regla_id_seq OWNER TO clabsuser;

--
-- TOC entry 2573 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_reglas_regla_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_reglas_regla_id_seq OWNED BY tb_reglas.regla_id;


--
-- TOC entry 178 (class 1259 OID 58731)
-- Name: tb_sys_menu; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_menu (
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
-- TOC entry 179 (class 1259 OID 58736)
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_menu_menu_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_menu_menu_id_seq OWNER TO atluser;

--
-- TOC entry 2574 (class 0 OID 0)
-- Dependencies: 179
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_menu_menu_id_seq OWNED BY tb_sys_menu.menu_id;


--
-- TOC entry 180 (class 1259 OID 58738)
-- Name: tb_sys_perfil; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_perfil (
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
-- TOC entry 181 (class 1259 OID 58742)
-- Name: tb_sys_perfil_detalle; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_perfil_detalle (
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
-- TOC entry 182 (class 1259 OID 58751)
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_perfil_detalle_perfdet_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_perfil_detalle_perfdet_id_seq OWNER TO atluser;

--
-- TOC entry 2575 (class 0 OID 0)
-- Dependencies: 182
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_perfil_detalle_perfdet_id_seq OWNED BY tb_sys_perfil_detalle.perfdet_id;


--
-- TOC entry 183 (class 1259 OID 58753)
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_perfil_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_perfil_id_seq OWNER TO atluser;

--
-- TOC entry 2576 (class 0 OID 0)
-- Dependencies: 183
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_perfil_id_seq OWNED BY tb_sys_perfil.perfil_id;


--
-- TOC entry 184 (class 1259 OID 58755)
-- Name: tb_sys_sistemas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_sistemas (
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
-- TOC entry 185 (class 1259 OID 58759)
-- Name: tb_sys_usuario_perfiles; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_usuario_perfiles (
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
-- TOC entry 186 (class 1259 OID 58763)
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_usuario_perfiles_usuario_perfil_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNER TO atluser;

--
-- TOC entry 2577 (class 0 OID 0)
-- Dependencies: 186
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNED BY tb_sys_usuario_perfiles.usuario_perfil_id;


--
-- TOC entry 196 (class 1259 OID 84146)
-- Name: tb_tcostos; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tcostos (
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
-- TOC entry 195 (class 1259 OID 84062)
-- Name: tb_tinsumo; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tinsumo (
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
-- TOC entry 194 (class 1259 OID 75877)
-- Name: tb_tipo_cambio; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tipo_cambio (
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
-- TOC entry 193 (class 1259 OID 75875)
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_tipo_cambio_tipo_cambio_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_tipo_cambio_tipo_cambio_id_seq OWNER TO clabsuser;

--
-- TOC entry 2578 (class 0 OID 0)
-- Dependencies: 193
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_tipo_cambio_tipo_cambio_id_seq OWNED BY tb_tipo_cambio.tipo_cambio_id;


--
-- TOC entry 210 (class 1259 OID 100944)
-- Name: tb_tipo_cliente; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tipo_cliente (
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
-- TOC entry 201 (class 1259 OID 92271)
-- Name: tb_tipo_empresa; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tipo_empresa (
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
-- TOC entry 189 (class 1259 OID 59224)
-- Name: tb_unidad_medida; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_unidad_medida (
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
  CONSTRAINT chk_unidad_medida_field_len CHECK ((((length(rtrim((unidad_medida_codigo)::text)) > 0) AND (length(rtrim((unidad_medida_siglas)::text)) > 0)) AND (length(rtrim((unidad_medida_descripcion)::text)) > 0))),
  CONSTRAINT chk_unidad_medida_tipo CHECK ((unidad_medida_tipo = ANY (ARRAY['P'::bpchar, 'V'::bpchar, 'L'::bpchar, 'T'::bpchar])))
);


ALTER TABLE public.tb_unidad_medida OWNER TO clabsuser;

--
-- TOC entry 192 (class 1259 OID 59377)
-- Name: tb_unidad_medida_conversion; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_unidad_medida_conversion (
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
-- TOC entry 191 (class 1259 OID 59375)
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_unidad_medida_conversion_unidad_medida_conversion_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNER TO clabsuser;

--
-- TOC entry 2579 (class 0 OID 0)
-- Dependencies: 191
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNED BY tb_unidad_medida_conversion.unidad_medida_conversion_id;


--
-- TOC entry 187 (class 1259 OID 58771)
-- Name: tb_usuarios; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_usuarios (
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
-- TOC entry 188 (class 1259 OID 58776)
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_usuarios_usuarios_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_usuarios_usuarios_id_seq OWNER TO atluser;

--
-- TOC entry 2580 (class 0 OID 0)
-- Dependencies: 188
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_usuarios_usuarios_id_seq OWNED BY tb_usuarios.usuarios_id;


--
-- TOC entry 215 (class 1259 OID 101306)
-- Name: v_insumo_costo; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE v_insumo_costo (
  insumo_costo numeric
);


ALTER TABLE public.v_insumo_costo OWNER TO postgres;

--
-- TOC entry 2206 (class 2604 OID 100959)
-- Name: cliente_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cliente ALTER COLUMN cliente_id SET DEFAULT nextval('tb_cliente_cliente_id_seq'::regclass);


--
-- TOC entry 2209 (class 2604 OID 101031)
-- Name: cotizacion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion ALTER COLUMN cotizacion_id SET DEFAULT nextval('tb_cotizacion_cotizacion_id_seq'::regclass);


--
-- TOC entry 2213 (class 2604 OID 109779)
-- Name: cotizacion_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion_detalle ALTER COLUMN cotizacion_detalle_id SET DEFAULT nextval('tb_cotizacion_detalle_cotizacion_detalle_id_seq'::regclass);


--
-- TOC entry 2194 (class 2604 OID 92361)
-- Name: empresa_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_empresa ALTER COLUMN empresa_id SET DEFAULT nextval('tb_empresa_empresa_id_seq'::regclass);


--
-- TOC entry 2192 (class 2604 OID 92331)
-- Name: entidad_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entidad ALTER COLUMN entidad_id SET DEFAULT nextval('tb_entidad_entidad_id_seq'::regclass);


--
-- TOC entry 2175 (class 2604 OID 84163)
-- Name: insumo_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo ALTER COLUMN insumo_id SET DEFAULT nextval('tb_insumo_insumo_id_seq'::regclass);


--
-- TOC entry 2216 (class 2604 OID 246564)
-- Name: insumo_history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_insumo_history ALTER COLUMN insumo_history_id SET DEFAULT nextval('tb_insumo_history_insumo_history_id_seq'::regclass);


--
-- TOC entry 2185 (class 2604 OID 84306)
-- Name: producto_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle ALTER COLUMN producto_detalle_id SET DEFAULT nextval('tb_producto_detalle_producto_detalle_id_seq'::regclass);


--
-- TOC entry 2200 (class 2604 OID 100523)
-- Name: regla_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_reglas ALTER COLUMN regla_id SET DEFAULT nextval('tb_reglas_regla_id_seq'::regclass);


--
-- TOC entry 2134 (class 2604 OID 58799)
-- Name: menu_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu ALTER COLUMN menu_id SET DEFAULT nextval('tb_sys_menu_menu_id_seq'::regclass);


--
-- TOC entry 2136 (class 2604 OID 58800)
-- Name: perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil ALTER COLUMN perfil_id SET DEFAULT nextval('tb_sys_perfil_id_seq'::regclass);


--
-- TOC entry 2143 (class 2604 OID 58801)
-- Name: perfdet_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle ALTER COLUMN perfdet_id SET DEFAULT nextval('tb_sys_perfil_detalle_perfdet_id_seq'::regclass);


--
-- TOC entry 2146 (class 2604 OID 58802)
-- Name: usuario_perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles ALTER COLUMN usuario_perfil_id SET DEFAULT nextval('tb_sys_usuario_perfiles_usuario_perfil_id_seq'::regclass);


--
-- TOC entry 2162 (class 2604 OID 75880)
-- Name: tipo_cambio_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio ALTER COLUMN tipo_cambio_id SET DEFAULT nextval('tb_tipo_cambio_tipo_cambio_id_seq'::regclass);


--
-- TOC entry 2159 (class 2604 OID 59380)
-- Name: unidad_medida_conversion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion ALTER COLUMN unidad_medida_conversion_id SET DEFAULT nextval('tb_unidad_medida_conversion_unidad_medida_conversion_id_seq'::regclass);


--
-- TOC entry 2150 (class 2604 OID 58803)
-- Name: usuarios_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_usuarios ALTER COLUMN usuarios_id SET DEFAULT nextval('tb_usuarios_usuarios_id_seq'::regclass);


--
-- TOC entry 2540 (class 0 OID 92399)
-- Dependencies: 206
-- Data for Name: ci_sessions; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY ci_sessions (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
9cf5b1bf99f289c29c4f95adb1798021	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.98 Safari/537.36 Vivaldi/1.6.689	1486345044	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
e276d5dc37314671720f120eb053f7de	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.98 Safari/537.36 Vivaldi/1.6.689	1486343409	a:6:{s:9:"user_data";s:0:"";s:10:"empresa_id";s:1:"5";s:10:"usuario_id";s:2:"21";s:12:"usuario_code";s:5:"ADMIN";s:12:"usuario_name";s:21:"Carlos Arana Reategui";s:10:"isLoggedIn";b:1;}
\.


--
-- TOC entry 2546 (class 0 OID 100956)
-- Dependencies: 212
-- Data for Name: tb_cliente; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_cliente (cliente_id, empresa_id, cliente_razon_social, tipo_cliente_codigo, cliente_ruc, cliente_direccion, cliente_telefonos, cliente_fax, cliente_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	5	ewrwerewrew	DIS	10088090867	sfsdfsdfsdf		1234222222		t	ADMIN	2016-10-29 16:00:17.908844	ADMIN	2017-02-08 00:58:09.315482
5	5	dfyfrtyrty	DIS	54645364564	rtyrtyrty				t	ADMIN	2017-02-09 05:26:06.987284	\N	\N
\.


--
-- TOC entry 2581 (class 0 OID 0)
-- Dependencies: 211
-- Name: tb_cliente_cliente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_cliente_cliente_id_seq', 6, true);


--
-- TOC entry 2548 (class 0 OID 101028)
-- Dependencies: 214
-- Data for Name: tb_cotizacion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_cotizacion (cotizacion_id, empresa_id, cliente_id, cotizacion_es_cliente_real, cotizacion_numero, moneda_codigo, cotizacion_fecha, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, cotizacion_cerrada) FROM stdin;
5	5	7	f	18	EURO	2016-12-15	t	ADMIN	2016-12-07 02:05:24.714805	ADMIN	2017-01-16 02:09:50.115133	t
4	5	1	t	17	EURO	2016-12-15	t	ADMIN	2016-11-02 04:02:42.749312	ADMIN	2017-01-16 02:11:12.681956	t
15	5	7	f	24	USD	2016-12-26	t	ADMIN	2016-12-26 14:39:05.412198	ADMIN	2017-01-16 02:12:58.577998	t
11	5	1	t	20	USD	2016-12-21	t	ADMIN	2016-12-21 15:37:53.983507	ADMIN	2017-01-16 02:13:17.932435	t
18	5	5	t	25	USD	2017-01-14	t	ADMIN	2017-01-14 02:22:54.889457	ADMIN	2017-02-15 03:50:12.327554	t
13	5	5	t	22	EURO	2016-12-22	t	ADMIN	2016-12-22 03:42:29.319153	ADMIN	2017-02-15 03:53:49.160578	t
20	5	1	t	27	EURO	2017-02-15	t	ADMIN	2017-02-15 03:54:16.466348	ADMIN	2017-02-20 04:05:35.195021	t
12	5	7	f	21	USD	2016-12-22	t	ADMIN	2016-12-22 03:41:41.650949	ADMIN	2017-02-20 04:12:06.006455	t
10	5	7	f	19	USD	2016-12-21	t	ADMIN	2016-12-21 15:08:17.359936	ADMIN	2017-02-20 04:19:28.406972	f
26	7	23	f	33	EURO	2017-02-22	t	PUSER	2017-02-23 00:31:52.466435	PUSER	2017-02-23 00:49:54.993534	t
\.


--
-- TOC entry 2582 (class 0 OID 0)
-- Dependencies: 213
-- Name: tb_cotizacion_cotizacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_cotizacion_cotizacion_id_seq', 26, true);


--
-- TOC entry 2543 (class 0 OID 100641)
-- Dependencies: 209
-- Data for Name: tb_cotizacion_counter; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_cotizacion_counter (cotizacion_counter_last_id) FROM stdin;
33
\.


--
-- TOC entry 2551 (class 0 OID 109776)
-- Dependencies: 222
-- Data for Name: tb_cotizacion_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_cotizacion_detalle (cotizacion_detalle_id, cotizacion_id, insumo_id, unidad_medida_codigo, cotizacion_detalle_cantidad, cotizacion_detalle_precio, cotizacion_detalle_total, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, log_regla_by_costo, log_regla_porcentaje, log_tipo_cambio_tasa_compra, log_tipo_cambio_tasa_venta, log_moneda_codigo_costo, log_unidad_medida_codigo_costo, log_insumo_precio_original, log_insumo_precio_mercado, log_insumo_costo_original) FROM stdin;
17	5	10	GALON	0.81	3120.54	2527.64	t	ADMIN	2016-12-14 02:04:17.141361	ADMIN	2017-01-12 01:33:26.749682	t	50.00	1.0000	1.0000	EURO	GALON	3120.54	3500.00	2039.57
18	5	16	GALON	0.64	530.70	339.65	t	ADMIN	2016-12-14 02:05:18.385587	ADMIN	2017-01-12 01:34:08.816272	t	50.00	0.9000	0.9100	USD	GALON	589.67	420.00	385.40
19	4	10	GALON	1.10	3500.00	3850.00	t	ADMIN	2016-12-14 02:07:02.312474	ADMIN	2017-01-12 01:35:39.901831	\N	\N	1.0000	1.0000	EURO	GALON	3500.00	3500.00	2039.57
20	4	12	GALON	0.98	315.00	308.70	t	ADMIN	2016-12-14 02:07:40.748058	ADMIN	2017-01-12 01:35:47.563191	\N	\N	0.9000	0.9100	USD	GALON	350.00	350.00	188.85
28	15	16	GALON	3.50	143.00	500.50	t	ADMIN	2016-12-26 14:39:18.916866	ADMIN	2017-01-12 01:37:00.189201	t	50.00	1.0000	1.0000	USD	GALON	143.00	420.00	93.46
31	11	16	GALON	2.00	420.00	840.00	t	ADMIN	2017-01-16 01:33:51.107513	\N	\N	\N	\N	1.0000	1.0000	USD	GALON	420.00	420.00	99.87
32	20	12	GALON	2.00	700.00	1400.00	t	ADMIN	2017-02-15 04:40:08.262112	\N	\N	\N	\N	2.0000	3.0000	USD	GALON	350.00	350.00	-2.00
33	20	10	GALON	4.00	3500.00	14000.00	t	ADMIN	2017-02-15 04:40:22.32689	ADMIN	2017-02-15 14:39:31.618328	\N	\N	1.0000	1.0000	EURO	GALON	3500.00	3500.00	-2.00
34	20	16	GALON	3.00	840.00	2520.00	t	ADMIN	2017-02-15 14:39:43.246157	\N	\N	\N	\N	2.0000	3.0000	USD	GALON	420.00	420.00	-2.00
37	26	36	GALON	2.00	4069.58	8139.16	t	PUSER	2017-02-23 00:32:07.230166	\N	\N	\N	\N	2.0000	3.0000	USD	GALON	2034.79	5.00	1975.52
\.


--
-- TOC entry 2583 (class 0 OID 0)
-- Dependencies: 221
-- Name: tb_cotizacion_detalle_cotizacion_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_cotizacion_detalle_cotizacion_detalle_id_seq', 37, true);


--
-- TOC entry 2539 (class 0 OID 92358)
-- Dependencies: 205
-- Data for Name: tb_empresa; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_empresa (empresa_id, empresa_razon_social, tipo_empresa_codigo, empresa_ruc, empresa_direccion, empresa_telefonos, empresa_fax, empresa_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
11	GENOME STAFF	FAB	23131232132	Av.Grau 3527		12121212		t	TESTUSER	2016-09-15 11:16:33.334354	ADMIN	2016-11-30 00:02:38.747208
23	MATRIX VET	DIS	33333433333	Jr.Carabaya 1242				t	ADMIN	2016-10-30 13:04:28.374891	ADMIN	2016-11-30 00:03:24.740916
5	IMPORTADORA	IMP	23323232323	Monte De Los Olicos 245	2756910	1212111	importadora@gmail.com	t	TESTUSER	2016-09-15 02:24:52.27879	ADMIN	2016-12-29 15:59:15.149095
7	FUTURE LAB S.A.C	FAB	23232232323	Isadora Duncan 345	2756910	2756910	aranape@gmail.com	t	TESTUSER	2016-09-15 02:26:34.750111	ADMIN	2016-12-29 15:59:26.171207
\.


--
-- TOC entry 2584 (class 0 OID 0)
-- Dependencies: 204
-- Name: tb_empresa_empresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_empresa_empresa_id_seq', 26, true);


--
-- TOC entry 2537 (class 0 OID 92328)
-- Dependencies: 203
-- Data for Name: tb_entidad; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entidad (entidad_id, entidad_razon_social, entidad_ruc, entidad_direccion, entidad_telefonos, entidad_fax, entidad_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	LABODEC S.A	12345654457	Ate	2756910		labodec@gmail.com	t	ADMIN	2016-09-21 02:08:40.288333	ADMIN	2017-02-20 03:59:44.131697
\.


--
-- TOC entry 2585 (class 0 OID 0)
-- Dependencies: 202
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_entidad_entidad_id_seq', 1, true);


--
-- TOC entry 2552 (class 0 OID 110317)
-- Dependencies: 223
-- Data for Name: tb_igv; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_igv (fecha_desde, fecha_hasta, igv_valor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
2016-01-01	2021-12-31	18.00	t	admin	2016-12-31 01:39:21.957222	\N	\N
\.


--
-- TOC entry 2532 (class 0 OID 84160)
-- Dependencies: 198
-- Data for Name: tb_insumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_insumo (insumo_id, insumo_tipo, insumo_codigo, insumo_descripcion, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_ingreso, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, empresa_id, insumo_precio_mercado) FROM stdin;
15	IN	XXXX	xxxxxx	EQUIP	CIND	NING	LITROS	0.0000	30.0000	EURO	t	PUSER	2016-10-05 02:23:31.072687	\N	\N	7	0.00
12	PR	PRODDOS	prodos	NING	NING	NING	GALON	10.0000	\N	USD	t	TESTUSER	2016-09-01 03:30:37.600921	ADMIN	2016-11-30 21:54:07.394495	5	350.00
10	PR	PRODUNO	Producto 1	NING	NING	NING	GALON	2.0000	\N	EURO	t	TESTUSER	2016-08-31 23:07:15.951263	ADMIN	2016-12-17 16:12:05.442705	5	3500.00
30	IN	DFGD	dfgdfgdfg	SERV	CDIR	GALON	GALON	3.0000	22.0000	EURO	t	ADMIN	2017-02-20 04:30:35.549945	ADMIN	2017-02-20 04:33:21.112207	5	24.00
9	IN	CODTRES	Transportista	SERV	CIND	NING	COMIS	0.0000	3.0000	USD	t	TESTUSER	2016-08-31 01:51:52.552593	ADMIN	2017-01-13 15:07:46.781123	5	0.00
2	IN	CODDOS	Ivermectina	SOLUCION	CDIR	GALON	LITROS	0.0000	24.0000	EURO	t	TESTUSER	2016-08-30 21:24:05.160225	ADMIN	2017-01-13 15:49:01.904693	5	40.00
13	IN	PUTTTT	Insumo 1 de PUSER	SOLUCION	CDIR	LITROS	LITROS	23.0000	7.0000	EURO	t	PUSER	2016-09-27 00:05:46.171545	PUSER	2017-02-22 01:44:32.674313	7	7.00
1	IN	CODUNO	Agente de Aduanas	SERV	CIND	NING	COMIS	0.0000	4.0000	USD	t	TESTUSER	2016-08-30 21:23:10.087079	ADMIN	2017-02-22 17:44:37.819658	5	0.00
20	IN	DDDDD	ddddd	MOBRA	CDIR	GALON	GALON	2.0000	4.0000	EURO	t	ADMIN	2017-01-26 17:00:36.528241	ADMIN	2017-01-26 19:19:32.082665	5	4523.12
16	PR	PROTREES	qweqwwqe	NING	NING	NING	GALON	2.0000	\N	USD	t	ADMIN	2016-10-10 02:05:38.919148	ADMIN	2016-11-30 22:39:36.281245	5	420.00
21	IN	XXXVVV	asdjkasdkasjhd	SERV	CIND	NING	KILOS	0.0000	45.0000	EURO	t	ADMIN	2017-02-06 04:24:53.60653	ADMIN	2017-02-15 02:55:09.45106	5	0.00
27	IN	GGGGG	ggggg	MOBRA	CIND	NING	GALON	0.0000	2.0000	EURO	t	ADMIN	2017-02-15 02:57:56.512351	\N	\N	5	0.00
14	PR	ERTERT	ertert	NING	NING	NING	LITROS	3.0000	\N	USD	t	PUSER	2016-09-28 16:07:13.050767	PUSER	2017-02-23 00:43:16.207969	7	12.00
36	PR	WERWER	43r34	NING	NING	NING	LITROS	3.0000	\N	USD	t	PUSER	2017-02-22 00:40:03.008797	PUSER	2017-02-23 01:21:11.070369	7	5.00
\.


--
-- TOC entry 2554 (class 0 OID 246561)
-- Dependencies: 225
-- Data for Name: tb_insumo_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tb_insumo_history (insumo_history_id, insumo_history_fecha, insumo_id, insumo_tipo, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, insumo_precio_mercado, insumo_history_origen_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
57	2017-02-21 02:31:37.171505	1	IN	SERV	CIND	COMIS	0.0000	3.0000	USD	0.00	\N	\N	clabsuser	2017-02-21 02:31:37.171505	\N	\N
59	2017-02-22 01:36:16.070428	13	IN	SOLUCION	CDIR	LITROS	23.0000	5.0000	EURO	6.00	\N	\N	clabsuser	2017-02-22 01:36:16.070428	\N	\N
60	2017-02-22 01:43:05.408002	13	IN	SOLUCION	CDIR	LITROS	23.0000	7.0000	EURO	6.00	\N	\N	clabsuser	2017-02-22 01:43:05.408002	\N	\N
61	2017-02-22 01:44:32.674313	13	IN	SOLUCION	CDIR	LITROS	23.0000	7.0000	EURO	7.00	\N	\N	clabsuser	2017-02-22 01:44:32.674313	\N	\N
62	2017-02-22 17:44:37.819658	1	IN	SERV	CIND	COMIS	0.0000	4.0000	USD	0.00	\N	\N	clabsuser	2017-02-22 17:44:37.819658	\N	\N
63	2017-02-22 00:00:00	12	PR	NING	NING	GALON	10.0000	48.1497	USD	350.00	26	\N	clabsuser	2017-02-23 00:49:54.993534	\N	\N
64	2017-02-22 00:00:00	36	PR	NING	NING	GALON	3.0000	1975.5218	USD	5.00	26	\N	clabsuser	2017-02-23 00:49:54.993534	\N	\N
65	2017-02-22 00:00:00	14	PR	NING	NING	LITROS	3.0000	949.7701	USD	12.00	26	\N	clabsuser	2017-02-23 00:49:54.993534	\N	\N
19	2016-12-15 00:00:00	16	PR	NING	NING	GALON	2.0000	404.4942	USD	420.00	5	\N	clabsuser	2017-01-16 02:09:50.115133	\N	\N
20	2016-12-15 00:00:00	12	PR	NING	NING	GALON	10.0000	198.2114	USD	350.00	5	\N	clabsuser	2017-01-16 02:09:50.115133	\N	\N
21	2016-12-15 00:00:00	10	PR	NING	NING	GALON	2.0000	2140.7236	EURO	3500.00	5	\N	clabsuser	2017-01-16 02:09:50.115133	\N	\N
22	2016-12-15 00:00:00	10	PR	NING	NING	GALON	2.0000	2140.7236	EURO	3500.00	4	\N	clabsuser	2017-01-16 02:11:12.681956	\N	\N
23	2016-12-15 00:00:00	12	PR	NING	NING	GALON	10.0000	198.2114	USD	350.00	4	\N	clabsuser	2017-01-16 02:11:12.681956	\N	\N
24	2016-12-15 00:00:00	16	PR	NING	NING	GALON	2.0000	404.4942	USD	420.00	4	\N	clabsuser	2017-01-16 02:11:12.681956	\N	\N
25	2016-12-26 00:00:00	12	PR	NING	NING	GALON	10.0000	48.8834	USD	350.00	15	\N	clabsuser	2017-01-16 02:12:58.577998	\N	\N
26	2016-12-26 00:00:00	16	PR	NING	NING	GALON	2.0000	99.8650	USD	420.00	15	\N	clabsuser	2017-01-16 02:12:58.577998	\N	\N
27	2016-12-21 00:00:00	16	PR	NING	NING	GALON	2.0000	99.8650	USD	420.00	11	\N	clabsuser	2017-01-16 02:13:17.932435	\N	\N
28	2016-12-21 00:00:00	12	PR	NING	NING	GALON	10.0000	48.8834	USD	350.00	11	\N	clabsuser	2017-01-16 02:13:17.932435	\N	\N
29	2017-01-16 02:14:00.859743	1	IN	SERV	CIND	COMIS	0.0000	2.0000	USD	0.00	\N	\N	clabsuser	2017-01-16 02:14:00.859743	\N	\N
31	2017-01-18 02:34:23.518848	1	IN	SERV	CIND	COMIS	0.0000	4.0000	USD	0.00	\N	\N	clabsuser	2017-01-18 02:34:23.518848	\N	\N
32	2017-01-26 17:00:36.528241	20	IN	SOLUCION	CDIR	GALON	2.0000	2.0000	EURO	12.00	\N	\N	clabsuser	2017-01-26 17:00:36.528241	\N	\N
33	2017-01-26 17:01:29.698425	20	IN	SOLUCION	CDIR	GALON	2.0000	3.0000	EURO	12.00	\N	\N	clabsuser	2017-01-26 17:01:29.698425	\N	\N
34	2017-01-26 17:05:59.249476	20	IN	SOLUCION	CDIR	GALON	2.0000	4.0000	EURO	12.00	\N	\N	clabsuser	2017-01-26 17:05:59.249476	\N	\N
35	2017-01-26 19:14:17.928139	20	IN	SOLUCION	CDIR	GALON	2.0000	4.0000	EURO	4523.12	\N	\N	clabsuser	2017-01-26 19:14:17.928139	\N	\N
36	2017-01-26 19:19:32.082665	20	IN	MOBRA	CDIR	GALON	2.0000	4.0000	EURO	4523.12	\N	\N	clabsuser	2017-01-26 19:19:32.082665	\N	\N
37	2017-01-27 23:50:39.717108	1	IN	SERV	CIND	COMIS	0.0000	3.0000	USD	0.00	\N	\N	clabsuser	2017-01-27 23:50:39.717108	\N	\N
38	2017-01-28 00:34:07.62361	1	IN	SERV	CDIR	COMIS	0.0000	3.0000	USD	0.00	\N	\N	clabsuser	2017-01-28 00:34:07.62361	\N	\N
39	2017-01-28 00:34:15.084949	1	IN	SERV	CDIR	COMIS	0.0000	3.0000	USD	4.00	\N	\N	clabsuser	2017-01-28 00:34:15.084949	\N	\N
41	2017-02-06 04:24:53.60653	21	IN	SOLUCION	CIND	KILOS	0.0000	33.0000	EURO	0.00	\N	\N	clabsuser	2017-02-06 04:24:53.60653	\N	\N
43	2017-02-15 02:55:09.45106	21	IN	SERV	CIND	KILOS	0.0000	45.0000	EURO	0.00	\N	\N	clabsuser	2017-02-15 02:55:09.45106	\N	\N
45	2017-02-15 02:57:56.512351	27	IN	MOBRA	CIND	GALON	0.0000	2.0000	EURO	0.00	\N	\N	clabsuser	2017-02-15 02:57:56.512351	\N	\N
47	2017-02-15 00:00:00	12	PR	NING	NING	GALON	10.0000	-2.0000	USD	350.00	20	\N	clabsuser	2017-02-20 04:05:35.195021	\N	\N
48	2017-02-15 00:00:00	16	PR	NING	NING	GALON	2.0000	-2.0000	USD	420.00	20	\N	clabsuser	2017-02-20 04:05:35.195021	\N	\N
49	2017-02-15 00:00:00	10	PR	NING	NING	GALON	2.0000	-2.0000	EURO	3500.00	20	\N	clabsuser	2017-02-20 04:05:35.195021	\N	\N
50	2017-02-20 04:30:35.549945	30	IN	MOBRA	CIND	GALON	0.0000	22.0000	EURO	0.00	\N	\N	clabsuser	2017-02-20 04:30:35.549945	\N	\N
51	2017-02-20 04:30:56.923949	30	IN	MOBRA	CIND	KILOS	0.0000	22.0000	EURO	0.00	\N	\N	clabsuser	2017-02-20 04:30:56.923949	\N	\N
52	2017-02-20 04:31:03.372385	30	IN	SOLUCION	CIND	KILOS	0.0000	22.0000	EURO	0.00	\N	\N	clabsuser	2017-02-20 04:31:03.372385	\N	\N
53	2017-02-20 04:31:33.273625	30	IN	SERV	CDIR	GALON	0.0000	22.0000	EURO	0.00	\N	\N	clabsuser	2017-02-20 04:31:33.273625	\N	\N
54	2017-02-20 04:33:04.843716	30	IN	SERV	CDIR	GALON	0.0000	22.0000	EURO	24.00	\N	\N	clabsuser	2017-02-20 04:33:04.843716	\N	\N
55	2017-02-20 04:33:21.112207	30	IN	SERV	CDIR	GALON	3.0000	22.0000	EURO	24.00	\N	\N	clabsuser	2017-02-20 04:33:21.112207	\N	\N
\.


--
-- TOC entry 2586 (class 0 OID 0)
-- Dependencies: 224
-- Name: tb_insumo_history_insumo_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tb_insumo_history_insumo_history_id_seq', 65, true);


--
-- TOC entry 2587 (class 0 OID 0)
-- Dependencies: 197
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_insumo_insumo_id_seq', 36, true);


--
-- TOC entry 2524 (class 0 OID 59242)
-- Dependencies: 190
-- Data for Name: tb_moneda; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_moneda (moneda_codigo, moneda_simbolo, moneda_descripcion, moneda_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
PEN	S/.	Nuevos Soles	f	t	TESTUSER	2016-07-10 18:16:12.815048	\N	\N
USD	$	Dolares	f	t	TESTUSER	2016-07-10 18:20:47.857316	TESTUSER	2016-07-10 18:22:59.862666
JPY	Yen	Yen Japones	f	t	TESTUSER	2016-07-14 00:40:58.095941	\N	\N
EURO	â¬	Euros	f	t	TESTUSER	2016-08-21 23:36:32.726364	TESTUSER	2017-01-01 23:57:25.114217
\.


--
-- TOC entry 2534 (class 0 OID 84303)
-- Dependencies: 200
-- Data for Name: tb_producto_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_producto_detalle (producto_detalle_id, insumo_id_origen, insumo_id, unidad_medida_codigo, producto_detalle_cantidad, producto_detalle_valor, producto_detalle_merma, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, empresa_id) FROM stdin;
8	10	12	GALON	1.0000	0.0000	2.0000	t	TESTUSER	2016-09-03 02:28:27.123146	postgres	2016-09-03 04:45:51.581321	5
7	12	2	LITROS	2.0000	23.0000	2.0000	t	TESTUSER	2016-09-03 02:28:02.69155	TESTUSER	2016-09-03 14:00:43.946944	5
6	12	1	NING	8.0000	10.0000	0.0000	t	TESTUSER	2016-09-03 02:27:49.294336	TESTUSER	2016-09-13 01:45:55.579695	5
11	10	9	NING	2.0000	1.0000	0.0000	t	ADMIN	2016-09-21 17:38:09.157325	\N	\N	5
13	10	1	NING	4.0000	45.0000	0.0000	t	ADMIN	2016-09-22 04:21:23.809114	\N	\N	5
10	10	2	LITROS	4.0000	23.0000	5.0000	t	TESTUSER	2016-09-03 04:41:33.985805	ADMIN	2016-09-27 16:44:41.430438	5
16	14	13	LITROS	2.0000	4.0000	23.0000	t	PUSER	2016-09-28 23:29:20.767014	\N	\N	7
19	14	15	NING	2.0000	30.0000	0.0000	t	PUSER	2016-10-05 02:23:47.353582	\N	\N	7
27	14	12	GALON	2.0000	217.6800	2.0000	t	PUSER	2016-10-05 04:29:22.858285	\N	\N	5
30	14	2	LITROS	23.0000	23.0000	0.0000	t	PUSER	2016-10-05 04:53:19.621915	\N	\N	5
32	16	12	GALON	2.0000	217.6800	2.0000	t	ADMIN	2016-10-10 02:07:20.921027	\N	\N	5
33	10	16	GALON	5.0000	444.0672	2.0000	t	ADMIN	2016-10-10 02:07:32.777017	\N	\N	5
34	16	1	NING	2.0000	45.0000	0.0000	t	ADMIN	2016-11-01 17:47:30.196773	\N	\N	5
35	12	9	NING	3.0000	1.0000	0.0000	t	ADMIN	2016-11-09 04:09:30.589009	\N	\N	5
31	14	21	NING	2.0000	45.0000	0.0000	t	PUSER	2016-10-05 04:56:40.967503	PUSER	2017-02-22 00:45:21.038866	5
43	36	14	LITROS	2.0000	941.2046	4.0000	t	PUSER	2017-02-22 00:48:56.480582	\N	\N	7
\.


--
-- TOC entry 2588 (class 0 OID 0)
-- Dependencies: 199
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_producto_detalle_producto_detalle_id_seq', 45, true);


--
-- TOC entry 2542 (class 0 OID 100520)
-- Dependencies: 208
-- Data for Name: tb_reglas; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_reglas (regla_id, regla_empresa_origen_id, regla_empresa_destino_id, regla_by_costo, regla_porcentaje, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
17	5	11	f	20.00	t	ADMIN	2016-10-01 14:35:44.193287	ADMIN	2016-11-30 21:51:51.883136
16	5	7	t	50.00	t	ADMIN	2016-10-01 01:59:52.134056	ADMIN	2016-12-26 14:37:04.536824
19	5	23	f	10.00	t	ADMIN	2016-12-02 20:13:18.243966	ADMIN	2017-02-20 03:49:42.116643
\.


--
-- TOC entry 2589 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_reglas_regla_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_reglas_regla_id_seq', 25, true);


--
-- TOC entry 2512 (class 0 OID 58731)
-- Dependencies: 178
-- Data for Name: tb_sys_menu; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_menu (sys_systemcode, menu_id, menu_codigo, menu_descripcion, menu_accesstype, menu_parent_id, menu_orden, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	60	smn_tipocambio	Tipo De Cambio	A         	11	165	t	TESTUSER	2016-07-15 03:24:37.087685	\N	\N
labcostos	61	smn_tcostos	Tipo De Costos	A         	11	155	t	TESTUSER	2016-07-19 03:17:27.948919	\N	\N
labcostos	62	smn_producto	Producto	A         	11	165	t	TESTUSER	2016-08-06 15:02:59.319601	\N	\N
labcostos	64	smn_empresas	Empresas	A         	56	120	t	TESTUSER	2016-09-15 00:42:19.770493	\N	\N
labcostos	65	smn_login	Login	A         	56	125	t	TESTUSER	2016-09-17 00:43:56.745552	\N	\N
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
labcostos	59	smn_insumo	Insumos	A         	11	160	t	TESTUSER	2014-01-17 15:35:42.866956	\N	\N
labcostos	66	smn_reglas	Reglas	A         	56	130	t	TESTUSER	2016-09-30 15:58:37.85865	\N	\N
labcostos	67	smn_cotizacion	Cotizacion	A         	11	135	t	TESTUSER	2016-10-18 16:16:32.47756	\N	\N
labcostos	68	smn_tcliente	Tipo Cliente	A         	11	180	t	TESTUSER	2016-10-29 00:57:43.393922	\N	\N
labcostos	69	smn_clientes	Clientes	A         	11	185	t	TESTUSER	2016-10-29 14:51:58.525005	\N	\N
labcostos	70	mn_reportes	Reportes	A         	4	15	t	TESTUSER	2017-01-21 02:09:51.841752	\N	\N
labcostos	72	smn_costos_historicos	Costo Historico	A         	70	10	t	TESTUSER	2017-01-21 02:11:05.133935	\N	\N
\.


--
-- TOC entry 2590 (class 0 OID 0)
-- Dependencies: 179
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_menu_menu_id_seq', 72, true);


--
-- TOC entry 2514 (class 0 OID 58738)
-- Dependencies: 180
-- Data for Name: tb_sys_perfil; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil (perfil_id, sys_systemcode, perfil_codigo, perfil_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
22	labcostos	ADMIN	Perfil Administrador	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-10-01 15:42:56.096589
21	labcostos	POWERUSER	Usuario Avanzado	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-10-01 15:43:34.567822
\.


--
-- TOC entry 2515 (class 0 OID 58742)
-- Dependencies: 181
-- Data for Name: tb_sys_perfil_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil_detalle (perfdet_id, perfdet_accessdef, perfdet_accleer, perfdet_accagregar, perfdet_accactualizar, perfdet_acceliminar, perfdet_accimprimir, perfil_id, menu_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
691	\N	t	t	t	t	t	22	66	t	ADMIN	2016-09-30 16:00:25.525598	\N	\N
692	\N	t	t	t	t	t	21	66	t	ADMIN	2016-09-30 16:00:48.579902	\N	\N
661	\N	f	f	f	f	f	21	4	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:02.430643
710	\N	t	t	t	t	t	21	67	t	admin	2016-10-18 16:20:20.661622	\N	\N
711	\N	t	t	t	t	t	22	67	t	admin	2016-10-18 16:21:02.471708	\N	\N
712	\N	t	t	t	t	t	22	68	t	admin	2016-10-29 00:59:01.242346	\N	\N
713	\N	t	t	t	t	t	22	69	t	admin	2016-10-29 14:52:32.88562	\N	\N
714	\N	t	t	t	t	t	21	69	t	admin	2016-10-30 12:51:17.394367	\N	\N
662	\N	f	f	f	f	f	21	56	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:02.430643
664	\N	f	f	f	f	f	21	57	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:02.430643
666	\N	f	f	f	f	f	21	58	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:02.430643
663	\N	t	t	t	t	t	21	11	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
665	\N	t	t	t	t	t	21	12	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
667	\N	t	t	t	t	t	21	15	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
668	\N	t	t	t	t	t	21	21	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
669	\N	t	t	t	t	t	21	16	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
675	\N	t	t	t	t	t	22	4	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
676	\N	t	t	t	t	t	22	56	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
677	\N	t	t	t	t	t	22	11	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
678	\N	t	t	t	t	t	22	57	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
679	\N	t	t	t	t	t	22	12	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
680	\N	t	t	t	t	t	22	58	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
681	\N	t	t	t	t	t	22	64	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
682	\N	t	t	t	t	t	22	65	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
683	\N	t	t	t	t	t	22	15	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
684	\N	t	t	t	t	t	22	21	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
685	\N	t	t	t	t	t	22	16	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
686	\N	t	t	t	t	t	22	17	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
687	\N	t	t	t	t	t	22	61	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
688	\N	t	t	t	t	t	22	59	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
689	\N	t	t	t	t	t	22	62	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
690	\N	t	t	t	t	t	22	60	t	ADMIN	2016-09-21 01:57:56.64793	ADMIN	2016-09-21 01:58:25.618904
670	\N	t	t	t	t	t	21	17	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
671	\N	t	t	t	t	t	21	61	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
672	\N	t	t	t	t	t	21	59	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
673	\N	t	t	t	t	t	21	62	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
674	\N	t	t	t	t	t	21	60	t	TESTUSER	2016-09-14 02:08:42.272458	ADMIN	2016-09-21 01:59:19.240294
715	\N	t	t	t	t	t	21	70	t	admin	2017-01-21 02:13:15.880176	\N	\N
716	\N	t	t	t	t	t	22	70	t	admin	2017-01-21 02:13:48.742345	\N	\N
717	\N	t	t	t	t	t	21	72	t	admin	2017-01-21 02:14:11.358034	postgres	2017-01-21 02:15:52.317802
718	\N	t	t	t	t	t	22	72	t	admin	2017-01-21 02:14:26.943334	postgres	2017-01-21 02:15:56.417582
\.


--
-- TOC entry 2591 (class 0 OID 0)
-- Dependencies: 182
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_detalle_perfdet_id_seq', 872, true);


--
-- TOC entry 2592 (class 0 OID 0)
-- Dependencies: 183
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_id_seq', 31, true);


--
-- TOC entry 2518 (class 0 OID 58755)
-- Dependencies: 184
-- Data for Name: tb_sys_sistemas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_sistemas (sys_systemcode, sistema_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	Sistema De Costos Laboratorios	t	TESTUSER	2016-07-08 23:47:11.960862	postgres	2016-09-21 01:38:36.399968
\.


--
-- TOC entry 2519 (class 0 OID 58759)
-- Dependencies: 185
-- Data for Name: tb_sys_usuario_perfiles; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_usuario_perfiles (usuario_perfil_id, perfil_id, usuarios_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
14	21	22	t	ADMIN	2016-09-21 02:04:24.698619	ADMIN	2016-10-03 01:59:00.526257
13	22	21	t	ADMIN	2016-09-21 02:02:31.236401	ADMIN	2016-10-03 02:01:50.620326
24	22	25	t	ADMIN	2017-02-09 15:27:53.125555	ADMIN	2017-02-09 16:53:12.017344
26	22	26	t	ADMIN	2017-02-20 01:28:23.624613	ADMIN	2017-02-20 01:28:35.265531
\.


--
-- TOC entry 2593 (class 0 OID 0)
-- Dependencies: 186
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_usuario_perfiles_usuario_perfil_id_seq', 26, true);


--
-- TOC entry 2530 (class 0 OID 84146)
-- Dependencies: 196
-- Data for Name: tb_tcostos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tcostos (tcostos_codigo, tcostos_descripcion, tcostos_protected, tcostos_indirecto, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
CIND	Costo Indirecto	f	t	t	TESTUSER	2016-08-30 20:18:59.46133	ADMIN	2017-02-14 00:47:20.776931
NING	Ninguno	t	f	t	admin	2016-08-30 20:03:40.281843	ADMIN	2017-02-14 00:48:13.45147
CDIR	Costo Directo	f	f	t	TESTUSER	2016-08-30 20:18:08.544862	ADMIN	2017-02-14 01:12:02.164853
\.


--
-- TOC entry 2529 (class 0 OID 84062)
-- Dependencies: 195
-- Data for Name: tb_tinsumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tinsumo (tinsumo_codigo, tinsumo_descripcion, tinsumo_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
NING	Ninguno	t	t	admin	2016-08-30 17:48:41.042868	\N	\N
MOBRA	Mano De Obra	f	t	TESTUSER	2016-08-30 21:22:19.135911	\N	\N
SOLUCION	Solucion	f	t	PUSER	2016-09-26 22:29:14.474284	\N	\N
SERV	Servicios	f	t	ADMIN	2016-11-29 23:49:45.766442	\N	\N
TRANS	Transporte	f	t	ADMIN	2016-11-29 23:51:15.20716	\N	\N
EQUIP	Equipo	f	t	TESTUSER	2016-08-30 21:22:31.390434	ADMIN	2017-02-14 00:00:40.670564
\.


--
-- TOC entry 2528 (class 0 OID 75877)
-- Dependencies: 194
-- Data for Name: tb_tipo_cambio; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tipo_cambio (tipo_cambio_id, moneda_codigo_origen, moneda_codigo_destino, tipo_cambio_fecha_desde, tipo_cambio_fecha_hasta, tipo_cambio_tasa_compra, tipo_cambio_tasa_venta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	USD	JPY	2016-08-18	2016-08-19	3.0000	3.5000	t	TESTUSER	2016-08-13 15:41:24.405659	TESTUSER	2016-08-13 15:47:08.433642
3	EURO	USD	2016-12-15	2016-12-15	4.0000	4.2000	t	TESTUSER	2016-08-22 15:58:06.566396	ADMIN	2016-12-15 01:05:55.682777
5	PEN	USD	2016-12-15	2016-12-15	3.2400	3.2900	t	TESTUSER	2016-08-24 16:18:47.669771	ADMIN	2016-12-15 01:06:06.582977
6	USD	EURO	2016-12-15	2016-12-15	0.9000	0.9100	t	TESTUSER	2016-09-01 01:20:07.450926	ADMIN	2016-12-15 01:06:14.767977
10	USD	EURO	2016-12-21	2016-12-21	4.2500	4.2100	t	ADMIN	2016-12-21 22:21:42.120595	\N	\N
12	EURO	USD	2016-12-21	2016-12-21	0.9500	0.9400	t	ADMIN	2016-12-21 22:23:47.148811	\N	\N
13	USD	EURO	2016-12-26	2016-12-26	4.2500	4.2100	t	ADMIN	2016-12-26 14:32:15.132598	\N	\N
14	EURO	USD	2016-12-26	2016-12-26	0.9500	0.9400	t	ADMIN	2016-12-26 14:33:32.727022	\N	\N
4	PEN	USD	2016-09-13	2016-09-13	3.2500	3.3000	t	TESTUSER	2016-08-23 14:31:00.466178	TESTUSER	2016-09-13 01:31:28.473115
15	USD	EURO	2017-01-10	2017-01-14	4.2500	4.2100	t	ADMIN	2017-01-10 01:19:50.376197	ADMIN	2017-01-14 00:07:44.046276
2	USD	JPY	2016-08-22	2017-02-20	3.1000	3.2000	t	TESTUSER	2016-08-22 15:35:06.442191	ADMIN	2017-02-20 23:28:08.789636
20	USD	PEN	2017-02-15	2017-02-22	4.0000	5.0000	t	ADMIN	2017-02-15 04:35:05.101076	PUSER	2017-02-22 00:41:16.91239
19	USD	EURO	2017-02-15	2017-02-22	2.0000	3.0000	t	ADMIN	2017-02-15 04:34:29.168028	ADMIN	2017-02-22 00:47:42.531617
11	PEN	USD	2016-12-21	2017-02-23	3.2400	3.2300	t	ADMIN	2016-12-21 22:22:57.348017	PUSER	2017-02-23 01:45:31.09867
17	EURO	USD	2017-01-10	2017-02-24	0.9000	0.9100	t	ADMIN	2017-01-12 01:44:16.450111	PUSER	2017-02-23 01:45:45.221144
\.


--
-- TOC entry 2594 (class 0 OID 0)
-- Dependencies: 193
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_tipo_cambio_tipo_cambio_id_seq', 21, true);


--
-- TOC entry 2544 (class 0 OID 100944)
-- Dependencies: 210
-- Data for Name: tb_tipo_cliente; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tipo_cliente (tipo_cliente_codigo, tipo_cliente_descripcion, tipo_cliente_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
DIS	Distribuidor Externo	f	t	ADMIN	2016-10-29 01:14:35.022862	ADMIN	2016-10-29 01:15:20.899442
VET	Veterinaria	f	t	ADMIN	2016-10-29 01:16:24.303677	\N	\N
\.


--
-- TOC entry 2535 (class 0 OID 92271)
-- Dependencies: 201
-- Data for Name: tb_tipo_empresa; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tipo_empresa (tipo_empresa_codigo, tipo_empresa_descripcion, tipo_empresa_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
IMP	Importador	t	t	TESTUSER	2016-09-14 14:32:00.336057	postgres	2016-09-21 01:40:12.22007
FAB	Fabrica	t	t	TESTUSER	2016-09-14 14:32:18.634844	postgres	2016-09-21 01:40:12.22007
DIS	Distribuidor	t	t	TESTUSER	2016-09-14 14:32:35.783304	postgres	2016-09-21 01:40:12.22007
\.


--
-- TOC entry 2523 (class 0 OID 59224)
-- Dependencies: 189
-- Data for Name: tb_unidad_medida; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_unidad_medida (unidad_medida_codigo, unidad_medida_siglas, unidad_medida_descripcion, unidad_medida_tipo, unidad_medida_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, unidad_medida_default) FROM stdin;
GALON	Gls.	Galones	V	f	t	TESTUSER	2016-07-17 15:07:47.744565	TESTUSER	2016-07-18 04:56:08.667067	f
NING	Ning	Ninguna	P	t	t	TESTUSER	2016-08-15 02:29:09.264036	postgres	2016-08-15 02:29:30.986832	f
TONELAD	Ton.	Toneladas	P	f	t	TESTUSER	2016-07-11 17:17:40.095483	ADMIN	2016-10-11 01:38:35.010705	f
KILOS	Kgs.	Kilogramos	P	t	t	TESTUSER	2016-07-09 14:30:43.815942	ADMIN	2017-02-13 23:00:14.941311	t
HHOMBRE	HHOMBR	Hora Hombre	T	t	t	ADMIN	2016-11-29 23:33:52.541501	ADMIN	2017-02-13 23:00:28.304606	t
LITROS	Ltrs.	Litros	V	f	t	TESTUSER	2016-07-09 14:13:29.603714	ADMIN	2017-02-15 02:13:46.093291	t
COMIS	Com.	Comision	T	f	t	ADMIN	2016-11-29 23:48:42.283533	ADMIN	2017-02-20 04:00:21.289677	f
\.


--
-- TOC entry 2526 (class 0 OID 59377)
-- Dependencies: 192
-- Data for Name: tb_unidad_medida_conversion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_unidad_medida_conversion (unidad_medida_conversion_id, unidad_medida_origen, unidad_medida_destino, unidad_medida_conversion_factor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
10	TONELAD	KILOS	1000.00000	t	TESTUSER	2016-07-11 17:18:02.132735	\N	\N
60	GALON	LITROS	3.78540	t	TESTUSER	2016-07-18 04:44:20.861417	TESTUSER	2016-08-27 14:47:27.766392
70	LITROS	GALON	0.26420	t	TESTUSER	2016-07-30 00:33:37.114577	TESTUSER	2016-08-27 14:47:33.986013
24	KILOS	TONELAD	0.00100	t	TESTUSER	2016-07-12 15:58:35.930938	ADMIN	2017-02-14 01:49:05.979355
\.


--
-- TOC entry 2595 (class 0 OID 0)
-- Dependencies: 191
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_unidad_medida_conversion_unidad_medida_conversion_id_seq', 78, true);


--
-- TOC entry 2521 (class 0 OID 58771)
-- Dependencies: 187
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_usuarios (usuarios_id, usuarios_code, usuarios_password, usuarios_nombre_completo, usuarios_admin, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, empresa_id) FROM stdin;
21	ADMIN	melivane	Carlos Arana Reategui	t	t	ADMIN	2016-09-21 01:45:30.980176	postgres	02:07:33.907445	5
22	PUSER	puser	Soy Power User	f	t	ADMIN	2016-09-21 02:03:18.100401	ADMIN	16:14:37.451062	7
25	YUIYTIY	yuiyuiyutyuti5	fddfgdfg	f	t	ADMIN	2017-02-09 05:13:53.596983	ADMIN	15:47:06.747233	7
26	RWERWER	werwerwrw	werwerwerewrwer	f	t	ADMIN	2017-02-20 01:28:14.924596	ADMIN	01:28:42.49441	5
\.


--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 188
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_usuarios_usuarios_id_seq', 26, true);


--
-- TOC entry 2549 (class 0 OID 101306)
-- Dependencies: 215
-- Data for Name: v_insumo_costo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY v_insumo_costo (insumo_costo) FROM stdin;
\.


--
-- TOC entry 2301 (class 2606 OID 100966)
-- Name: pk_cliente; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_cliente
  ADD CONSTRAINT pk_cliente PRIMARY KEY (cliente_id);


--
-- TOC entry 2305 (class 2606 OID 101035)
-- Name: pk_cotizacion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_cotizacion
  ADD CONSTRAINT pk_cotizacion PRIMARY KEY (cotizacion_id);


--
-- TOC entry 2314 (class 2606 OID 109782)
-- Name: pk_cotizacion_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_cotizacion_detalle
  ADD CONSTRAINT pk_cotizacion_detalle PRIMARY KEY (cotizacion_detalle_id);


--
-- TOC entry 2286 (class 2606 OID 92368)
-- Name: pk_empresa; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_empresa
  ADD CONSTRAINT pk_empresa PRIMARY KEY (empresa_id);


--
-- TOC entry 2281 (class 2606 OID 92337)
-- Name: pk_entidad; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_entidad
  ADD CONSTRAINT pk_entidad PRIMARY KEY (entidad_id);


--
-- TOC entry 2267 (class 2606 OID 84171)
-- Name: pk_insumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT pk_insumo PRIMARY KEY (insumo_id);


--
-- TOC entry 2321 (class 2606 OID 246569)
-- Name: pk_insumo_history; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY tb_insumo_history
  ADD CONSTRAINT pk_insumo_history PRIMARY KEY (insumo_history_id);


--
-- TOC entry 2223 (class 2606 OID 58841)
-- Name: pk_menu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
  ADD CONSTRAINT pk_menu PRIMARY KEY (menu_id);


--
-- TOC entry 2248 (class 2606 OID 59248)
-- Name: pk_moneda; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_moneda
  ADD CONSTRAINT pk_moneda PRIMARY KEY (moneda_codigo);


--
-- TOC entry 2234 (class 2606 OID 58845)
-- Name: pk_perfdet_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil_detalle
  ADD CONSTRAINT pk_perfdet_id PRIMARY KEY (perfdet_id);


--
-- TOC entry 2274 (class 2606 OID 84313)
-- Name: pk_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_producto_detalle
  ADD CONSTRAINT pk_producto_detalle PRIMARY KEY (producto_detalle_id);


--
-- TOC entry 2291 (class 2606 OID 100527)
-- Name: pk_reglas; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_reglas
  ADD CONSTRAINT pk_reglas PRIMARY KEY (regla_id);


--
-- TOC entry 2289 (class 2606 OID 92409)
-- Name: pk_sessions; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY ci_sessions
  ADD CONSTRAINT pk_sessions PRIMARY KEY (session_id);


--
-- TOC entry 2236 (class 2606 OID 58859)
-- Name: pk_sistemas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_sistemas
  ADD CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode);


--
-- TOC entry 2228 (class 2606 OID 58861)
-- Name: pk_sys_perfil; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
  ADD CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id);


--
-- TOC entry 2259 (class 2606 OID 84154)
-- Name: pk_tcostos; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tcostos
  ADD CONSTRAINT pk_tcostos PRIMARY KEY (tcostos_codigo);


--
-- TOC entry 2257 (class 2606 OID 84070)
-- Name: pk_tinsumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tinsumo
  ADD CONSTRAINT pk_tinsumo PRIMARY KEY (tinsumo_codigo);


--
-- TOC entry 2255 (class 2606 OID 75885)
-- Name: pk_tipo_cambio; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tipo_cambio
  ADD CONSTRAINT pk_tipo_cambio PRIMARY KEY (tipo_cambio_id);


--
-- TOC entry 2296 (class 2606 OID 100951)
-- Name: pk_tipo_cliente; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tipo_cliente
  ADD CONSTRAINT pk_tipo_cliente PRIMARY KEY (tipo_cliente_codigo);


--
-- TOC entry 2279 (class 2606 OID 92278)
-- Name: pk_tipo_empresa; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tipo_empresa
  ADD CONSTRAINT pk_tipo_empresa PRIMARY KEY (tipo_empresa_codigo);


--
-- TOC entry 2251 (class 2606 OID 59384)
-- Name: pk_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida_conversion
  ADD CONSTRAINT pk_unidad_conversion PRIMARY KEY (unidad_medida_conversion_id);


--
-- TOC entry 2246 (class 2606 OID 59231)
-- Name: pk_unidad_medida; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida
  ADD CONSTRAINT pk_unidad_medida PRIMARY KEY (unidad_medida_codigo);


--
-- TOC entry 2240 (class 2606 OID 58865)
-- Name: pk_usuarioperfiles; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
  ADD CONSTRAINT pk_usuarioperfiles PRIMARY KEY (usuario_perfil_id);


--
-- TOC entry 2244 (class 2606 OID 58867)
-- Name: pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_usuarios
  ADD CONSTRAINT pk_usuarios PRIMARY KEY (usuarios_id);


--
-- TOC entry 2225 (class 2606 OID 58885)
-- Name: unq_codigomenu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
  ADD CONSTRAINT unq_codigomenu UNIQUE (menu_codigo);


--
-- TOC entry 2307 (class 2606 OID 101037)
-- Name: unq_cotizacion_numero; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_cotizacion
  ADD CONSTRAINT unq_cotizacion_numero UNIQUE (empresa_id, cotizacion_numero);


--
-- TOC entry 2269 (class 2606 OID 84235)
-- Name: unq_insumo_codigo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT unq_insumo_codigo UNIQUE (insumo_codigo);


--
-- TOC entry 2230 (class 2606 OID 58889)
-- Name: unq_perfil_syscode_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
  ADD CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode, perfil_codigo);


--
-- TOC entry 2232 (class 2606 OID 58891)
-- Name: unq_perfil_syscode_perfil_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
  ADD CONSTRAINT unq_perfil_syscode_perfil_id UNIQUE (sys_systemcode, perfil_id);


--
-- TOC entry 2276 (class 2606 OID 84315)
-- Name: unq_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_producto_detalle
  ADD CONSTRAINT unq_producto_detalle UNIQUE (insumo_id_origen, insumo_id);


--
-- TOC entry 2293 (class 2606 OID 100529)
-- Name: unq_regla; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_reglas
  ADD CONSTRAINT unq_regla UNIQUE (regla_empresa_origen_id, regla_empresa_destino_id);


--
-- TOC entry 2253 (class 2606 OID 59386)
-- Name: uq_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida_conversion
  ADD CONSTRAINT uq_unidad_conversion UNIQUE (unidad_medida_origen, unidad_medida_destino);


--
-- TOC entry 2297 (class 1259 OID 100992)
-- Name: fki_cliente_tipo_empresa; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cliente_tipo_empresa ON tb_cliente USING btree (tipo_cliente_codigo);


--
-- TOC entry 2308 (class 1259 OID 109798)
-- Name: fki_cotizacion_detalle_cotizacion; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_detalle_cotizacion ON tb_cotizacion_detalle USING btree (cotizacion_id);


--
-- TOC entry 2309 (class 1259 OID 109799)
-- Name: fki_cotizacion_detalle_insumo; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_detalle_insumo ON tb_cotizacion_detalle USING btree (insumo_id);


--
-- TOC entry 2310 (class 1259 OID 109831)
-- Name: fki_cotizacion_detalle_moneda_codigo_costo; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_detalle_moneda_codigo_costo ON tb_cotizacion_detalle USING btree (log_moneda_codigo_costo);


--
-- TOC entry 2311 (class 1259 OID 109800)
-- Name: fki_cotizacion_detalle_umedida; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_detalle_umedida ON tb_cotizacion_detalle USING btree (unidad_medida_codigo);


--
-- TOC entry 2312 (class 1259 OID 109832)
-- Name: fki_cotizacion_detalle_umedida_costo; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_detalle_umedida_costo ON tb_cotizacion_detalle USING btree (log_unidad_medida_codigo_costo);


--
-- TOC entry 2302 (class 1259 OID 101048)
-- Name: fki_cotizacion_empresa_origen; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_empresa_origen ON tb_cotizacion USING btree (empresa_id);


--
-- TOC entry 2303 (class 1259 OID 101049)
-- Name: fki_cotizacion_moneda; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_cotizacion_moneda ON tb_cotizacion USING btree (moneda_codigo);


--
-- TOC entry 2282 (class 1259 OID 100875)
-- Name: fki_empresa_tipo_empresa; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_empresa_tipo_empresa ON tb_empresa USING btree (tipo_empresa_codigo);


--
-- TOC entry 2260 (class 1259 OID 100669)
-- Name: fki_insumo_empresa; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_insumo_empresa ON tb_insumo USING btree (empresa_id);


--
-- TOC entry 2315 (class 1259 OID 246595)
-- Name: fki_insumo_history_insumo; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_insumo_history_insumo ON tb_insumo_history USING btree (insumo_id);


--
-- TOC entry 2316 (class 1259 OID 246596)
-- Name: fki_insumo_history_moneda_costo; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_insumo_history_moneda_costo ON tb_insumo_history USING btree (moneda_codigo_costo);


--
-- TOC entry 2317 (class 1259 OID 246597)
-- Name: fki_insumo_history_tcostos; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_insumo_history_tcostos ON tb_insumo_history USING btree (tcostos_codigo);


--
-- TOC entry 2318 (class 1259 OID 246598)
-- Name: fki_insumo_history_tinsumo; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_insumo_history_tinsumo ON tb_insumo_history USING btree (tinsumo_codigo);


--
-- TOC entry 2319 (class 1259 OID 246599)
-- Name: fki_insumo_history_unidad_medida_costo; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_insumo_history_unidad_medida_costo ON tb_insumo_history USING btree (unidad_medida_codigo_costo);


--
-- TOC entry 2261 (class 1259 OID 100670)
-- Name: fki_insumo_moneda_costo; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_insumo_moneda_costo ON tb_insumo USING btree (moneda_codigo_costo);


--
-- TOC entry 2262 (class 1259 OID 100671)
-- Name: fki_insumo_tcostos; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_insumo_tcostos ON tb_insumo USING btree (tcostos_codigo);


--
-- TOC entry 2263 (class 1259 OID 100672)
-- Name: fki_insumo_tinsumo; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_insumo_tinsumo ON tb_insumo USING btree (tinsumo_codigo);


--
-- TOC entry 2264 (class 1259 OID 100673)
-- Name: fki_insumo_unidad_medida_costo; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_insumo_unidad_medida_costo ON tb_insumo USING btree (unidad_medida_codigo_costo);


--
-- TOC entry 2265 (class 1259 OID 100674)
-- Name: fki_insumo_unidad_medida_ingreso; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_insumo_unidad_medida_ingreso ON tb_insumo USING btree (unidad_medida_codigo_ingreso);


--
-- TOC entry 2220 (class 1259 OID 58916)
-- Name: fki_menu_parent_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_parent_id ON tb_sys_menu USING btree (menu_parent_id);


--
-- TOC entry 2221 (class 1259 OID 58917)
-- Name: fki_menu_sistemas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_sistemas ON tb_sys_menu USING btree (sys_systemcode);


--
-- TOC entry 2226 (class 1259 OID 58918)
-- Name: fki_perfil_sistema; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_sistema ON tb_sys_perfil USING btree (sys_systemcode);


--
-- TOC entry 2237 (class 1259 OID 58919)
-- Name: fki_perfil_usuario; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_usuario ON tb_sys_usuario_perfiles USING btree (perfil_id);


--
-- TOC entry 2270 (class 1259 OID 92422)
-- Name: fki_producto_detalle_empresa; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_producto_detalle_empresa ON tb_producto_detalle USING btree (empresa_id);


--
-- TOC entry 2271 (class 1259 OID 100667)
-- Name: fki_producto_detalle_insumo_id; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_producto_detalle_insumo_id ON tb_producto_detalle USING btree (insumo_id);


--
-- TOC entry 2272 (class 1259 OID 100668)
-- Name: fki_producto_detalle_unidad_medida; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_producto_detalle_unidad_medida ON tb_producto_detalle USING btree (unidad_medida_codigo);


--
-- TOC entry 2249 (class 1259 OID 100675)
-- Name: fki_unidad_conversion_medida_destino; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX fki_unidad_conversion_medida_destino ON tb_unidad_medida_conversion USING btree (unidad_medida_destino);


--
-- TOC entry 2241 (class 1259 OID 92398)
-- Name: fki_usuario_empresa; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_usuario_empresa ON tb_usuarios USING btree (empresa_id);


--
-- TOC entry 2238 (class 1259 OID 58932)
-- Name: fki_usuarioperfiles; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_usuarioperfiles ON tb_sys_usuario_perfiles USING btree (usuarios_id);


--
-- TOC entry 2287 (class 1259 OID 92410)
-- Name: idx_sessions_last_activity; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE INDEX idx_sessions_last_activity ON ci_sessions USING btree (last_activity);


--
-- TOC entry 2242 (class 1259 OID 58937)
-- Name: idx_unique_usuarios; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unique_usuarios ON tb_usuarios USING btree (upper((usuarios_code)::text));


--
-- TOC entry 2298 (class 1259 OID 100972)
-- Name: idx_unq_cliente_razon_social; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_cliente_razon_social ON tb_cliente USING btree (empresa_id, upper((cliente_razon_social)::text));


--
-- TOC entry 2299 (class 1259 OID 100973)
-- Name: idx_unq_cliente_ruc; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_cliente_ruc ON tb_cliente USING btree (empresa_id, upper((cliente_ruc)::text));


--
-- TOC entry 2283 (class 1259 OID 100921)
-- Name: idx_unq_empresa_razon_social; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_empresa_razon_social ON tb_empresa USING btree (upper((empresa_razon_social)::text));


--
-- TOC entry 2284 (class 1259 OID 100920)
-- Name: idx_unq_empresa_ruc; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_empresa_ruc ON tb_empresa USING btree (upper((empresa_ruc)::text));


--
-- TOC entry 2294 (class 1259 OID 100952)
-- Name: idx_unq_tipo_cliente_descripcion; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_tipo_cliente_descripcion ON tb_tipo_cliente USING btree (upper((tipo_cliente_descripcion)::text));


--
-- TOC entry 2277 (class 1259 OID 92381)
-- Name: idx_unq_tipo_empresa_descripcion; Type: INDEX; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_tipo_empresa_descripcion ON tb_tipo_empresa USING btree (upper((tipo_empresa_descripcion)::text));


--
-- TOC entry 2365 (class 2620 OID 58944)
-- Name: sptrg_verify_usuario_code_change; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER sptrg_verify_usuario_code_change BEFORE INSERT OR DELETE OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_verify_usuario_code_change();


--
-- TOC entry 2395 (class 2620 OID 100974)
-- Name: tr_cliente; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cliente BEFORE INSERT OR UPDATE ON tb_cliente FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2394 (class 2620 OID 101057)
-- Name: tr_cliente_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cliente_validate_delete BEFORE DELETE ON tb_cliente FOR EACH ROW EXECUTE PROCEDURE sptrg_cliente_validate_delete();


--
-- TOC entry 2396 (class 2620 OID 101050)
-- Name: tr_cotizacion; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion BEFORE INSERT OR UPDATE ON tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2400 (class 2620 OID 109801)
-- Name: tr_cotizacion_detalle; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_detalle BEFORE INSERT OR UPDATE ON tb_cotizacion_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2402 (class 2620 OID 246555)
-- Name: tr_cotizacion_detalle_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_detalle_validate_delete BEFORE DELETE ON tb_cotizacion_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_cotizacion_detalle_validate_delete();


--
-- TOC entry 2401 (class 2620 OID 109802)
-- Name: tr_cotizacion_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_detalle_validate_save BEFORE INSERT OR UPDATE ON tb_cotizacion_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_cotizacion_detalle_validate_save();


--
-- TOC entry 2399 (class 2620 OID 246552)
-- Name: tr_cotizacion_producto_history_log; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_producto_history_log AFTER UPDATE OF cotizacion_cerrada ON tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE sptrg_cotizacion_producto_history_log();


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 2399
-- Name: TRIGGER tr_cotizacion_producto_history_log ON tb_cotizacion; Type: COMMENT; Schema: public; Owner: clabsuser
--

COMMENT ON TRIGGER tr_cotizacion_producto_history_log ON tb_cotizacion IS 'Este trigger actualiza los history log de productos comprendidos en la cotizacion.
IMPORTANTE: solo se dispara cuando se cierra la cotizacion osea cuando el campo
cotizacion cerrada es alterado o modificado.
';


--
-- TOC entry 2398 (class 2620 OID 110324)
-- Name: tr_cotizacion_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_validate_delete BEFORE DELETE ON tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE sptrg_cotizacion_validate_delete();


--
-- TOC entry 2397 (class 2620 OID 101053)
-- Name: tr_cotizacion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_cotizacion_validate_save BEFORE INSERT OR UPDATE OF cliente_id, cotizacion_es_cliente_real ON tb_cotizacion FOR EACH ROW EXECUTE PROCEDURE sptrg_cotizacion_validate_save();


--
-- TOC entry 2390 (class 2620 OID 92374)
-- Name: tr_empresa; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_empresa BEFORE INSERT OR UPDATE ON tb_empresa FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2389 (class 2620 OID 101056)
-- Name: tr_empresa_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_empresa_validate_delete BEFORE DELETE ON tb_empresa FOR EACH ROW EXECUTE PROCEDURE sptrg_empresa_validate_delete();


--
-- TOC entry 2388 (class 2620 OID 92338)
-- Name: tr_entidad; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entidad BEFORE INSERT OR UPDATE ON tb_entidad FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2404 (class 2620 OID 246600)
-- Name: tr_insumo_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_insumo_history BEFORE INSERT OR UPDATE ON tb_insumo_history FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2384 (class 2620 OID 246540)
-- Name: tr_insumo_history_log; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_history_log AFTER INSERT OR UPDATE OF insumo_tipo, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, insumo_precio_mercado ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_insumo_history_log();


--
-- TOC entry 2382 (class 2620 OID 84197)
-- Name: tr_insumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_validate_save BEFORE INSERT OR UPDATE ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_insumo_validate_save();


--
-- TOC entry 2370 (class 2620 OID 59409)
-- Name: tr_moneda_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_moneda_validate_save BEFORE INSERT OR UPDATE ON tb_moneda FOR EACH ROW EXECUTE PROCEDURE sptrg_moneda_validate_save();


--
-- TOC entry 2385 (class 2620 OID 84331)
-- Name: tr_producto_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_detalle_validate_save BEFORE INSERT OR UPDATE ON tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_producto_detalle_validate_save();


--
-- TOC entry 2392 (class 2620 OID 100542)
-- Name: tr_reglas_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_reglas_validate_save BEFORE INSERT OR UPDATE ON tb_reglas FOR EACH ROW EXECUTE PROCEDURE sptrg_reglas_validate_save();


--
-- TOC entry 2360 (class 2620 OID 58977)
-- Name: tr_sys_perfil; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil BEFORE INSERT OR UPDATE ON tb_sys_perfil FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2361 (class 2620 OID 58978)
-- Name: tr_sys_perfil_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil_detalle BEFORE INSERT OR UPDATE ON tb_sys_perfil_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2362 (class 2620 OID 58979)
-- Name: tr_sys_sistemas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_sistemas BEFORE INSERT OR UPDATE ON tb_sys_sistemas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2363 (class 2620 OID 58980)
-- Name: tr_sys_usuario_perfiles; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_usuario_perfiles BEFORE INSERT OR UPDATE ON tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2379 (class 2620 OID 84155)
-- Name: tr_tcostos_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_delete BEFORE DELETE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_tcostos_validate_delete();


--
-- TOC entry 2380 (class 2620 OID 84156)
-- Name: tr_tcostos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_save BEFORE INSERT OR UPDATE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_tcostos_validate_save();


--
-- TOC entry 2376 (class 2620 OID 84071)
-- Name: tr_tinsumo_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_delete BEFORE DELETE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_tinsumo_validate_delete();


--
-- TOC entry 2377 (class 2620 OID 84072)
-- Name: tr_tinsumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_save BEFORE INSERT OR UPDATE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_tinsumo_validate_save();


--
-- TOC entry 2374 (class 2620 OID 75896)
-- Name: tr_tipo_cambio; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio BEFORE INSERT OR UPDATE ON tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2375 (class 2620 OID 75897)
-- Name: tr_tipo_cambio_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio_validate_save BEFORE INSERT OR UPDATE ON tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE sptrg_tipo_cambio_validate_save();


--
-- TOC entry 2372 (class 2620 OID 59398)
-- Name: tr_unidad_medida_conversion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_conversion_validate_save BEFORE INSERT OR UPDATE ON tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_conversion_validate_save();


--
-- TOC entry 2367 (class 2620 OID 75962)
-- Name: tr_unidad_medida_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_delete BEFORE DELETE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_validate_delete();


--
-- TOC entry 2368 (class 2620 OID 59401)
-- Name: tr_unidad_medida_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_save BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_validate_save();


--
-- TOC entry 2369 (class 2620 OID 59233)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2371 (class 2620 OID 59249)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_moneda FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2373 (class 2620 OID 59397)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2378 (class 2620 OID 84073)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2381 (class 2620 OID 84157)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2383 (class 2620 OID 84198)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2386 (class 2620 OID 84332)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2387 (class 2620 OID 92279)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tipo_empresa FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2391 (class 2620 OID 100540)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_reglas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2393 (class 2620 OID 100953)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tipo_cliente FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2403 (class 2620 OID 110321)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_igv FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2364 (class 2620 OID 100554)
-- Name: tr_usuario_perfiles_save; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuario_perfiles_save BEFORE INSERT OR UPDATE ON tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE sptrg_usuario_perfiles_save();


--
-- TOC entry 2366 (class 2620 OID 58981)
-- Name: tr_usuarios; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuarios BEFORE INSERT OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2346 (class 2606 OID 100982)
-- Name: fk_cliente_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cliente
  ADD CONSTRAINT fk_cliente_empresa FOREIGN KEY (empresa_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2347 (class 2606 OID 100987)
-- Name: fk_cliente_tipo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cliente
  ADD CONSTRAINT fk_cliente_tipo_empresa FOREIGN KEY (tipo_cliente_codigo) REFERENCES tb_tipo_cliente(tipo_cliente_codigo);


--
-- TOC entry 2354 (class 2606 OID 262864)
-- Name: fk_cotizacion_detalle_cotizacion; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion_detalle
  ADD CONSTRAINT fk_cotizacion_detalle_cotizacion FOREIGN KEY (cotizacion_id) REFERENCES tb_cotizacion(cotizacion_id) ON DELETE CASCADE;


--
-- TOC entry 2350 (class 2606 OID 109788)
-- Name: fk_cotizacion_detalle_insumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion_detalle
  ADD CONSTRAINT fk_cotizacion_detalle_insumo FOREIGN KEY (insumo_id) REFERENCES tb_insumo(insumo_id);


--
-- TOC entry 2353 (class 2606 OID 109826)
-- Name: fk_cotizacion_detalle_moneda_codigo_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion_detalle
  ADD CONSTRAINT fk_cotizacion_detalle_moneda_codigo_costo FOREIGN KEY (log_moneda_codigo_costo) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2351 (class 2606 OID 109793)
-- Name: fk_cotizacion_detalle_umedida; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion_detalle
  ADD CONSTRAINT fk_cotizacion_detalle_umedida FOREIGN KEY (unidad_medida_codigo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2352 (class 2606 OID 109821)
-- Name: fk_cotizacion_detalle_umedida_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion_detalle
  ADD CONSTRAINT fk_cotizacion_detalle_umedida_costo FOREIGN KEY (log_unidad_medida_codigo_costo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2349 (class 2606 OID 101038)
-- Name: fk_cotizacion_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion
  ADD CONSTRAINT fk_cotizacion_empresa FOREIGN KEY (empresa_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2348 (class 2606 OID 101043)
-- Name: fk_cotizacion_moneda; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_cotizacion
  ADD CONSTRAINT fk_cotizacion_moneda FOREIGN KEY (moneda_codigo) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2343 (class 2606 OID 92369)
-- Name: fk_empresa_tipo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_empresa
  ADD CONSTRAINT fk_empresa_tipo_empresa FOREIGN KEY (tipo_empresa_codigo) REFERENCES tb_tipo_empresa(tipo_empresa_codigo);


--
-- TOC entry 2335 (class 2606 OID 100451)
-- Name: fk_insumo_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT fk_insumo_empresa FOREIGN KEY (empresa_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2359 (class 2606 OID 262825)
-- Name: fk_insumo_history_insumo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_insumo_history
  ADD CONSTRAINT fk_insumo_history_insumo FOREIGN KEY (insumo_id) REFERENCES tb_insumo(insumo_id) ON DELETE CASCADE;


--
-- TOC entry 2355 (class 2606 OID 246575)
-- Name: fk_insumo_history_moneda_costo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_insumo_history
  ADD CONSTRAINT fk_insumo_history_moneda_costo FOREIGN KEY (moneda_codigo_costo) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2356 (class 2606 OID 246580)
-- Name: fk_insumo_history_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_insumo_history
  ADD CONSTRAINT fk_insumo_history_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES tb_tcostos(tcostos_codigo);


--
-- TOC entry 2357 (class 2606 OID 246585)
-- Name: fk_insumo_history_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_insumo_history
  ADD CONSTRAINT fk_insumo_history_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 2358 (class 2606 OID 246590)
-- Name: fk_insumo_history_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_insumo_history
  ADD CONSTRAINT fk_insumo_history_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2333 (class 2606 OID 84172)
-- Name: fk_insumo_moneda_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT fk_insumo_moneda_costo FOREIGN KEY (moneda_codigo_costo) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2334 (class 2606 OID 84177)
-- Name: fk_insumo_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT fk_insumo_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES tb_tcostos(tcostos_codigo);


--
-- TOC entry 2336 (class 2606 OID 84182)
-- Name: fk_insumo_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT fk_insumo_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 2337 (class 2606 OID 84187)
-- Name: fk_insumo_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT fk_insumo_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2338 (class 2606 OID 84192)
-- Name: fk_insumo_unidad_medida_ingreso; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
  ADD CONSTRAINT fk_insumo_unidad_medida_ingreso FOREIGN KEY (unidad_medida_codigo_ingreso) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2322 (class 2606 OID 59107)
-- Name: fk_menu_parent; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
  ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES tb_sys_menu(menu_id);


--
-- TOC entry 2323 (class 2606 OID 59112)
-- Name: fk_menu_sistemas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
  ADD CONSTRAINT fk_menu_sistemas FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2331 (class 2606 OID 75886)
-- Name: fk_moneda_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio
  ADD CONSTRAINT fk_moneda_destino FOREIGN KEY (moneda_codigo_destino) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2332 (class 2606 OID 75891)
-- Name: fk_moneda_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio
  ADD CONSTRAINT fk_moneda_origen FOREIGN KEY (moneda_codigo_origen) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2325 (class 2606 OID 59122)
-- Name: fk_perfdet_perfil; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle
  ADD CONSTRAINT fk_perfdet_perfil FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2324 (class 2606 OID 59127)
-- Name: fk_perfil_sistema; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil
  ADD CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2340 (class 2606 OID 92417)
-- Name: fk_producto_detalle_empresa; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
  ADD CONSTRAINT fk_producto_detalle_empresa FOREIGN KEY (empresa_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2341 (class 2606 OID 262849)
-- Name: fk_producto_detalle_insumo_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
  ADD CONSTRAINT fk_producto_detalle_insumo_id FOREIGN KEY (insumo_id) REFERENCES tb_insumo(insumo_id);


--
-- TOC entry 2342 (class 2606 OID 262859)
-- Name: fk_producto_detalle_insumo_id_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
  ADD CONSTRAINT fk_producto_detalle_insumo_id_origen FOREIGN KEY (insumo_id_origen) REFERENCES tb_insumo(insumo_id);


--
-- TOC entry 2339 (class 2606 OID 84326)
-- Name: fk_producto_detalle_unidad_medida; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
  ADD CONSTRAINT fk_producto_detalle_unidad_medida FOREIGN KEY (unidad_medida_codigo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2344 (class 2606 OID 100530)
-- Name: fk_regla_empresa_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_reglas
  ADD CONSTRAINT fk_regla_empresa_destino FOREIGN KEY (regla_empresa_destino_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2345 (class 2606 OID 100535)
-- Name: fk_regla_empresa_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_reglas
  ADD CONSTRAINT fk_regla_empresa_origen FOREIGN KEY (regla_empresa_origen_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2329 (class 2606 OID 59387)
-- Name: fk_unidad_conversion_medida_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion
  ADD CONSTRAINT fk_unidad_conversion_medida_destino FOREIGN KEY (unidad_medida_destino) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2330 (class 2606 OID 59392)
-- Name: fk_unidad_conversion_medida_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion
  ADD CONSTRAINT fk_unidad_conversion_medida_origen FOREIGN KEY (unidad_medida_origen) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2328 (class 2606 OID 92393)
-- Name: fk_usuario_empresa; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_usuarios
  ADD CONSTRAINT fk_usuario_empresa FOREIGN KEY (empresa_id) REFERENCES tb_empresa(empresa_id);


--
-- TOC entry 2326 (class 2606 OID 59172)
-- Name: fk_usuarioperfiles; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
  ADD CONSTRAINT fk_usuarioperfiles FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2327 (class 2606 OID 59177)
-- Name: fk_usuarioperfiles_usuario; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
  ADD CONSTRAINT fk_usuarioperfiles_usuario FOREIGN KEY (usuarios_id) REFERENCES tb_usuarios(usuarios_id);


--
-- TOC entry 2561 (class 0 OID 0)
-- Dependencies: 8
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2017-02-23 02:08:16 PET

--
-- PostgreSQL database dump complete
--

