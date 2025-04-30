-- Reemplaza con la tabla y columna que deseas consultar
SELECT 
    cols.table_name AS tabla_origen,
    cols.column_name AS columna_origen,
    cols.data_type,
    cols.is_nullable,
    cols.character_maximum_length,
    tc.constraint_name,
    tc.constraint_type,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada
FROM 
    information_schema.columns cols
LEFT JOIN 
    information_schema.key_column_usage kcu 
    ON cols.table_name = kcu.table_name 
    AND cols.column_name = kcu.column_name
LEFT JOIN 
    information_schema.table_constraints tc 
    ON kcu.constraint_name = tc.constraint_name 
    AND kcu.table_name = tc.table_name
LEFT JOIN 
    information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE 
    cols.table_name = 't470_cm_movto_invent'
    AND cols.column_name = 'f470_id_concepto'
    AND tc.constraint_type = 'FOREIGN KEY';


SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
    sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN 
    sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN 
    sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN 
    sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE 
    tp.name = 't351_co_mov_docto';  -- Cambia esto por el nombre de tu tabla
