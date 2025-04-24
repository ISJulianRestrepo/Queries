------------MAESTRO DEL VALOR CAVIDADES POR MOLDEO PARA EL MÉTODO = 0001

SELECT
    tmr.f808_id AS 'CODIGO_RUTA',
    tmro.f809_id_metodo AS 'CODIGO_METODO',
    tmdtc.f104_id AS 'CAMPO DESCRIPCION TECNICA',
    tmroi.f810_dato AS 'VALOR_ASIGNADO'
INTO #TempValoresPorRuta
FROM
    UnoEE.dbo.t810_mf_rutas_operacion_instru AS tmroi
    LEFT JOIN
    UnoEE.dbo.t809_mf_rutas_operacion AS tmro
    ON tmroi.f810_rowid_ruta_oper = tmro.f809_rowid
    LEFT JOIN
    UnoEE.dbo.t808_mf_rutas AS tmr
    ON tmr.f808_rowid = tmro.f809_rowid_rutas
    LEFT JOIN
    UnoEE.dbo.t104_mc_desc_tecnicas_campos AS tmdtc
    ON tmdtc.f104_rowid = tmroi.f810_rowid_campo
WHERE f104_id LIKE '%07 CAVIDADES POR MOLDEO%'
    AND f809_id_metodo != '0001'


--MAESTRO DE LOS CALIBRES Y ANCHOS DE LOS MATERIALES:
SELECT
    f120_rowid AS row_id_item,
    f105_id AS id_plan,
    t106.f106_descripcion AS valor
INTO #TempCalibres_Anchos
FROM [dbo].[t125_mc_items_criterios] t125
    INNER JOIN t106_mc_criterios_item_mayores t106
    ON t125.f125_id_cia = t106.f106_id_cia
        AND T125.f125_id_plan = f106_id_plan
        AND t125.f125_id_criterio_mayor = t106.f106_id
    INNER JOIN t120_mc_items t120
    ON f120_rowid = f125_rowid_item
    INNER JOIN t105_mc_criterios_item_planes T105
    ON f105_id_cia=f106_id_cia
        AND f105_id= f106_id_plan
WHERE f125_id_plan in('007', '008')
------------COMPLETO:


SELECT DISTINCT
    T850.f850_id_tipo_docto AS Type_docto
	, T850.f850_consec_docto AS workOrderId
    , LTRIM(v121_op.v121_referencia) AS productId
    , LTRIM(v121_op.v121_descripcion) AS productName
    , v851.v851_cant_planeada_base AS programmedQty
    , FORMAT(v851.v851_fecha_inicio, 'yyyy-MM-dd') AS startDate
    , FORMAT(v851.v851_fecha_terminacion, 'yyyy-MM-dd') AS endDate
	, CASE
        WHEN T850.f850_ind_estado = 2 THEN 'Comprometido'
        ELSE 'Aprobado' 
    END AS status
	, v851.v851_id_unidad_medida AS unit
    --,v121_op.v121_id_unidad_empaque AS pickingUnit
    , ISNULL(t122_cajas.f122_factor, 1) AS pickingUnit
    -- ,1 AS pickingUnit
    , T122.f122_peso AS weight 
	, T809.f809_numero_operacion AS operationFase
	, f809_descripcion AS operationName
	, LTRIM(T806.f806_id) AS workUnitId
	, t809.f809_horas_ejecucion AS t809_horas_ejecucion
	, t809.f809_cantidad_base AS t809_cantidad_base
	, CASE 
	 	WHEN f809_id_metodo = '0001' THEN
	 		CASE
	 			WHEN LEN(T123.f123_dato) > 0 THEN T123.f123_dato
	 			ELSE 1
	 		END
	 	WHEN f809_id_metodo != '0001' THEN
	 		CASE	
	 			WHEN TEMP.VALOR_ASIGNADO IS NOT NULL THEN TEMP.VALOR_ASIGNADO
	 			ELSE 1
	 		END
	 	ELSE 1
     END AS cavidades_moldeo
	     , CASE 
         WHEN f809_descripcion LIKE '%TERMOFOR%' THEN 0
	 	WHEN f809_descripcion LIKE '%EXT%' THEN 1
	 	ELSE 1
     END AS timeFactor
	, t150_a.f150_id AS store
	, CASE 
         WHEN f809_descripcion LIKE '%TERMO%' THEN ''
	 	WHEN f809_descripcion LIKE '%EXT%' THEN temp_Calibre.valor
	 	ELSE ''
     END AS Calibre
	 , CASE 
         WHEN f809_descripcion LIKE '%TERMO%' THEN ''
	 	WHEN f809_descripcion LIKE '%EXT%' THEN temp_Ancho.valor
	 	ELSE ''
     END AS Ancho
	, f809_numero_operarios AS Operarios
