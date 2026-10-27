# Validación de Silver

| Capa   | Filas     | IDs únicos |
|--------|-----------|------------|
| raw    | 2,791,997 | 2,791,801  |
| silver | 2,791,801 | 2,791,801  |

**Hallazgo:** 196 filas duplicadas exactas en raw.
**Regla:** se conserva una fila por id_contrato con ROW_NUMBER().


# Validación de fechas

-----
## Columna: `fecha_inicio_contrato`
**Reglas:** Fechas anteriores a 2013 se consideran placeholder y se convierten a NULL
con `valid_date(parse_fecha_us(...))`.

## Resultado esperado
Ningún contrato con inicio anterior a 2013.

## Resultado real (antes de limpiar)

| Año inicio de contratos | Contratos |
|-------------------------|-----------|
| 1899                    | 5         |
| 2016                    | 1         |
| 2017                    | 14        |
| 2018                    | 240       |
| 2019                    | 27        |
| 2020                    | 11        |
| 2022                    | 2         |
| 2023                    | 1         |
| 2024                    | 869769    |
| 2025                    | 1006845   |
| 2026                    | 866008    |
| 2027                    | 12        |
| 2028                    | 5         |
| 2035                    | 2         |
|                         | 49055     |

## Hallazgos
- 5 contratos con inicio en 1899: placeholder de fecha vacía. Se convierten a NULL.
- 19 contratos con inicio entre 2027 y 2035 (2 en 2035). No se modifican; quedan marcados para revisión.
- 49,055 contratos sin fecha de inicio en origen (1.8 %).

## Decisión
Se aplica `valid_date`. Tras regenerar Silver: 0 contratos anteriores a 2013 y 49,060 NULL.

----

## Columna: `fecha_firma`
**Reglas:** Fechas anteriores a 2013 se consideran placeholder y se convierten a NULL
con `valid_date(parse_fecha_us(...))`.

## Resultado esperado
Ningún contrato con inicio anterior a 2013.

## Resultado real (antes de limpiar)

| Año de firma de contrato | Contratos |
|--------------------------|-----------|
| 2024                     | 880929    |
| 2025                     | 1017074   |
| 2026                     | 893994    |

## Hallazgos
No se encontró ningún contrato que presentada alguna anomalía. 

## Decisión 
No se aplica `valid_date`: 0 contratos anteriores a 2013.

----

# Validación de texto en columnas

## Columna: `nombre_supervisor`
**Reglas:** Fechas anteriores a 2013 se consideran placeholder y se convierten a NULL
con `valid_date(parse_fecha_us(...))`.

## Resultado esperado
Encontrar valores  `null` donde no hay supervisor.

| Nombre_supervisor |anomalias|
|-------------------|---------|
| No definido       |728744|

## Hallazgos
Se encontro 728744 contratos con un supervisor que no esta definido donde se categorizo como `No definido`.

## Decisión 

Aplicar `clean text` para normalizar la columna y cambiar estos supervisores no definidos como **null**.

----
## Consistencia: valor_pagado vs valor_contrato

**Regla:** `valor_pagado` no debería superar `valor_contrato` (salvo adiciones).

**Resultado esperado:** 0 casos, o casos explicables.

| Tramo | Casos |
|---|---|
| Hasta 10 % más | 1,063 |
| Hasta el doble | 173 |
| Hasta 10 veces | 59 |
| Más de 10 veces | 6 |

**Total:** 1,301 (0.05 % de 2,791,801). Excluye contratos con `valor_contrato` = 0 o NULL.

**Causa:** no confirmada (posibles adiciones o errores de digitación en la fuente).

**Decisión:** se marcan con `flag_pagado_supera_contrato`; no se modifican valores.

----

## Consistencia: fecha_inicio_contrato vs fecha_fin_contrato

**Regla:** `fecha_fin_contrato` no debería ser menor a `fecha_inicio_contrato`.


**Resultado esperado:** 0 casos, o casos explicables.

|fechas_fin_mayores|
|------------------|
|595|

**Total:** Se encontraron 595 contratos con `fecha_fin_contrato` menor a la
`fecha_inicio_contrato`.

**Causa:** No confirmados (posiblemente errores de digitación o errores en migración de datos)

**Decisión:** se marcan con `flag_fin_antes_inicio`; no se modifican valores.