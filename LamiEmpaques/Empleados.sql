SELECT	
    t815.f815_id                         AS f_id_empleado,
    t200.f200_id                         AS f_tercero,
    t200.f200_razon_social               AS f_razon_social,
    t814.f814_descripcion                AS f_desc_cat_laboral,
    CASE f815_ind_estado
        WHEN 0 THEN 'Inactivo'
        WHEN 1 THEN 'Activo'
    END                             AS f_estado
FROM 
    t815_mf_empleados t815
    INNER JOIN t200_mm_terceros t200 ON t200.f200_rowid = t815.f815_rowid_tercero
    INNER JOIN t814_mf_categoria_laboral t814 ON t814.f814_rowid = t815.f815_rowid_categoria_laboral
WHERE 
    t815.f815_id_cia = 34;