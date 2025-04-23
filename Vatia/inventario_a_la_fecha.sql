
DECLARE @p_fecha_desde AS datetime = {'FechaInicio'}--'2023-08-01'
-- DECLARE @p_fecha_desde AS datetime = '2023-08-01'
DECLARE @p_fecha_hasta AS datetime = {'FechaFin'}--'2023-08-23'
-- DECLARE @p_fecha_hasta AS datetime = '2025-08-23'


SELECT f120_id                                                                                            Item,
    f120_descripcion                                                                                      DescItem,
    f417_id                                                                                               Serial,
    --Rtrim(f2_350_id_co) + '-' + Rtrim(f2_350_id_tipo_docto) + '-' + RIGHT('00000000' + Rtrim(f2_350_consec_docto), 8) f_docto_salida,
    CAST(f417_fecha_salida AS DATE)                                                                       FechaSalida,
    f150_id                                                                                               Bodega,
    f417_id_ubicacion                                                                                     Ubicacion,
    f417_id_lote                                                                                          Lote,
    f120_id_unidad_inventario                                                                             UM,
    CASE
                      WHEN v417_estado = 1 THEN 1
                      ELSE 0
           END f_cant_exist,

    v417_estado,


    CASE Isnull(v417_estado, -1)
                      WHEN 2 THEN 'No disponible'
                      WHEN 1 THEN 'Disponible'
                      WHEN -1 THEN 'Creado'
           END                                                                                                         Estado,
    f120_referencia                                                                                             Referencia,
    Rtrim(f420_id_tipo_docto) + '-' + RIGHT('00000000' + Rtrim(f420_consec_docto), 8)                                       OrdenDeCompra,
    CAST(f417_fecha_creacion AS DATE)                                                                     FechaCreacion,
    CAST(f417_fecha_ingreso AS DATE)                                                                      FechaIngreso,
    CAST(t470_2.f_fecha_ultimo_ingreso AS DATE)                                                           FechaUltimoIngreso,
    f150_descripcion                                                                                            DecBodega
