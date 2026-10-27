
# Pipeline Medallion con datos de SECOP II

Pipeline de datos sobre los contratos electrónicos de SECOP II (datos.gov.co),
organizado en capas Raw/Bronze → Silver → Gold.

**Estado:** Raw y Silver completos y validados en PostgreSQL. Gold, Databricks y Azure en progreso.

## Fuente de datos

- Dataset: Contratos Electrónicos, SECOP II (`jbjy-vk9h`), datos.gov.co
- Descarga: 2026-10-13 (el dataset se actualiza, por lo que los conteos pueden variar)
- Formato: CSV, 95 columnas, 2,791,997 filas (~5 GB)
- El CSV no se incluye en el repositorio. Descárgalo desde datos.gov.co y guárdalo en `data/`.

## Arquitectura

| Capa | Esquema | Contenido | Transformación |
|---|---|---|---|
| Raw | `raw.contratos_electronicos` | Copia fiel del CSV, todo como `TEXT` | Ninguna |
| Silver | `silver.contratos_electronicos_financiero` | 22 columnas con tipos correctos, sin duplicados | Limpieza, tipos, flags |
| Gold | `gold.*` | Esquema estrella | En progreso |

Enfoque **ELT**: el dato crudo se carga primero y se transforma dentro de la base.

## Raw

- Carga con `COPY` de PostgreSQL <o con pandas por chunks: indica cuál usaste>.
- Todo como `TEXT` para no perder información por inferencia de tipos.
- Raw no se modifica nunca; si algo falla en Silver, se reconstruye desde aquí.

## Silver

**Grano:** una fila por contrato (`id_contrato`).

Transformaciones aplicadas:

- **Deduplicación:** 196 filas duplicadas exactas en raw (2,791,997 → 2,791,801).
- **Tipos:** dinero a `NUMERIC` (`parse_moneda`), fechas a `DATE` (`parse_fecha_us`), duración a horas (`parse_duracion_horas`).
- **Pseudo-nulos:** `No Definido`, vacíos y similares pasan a `NULL` (`limpiar_texto`).
- **Fechas inválidas:** fechas anteriores a 2013 (placeholders como 1899) pasan a `NULL` (`valid_date`). El límite es una decisión mía, documentada en `docs/validacion_silver.md`.
- **Flag de calidad:** `flag_inconsistencia_fechas` y/o `flag_pagado_supera_contrato` <deja solo los que realmente creaste>. Los datos se marcan, no se corrigen.

## Validaciones

Resumen (detalle en `docs/validacion_silver.md`):

| Validación | Resultado |
|---|---|
| Filas = ids únicos en Silver | 2,791,801 = 2,791,801 |
| Rango de fechas | <tu resultado> |
| Valor pagado > valor del contrato | <tu conteo> casos (<tu %>) |
| Fin de contrato antes del inicio | <tu conteo> casos |

## Estructura del repositorio

```
├── sql/
    ├── bronze
        ├── details_contracts.sql
    ├── silver
        ├── 01_silver_contratos_electronicos.sql
    ├── validation
│       ├── 01_validar_silver.sql 
│   └── 00_parseo_functions.sql
├── notebooks/
    ├── raw_create_schema.ipynb 
    ├── silver_contratos_electronicos.ipynb
├── docs/
│   ├── decisiones_columnas.md
│   ├── validacion_silver.md
│   └── profiling.csv
├── .env.example
└── README.md
```

## Cómo reproducirlo

1. Levantar PostgreSQL (Docker).
2. Descargar el CSV y cargarlo en `raw.contratos_electronicos`.
3. Ejecutar en orden: `00_parseo_functions` → `01_silver_contratos_electronicos.sql` → `01_validar_silver.sql`.
4. Las credenciales van en `.env` (ver `.env.example`).

## Decisiones y limitaciones

- De 95 columnas se conservaron 23 en Silver (criterios en `docs/decisiones_columnas.md`).
- <Limitaciones: causas no confirmadas de `valor_pagado > valor_contrato`, fechas futuras 2027-2035 sin modificar, etc.>

## Próximos pasos

- [ ] Gold: esquema estrella (hechos y dimensiones)
- [ ] Segunda tabla Silver (transacciones y relaciones)
- [ ] Reimplementar en Databricks con Delta Lake y comparar conteos
- [ ] Ingesta incremental con la API de Socrata
- [ ] ADLS, Data Factory y Key Vault