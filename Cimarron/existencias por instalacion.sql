DECLARE @codi_rev AS VARCHAR(20) = '{codi_rev}'
-- DECLARE @data_ini AS VARCHAR(20) = '{data_ini}'
-- DECLARE @data_fim AS VARCHAR(20) = '{data_fim}'



SELECT DISTINCT TOP 100 --*,
    t120.f120_id AS 'codi_pro',
    -- RTRIM(t120.f120_referencia) AS Referencia, 
    RTRIM(t120.f120_descripcion) AS 'desc_pro', 
    ROUND(v400_cant_existencia_1 / 1, 4) AS 'qtde_pro', 
    -- ROUND(v400_cant_comprometida_1 / 1, 4) AS 'Cant. Comprometida', 
    ROUND(v400_cant_existencia_1 / 1, 4) 
        - ROUND(v400_cant_salida_sin_conf_1 / 1, 4) 
        - ROUND(v400_cant_comprometida_1 / 1, 4) AS 'qtdi_pro', 
    -- CAST(
    --     CASE 
    --         WHEN 1 = 0 THEN 0   
    --         ELSE 
    --             CASE   
    --                 WHEN 0 = 0 THEN f132_costo_prom_uni    
    --                 ELSE 
    --                     CASE 
    --                         WHEN ROUND(v400_cant_existencia_1 / 1, 4) = 0 THEN 0   
    --                         ELSE ROUND(f132_costo_prom_uni * v400_cant_existencia_1, 2) 
    --                              / ROUND(v400_cant_existencia_1 / 1, 4)   
    --                     END  
    --             END   
    --     END AS DECIMAL(28, 4)
    -- ) AS 'Costo prom uni', 
    v400_id_instalacion AS 'codi_rev', 
    -- CASE 
    --     WHEN 1 = 0 THEN 0   
    --     ELSE 
    --         CASE 
    --             WHEN v400_cant_existencia_1 = 0 THEN f132_costo_prom_tot   
    --             ELSE f132_costo_prom_tot  
    --         END  
    -- END AS 'Costo prom total', 
    v125_descripcion AS Marca,
    t120.f120_id_unidad_inventario AS 'unid_pro',
    fecha AS 'data_pro'

FROM (
    SELECT 
        400 v400_origen,  
        f400_rowid_item_ext v400_rowid_item_ext,  
        f400_id_instalacion v400_id_instalacion,  
        SUM(f400_cant_existencia_1) v400_cant_existencia_1,  
        SUM(f400_cant_salida_sin_conf_1) v400_cant_salida_sin_conf_1,  
        SUM(f400_cant_comprometida_1) v400_cant_comprometida_1,
        f400_fecha_ult_salida fecha
    FROM t400_cm_existencia  
    WHERE f400_id_instalacion = @codi_rev
    GROUP BY 
        f400_id_cia,  
        f400_rowid_item_ext,  
        f400_id_instalacion  ,
        f400_fecha_ult_salida
    HAVING  
        SUM(f400_cant_existencia_1) <> 0  
        AND SUM(f400_cant_existencia_1 - f400_cant_salida_sin_conf_1 - f400_cant_comprometida_1) <> 0 
) v400  

INNER JOIN t121_mc_items_extensiones t121 
    ON t121.f121_rowid = v400_rowid_item_ext 

INNER JOIN t120_mc_items t120 
    ON t120.f120_rowid = t121.f121_rowid_item 

INNER JOIN t132_mc_items_instalacion 
    ON f132_rowid_item_ext = v400_rowid_item_ext   
    AND f132_id_instalacion = v400_id_instalacion 

INNER JOIN t101_mc_unidades_medida t101_um 
    ON t101_um.f101_id_cia = t120.f120_id_cia   
    AND t101_um.f101_id = f120_id_unidad_inventario   

INNER JOIN t126_mc_items_precios t126 
    ON t126.f126_rowid_item = t120.f120_rowid 
    AND t126.f126_id_cia = t120.f120_id_cia -- Lista de precios por defecto

INNER JOIN t112_mc_listas_precios t112 
    ON t112.f112_id_cia = t126.f126_id_cia
    AND t112.f112_id = t126.f126_id_lista_precio

LEFT JOIN v125 
    ON v125.v125_rowid_item = t120.f120_rowid  
    AND v125_id_plan = '004'

WHERE 
    ROUND(v400_cant_existencia_1 / 1, 4) <> 0  
    AND ROUND(v400_cant_existencia_1 / 1, 4) 
        - ROUND(v400_cant_salida_sin_conf_1 / 1, 4) 
        - ROUND(v400_cant_comprometida_1 / 1, 4) <> 0 
    AND f112_descripcion LIKE 'CONTADO'



-- Select 
-- 1 as codi_rev,
-- 1 as codi_pro,
-- 1 as desc_pro,
-- 1 as unid_pro,
-- 1 as lote_pro,
-- 1 as barr_pro,
-- 1 as cind_pro,
-- 1 as data_pro,
-- 1 as dvlt_pro,
-- 1 as qtde_pro,
-- 1 as qtdi_pro
-- from	   dbo.t400_cm_existencia t400
-- inner join dbo.t121_mc_items_extensiones t121 on t400.f400_rowid_item_ext = t121.f121_rowid
-- inner join dbo.t120_mc_items t120 on t121.f121_rowid_item = t120.f120_rowid
-- inner join dbo.t150_mc_bodegas t150 on t400.f400_rowid_bodega = t150.f150_rowid
-- where t400.f400_id_cia in (1)