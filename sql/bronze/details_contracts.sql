-- bloque pl para tener panorama sobre una tabla en crudo

DO $$
DECLARE
    r RECORD;
    sql_query TEXT;
    total_rows BIGINT;

    -- CONFIGURA AQUÍ TU TABLA Y ESQUEMA
    target_schema TEXT := 'raw';
    target_table TEXT := 'contratos_electronicos';
BEGIN
    -- 1. Obtener el total de filas de la tabla base una sola vez
    EXECUTE format('SELECT COUNT(*) FROM %I.%I', target_schema, target_table) INTO total_rows;

    -- Si la tabla está vacía, evitamos divisiones por cero
    IF total_rows = 0 THEN
        RAISE NOTICE 'La tabla está completamente vacía.';
        RETURN;
    END IF;

    -- Crear una tabla temporal para almacenar los resultados del perfilamiento
    CREATE TEMP TABLE IF NOT EXISTS temp_data_profile (
        columna TEXT,
        tipo_dato TEXT,
        total_filas BIGINT,
        valores_nulos BIGINT,
        porcentaje_nulos NUMERIC(5,2),
        valores_unicos BIGINT
    ) ON COMMIT DROP;

    -- Limpiar la tabla temporal por si se ejecuta varias veces en la misma sesión
    TRUNCATE temp_data_profile;

    -- 2. Recorrer iterativamente cada columna usando el catálogo de Postgres
    FOR r IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = target_schema
          AND table_name = target_table
        ORDER BY ordinal_position
    LOOP
        -- 3. Construir dinámicamente la consulta de agregación para la columna actual
        -- Usamos %I para blindar los nombres de columnas y evitar errores de sintaxis
        sql_query := format(
            'INSERT INTO temp_data_profile ' ||
            'SELECT %L, %L, %s, ' ||
            '       (%s - COUNT(%I)), ' ||
            '       ROUND((%s - COUNT(%I)) * 100.0 / %s, 2), ' ||
            '       COUNT(DISTINCT %I) ' ||
            'FROM %I.%I',
            r.column_name,
            r.data_type,
            total_rows,
            total_rows, r.column_name,
            total_rows, r.column_name, total_rows,
            r.column_name,
            target_schema,
            target_table
        );

        -- Ejecutar la consulta dinámica generada
        EXECUTE sql_query;
    END LOOP;
END $$;

-- 4. Consultar el reporte consolidado ordenado de mayor a menor porcentaje de nulos
SELECT *
FROM temp_data_profile
ORDER BY porcentaje_nulos DESC;