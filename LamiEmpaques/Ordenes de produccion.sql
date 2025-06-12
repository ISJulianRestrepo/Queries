------------MAESTRO DEL VALOR CAVIDADES POR MOLDEO PARA EL MÉTODO != 0001

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


--Tabla temporal para almacenar los id de operaciones de troquelado para cada OP y los valores necesarios para obtener las cavidades por moldeo de cada proceso
SELECT DISTINCT
    f850_consec_docto
    ,f809_numero_operacion
    ,f809_descripcion
    ,t123_troquel.f123_dato AS troquel
    ,t123_apilados.f123_dato AS apilados
    ,TEMP.VALOR_ASIGNADO
INTO #TempIdOperacionesTroqueladoPorOP
FROM t850_mf_op_docto t850
    INNER JOIN v851
    ON v851_rowid_op_docto = t850.f850_rowid AND v851.v851_cant_planeada_base > 0
    INNER JOIN t808_mf_rutas  AS t808
    ON t808.f808_rowid = v851.v851_rowid_ruta
    INNER JOIN t809_mf_rutas_operacion AS T809
    ON f809_rowid_rutas = t808.f808_rowid AND f809_id_metodo = v851_id_metodo_ruta
    INNER JOIN v121 v121_op
        ON v121_op.v121_rowid_item_ext = v851_rowid_item_ext_op
            LEFT JOIN t103_mc_descripciones_tecnicas T103
        ON v121_op.v121_id_descripcion_tecnica = T103.f103_id
            --AND t103.f103_descripcion = 'TERMOFORMADO'
    LEFT JOIN t104_mc_desc_tecnicas_campos t104_troquel
        ON t103.f103_id = t104_troquel.f104_id_descripcion_tecnica
            AND t104_troquel.f104_id = 'CAVIDADES POR TROQUEL' AND t104_troquel.f104_id_descripcion_tecnica = '010'
    LEFT JOIN t123_mc_items_desc_tecnicas t123_troquel
        ON t123_troquel.f123_id_cia = 1 AND t123_troquel.f123_rowid_item = v121_op.v121_rowid_item AND t123_troquel.f123_rowid_campo = t104_troquel.f104_rowid
    FULL JOIN #TempValoresPorRuta temp
    ON t808.f808_id  = temp.CODIGO_RUTA
        AND t809.f809_id_metodo =  temp.CODIGO_METODO

    LEFT JOIN t104_mc_desc_tecnicas_campos t104_apilados
    ON t103.f103_id = t104_apilados.f104_id_descripcion_tecnica
        AND t104_apilados.f104_id = 'APILADOS POR TROQUEL' AND t104_apilados.f104_id_descripcion_tecnica = '010'
    LEFT JOIN t123_mc_items_desc_tecnicas t123_apilados
    ON t123_apilados.f123_id_cia = 1 AND t123_apilados.f123_rowid_item = v121_op.v121_rowid_item AND t123_apilados.f123_rowid_campo = t104_apilados.f104_rowid
WHERE  t850.f850_id_cia = 1
    AND t850.f850_id_grupo_clase_docto = 701
    AND t850.f850_ind_estado IN ( 1, 2 )
    AND T850.f850_id_tipo_docto IN ('MOP', 'MOE')
    AND t809.f809_descripcion LIKE '%TROQUELADO%'


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


