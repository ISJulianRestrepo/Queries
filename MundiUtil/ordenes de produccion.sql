-- Crear tabla temporal con criterios
SELECT
    f120_rowid AS row_id_item,
    f125_id_plan AS id_plan, 
    t106.f106_descripcion AS valor
INTO #CriteriosItems
FROM [dbo].[t125_mc_items_criterios] t125
INNER JOIN t106_mc_criterios_item_mayores t106
    ON t125.f125_id_cia = t106.f106_id_cia
    AND t125.f125_id_plan = f106_id_plan
    AND t125.f125_id_criterio_mayor = t106.f106_id
INNER JOIN t120_mc_items t120
    ON f120_rowid = f125_rowid_item
WHERE f125_id_plan IN ('001', '002');

-- Consulta principal
SELECT 
    T850.f850_id_tipo_docto AS Type_docto,     
    T850.f850_consec_docto AS workOrderId,
    TRIM(T120.f120_referencia) AS productId,
    TRIM(T120.f120_descripcion) AS productName,
    T851.f851_cant_planeada_base AS programmedQty,
    FORMAT(T851.f851_fecha_inicio, 'yyyy-MM-dd') AS startDate,
    FORMAT(T851.f851_fecha_terminacion, 'yyyy-MM-dd') AS endDate,
    CASE
        WHEN T850.f850_ind_estado = 2 THEN 'Comprometido'
        ELSE 'Aprobado' 
    END AS status,
    T851.f851_id_unidad_medida AS unit,
    T120.f120_id_unidad_empaque AS pickingUnit,
    T122.f122_peso AS weight,
    T865.f865_numero_operacion AS operationFase,
    f809_descripcion AS operationName,
    TRIM(T806.f806_id) AS workUnitId,
    --TRIM(T806.f806_id) AS workUnitId,
    T865.f865_rt_horas_ejecucion,
    T865.f865_rt_cantidad_base,
	CASE 
        WHEN t810Cavidades.f810_dato IS NULL THEN ''
        ELSE t810Cavidades.f810_dato
    END AS conversionFactor,
    CASE 
        WHEN t810Ciclo.f810_dato IS NULL THEN ''
        ELSE t810Ciclo.f810_dato
    END AS Ciclo,
    T150.f150_id AS store,
    T850.f850_notas AS notesDocto,
    T200.f200_nit AS customerOrders,
    T120.f120_notas AS notesItem,
    T120.f120_ind_lote AS lote,
    CASE 
        WHEN T120.f120_ind_lote_asignacion = 1 THEN 'Manual'
        ELSE 'Automatico'
    END AS asignacionLote,
    T120.f120_vida_util AS vidaUtil,
    f809_numero_operarios AS Operarios,
    t149.f149_descripcion AS TipoInventario,
    CILinea.valor AS Linea,
    CIFamilia.valor AS Familia
FROM t850_mf_op_docto AS t850
INNER JOIN t851_mf_op_docto_item AS t851 
    ON t850.f850_rowid = t851.f851_rowid_op_docto
LEFT JOIN t121_mc_items_extensiones T121 
    ON T121.f121_rowid = T851.f851_rowid_item_ext_padre
INNER JOIN t120_mc_items T120 
    ON T120.f120_rowid = f121_rowid_item
INNER JOIN t122_mc_items_unidades T122 
    ON T122.f122_rowid_item = T120.f120_rowid
INNER JOIN t865_mf_op_operaciones T865 
    ON T865.f865_rowid_op_docto_item = T851.f851_rowid
INNER JOIN t808_mf_rutas AS T808 
    ON t851.f851_rowid_ruta = T808.f808_rowid
INNER JOIN t809_mf_rutas_operacion T809 
    ON t851.f851_rowid_ruta = T809.f809_rowid_rutas
INNER JOIN t806_mf_centros_trabajo AS T806 
    ON t865.f865_rowid_ctrabajo = T806.f806_rowid
INNER JOIN t810_mf_rutas_operacion_instru t810Ciclo 
    ON t810Ciclo.f810_rowid_ruta_oper = T809.f809_rowid AND t810Ciclo.f810_rowid_campo = 3 AND t851.f851_id_metodo_ruta = t809.f809_id_metodo
INNER JOIN t810_mf_rutas_operacion_instru t810Cavidades 
    ON t810Cavidades.f810_rowid_ruta_oper = T809.f809_rowid AND t810Cavidades.f810_rowid_campo = 4 AND t851.f851_id_metodo_ruta = t809.f809_id_metodo
INNER JOIN t150_mc_bodegas T150 
    ON T150.f150_rowid = T851.f851_rowid_bodega
INNER JOIN t200_mm_terceros T200 
    ON T200.f200_rowid = T850.f850_rowid_tercero_planif
INNER JOIN t149_mc_tipo_inv_serv t149 
    ON t149.f149_id = t120.f120_id_tipo_inv_serv
INNER JOIN #CriteriosItems CILinea 
    ON CILinea.row_id_item = t120.f120_rowid AND CILinea.id_plan = '001'
INNER JOIN #CriteriosItems CIFamilia 
    ON CIFamilia.row_id_item = t120.f120_rowid AND CIFamilia.id_plan = '002'

WHERE 
    T850.f850_ind_estado IN (1, 2)
    AND T850.f850_id_tipo_docto = 'MOP'
    AND T865.f865_numero_operacion IN (120, 121, 140)
ORDER BY f850_consec_docto DESC;

-- Eliminar tabla temporal
DROP TABLE #CriteriosItems;