FROM t417_cm_seriales
    LEFT JOIN
    (
                                                                                      SELECT f417_rowid_item_ext v417_rowid_item,
            f417_rowid          v417_rowid,
            CASE Sum(CASE f470_ind_naturaleza
                        WHEN 1 THEN 1
                        ELSE -1
                        END)
                WHEN 1 THEN 1
                ELSE 2
            END v417_estado
        FROM t417_cm_seriales
            INNER JOIN t479_cm_movto_seriales
            ON         f479_rowid_serial = f417_rowid
            INNER JOIN t470_cm_movto_invent
            ON         f479_rowid_movto_inv = f470_rowid
            INNER JOIN t121_mc_items_extensiones
            ON         f121_rowid = f417_rowid_item_ext
            INNER JOIN t120_mc_items
            ON         f120_rowid = f121_rowid_item
        GROUP BY   f417_rowid_item_ext,
                                 f417_rowid
    UNION ALL
        SELECT f417_rowid_item_ext v417_rowid_item,
            f417_rowid          v417_rowid,
            CASE Sum(CASE f470_ind_naturaleza
                        WHEN 1 THEN 1
                        ELSE -1
                        END)
                WHEN 1 THEN 1
                ELSE 2
                END v417_estado
        FROM t417_cm_seriales
            INNER JOIN t479_cm_movto_seriales
            ON         f479_rowid_serial = f417_rowid
            INNER JOIN t911_desconexion_t470
            ON         f479_rowid_movto_inv = f470_rowid
            INNER JOIN t121_mc_items_extensiones
            ON         f121_rowid = f417_rowid_item_ext
            INNER JOIN t120_mc_items
            ON         f120_rowid = f121_rowid_item
        GROUP BY   f417_rowid_item_ext,
                                 f417_rowid)v417
    ON         v417.v417_rowid = f417_rowid
    INNER JOIN t121_mc_items_extensiones
    ON         f121_rowid = f417_rowid_item_ext
    INNER JOIN t120_mc_items
    ON         f120_rowid = f121_rowid_item
    LEFT JOIN t150_mc_bodegas
    ON         f150_rowid = f417_rowid_bodega
    LEFT JOIN
    (
                      SELECT f1_rowid_serial,
        f451_rowid_oc_docto f1_451_rowid_oc_docto,
        f350_id_co          f1_350_id_co,
        f350_id_tipo_docto  f1_350_id_tipo_docto,
        f350_consec_docto   f1_350_consec_docto,
        f1_470_rowid_op_docto
    FROM (
                                          SELECT f1_rowid_serial,
            Min(f1_470_rowid_docto)    f1_470_rowid_docto,
            Min(f1_470_rowid_op_docto) f1_470_rowid_op_docto
        FROM (
                                                                                                                                                                                              SELECT f1_rowid_serial,
                    f470_rowid_docto    f1_470_rowid_docto,
                    f470_rowid_op_docto f1_470_rowid_op_docto
                FROM (
                                                                                    SELECT f479_rowid_serial f1_rowid_serial,
                        Min(f470_rowid)   f1_min_movto_470
                    FROM t417_cm_seriales
                        INNER JOIN t479_cm_movto_seriales
                        ON         f479_rowid_serial = f417_rowid
                        INNER JOIN t470_cm_movto_invent
                        ON         f470_rowid = f479_rowid_movto_inv
                        INNER JOIN t121_mc_items_extensiones
                        ON         f121_rowid = f417_rowid_item_ext
                        INNER JOIN t120_mc_items
                        ON         f120_rowid = f121_rowid_item
                    WHERE      Isnull(
                                    CASE (
                                        CASE f470_ind_naturaleza
                                            WHEN 1 THEN 1
                                            ELSE -1
                                        END)
                                        WHEN 1 THEN 1
                                    ELSE 2
                                    END, 
                                    0) IN (0,1)
                        AND f417_id_cfg_serial = '01'
                        AND f470_ind_naturaleza = 1
                    GROUP BY   f479_rowid_serial ) tbl1
                    INNER JOIN t470_cm_movto_invent
                    ON         f470_rowid = f1_min_movto_470
            UNION ALL
                SELECT f1_rowid_serial,
                    f470_rowid_docto    f1_470_rowid_docto,
                    f470_rowid_op_docto f1_470_rowid_op_docto
                FROM (
                                                                                    SELECT f479_rowid_serial f1_rowid_serial,
                        Min(f470_rowid)   f1_min_movto_470
                    FROM t417_cm_seriales
                        INNER JOIN t479_cm_movto_seriales
                        ON         f479_rowid_serial = f417_rowid
                        INNER JOIN t911_desconexion_t470
                        ON         f470_rowid = f479_rowid_movto_inv
                        INNER JOIN t121_mc_items_extensiones
                        ON         f121_rowid = f417_rowid_item_ext
                        INNER JOIN t120_mc_items
                        ON         f120_rowid = f121_rowid_item
                    WHERE      Isnull(
                                                                                               CASE (
                                                                                                                     CASE f470_ind_naturaleza
                                                                                                                                WHEN 1 THEN 1
                                                                                                                                ELSE -1
                                                                                                                     END)
                                                                                                          WHEN 1 THEN 1
                                                                                                          ELSE 2
                                                                                               END, 0) IN (0,1)
                        AND f417_id_cfg_serial = '01'
                        AND f470_ind_naturaleza = 1
                    GROUP BY   f479_rowid_serial ) tbl1
                    INNER JOIN t911_desconexion_t470
                    ON         f470_rowid = f1_min_movto_470 )tp1
        GROUP BY f1_rowid_serial )tp2
        INNER JOIN t350_co_docto_contable
        ON         f350_rowid = f1_470_rowid_docto
        LEFT JOIN t451_cm_docto_compras
        ON         f451_rowid_docto = f350_rowid ) tblser_crea
    ON         f1_rowid_serial = f417_rowid
    LEFT JOIN t420_cm_oc_docto
    ON         f420_rowid = f1_451_rowid_oc_docto
    LEFT JOIN
    (
                                                                                      SELECT f479_rowid_serial   f_rowid_serial,
            f470_rowid_item_ext f470_rowid_item_ext ,
            Max(f470_id_fecha)  f_fecha_ultimo_ingreso
        FROM t479_cm_movto_seriales
            INNER JOIN t470_cm_movto_invent
            ON         f470_rowid = f479_rowid_movto_inv
        WHERE      f470_ind_estado_cm <> 2
            AND f470_ind_naturaleza = 1
        GROUP BY   f479_rowid_serial,
                                 f470_rowid_item_ext
    UNION ALL
        SELECT f479_rowid_serial   f_rowid_serial,
            f470_rowid_item_ext f470_rowid_item_ext ,
            Max(f470_id_fecha)  f_fecha_ultimo_ingreso
        FROM t479_cm_movto_seriales
            INNER JOIN t911_desconexion_t470
            ON         f470_rowid = f479_rowid_movto_inv
        WHERE      f470_ind_estado_cm <> 2
            AND f470_ind_naturaleza = 1
        GROUP BY   f479_rowid_serial,
                                 f470_rowid_item_ext ) t470_2
    ON         t470_2.f470_rowid_item_ext = f417_rowid_item_ext
        AND t470_2.f_rowid_serial =f417_rowid
        AND Isnull(v417_estado, 0) IN (0,1)
        AND f417_id_cfg_serial = '01'


WHERE v417_estado IN (1)
    AND f417_fecha_creacion BETWEEN @p_fecha_desde AND @p_fecha_hasta