--- CONSULTAR: Qué tipos de documentos se deben consultar para el saldo abierto de un tercero


---- Tabla temporal para almacenar los saldos de los clientes
SELECT 
    t353.f353_rowid                                                                     AS rowidsa,
    t353.f353_id_co_cruce                                                               AS idco,
    t353.f353_id_un_cruce                                                               AS idun,
    CONCAT(t353.f353_id_tipo_docto_cruce, '-',
        RIGHT('00000000' + CAST(t353.f353_consec_docto_cruce AS VARCHAR(8)), 8),
        '-',
        RIGHT('00' + CAST(t353.f353_nro_cuota_cruce AS VARCHAR(2)), 2)
    )                                                                                   AS doccruce,
    t200.f200_id                                                                        AS idtercero,
    t353.f353_fecha                                                                     AS fecha,
    t353.f353_fecha_cancelacion                                                         AS f_fecha_cancelacion,
    t353.f353_fecha_cancelacion_rec                                                     AS f_fecha_cancelacion_rec,
    t353.f353_fecha_vcto                                                                AS vencimiento,
CASE 
    WHEN DATEDIFF(DAY, f353_fecha_vcto, ISNULL(f353_fecha_cancelacion_rec, GETDATE())) < 0 
    THEN 0
    ELSE DATEDIFF(DAY, f353_fecha_vcto, ISNULL(f353_fecha_cancelacion_rec, GETDATE()))
END AS diasvencidos,
T208.f208_dias_vcto AS DiasCondPago,
f353_rowid_tercero AS RowIdTercero
INTO #TempSaldos
FROM   t353_co_saldo_abierto t353
LEFT OUTER JOIN t210_mm_vendedores t210
    ON t353.f353_rowid_vend = t210.f210_rowid_tercero
INNER JOIN t200_mm_terceros t200
    ON f353_rowid_tercero = t200.f200_rowid
INNER JOIN t200_mm_terceros t2
    ON t2.f200_rowid = f353_rowid_vend
INNER JOIN t253_co_auxiliares t253
    ON f353_rowid_auxiliar = t253.f253_rowid
INNER JOIN t201_mm_clientes t201
    ON  t201.f201_rowid_tercero = f353_rowid_tercero
        AND t201.f201_id_sucursal = f353_id_sucursal
INNER JOIN t017_mm_monedas t017
    ON t017.f017_id_cia = t253.f253_id_cia
        AND t017.f017_id = t253.f253_id_moneda

INNER JOIN t208_mm_condiciones_pago T208
    ON t201.f201_id_cond_pago = T208.f208_id






WHERE f353_fecha_cancelacion_rec > DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
    --AND f353_fecha_cancelacion_rec>'20250101'
    AND t353.f353_id_tipo_docto_cruce like 'FEL'
    AND f353_fecha_cancelacion_rec IS NOT NULL
ORDER BY T200.f200_id


				 
SELECT IdTercero, 
    AVG(diasvencidos) PromedioDiasVencidos, 
    MAX(DiasCondPago) MaxDiasCondPago,
    t201Suc.f201_id_sucursal AS IdSucursal
FROM #TempSaldos Temp
INNER JOIN t201_mm_clientes t201Suc
    ON  t201Suc.f201_rowid_tercero = Temp.RowIdTercero
        --AND t201Suc.f201_id_sucursal = f353_id_sucursal
GROUP BY IdTercero, t201Suc.f201_id_sucursal
ORDER BY IdTercero

DROP TABLE #TempSaldos





SELECT * FROM 
t201_mm_clientes t201Suc
    --ON  t201Suc.f201_rowid_tercero = f353_rowid_tercero
INNER JOIN t200_mm_terceros t200
    ON f201_rowid_tercero = t200.f200_rowid
where f201_rowid_tercero = 8565

t200.f200_id  IN ('892300678')





                  ----------------------*************************----------------------
                -- Consulta para obtener los datos de la condición de pago de un tercero  


SELECT 
    t353.f353_rowid                                                                     AS rowidsa,
    t353.f353_id_co_cruce                                                               AS idco,
    t353.f353_id_un_cruce                                                               AS idun,
    CONCAT(t353.f353_id_tipo_docto_cruce, '-',
        RIGHT('00000000' + CAST(t353.f353_consec_docto_cruce AS VARCHAR(8)), 8),
        '-',
        RIGHT('00' + CAST(t353.f353_nro_cuota_cruce AS VARCHAR(2)), 2)
    )                                                                                   AS doccruce,
    t200.f200_id                                                                        AS idtercero,
    t353.f353_fecha                                                                     AS fecha,
    t353.f353_fecha_cancelacion                                                         AS f_fecha_cancelacion,
    t353.f353_fecha_cancelacion_rec                                                     AS f_fecha_cancelacion_rec,
    t353.f353_fecha_vcto                                                                AS vencimiento,
CASE 
    WHEN DATEDIFF(DAY, f353_fecha_vcto, ISNULL(f353_fecha_cancelacion_rec, GETDATE())) < 0 
    THEN 0
    ELSE DATEDIFF(DAY, f353_fecha_vcto, ISNULL(f353_fecha_cancelacion_rec, GETDATE()))
END AS diasvencidos,
T208.f208_dias_vcto AS DiasCondPago
INTO #TempSaldos
FROM   t353_co_saldo_abierto t353
LEFT OUTER JOIN t210_mm_vendedores t210
    ON t353.f353_rowid_vend = t210.f210_rowid_tercero
INNER JOIN t200_mm_terceros t200
    ON f353_rowid_tercero = t200.f200_rowid
INNER JOIN t200_mm_terceros t2
    ON t2.f200_rowid = f353_rowid_vend
