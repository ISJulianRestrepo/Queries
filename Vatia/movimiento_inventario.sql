DECLARE @p_cia AS INT = 1
-- DECLARE @p_fecha_desde AS datetime = {'FechaInicio'}--'2023-08-01'
DECLARE @p_fecha_desde AS datetime = '2024-08-23'
-- DECLARE @p_fecha_hasta AS datetime = {'FechaFin'} --'2023-08-23'
DECLARE @p_fecha_hasta AS datetime = '2024-08-23'



select distinct f053_id f1_fecha, 1 as f1_factor
into #tp1_generico_factor_fecha
from t053_mm_fechas

where	f053_id_cia = @p_cia
        and f053_id between @p_fecha_desde and @p_fecha_hasta

SELECT DISTINCT
        f470_id_fecha as Fecha,
        t350.f350_id_tipo_docto + '-' + convert(varchar(50),
t350.f350_consec_docto) f_docto,
        f350_id_tipo_docto as TipoDocumento,
        f021_descripcion f_desc_tipo_docto, t350.f350_id_co as CoMovt,
        t150.f150_id                                       bodega,
        t150.f150_descripcion                                Desc_bodega,
        t470_movto.f470_rowid                              OrdenInterno,
        f120_id Item,
        f120_referencia                                    Referencia,
        f120_descripcion                                   Desc_item,
        Isnull(t470_movto.f470_id_lote, ' ')               lote,
        Isnull(t470_movto.f470_id_ubicacion_aux, ' ')      Ubicacion,
        t417.f417_id                                            as Seriales,
        0 as CodigoBarras,
        0 as OrdenCompra,
        t350.f350_referencia                               f_docto_Alerno,
        Replace(t350.f350_notas, Char(13) + Char(10), ' ') f_notas_docto,

        CASE t470_movto.f470_ind_naturaleza
         WHEN 1 THEN t470_movto.f470_cant_1
         ELSE 0
       END                                                f_cant_ent_1,
        CASE t470_movto.f470_ind_naturaleza
         WHEN 2 THEN t470_movto.f470_cant_1
         ELSE 0
       END                                                f_cant_sal_1,
        f120_id_unidad_inventario UMINV,
        f120_id_unidad_orden UMORDER,

        f1_factor,

        --CASE
        --  WHEN 1 = 1 THEN
        --    CASE t470_movto.f470_ind_naturaleza
        --      WHEN 1 THEN Isnull(t470_movto.f470_costo_prom_tot, 0)
        --      ELSE 0
        --    END
        --  ELSE 0
        --END                                                f_costo_prom_ent,
        --CASE
        --  WHEN 1 = 1 THEN
        --    CASE t470_movto.f470_ind_naturaleza
        --      WHEN 2 THEN Isnull(t470_movto.f470_costo_prom_tot, 0)
        --      ELSE 0
        --    END
        --  ELSE 0
        --END                                                f_costo_prom_sal,
        --CASE
        --  WHEN 1 = 1 THEN
        --    CASE t470_movto.f470_ind_naturaleza
        --      WHEN 1 THEN t470_movto.f470_costo_prom_tot
        --      ELSE -t470_movto.f470_costo_prom_tot
        --    END
        --  ELSE 0
        --END                                                f_costo_prom_net,
        --CASE
        --  WHEN 1 = 1 THEN t470_movto.f470_costo_prom_uni
        --  ELSE 0
        --END                                                f_costo_unitario,
        CASE
         WHEN 1 = 1 THEN
           CASE
             WHEN 'COP' <> 'COP' THEN Round(( t470_movto.f470_costo_prom_uni *
                                              f1_factor ),
                                      4)
             ELSE t470_movto.f470_costo_prom_uni
           END
         ELSE 0
       END                                                f_costo_unitario_reexp
       ,


        Isnull(Replace(t155_470.f155_notas, Char(13) + Char(10), ' '), ' ')
                                                          f_notas_ubicacion,

        t350.f350_usuario_creacion,
        t350.f350_usuario_aprobacion,
        t350.f350_usuario_actualizacion,
        f120_id_tipo_inv_serv as TipoInventario,

        cast(f470_id_concepto as varchar(3))	+ ' - ' + f470_id_motivo as Motivo,
        (select f200_id
        from t200_mm_terceros
        where f200_rowid =t350.f350_rowid_tercero) as IdTercero,
        (select f200_razon_social
        from t200_mm_terceros
        where f200_rowid =t350.f350_rowid_tercero) as Tercero


