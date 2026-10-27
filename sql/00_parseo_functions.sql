-- Limpieza y cast sobre valores monetarios
CREATE OR REPLACE FUNCTION parse_moneda(p_texto TEXT)
RETURNS NUMERIC(18, 2)
LANGUAGE sql
IMMUTABLE
AS $$
    -- '$1.234.567' -> 1234567.00 | '$1.234.567,89' -> 1234567.89
    SELECT CASE
        WHEN TRANSLATE(p_texto, '$. ', '') ~ '^\d+(,\d+)?$'
        THEN REPLACE(TRANSLATE(p_texto, '$. ', ''), ',', '.')::NUMERIC(18, 2)
    END
$$;

-- Cast de fechas
CREATE OR REPLACE FUNCTION parse_fecha_us(p_texto TEXT)
RETURNS DATE
LANGUAGE sql
IMMUTABLE
AS $$
    -- '09/14/2026' -> 2026-09-14 (MM/DD/YYYY)
    SELECT CASE
        WHEN p_texto ~ '^\d{2}/\d{2}/\d{4}$'
         AND SUBSTRING(p_texto, 1, 2)::INT BETWEEN 1 AND 12
         AND SUBSTRING(p_texto, 4, 2)::INT BETWEEN 1 AND 31
        THEN TO_DATE(p_texto, 'MM/DD/YYYY')
    END
$$;

--Normalización de tiempo
DROP FUNCTION IF EXISTS parse_duracion_horas(TEXT);

CREATE FUNCTION parse_duracion_horas(p_texto TEXT)
RETURNS BIGINT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN p_texto ~* '^\d{1,9}\s*hora'   THEN SUBSTRING(p_texto FROM '^\d+')::BIGINT
        WHEN p_texto ~* '^\d{1,9}\s*dia'    THEN SUBSTRING(p_texto FROM '^\d+')::BIGINT * 24
        WHEN p_texto ~* '^\d{1,9}\s*semana' THEN SUBSTRING(p_texto FROM '^\d+')::BIGINT * 24 * 7
        WHEN p_texto ~* '^\d{1,9}\s*mes'    THEN SUBSTRING(p_texto FROM '^\d+')::BIGINT * 24 * 30
        WHEN p_texto ~* '^\d{1,9}\s*a[ñn]o' THEN SUBSTRING(p_texto FROM '^\d+')::BIGINT * 24 * 365
    END
$$;

--Limpiar texto
CREATE OR REPLACE FUNCTION clean_text(t TEXT)
RETURNS TEXT AS $$
    SELECT
        CASE WHEN lower(trim(t)) IN ('', 'no definido', 'n/a') THEN NULL
                ELSE trim(t) END
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION valid_date(d DATE)
RETURNS DATE
AS $$
    SELECT CASE
        WHEN d BETWEEN DATE '2013-01-01' AND DATE '2038-10-13' THEN d
    END
$$ LANGUAGE sql IMMUTABLE;
