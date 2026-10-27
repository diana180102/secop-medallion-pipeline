# Decisiones de columnas: raw.contratos_electronicos → silver.contratos_electronicos_financiero

Fuente: `jbjy-vk9h` (SECOP II, Contratos Electrónicos) |
Descarga: 2026-10-13
Columnas: 95 en raw → 23 en Silver | 
Filas: 2,791,997 en raw → 2,791,801 tras deduplicar
Grano: una fila por contrato (`id_contrato`)
Evidencia: `docs/contratos_electrónicos_20261013.csv` (profiling de las 95 columnas)

## Conservadas (23)

| Columna raw                  | Columna Silver         | Tipo | Limpieza | Uso en Gold |
|------------------------------|------------------------|---|---|---|
| ID Contrato                  | id_contrato            | TEXT | Deduplicación (196 réplicas exactas) | Llave del hecho |
| Tipo de Contrato             | tipo_contrato          | TEXT | pseudo-nulos → NULL | Dimensión contrato |
| Modalidad de Contratacion    | modalidad_contratacion | TEXT | pseudo-nulos → NULL | Dimensión contrato |
| Estado Contrato              | estado_contrato        | TEXT | pseudo-nulos → NULL | Dimensión contrato |
| Origen de los Recursos       | origen_recursos        | TEXT | pseudo-nulos → NULL | Dimensión presupuesto |
| Destino Gasto                | destino_gasto          | TEXT | pseudo-nulos → NULL | Dimensión presupuesto |
| Valor del Contrato           | valor_contrato         | NUMERIC | `parse_moneda` | Hecho |
| Valor Pagado                 | valor_pagado           | NUMERIC | `parse_moneda` | Hecho |
| Valor Pendiente de Pago      | valor_pendiente_pago   | NUMERIC | `parse_moneda` | Hecho |
| Valor Facturado              | valor_facturado        | NUMERIC | `parse_moneda` | Hecho |
| Valor de pago adelantado     | valor_pago_adelantado  | NUMERIC | `parse_moneda` | Hecho |
| Valor Amortizado             | valor_amortizado       | NUMERIC | `parse_moneda` | Hecho |
| Saldo CDP                    | saldo_cdp              | NUMERIC | `parse_moneda` | Hecho |
| Saldo Vigencia               | saldo_vigencia         | NUMERIC | `parse_moneda` | Hecho |
| Fecha de Firma               | fecha_firma            | DATE | `parse_fecha_us` | dim_fecha |
| Fecha de Inicio del Contrato | fecha_inicio_contrato  | DATE | `parse_fecha_us` | dim_fecha |
| Fecha de Fin del Contrato    | fecha_fin_contrato     | DATE | `parse_fecha_us` | dim_fecha |
| Duración del contrato        | duracion_horas         | NUMERIC | `parse_duracion_horas` | Hecho / atributo |
| Nit Entidad                  | nit_entidad            | TEXT | — | dim_entidad (llave natural) |
| Nombre Entidad               | nombre_entidad         | TEXT | pseudo-nulos → NULL | dim_entidad |
| Proveedor Adjudicado         | proveedor_adjudicado   | TEXT | pseudo-nulos → NULL | dim_proveedor |
| (nombre real de la col.)     | nombre_supervisor      | TEXT | pseudo-nulos → NULL | Atributo |
| Objeto del Contrato          | objeto_contrato        | TEXT | pseudo-nulos → NULL | Atributo (texto libre) |


## Columnas descartadas (73)

Se excluyeron de Silver las columnas sin aporte informativo para el análisis
financiero de los contratos (alto porcentaje de nulos, valor constante o datos
administrativos/descriptivos sin relación con montos, pagos, fechas o plazos).
Siguen disponibles en `raw.contratos_electronicos`.



## Limpieza aplicada

- Pseudo-nulos (`''`, `No Definido`, `N/A`) → NULL con `clean_text()`. Lista final: __ (según profiling).
- Dinero: `parse_moneda` (formato de origen: __). 
- Fechas: `parse_fecha_us` (formato MM/DD/YYYY).
- Duración: `parse_duracion_horas` (unidad de origen: __).
- Deduplicación: `DISTINCT ON ("ID Contrato")`, porque las 196 filas repetidas eran idénticas en las 95 columnas.
- Rango fecha:`valid_date`, para verificar la existencia de fechas placeholder.

