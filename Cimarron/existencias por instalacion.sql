select DISTINCT top 100 --f112_descripcion, 
v125_rowid_item,
    t120.f120_id,7 f_item, 
    rtrim(t120.f120_referencia) f_referencia, 
    rtrim(t120.f120_descripcion) f_desc_item, 
    round(v400_cant_existencia_1 / 1, 4) f_cant_existencia_1, 
    round(v400_cant_comprometida_1 / 1,4) f_cant_comprometida_1, 
    round(v400_cant_existencia_1 / 1, 4) - round(v400_cant_salida_sin_conf_1 / 1,4) - round(v400_cant_comprometida_1 / 1,4) f_cant_disponible_1, 
    cast(case 
            when 1 = 0 then 0   
                else 
                case   
                    when 0 = 0 then f132_costo_prom_uni    
                    else 
                    case when round(v400_cant_existencia_1 / 1, 4) = 0 then 0   
                        else round(f132_costo_prom_uni  * v400_cant_existencia_1,2) / round(v400_cant_existencia_1 / 1, 4)   
                    end  
                end   
        end as decimal(28,4)) f_costo_prom_uni, 
    v400_id_instalacion f_instalacion, 
    case 
        when 1 = 0 then 0   
        else 
            case when v400_cant_existencia_1 = 0 then f132_costo_prom_tot   
                else f132_costo_prom_tot  
            end  
        end   f_costo_prom_tot, 
    case 0   
        when 0 then t120.f120_id_unidad_inventario   
        when 1 then 
            case when t120.f120_id_unidad_empaque is null then t120.f120_id_unidad_inventario    
                else t120.f120_id_unidad_empaque 
            end   
            else t120.f120_id_unidad_inventario   
    end f_um, 
    v125_descripcion AS Marca
    -- v400_origen f_origen, 
    -- t121.f121_rowid_item f_rowid_item_cri, 
    -- v400_rowid_item_ext f_rowid_item_ext, 
    -- t120.f120_ind_tipo_item f_ind_tipo_item, 
    -- v400_cant_existencia_1 f_cant_existencia, 
    -- v400_cant_existencia_1 - v400_cant_salida_sin_conf_1 - v400_cant_comprometida_1 f_cant_disponible, 
    -- case 0 when 0 then isnull((f1_precio_unitario - dbo.F_HALLAR_VLR_IMPTO_INCL(11,f1_id_lista_precios,f1_rowid_item_ext,f1_precio_unitario)),0)  else isnull(f132_costo_prom_uni,0) end f_divisor_margen, case when 1 = 0 then 0 else  isnull((f1_precio_unitario - dbo.F_HALLAR_VLR_IMPTO_INCL(11,f1_id_lista_precios,f1_rowid_item_ext,f1_precio_unitario)),0) - isnull(f132_costo_prom_uni,0) end f_utilidad, v400_id_instalacion f_id_instalacion 
    from (
        select 400 v400_origen,  
        f400_id_cia  v400_id_cia,  
        f400_rowid_item_ext v400_rowid_item_ext,  
        f400_id_instalacion v400_id_instalacion,  
        sum(f400_cant_existencia_1) v400_cant_existencia_1,  
        sum(f400_cant_salida_sin_conf_1) v400_cant_salida_sin_conf_1,  
        sum(f400_cant_comprometida_1) v400_cant_comprometida_1,  
        sum(f400_cant_pendiente_salir_1) 
        v400_cant_pendiente_salir_1,  
        sum(f400_cant_pendiente_entrar_1) v400_cant_pendiente_entrar_1,  
        sum(f400_cant_existencia_2) v400_cant_existencia_2,  
        sum(f400_cant_salida_sin_conf_2) v400_cant_salida_sin_conf_2,  
        sum(f400_cant_comprometida_2) v400_cant_comprometida_2,  
        sum(f400_cant_pendiente_salir_2) v400_cant_pendiente_salir_2,  
        sum(f400_cant_existencia_1 - f400_cant_salida_sin_conf_1) v400_cant_existencia_actual,  
        sum(f400_cant_existencia_1 - f400_cant_salida_sin_conf_1 - f400_cant_comprometida_1) v400_cant_disponible_1,  
        sum(f400_cant_existencia_2 - f400_cant_salida_sin_conf_2) v400_cant_existencia_actual_2,  
        sum(f400_cant_existencia_2 - f400_cant_salida_sin_conf_2 - f400_cant_comprometida_2) v400_cant_disponible_2,  
        sum(f400_consumo_promedio) v400_consumo_promedio,  
        sum(case when f400_consumo_promedio = 0 then 0 else f400_cant_existencia_1 / f400_consumo_promedio end) v400_existencias_dias  
        from t400_cm_existencia  
        where  f400_id_instalacion = '001' 
        group by f400_id_cia,  
        f400_rowid_item_ext,  
        f400_id_instalacion  
        having  sum(f400_cant_existencia_1) <> 0  
        and  sum(f400_cant_existencia_1 - f400_cant_salida_sin_conf_1 - f400_cant_comprometida_1) <> 0 ) v400  
        inner join t121_mc_items_extensiones t121 on t121.f121_rowid = v400_rowid_item_ext 
        inner join t120_mc_items t120 on t120.f120_rowid = t121.f121_rowid_item 
        inner join t132_mc_items_instalacion on f132_rowid_item_ext = v400_rowid_item_ext   
            and f132_id_instalacion = v400_id_instalacion 
        inner join t101_mc_unidades_medida t101_um on t101_um.f101_id_cia = t120.f120_id_cia   
            and t101_um.f101_id = f120_id_unidad_inventario   


        inner join t126_mc_items_precios t126 on t126.f126_rowid_item = t120.f120_rowid 
            and t126.f126_id_cia = t120.f120_id_cia -- Lista de precios por defecto
        inner join t112_mc_listas_precios t112 on t112.f112_id_cia = t126.f126_id_cia
            and t112.f112_id = t126.f126_id_lista_precio

        left join v125 on v125.v125_rowid_item = t120.f120_rowid  and v125_id_plan = '004'
    where   round(v400_cant_existencia_1 / 1, 4) <> 0  
    and round(v400_cant_existencia_1 / 1, 4) - round(v400_cant_salida_sin_conf_1 / 1,4) - round(v400_cant_comprometida_1 / 1,4) <> 0 
    -- and f120_descripcion like 'ASTEROID X 100 ML DHARP'
    and f112_descripcion like 'CONTADO'
-- order by f120_descripcion

-- select distinct top 100 *  from v125 where v125_rowid_item = 28470

-- exec sp_help 't125_mc_items_criterios'


-- SELECT top 500 * FROM t126_mc_items_precios t126
-- INNER JOIN t120_mc_items t120 ON t120.f120_rowid = t126.f126_rowid_item
-- INNER JOIN t112_mc_listas_precios t112 ON t112.f112_id_cia = t126.f126_id_cia
--     AND t112.f112_id = t126.f126_id_lista_precio


-- f126_id_cia, f126_id_lista_precio
-- REFERENCES UnoEE_AgCimarron_Real.dbo.t112_mc_listas_precios (f112_id_cia, f112_id)

-- f126_rowid_item
-- REFERENCES UnoEE_AgCimarron_Real.dbo.t120_mc_items (f120_rowid)