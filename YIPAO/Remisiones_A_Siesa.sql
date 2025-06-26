alter PROCEDURE [dbo].[Remisiones_A_Siesa]--'202506251'
    @row_id varchar(50)
AS
BEGIN
    DELETE FROM Remisiones 
    WHERE estado = 2 OR JSON_VALUE(jsonOrigen, '$.productName') LIKE '%DESCONOCIDO%'

    -- Crear tabla temporal #TemDoctos con notas incluida
    SELECT 
        JSON_VALUE(jsonOrigen, '$.transactionId') AS transactionId,
        JSON_VALUE(jsonOrigen, '$.productName') AS productName,
        JSON_VALUE(jsonOrigen, '$.cost') AS cost,
        CASE JSON_VALUE(jsonOrigen, '$.transactionType')
            WHEN 'EFECTIVO' THEN '009'
            WHEN 'CASHLESS' THEN '001'
        END AS co,
        CASE JSON_VALUE(jsonOrigen, '$.transactionType')
            WHEN 'EFECTIVO' THEN '222222222222'
            WHEN 'CASHLESS' THEN '800251569'
        END AS tercero,
        CASE JSON_VALUE(jsonOrigen, '$.transactionType')
            WHEN 'EFECTIVO' THEN 'CRC'
            WHEN 'CASHLESS' THEN '15D'
        END AS condicion,
        CONVERT(VARCHAR(8), REPLACE(JSON_VALUE(jsonOrigen, '$.date'), '-', ''), 112) AS fecha,
        Vw.Co as 'Co_Item',
        Vw.Id_Bodega as 'Bodega_Item',
        CASE Vw.Id_Bodega
            WHEN '001' THEN TRIM(m.Ubicacion)
            ELSE ''
        END AS Ubicacion,
        m.unidad_medida AS 'unidad_medida',
        paquete,
        CASE JSON_VALUE(jsonOrigen, '$.transactionType')
            WHEN 'EFECTIVO' THEN 'SERVICIO DE RESTAURANTES EFECTIVO MÁQUINAS'
            WHEN 'CASHLESS' THEN 'SERVICIO DE RESTAURANTE BENEFICIO MÁQUINAS NACIONAL'
        END AS notas
    INTO #TemDoctos
    FROM [dbo].[Remisiones] AS r
    LEFT JOIN MAESTRO_ITEMS_UBICACIONES m 
        ON JSON_VALUE(r.jsonOrigen, '$.productName') = m.Referencia 
        OR JSON_VALUE(r.jsonOrigen, '$.productName') = m.Descripcion
    LEFT JOIN VW_CO_Bodega_Dispensador Vw 
        ON JSON_VALUE(r.jsonOrigen, '$.dispenserName') = Vw.Descripcion_Dispensadora
    WHERE paquete = @row_id;

    -- Crear índices para optimizar joins
    CREATE INDEX IX_TemDoctos_Paquete ON #TemDoctos (paquete);
    CREATE INDEX IX_TemDoctos_TransactionId ON #TemDoctos (transactionId);
    CREATE INDEX IX_TemDoctos_GroupCols ON #TemDoctos (co, Bodega_Item, Ubicacion, Co_Item);

    --- TMP Encabezados (Remisión) - SIN columna id
    SELECT 
        'Remision' AS 'NombreSeccion',
        co AS 'F350_ID_CO',
        'RM' AS 'F350_ID_TIPO_DOCTO',
        ROW_NUMBER() OVER (ORDER BY MIN(fecha)) AS F350_CONSEC_DOCTO,
        MIN(fecha) AS 'F350_FECHA',
        tercero AS 'F350_ID_TERCERO',
        '002' AS 'f460_id_sucursal_fact',
        co AS 'f460_id_co_fact',
        tercero AS 'f460_id_tercero_rem',
        '002' AS 'f460_id_sucursal_rem',
        condicion AS 'f460_id_cond_pago',
        MIN(notas) AS 'f460_notas'
    INTO #TemRemision
    FROM #TemDoctos
    WHERE paquete = @row_id
    GROUP BY co, tercero, condicion;

    -- Crear tabla para relación entre documentos y transacciones
    SELECT 
        tr.F350_CONSEC_DOCTO,
        d.transactionId
    INTO #TemRemisionDetalle
    FROM #TemRemision tr
    INNER JOIN #TemDoctos d 
        ON tr.F350_ID_CO = d.co
        AND tr.F350_ID_TERCERO = d.tercero
        AND tr.f460_id_cond_pago = d.condicion
    WHERE d.paquete = @row_id;

    -- Crear índices para la tabla de detalle
    CREATE INDEX IX_TemRemisionDetalle_Consec ON #TemRemisionDetalle (F350_CONSEC_DOCTO);
    CREATE INDEX IX_TemRemisionDetalle_TransId ON #TemRemisionDetalle (transactionId);

    -- Resultado Remisión (Encabezado)
    SELECT 
        NombreSeccion,
        F350_ID_CO,
        F350_ID_TIPO_DOCTO,
        F350_CONSEC_DOCTO,
        F350_FECHA,
        F350_ID_TERCERO,
        f460_id_sucursal_fact,
        f460_id_co_fact,
        f460_id_tercero_rem,
        f460_id_sucursal_rem,
        f460_id_cond_pago,
        f460_notas
    FROM #TemRemision;

    --- Movimientos comerciales (optimizado usando #TemRemisionDetalle)
    SELECT
        'MovtoVentasComercial' AS NombreSeccion,
        d.co AS f470_id_co,
        'RM' AS f470_id_tipo_docto,
        rd.F350_CONSEC_DOCTO AS f470_consec_docto,
        ROW_NUMBER() OVER (
            PARTITION BY rd.F350_CONSEC_DOCTO 
            ORDER BY (SELECT NULL)
        ) AS f470_nro_registro,
        d.Bodega_Item AS f470_id_bodega,
        d.Ubicacion AS f470_id_ubicacion_aux,
        '01' AS f470_id_motivo,
        d.Co_Item AS f470_id_co_movto,
        '3001' AS f470_id_ccosto_movto,
        d.unidad_medida AS f470_id_unidad_medida,
        COUNT(*) AS f470_cant_base,
        TRY_CAST(d.cost AS DECIMAL(18,2)) * COUNT(*) AS f470_vlr_bruto,
        '' AS f470_notas,
        CASE d.productName
            WHEN 'TORTA' THEN 'TORTA MÁQUINAS' 
            WHEN 'GALLETA MUUU' THEN 'GALLETA MUU' 
            WHEN 'MUFFIN' THEN 'MUFFINS' 
            WHEN 'GALLETA MILO' THEN 'GALLETAS MILO' 
            ELSE d.productName
        END AS f470_referencia_item 
    FROM #TemDoctos d
    INNER JOIN #TemRemisionDetalle rd 
        ON d.transactionId = rd.transactionId
    WHERE d.paquete = @row_id
    GROUP BY 
        d.co,
        d.Bodega_Item,
        d.Ubicacion,
        d.Co_Item,
        d.unidad_medida,
        d.cost,
        d.productName,
        rd.F350_CONSEC_DOCTO
    ORDER BY rd.F350_CONSEC_DOCTO;

    -- Limpieza
    DROP TABLE #TemDoctos;
    DROP TABLE #TemRemision;
    DROP TABLE #TemRemisionDetalle;
END
GO