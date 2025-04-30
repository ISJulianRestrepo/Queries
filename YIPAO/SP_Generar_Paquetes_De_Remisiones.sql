
CREATE PROCEDURE SP_Generar_Paquetes_De_Remisiones
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE para calcular RowNum
    WITH CTE AS (
        SELECT 
            JSON_VALUE(jsonOrigen, '$.transactionId') AS Id, 
            ROW_NUMBER() OVER (ORDER BY JSON_VALUE(jsonOrigen, '$.date')) AS RowNum
        FROM 
            remisiones
    )
    
    -- Actualiza el campo paquete
    UPDATE T
    SET T.paquete = CONCAT(
        CONVERT(VARCHAR(8), REPLACE(JSON_VALUE(jsonOrigen, '$.date'), '-', ''), 112),
        ((CTE.RowNum - 1) / 500) + 1
    )
    FROM remisiones T
    JOIN CTE ON JSON_VALUE(T.jsonOrigen, '$.transactionId') = CTE.Id
    WHERE T.paquete IS NULL;

    -- Retorna los datos seleccionados
    SELECT DISTINCT 
        paquete AS Rowid,
        203017 AS IdDocumento,
        'Remisiones' AS NombreDocumento,
        'Remisiones_A_Siesa' AS ProcedimientoAlmacenado,
        2 AS estado
    FROM [YIPAO].[dbo].[Remisiones]
    WHERE estado != 2 
    ORDER BY paquete;
END;
GO