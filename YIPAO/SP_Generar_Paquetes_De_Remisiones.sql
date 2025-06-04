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
            JSON_VALUE(jsonOrigen, '$.transactionId') AS Id, 
            ROW_NUMBER() OVER (ORDER BY JSON_VALUE(jsonOrigen, '$.transactionType'), JSON_VALUE(jsonOrigen, '$.dispenserName')) AS RowNum
            -- ROW_NUMBER() OVER (ORDER BY JSON_VALUE(jsonOrigen, '$.transactionType')) AS RowNum
        FROM 
            remisiones
        WHERE paquete IS NULL
    )
    
    -- Actualiza el campo paquete
    UPDATE T
    SET T.paquete = CONCAT(
        CONVERT(VARCHAR(8), REPLACE(JSON_VALUE(jsonOrigen, '$.date'), '-', ''), 112),
        ((CTE.RowNum - 1) / 1000) + 1
    )
    FROM remisiones T
    JOIN CTE ON JSON_VALUE(T.jsonOrigen, '$.transactionId') = CTE.Id
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
