-- sql/validation/01_validar_silver.sql

-- Detalle de  la tabla silver
SELECT
	column_name,
	data_type,
	is_nullable,
	column_default
FROM
	information_schema."columns" c
WHERE
	c.table_schema = 'silver'
AND
	c.table_name = 'contratos_electronicos_financiero';

-- Compara filas e ids únicos entre raw y silver
SELECT 'raw' AS capa, count(*) AS filas, count(DISTINCT "ID Contrato") AS ids_unicos
FROM raw.contratos_electronicos
UNION ALL
SELECT 'silver', count(*), count(DISTINCT id_contrato)
FROM silver.contratos_electronicos_financiero;

-- Verificación que no exista valores negativos
SELECT COUNT(cef.valor_pago_adelantado) FROM silver.contratos_electronicos_financiero cef
WHERE cef.valor_pago_adelantado < 0;

SELECT COUNT(cef.valor_amortizado) FROM silver.contratos_electronicos_financiero cef
WHERE cef.valor_amortizado < 0;

-- Detección de anomalias entre fecha de firma y fecha de inicio de contrato
SELECT
cef.id_contrato,
cef.fecha_firma,
cef.fecha_inicio_contrato,
CASE WHEN cef.fecha_inicio_contrato < cef.fecha_firma THEN 'Inicia antes de firmar contrato'
ELSE 'ok'
END AS tipo_anomalia
FROM silver.contratos_electronicos_financiero cef
WHERE cef.fecha_inicio_contrato < cef.fecha_firma;

-- Validación de fechas
SELECT extract(year FROM fecha_firma) AS anio_firma,  count(*) AS contratos
FROM silver.contratos_electronicos_financiero
GROUP BY 1
ORDER BY 1;

SELECT extract(year FROM fecha_inicio_contrato) AS anio_inicio_contrato, count(*) AS contratos
FROM silver.contratos_electronicos_financiero
GROUP BY 1
ORDER BY 1;

--- Encontrar  no definidos o como textos vacios
SELECT cef.nombre_supervisor, COUNT(*) AS anomalias
FROM silver.contratos_electronicos_financiero cef
WHERE TRIM(cef.nombre_supervisor) = ''
   OR cef.nombre_supervisor = 'No definido'
GROUP BY cef.nombre_supervisor;


-- Comparar valor_pagado vs valor_contrato
SELECT CASE
	     WHEN valor_pagado <= valor_contrato * 0.05 THEN '1) 5%'
         WHEN valor_pagado <= valor_contrato * 1.1 THEN '1) hasta 10% más'
         WHEN valor_pagado <= valor_contrato * 2   THEN '2) hasta el doble'
         WHEN valor_pagado <= valor_contrato * 10  THEN '3) hasta 10 veces'
         ELSE '4) más de 10 veces' END AS tramo,
       count(*)
FROM silver.contratos_electronicos_financiero
WHERE valor_pagado > valor_contrato AND valor_contrato > 0
GROUP BY 1 ORDER BY 1;

SELECT cef.id_contrato, cef.valor_pagado,  cef.valor_contrato, cef.valor_amortizado, cef.valor_facturado, cef.saldo_vigencia, cef.saldo_cdp
FROM silver.contratos_electronicos_financiero cef
WHERE cef.valor_pagado > cef.valor_contrato;

-- Comparar fecha_inicio_contrato vs fecha_fin_contrato
SELECT count(*)
FROM silver.contratos_electronicos_financiero cef
WHERE cef.fecha_fin_contrato < cef.fecha_inicio_contrato ;

SELECT cef.id_contrato, cef.fecha_inicio_contrato, cef.fecha_fin_contrato
FROM silver.contratos_electronicos_financiero cef
WHERE cef.fecha_fin_contrato < cef.fecha_inicio_contrato ;
