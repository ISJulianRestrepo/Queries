SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_Generar_Paquetes_De_Remisiones]
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE para calcular RowNum
    WITH CTE AS (
        SELECT 
            transacciones AS Id, 
            ROW_NUMBER() OVER (ORDER BY transactionType, dispenserName) AS RowNum
            -- ROW_NUMBER() OVER (ORDER BY JSON_VALUE(jsonOrigen, '$.transactionType')) AS RowNum
        FROM 
            (
                -- Agrupa los datos de remisiones
                SELECT JSON_VALUE(jsonOrigen, '$.productName')  AS productName, 
                JSON_VALUE(jsonOrigen, '$.transactionType')     AS transactionType, 
                JSON_VALUE(jsonOrigen, '$.dispenserName')       AS dispenserName,
                COUNT(*)                                        AS Total,
                STRING_AGG(CAST(JSON_VALUE(jsonOrigen, '$.transactionId') AS VARCHAR), ', ') AS transacciones
                FROM remisiones
                WHERE paquete IS NULL
                GROUP BY 
                    JSON_VALUE(jsonOrigen, '$.dispenserName'),
                    JSON_VALUE(jsonOrigen, '$.productName'),  
                    JSON_VALUE(jsonOrigen, '$.transactionType')                  
            )AS DatosAEmpaquetar        
    )


    
    -- Actualiza el campo paquete
    UPDATE T
    SET T.paquete = CONCAT(
                        CONVERT(VARCHAR(8), REPLACE(JSON_VALUE(jsonOrigen, '$.date'), '-', ''), 112),
                        ((CTE.RowNum - 1) / 500) + 1
                    )
    FROM remisiones T
    JOIN CTE ON  CTE.Id  LIKE '%' + JSON_VALUE(T.jsonOrigen, '$.transactionId') + '%'  
    WHERE T.paquete IS NULL;

    -- Retorna los datos seleccionados
    SELECT DISTINCT 
        CONVERT(bigint,paquete) AS Rowid,
        203017 AS IdDocumento,
        'Remisiones' AS NombreDocumento,
        'Remisiones_A_Siesa' AS ProcedimientoAlmacenado,
        2 AS estado
    FROM Remisiones
    WHERE estado != 2 
    ORDER BY CONVERT(bigint,paquete) DESC;
END;
GO