FROM (                                                SELECT f470_rowid,
                        f470_rowid_bodega,
                        f470_rowid_docto,
                        f470_rowid_item_ext,
                        f470_rowid_ccosto_movto,
                        f470_rowid_movto_req_int,
                        f470_rowid_op_docto,
                        f470_rowid_oc_movto,
                        f470_rowid_docto_fact,
                        f470_rowid_mov_inv_base_nota,
                        f470_rowid_movto_entidad,
                        f470_id_cia,
                        f470_id_fecha,
                        f470_id_un_movto,
                        f470_ind_naturaleza,
                        f470_ind_estado_cm,
                        f470_id_concepto,
                        f470_id_motivo,
                        f470_id_instalacion,
                        f470_id_lote_transito_ent,
                        f470_id_proyecto,
                        f470_id_co_movto,
                        f470_id_lote,
                        f470_id_ubicacion_aux,
                        f470_cant_1,
                        f470_cant_2,
                        f470_costo_prom_tot,
                        f470_costo_est_tot,
                        f470_costo_mp_en,
                        f470_costo_mp_np,
                        f470_costo_mo_en,
                        f470_costo_mo_np,
                        f470_costo_cif_en,
                        f470_costo_cif_np,
                        f470_desc_variable,
                        f470_costo_prom_uni,
                        f470_notas,
                        f470_rowid_proy_etapa,
                        f470_factor,
                        f470_rowid_movto_proceso_ent
                FROM t470_cm_movto_invent
                WHERE  f470_id_cia = @p_cia
                        AND f470_id_fecha BETWEEN @p_fecha_desde AND @p_fecha_hasta
                        AND f470_ind_estado_cm <> 2
        UNION ALL
                SELECT f470_rowid,
                        f470_rowid_bodega,
                        f470_rowid_docto,
                        f470_rowid_item_ext,
                        f470_rowid_ccosto_movto,
                        f470_rowid_movto_req_int,
                        f470_rowid_op_docto,
                        f470_rowid_oc_movto,
                        f470_rowid_docto_fact,
                        f470_rowid_mov_inv_base_nota,
                        f470_rowid_movto_entidad,
                        f470_id_cia,
                        f470_id_fecha,
                        f470_id_un_movto,
                        f470_ind_naturaleza,
                        f470_ind_estado_cm,
                        f470_id_concepto,
                        f470_id_motivo,
                        f470_id_instalacion,
                        f470_id_lote_transito_ent,
                        f470_id_proyecto,
                        f470_id_co_movto,
                        f470_id_lote,
                        f470_id_ubicacion_aux,
                        f470_cant_1,
                        f470_cant_2,
                        f470_costo_prom_tot,
                        f470_costo_est_tot,
                        f470_costo_mp_en,
                        f470_costo_mp_np,
                        f470_costo_mo_en,
                        f470_costo_mo_np,
                        f470_costo_cif_en,
                        f470_costo_cif_np,
                        f470_desc_variable,
                        f470_costo_prom_uni,
                        f470_notas,
                        f470_rowid_proy_etapa,
                        f470_factor,
                        f470_rowid_movto_proceso_ent
                FROM t911_desconexion_t470
                WHERE  f470_id_cia = @p_cia
                        AND f470_id_fecha BETWEEN @p_fecha_desde AND @p_fecha_hasta
                        AND f470_ind_estado_cm <> 2
                        AND 0 = 1)t470_movto
        -- INNER JOIN t417_cm_seriales t417
        -- ON t417.f417_rowid_item_ext = t470_movto.f470_rowid_item_ext
        INNER JOIN t479_cm_movto_seriales t479
        ON t479.f479_rowid_movto_inv = t470_movto.f470_rowid
        INNER JOIN t417_cm_seriales t417
        ON t479.f479_rowid_serial = t417.f417_rowid

        INNER JOIN #tp1_generico_factor_fecha
        ON f1_fecha = t470_movto.f470_id_fecha
        INNER JOIN t150_mc_bodegas t150
        ON t150.f150_rowid = t470_movto.f470_rowid_bodega
        INNER JOIN t350_co_docto_contable t350
        ON t350.f350_rowid = t470_movto.f470_rowid_docto
        INNER JOIN t121_mc_items_extensiones
        ON f121_rowid = t470_movto.f470_rowid_item_ext
        INNER JOIN t120_mc_items
        ON f120_rowid = f121_rowid_item
        INNER JOIN t021_mm_tipos_documentos
        ON f021_id = t350.f350_id_tipo_docto
                AND f021_id_cia = t350.f350_id_cia
        LEFT JOIN t155_mc_ubicacion_auxiliares t155_470
        ON t155_470.f155_rowid_bodega = t470_movto.f470_rowid_bodega
                AND t155_470.f155_id = t470_movto.f470_id_ubicacion_aux
        LEFT JOIN (SELECT f485_rowid_movto f_rowid_movto
        FROM t485_cm_movto_destare
        GROUP  BY f485_rowid_movto) tp
        ON tp.f_rowid_movto = t470_movto.f470_rowid
WHERE  t470_movto.f470_id_cia = @p_cia
        AND t470_movto.f470_id_fecha BETWEEN @p_fecha_desde AND @p_fecha_hasta
        AND t470_movto.f470_ind_estado_cm <> 2
        AND f350_id_tipo_docto LIKE '%TR%'

DROP TABLE #tp1_generico_factor_fecha


--exec sp_help 't417_cm_seriales'