FROM t850_mf_op_docto t850
    INNER JOIN v851
    ON v851_rowid_op_docto = t850.f850_rowid AND v851.v851_cant_planeada_base > 0
    INNER JOIN v121 v121_op
    ON v121_op.v121_rowid_item_ext = v851_rowid_item_ext_op
    LEFT JOIN t150_mc_bodegas t150_a
    ON t150_a.f150_rowid = v851_rowid_bodega
    INNER JOIN t122_mc_items_unidades t122
    ON t122.f122_rowid_item = v121_op.v121_rowid_item
        AND t122.f122_id_unidad = v851_id_unidad_medida
    LEFT JOIN t122_mc_items_unidades t122_cajas
    ON t122_cajas.f122_rowid_item = v121_op.v121_rowid_item
        AND t122_cajas. f122_id_unidad !='UNID'
    INNER JOIN t808_mf_rutas  AS t808
    ON t808.f808_rowid = v851.v851_rowid_ruta


    INNER JOIN t809_mf_rutas_operacion AS T809
    ON f809_rowid_rutas = t808.f808_rowid AND f809_id_metodo = v851_id_metodo_ruta
    INNER JOIN t806_mf_centros_trabajo AS T806
    ON T809.f809_rowid_ctrabajo = T806.f806_rowid
    LEFT JOIN t810_mf_rutas_operacion_instru T810C
    ON T810C.f810_rowid_ruta_oper = T809.f809_rowid
        AND T810C.f810_rowid_campo IN ('433','656')
    LEFT JOIN t103_mc_descripciones_tecnicas T103
    ON v121_op.v121_id_descripcion_tecnica = T103.f103_id
        AND t103.f103_descripcion = 'TERMOFORMADO'
    LEFT JOIN t104_mc_desc_tecnicas_campos t104
    ON t103.f103_id = t104.f104_id_descripcion_tecnica
        AND f104_id = 'CAVIDADES POR MOLDEO' AND f104_id_descripcion_tecnica = '010'
    LEFT JOIN t123_mc_items_desc_tecnicas T123
    ON f123_id_cia = 1 AND t123.f123_rowid_item = v121_op.v121_rowid_item AND t123.f123_rowid_campo = t104.f104_rowid
    LEFT JOIN #TempCalibres_Anchos temp_Calibre
    ON v121_op.v121_rowid_item = temp_Calibre.row_id_item
        AND temp_Calibre.id_plan IN ('007')
    LEFT JOIN #TempCalibres_Anchos temp_Ancho
    ON v121_op.v121_rowid_item = temp_Ancho.row_id_item
        AND temp_Ancho.id_plan IN ('008')
    FULL JOIN #TempValoresPorRuta temp
    ON t808.f808_id  = temp.CODIGO_RUTA
        AND t809.f809_id_metodo =  temp.CODIGO_METODO
WHERE  t850.f850_id_cia = 1
    AND t850.f850_id_grupo_clase_docto = 701
    AND t850.f850_ind_estado IN ( 1, 2 )
    AND T850.f850_id_tipo_docto IN ('MOP', 'MOE')
    AND LEFT(f809_descripcion,12) NOT IN ('CAMBIO DE RE',
											'MONTAJE Y DE',
											'PUESTA A PUN',
											'CAMBIO DE RO',
                                            'REVISION Y E')
--AND f850_consec_docto = 8794 
DROP TABLE #TempValoresPorRuta
DROP TABLE #TempCalibres_Anchos

-- use unoee_pruebas


-- exec sp_help v121_rowid_item_ext

-- SELECT * FROM v121 WHERE v121_rowid_item_ext=245
-- SELECT * FROM t101_mc_unidades_medida
-- SELECT * FROM t122_mc_items_unidades where f122_rowid_item in (497)

-- SELECT t122_cajas.f122_factor AS pickingUnit
-- FROM t122_mc_items_unidades t122_cajas
-- WHERE t122_cajas.f122_rowid_item = 497 
-- 	AND t122_cajas.f122_id_unidad = 'CAJ'

-- SELECT * FROM 
-- LEFT JOIN t122_mc_items_unidades t122_cajas
-- 	ON t122.f122_rowid_item = v121_op.v121_rowid_item 
-- 		AND t122_cajas. f122_id_unidad='CAJ'