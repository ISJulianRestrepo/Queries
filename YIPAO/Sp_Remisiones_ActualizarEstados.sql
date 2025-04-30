SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_Remisiones_ActualizarEstados] 
	@RowId varchar(50),
	@IndicadorEstado varchar(2)

AS
BEGIN
	UPDATE Remisiones 
	SET estado = @IndicadorEstado,
		intentos = intentos + 1
	WHERE paquete = @RowId
END
GO