-- Tabla temporal para almacenar descripciones técnicas de los items para la ruta 0001, se almacenan los datos de:
-- ANCHO DEL PRODUCTO CM, DE CAJAS POR PLANCHA PALLET, DE PLANCHAS POR PALLET, DE RETAL
SELECT 
    t123.f123_rowid_item,
    f123_datos = STUFF((
        SELECT 
            ' ' + t104_sub.f104_id + ': ' + t123_sub.f123_dato + '    '
        FROM t123_mc_items_desc_tecnicas t123_sub
        LEFT JOIN t104_mc_desc_tecnicas_campos t104_sub
            ON t123_sub.f123_rowid_campo = t104_sub.f104_rowid
        WHERE 
            t123_sub.f123_rowid_item = t123.f123_rowid_item
            AND (
                t104_sub.f104_id LIKE '%ANCHO DEL PRODUCTO CM%' 
                OR t104_sub.f104_id LIKE '% DE CAJAS POR PLANCHA PALLET%'
                OR t104_sub.f104_id LIKE '% DE PLANCHAS POR PALLET%'
                OR t104_sub.f104_id LIKE '% DE RETAL%' 
            )
            AND t123_sub.f123_rowid_item IS NOT NULL
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
INTO #TempDesc_Tecnicas
FROM t123_mc_items_desc_tecnicas t123
GROUP BY t123.f123_rowid_item;



------------COMPLETO:
SELECT DISTINCT
    T850.f850_id_tipo_docto AS Type_docto
	,T850.f850_consec_docto AS workOrderId
    ,LTRIM(v121_op.v121_referencia) AS productId
    ,LTRIM(v121_op.v121_descripcion) AS productName
    ,v851.v851_cant_planeada_base AS programmedQty
    ,FORMAT(v851.v851_fecha_inicio, 'yyyy-MM-dd') AS startDate
    ,FORMAT(v851.v851_fecha_terminacion, 'yyyy-MM-dd') AS endDate
	,CASE
        WHEN T850.f850_ind_estado = 2 THEN 'Comprometido'
        ELSE 'Aprobado' 
    END AS status
    , v851.v851_id_unidad_medida AS unit
    --,v121_op.v121_id_unidad_empaque AS pickingUnit
    , ISNULL(t122_cajas.f122_factor, 1) AS pickingUnit
    ,T122.f122_peso AS weight 
	 ,T809.f809_numero_operacion AS operationFase
	 ,t809.f809_descripcion AS operationName
	,LTRIM(T806.f806_id) AS workUnitId
	,t809.f809_horas_ejecucion AS t809_horas_ejecucion
	,t809.f809_cantidad_base AS t809_cantidad_base
    ,CASE 
        --Validamos si la operación de troquelado existe en la tabla temporal para cada OP, lo que indica que la OP tiene una fase de troquelado 
        --y se debe asegurar que el valor de cavidades por moldeo sea igual al de la operación de troquelado para las operaciones posteriores a la fase se troquelado
        WHEN EXISTS (SELECT 1 FROM #TempIdOperacionesTroqueladoPorOP T WHERE T.f850_consec_docto = T850.f850_consec_docto) THEN
            CASE
                --Si el id de proceso es superior al id de la operación de troquelado, se pone la misma cantidad de cavidades que la operación de troquelado
                WHEN T809.f809_numero_operacion > (SELECT MAX(f809_numero_operacion) FROM #TempIdOperacionesTroqueladoPorOP T WHERE T.f850_consec_docto = T850.f850_consec_docto) 
                    THEN
                        CASE 
                            WHEN f809_id_metodo = '0001' THEN        
                                (
                                    (SELECT CONVERT(INT,t.troquel) FROM #TempIdOperacionesTroqueladoPorOP T WHERE T.f850_consec_docto = t850.f850_consec_docto)
                                        * 
                                    (SELECT CONVERT(INT,t.apilados) FROM #TempIdOperacionesTroqueladoPorOP T WHERE T.f850_consec_docto = t850.f850_consec_docto)
                                )
                            WHEN f809_id_metodo != '0001' THEN
                                CASE	
                                    WHEN (SELECT VALOR_ASIGNADO FROM #TempIdOperacionesTroqueladoPorOP T WHERE T.f850_consec_docto = t850.f850_consec_docto) IS NOT NULL THEN (SELECT VALOR_ASIGNADO FROM #TempIdOperacionesTroqueladoPorOP T WHERE T.f850_consec_docto = t850.f850_consec_docto)
                                    ELSE 1
                                END
                        END
                ELSE 
                    ----> A continuación, se determina el valor de las cavidades por moldeo para cada fase de las órdenes de producción (OP) 
                    ----> que incluyen una fase de troquelado, ya sea en la propia fase de troquelado o en alguna de las fases previas.
                    CASE 
                        WHEN LTRIM(T806.f806_id) LIKE '%TQ%' THEN 
                            CASE 
                                WHEN f809_id_metodo = '0001' THEN            
                                    (CONVERT(INT,t123_troquel.f123_dato) * CONVERT(INT,t123_apilados.f123_dato))
                                WHEN f809_id_metodo != '0001' THEN
                                    CASE	
                                        WHEN TEMP.VALOR_ASIGNADO IS NOT NULL THEN TEMP.VALOR_ASIGNADO
                                        ELSE 1
                                    END
                            END
                        ELSE
                            CASE 
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
                            END
                    END
            END                    
        ELSE
            ----> A continuación se obtiene el valor de las cavidades por moldeo para todas las fases de las OP que no tienen fase de troquelado
            CASE 
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
            END            
     END AS cavidades_moldeo
     ---> Versión inicial de la consulta para obtener el valor las cavidades por moldeo o troquelado ----- No valida las cantidades por moldeo posterior al troquelado
	-- ,CASE 
    --     WHEN LTRIM(T806.f806_id) LIKE '%TQ%' THEN 
    --         CASE 
	--           	WHEN f809_id_metodo = '0001' THEN            
    --                 (CONVERT(INT,t123_troquel.f123_dato) * CONVERT(INT,t123_apilados.f123_dato))
    --             WHEN f809_id_metodo != '0001' THEN
    --                 CASE	
    --                     WHEN TEMP.VALOR_ASIGNADO IS NOT NULL THEN TEMP.VALOR_ASIGNADO
    --                     ELSE 1
    --                 END
    --         END
    --     ELSE
    --         CASE 
    --             WHEN f809_id_metodo = '0001' THEN
    --                 CASE
    --                     WHEN LEN(T123.f123_dato) > 0 THEN T123.f123_dato
    --                     ELSE 1
    --                 END
    --             WHEN f809_id_metodo != '0001' THEN
    --                 CASE	
    --                     WHEN TEMP.VALOR_ASIGNADO IS NOT NULL THEN TEMP.VALOR_ASIGNADO
    --                     ELSE 1
    --                 END
	--  	        ELSE 1
    --         END
    --  END AS cavidades_moldeoV0
    ,CASE 
	 	WHEN t809.f809_descripcion LIKE '%EXT%' THEN 1
	 	ELSE 0
     END AS timeFactor
	,t150_a.f150_id AS store
	,CASE 
        WHEN t809.f809_descripcion LIKE '%TERMO%' THEN ''
	 	WHEN t809.f809_descripcion LIKE '%EXT%' THEN temp_Calibre.valor
	 	ELSE ''
     END AS Calibre
	 ,CASE 
        WHEN t809.f809_descripcion LIKE '%TERMO%' THEN ''
	 	WHEN t809.f809_descripcion LIKE '%EXT%' THEN temp_Ancho.valor
	 	ELSE ''
     END AS Ancho
	,f809_numero_operarios AS Operarios

    ,CASE 
        WHEN f809_id_metodo = '0001' THEN
            t_desc_tecnicas.f123_datos
        WHEN f809_id_metodo != '0001' THEN
            CASE	
                WHEN TEMP.VALOR_ASIGNADO IS NOT NULL THEN TEMP.VALOR_ASIGNADO
                ELSE '1'
            END
        ELSE '1'
    END AS ItemReferences,v121_op.v121_rowid_item--,t104.f104_id

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
        --AND t103.f103_descripcion = 'TERMOFORMADO'


    ---Inicio de la consulta para obtener el valor las cavidades por troquel

    LEFT JOIN t104_mc_desc_tecnicas_campos t104_troquel
    ON t103.f103_id = t104_troquel.f104_id_descripcion_tecnica
        AND t104_troquel.f104_id = 'CAVIDADES POR TROQUEL' AND t104_troquel.f104_id_descripcion_tecnica = '010'
    LEFT JOIN t123_mc_items_desc_tecnicas t123_troquel
    ON t123_troquel.f123_id_cia = 1 AND t123_troquel.f123_rowid_item = v121_op.v121_rowid_item AND t123_troquel.f123_rowid_campo = t104_troquel.f104_rowid

    LEFT JOIN t104_mc_desc_tecnicas_campos t104_apilados
    ON t103.f103_id = t104_apilados.f104_id_descripcion_tecnica
        AND t104_apilados.f104_id = 'APILADOS POR TROQUEL' AND t104_apilados.f104_id_descripcion_tecnica = '010'
    LEFT JOIN t123_mc_items_desc_tecnicas t123_apilados
    ON t123_apilados.f123_id_cia = 1 AND t123_apilados.f123_rowid_item = v121_op.v121_rowid_item AND t123_apilados.f123_rowid_campo = t104_apilados.f104_rowid

    ---Fin de la consulta para obtener el valor las cavidades por troquel



    ---Inicio de la consulta para obtener el ID de la operación de troquelado para cada OP
    LEFT JOIN #TempIdOperacionesTroqueladoPorOP tempTroquelado
    ON t850.f850_consec_docto = tempTroquelado.f850_consec_docto
        AND tempTroquelado.f809_descripcion = t809.f809_descripcion
    ---Fin de la consulta para obtener el ID de la operación de troquelado para cada OP

    LEFT JOIN t104_mc_desc_tecnicas_campos t104
    ON t103.f103_id = t104.f104_id_descripcion_tecnica
        AND t104.f104_id = 'CAVIDADES POR MOLDEO' AND t104.f104_id_descripcion_tecnica = '010'
    LEFT JOIN t123_mc_items_desc_tecnicas t123
    ON t123.f123_id_cia = 1 AND t123.f123_rowid_item = v121_op.v121_rowid_item AND t123.f123_rowid_campo = t104.f104_rowid
    LEFT JOIN #TempCalibres_Anchos temp_Calibre
    ON v121_op.v121_rowid_item = temp_Calibre.row_id_item
        AND temp_Calibre.id_plan IN ('007')
    LEFT JOIN #TempCalibres_Anchos temp_Ancho
    ON v121_op.v121_rowid_item = temp_Ancho.row_id_item
        AND temp_Ancho.id_plan IN ('008')
    FULL JOIN #TempValoresPorRuta temp
    ON t808.f808_id  = temp.CODIGO_RUTA
        AND t809.f809_id_metodo =  temp.CODIGO_METODO


    LEFT JOIN #TempDesc_Tecnicas t_desc_tecnicas 
    ON t_desc_tecnicas.f123_rowid_item = v121_op.v121_rowid_item

WHERE  t850.f850_id_cia = 1
    AND t850.f850_id_grupo_clase_docto = 701
    AND t850.f850_ind_estado IN ( 1, 2 )
    AND T850.f850_id_tipo_docto IN ('MOP', 'MOE')
    --Excluir las operaciones iniciadas por CAMBIO
    AND t809.f809_descripcion NOT LIKE 'CAMBIO%'
    --Excluir el centro de trabajo que inicie por SMED
    AND LTRIM(T806.f806_id) NOT LIKE 'SMED%'
    -- AND LEFT(f809_descripcion,12) NOT IN ('CAMBIO DE RE',
	-- 										'MONTAJE Y DE',
	-- 										'PUESTA A PUN',
	-- 										'CAMBIO DE RO',
    --                                         'REVISION Y E')
    --Omitir si el código item de la op es igual a 0001657
    -- AND v121_op.v121_referencia NOT LIKE '%11657%'
    --Omitir cuando el código de la ruta invocada en la orden de producción comienza por “ensamb”
    -- AND LTRIM(T806.f806_id) NOT LIKE '%ensamb%'
--AND t850.f850_consec_docto = 8760  
--AND T806.f806_id LIKE '%TQ%'
ORDER BY T850.f850_consec_docto, t809.f809_numero_operacion

DROP TABLE #TempValoresPorRuta
DROP TABLE #TempCalibres_Anchos
DROP TABLE #TempIdOperacionesTroqueladoPorOP
DROP TABLE #TempDesc_Tecnicas