INNER JOIN t253_co_auxiliares t253
    ON f353_rowid_auxiliar = t253.f253_rowid
INNER JOIN t201_mm_clientes t201
    ON  t201.f201_rowid_tercero = f353_rowid_tercero
        AND t201.f201_id_sucursal = f353_id_sucursal
INNER JOIN t017_mm_monedas t017
    ON t017.f017_id_cia = t253.f253_id_cia
        AND t017.f017_id = t253.f253_id_moneda

INNER JOIN t208_mm_condiciones_pago T208
    ON t201.f201_id_cond_pago = T208.f208_id
WHERE f353_fecha_cancelacion_rec > DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
    --AND f353_fecha_cancelacion_rec>'20250101'
    AND t353.f353_id_tipo_docto_cruce like 'FEL'
    AND f353_fecha_cancelacion_rec IS NOT NULL
ORDER BY T200.f200_id


				 
SELECT IdTercero, 
AVG(diasvencidos) PromedioDiasVencidos, 
    DiasCondPago
FROM #TempSaldos
GROUP BY IdTercero, DiasCondPago

DROP TABLE #TempSaldos






                  ----------------------*************************----------------------







SELECT  DISTINCT f353_consec_docto_cruce, 
    -- f353_id_co_cruce AS idco, 
    -- f353_id_un_cruce AS idun, 
    f353_id_tipo_docto_cruce + '-' + 
        REPLICATE('0', 8 - LEN(CONVERT(VARCHAR(8), f353_consec_docto_cruce))) + 
        CONVERT(VARCHAR(8), f353_consec_docto_cruce) + '-' + 
        REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(8), f353_nro_cuota_cruce))) + 
        CONVERT(VARCHAR(8), f353_nro_cuota_cruce) AS doccruce,
    DATEDIFF(DAY, f353_fecha_vcto, GETDATE()) AS diasvencidos, 
    f353_total_db - f353_total_cr + f353_total_ch_postf AS saldo,
    t1.f200_id AS idtercero
FROM t353_co_saldo_abierto 			
    INNER JOIN t200_mm_terceros t1 
        ON t1.f200_rowid = f353_rowid_tercero				
    INNER JOIN t200_mm_terceros t2 
        ON t2.f200_rowid = f353_rowid_vend
    INNER JOIN t017_mm_monedas 
        ON f017_id_cia = f353_id_cia
    INNER JOIN t201_mm_clientes 
        ON f201_rowid_tercero = f353_rowid_tercero
        AND f201_id_sucursal = f353_id_sucursal
    LEFT JOIN t210_mm_vendedores 
        ON f210_rowid_tercero = f353_rowid_vend				

WHERE 
    DATEDIFF(DAY, f353_fecha_vcto, GETDATE()) > 0
    AND t1.f200_nit IN ('9434044      ')
    AND  f353_fecha > DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
    AND (f353_total_db - f353_total_cr + f353_total_ch_postf)<>0


ORDER BY f353_consec_docto_cruce








SELECT  DISTINCT f353_consec_docto_cruce, 
    -- f353_id_co_cruce AS idco, 
    -- f353_id_un_cruce AS idun, 
    f353_id_tipo_docto_cruce + '-' + 
        REPLICATE('0', 8 - LEN(CONVERT(VARCHAR(8), f353_consec_docto_cruce))) + 
        CONVERT(VARCHAR(8), f353_consec_docto_cruce) + '-' + 
        REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(8), f353_nro_cuota_cruce))) + 
        CONVERT(VARCHAR(8), f353_nro_cuota_cruce) AS doccruce,
    -- f353_fecha AS fecha, 
    -- f353_fecha_vcto AS fecha_vcto_docto,
    -- f353_fecha_vcto AS vencimiento, 
    DATEDIFF(DAY, f353_fecha_vcto, GETDATE()) AS diasvencidos, 
    
    t1.f200_id AS idtercero
    -- t1.f200_nit AS nittercero,
    -- t1.f200_razon_social AS razontercero,

    -- f201_id_sucursal AS idsucursal, 
    -- f201_descripcion_sucursal AS dessucursal,

    -- f210_id AS idvendedor, 
    -- t2.f200_razon_social AS desvendedor,

    -- f353_fecha_dscto_pp AS fechaprontopago, 
    -- f353_vlr_dscto_pp AS valordescuentopp,
    -- RTRIM(f353_notas) AS notas,

    -- f353_fecha_docto_cruce AS fecha_docto_cruce
INTO #TempSaldoAbierto
FROM t353_co_saldo_abierto 			
    INNER JOIN t200_mm_terceros t1 
        ON t1.f200_rowid = f353_rowid_tercero				
    INNER JOIN t200_mm_terceros t2 
        ON t2.f200_rowid = f353_rowid_vend
    INNER JOIN t017_mm_monedas 
        ON f017_id_cia = f353_id_cia
    INNER JOIN t201_mm_clientes 
        ON f201_rowid_tercero = f353_rowid_tercero
        AND f201_id_sucursal = f353_id_sucursal
    LEFT JOIN t210_mm_vendedores 
        ON f210_rowid_tercero = f353_rowid_vend				

WHERE 
    DATEDIFF(DAY, f353_fecha_vcto, GETDATE()) > 0
    AND t1.f200_nit IN ('800052534')
    AND  f353_fecha > DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
    AND (f353_total_db - f353_total_cr + f353_total_ch_postf)<>0


ORDER BY f353_consec_docto_cruce


SELECT IdTercero, AVG(diasvencidos) 
FROM #TempSaldoAbierto
GROUP BY IdTercero

DROP TABLE #TempSaldoAbierto