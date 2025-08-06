SELECT DISTINCT top 1000
t120.f120_referencia Referencia
,t120.f120_descripcion Descripcion
,t120.f120_id_unidad_inventario UnidadMedida
,t150.f150_descripcion Bodega
-- ,t155.f155_id AS Ubicacion
,f400_cant_existencia_1 Existencia
,f400_cant_comprometida_1 Comprometida
,(f400_cant_existencia_1 - f400_cant_salida_sin_conf_1 - f400_cant_comprometida_1 ) Disponible
-- ,t400.*
 ,t150.*
-- ,t121.*
-- ,t120.*
FROM	   dbo.t400_cm_existencia t400
LEFT JOIN dbo.t121_mc_items_extensiones t121 ON t400.f400_rowid_item_ext = t121.f121_rowid
LEFT JOIN dbo.t120_mc_items t120 ON t121.f121_rowid_item = t120.f120_rowid
LEFT JOIN dbo.t150_mc_bodegas t150 ON t400.f400_rowid_bodega = t150.f150_rowid
-- LEFT JOIN dbo.t155_mc_ubicacion_auxiliares t155 ON t150.f150_rowid = t155.f155_rowid_bodega 
WHERE t400.f400_id_cia IN (1) AND t150.f150_id='040'  
and t120.f120_referencia = '07870'


-- EXEC SP_HELP 't401_cm_existencia_lote'
-- EXEC SP_HELP 't121_mc_items_extensiones'


-- f401_rowid_item_ext
-- REFERENCES UnoEE.dbo.t121_mc_items_extensiones (f121_rowid)

-- f121_rowid_item
-- REFERENCES UnoEE.dbo.t120_mc_items (f120_rowid)

SELECT * FROM t401_cm_existencia_lote t401

----------------------


SELECT 
t150.f150_id Bodega
,t150.f150_descripcion BodegaDescripcion
,t120.f120_referencia Referencia
,t120.f120_descripcion Descripcion
,f401_id_ubicacion_aux Ubicacion
,f401_id_lote Lote
,f401_cant_existencia_1 Existencia
,f401_cant_comprometida_1 Comprometida
,(f401_cant_existencia_1 - f401_cant_salida_sin_conf_1 - f401_cant_comprometida_1 ) Disponible
,t120.f120_id_unidad_orden UnidadMedida
,t403.f403_fecha_vcto FechaVencimiento FROM t401_cm_existencia_lote t401
INNER JOIN t121_mc_items_extensiones t121 ON t401.f401_rowid_item_ext = t121.f121_rowid
INNER JOIN t120_mc_items t120 ON t121.f121_rowid_item = t120.f120_rowid

INNER JOIN t403_cm_lotes t403
    ON t401.f401_id_cia = t403.f403_id_cia
    AND t401.f401_id_lote = t403.f403_id

LEFT JOIN dbo.t150_mc_bodegas t150 ON t401.f401_rowid_bodega = t150.f150_rowid
WHERE f401_cant_existencia_1 > 0
AND t401.f401_rowid_bodega = '6'



AND t120.f120_referencia = '07870'












SELECT       dbo.v121.v121_id_item AS IdItem, dbo.v121.v121_referencia AS RefItem, dbo.v121.v121_descripcion AS DescItem, 
                      dbo.v121.v121_id_unidad_inventario AS UN, dbo.v121.v121_id_extension1 AS Ext1, dbo.v121.v121_id_extension2 AS Ext2, 
                      dbo.t401_cm_existencia_lote.f401_cant_existencia_1 AS Existencia, dbo.t150_mc_bodegas.f150_id AS IdBodega, dbo.v121.v121_id_ext1_detalle AS DescrpIdExt1, 
                      dbo.v121.v121_id_ext2_detalle AS DescrpIdExt2, dbo.t401_cm_existencia_lote.f401_id_lote AS idLote
FROM         dbo.t401_cm_existencia_lote 
left JOIN dbo. t403_cm_lotes 
    ON dbo.t401_cm_existencia_lote.f401_id_cia = dbo.t403_cm_lotes.f403_id_cia 
    AND dbo.t401_cm_existencia_lote.f401_id_lote = dbo.t403_cm_lotes.f403_id 
left JOIN dbo.t150_mc_bodegas 
    ON dbo.t401_cm_existencia_lote.f401_rowid_bodega = dbo.t150_mc_bodegas.f150_rowid 
left JOIN dbo.v121 
    ON dbo.t417_cm_seriales.f417_rowid_item_ext = dbo.v121.v121_rowid_item_ext
ORDER BY idLote