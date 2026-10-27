CREATE SCHEMA IF NOT EXISTS silver;
DROP TABLE IF EXISTS silver.contratos_electronicos_financiero;

CREATE TABLE silver.contratos_electronicos_financiero AS
WITH base AS (
SELECT DISTINCT ON ("ID Contrato")
    "ID Contrato"                                   AS id_contrato,
    clean_text("Tipo de Contrato")                  AS tipo_contrato,
    clean_text("Modalidad de Contratacion")         AS modalidad_contratacion,
    parse_moneda("Valor del Contrato")              AS valor_contrato,
    parse_moneda("Valor Pagado")                    AS valor_pagado,
    parse_moneda("Valor Pendiente de Pago")         AS valor_pendiente_pago,
    parse_moneda("Valor Facturado")                 AS valor_facturado,
    parse_moneda("Valor de pago adelantado")        AS valor_pago_adelantado,
    parse_moneda("Valor Amortizado")                AS valor_amortizado,
    clean_text("Estado Contrato")                   AS estado_contrato,
    parse_moneda("Saldo CDP")                       AS saldo_cdp,
    parse_moneda("Saldo Vigencia")                  AS saldo_vigencia,
    clean_text("Origen de los Recursos")            AS origen_recursos,
    clean_text("Proveedor Adjudicado")              AS proveedor_adjudicado,
    valid_date(parse_fecha_us("Fecha de Firma"))    AS fecha_firma              ,
    valid_date(parse_fecha_us("Fecha de Inicio del Contrato"))  AS fecha_inicio_contrato,
    valid_date(parse_fecha_us("Fecha de Fin del Contrato"))     AS fecha_fin_contrato,
    parse_duracion_horas("Duración del contrato")   AS duracion_horas,
    clean_text("Destino Gasto")                     AS destino_gasto,
    "Nit Entidad"                                   AS nit_entidad,
    clean_text("Nombre Entidad")                    AS nombre_entidad,
    clean_text("Nombre supervisor")                 AS nombre_supervisor,
    clean_text("Objeto del Contrato")               AS objeto_contrato
FROM raw.contratos_electronicos
ORDER BY "ID Contrato";
)


SELECT *,
    (fecha_inicio_contrato < fecha_firma)           AS flag_inicio_antes_firma,
    (fecha_fin_contrato    < fecha_inicio_contrato) AS flag_fin_antes_inicio,
    (valor_pagado > valor_contrato) AS flag_pagado_mayor_valor_contrato

FROM base;