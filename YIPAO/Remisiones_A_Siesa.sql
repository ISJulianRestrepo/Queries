SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DELETE FROM REMISIONES
CREATE PROCEDURE [dbo].[Remisiones_A_Siesa] 
	@row_id varchar(50)
AS
BEGIN
	DELETE FROM Remisiones 
	WHERE fechaRegistro < DATEADD(DAY, -5, GETDATE()) OR estado=2 OR JSON_VALUE(jsonOrigen, '$.productName') = 'DESCONOCIDO SNACK'
	SELECT --TOP 1
	 
		m.Referencia,
		m.[Descripcion],
		---------------------

		JSON_VALUE(jsonOrigen, '$.transactionId')											AS transactionId,
		JSON_VALUE(jsonOrigen, '$.date')													AS date,
		JSON_VALUE(jsonOrigen, '$.operationName')											AS operationName,
		JSON_VALUE(jsonOrigen, '$.serialMachine')											AS serialMachine,
		JSON_VALUE(jsonOrigen, '$.dispenserName')											AS dispenserName,
		JSON_VALUE(jsonOrigen, '$.selection')												AS selection,
		JSON_VALUE(jsonOrigen, '$.productName')												AS productName,
		JSON_VALUE(jsonOrigen, '$.value')													AS value,
		JSON_VALUE(jsonOrigen, '$.transactionType')											AS transactionType,
		
		CASE JSON_VALUE(jsonOrigen, '$.transactionType')
			WHEN 'EFECTIVO' THEN '009'
			WHEN 'CASHLESS' THEN '001'
		END																					AS co,		
		CASE JSON_VALUE(jsonOrigen, '$.transactionType')
			WHEN 'EFECTIVO' THEN '222222222222'
			WHEN 'CASHLESS' THEN '800251569'
		END																					AS tercero,
		CASE JSON_VALUE(jsonOrigen, '$.transactionType')
			WHEN 'EFECTIVO' THEN 'CRC'
			WHEN 'CASHLESS' THEN '15D'
		END																					AS condicion,
		CASE JSON_VALUE(jsonOrigen, '$.transactionType')
			WHEN 'EFECTIVO' THEN 'SERVICIO DE RESTAURANTES EFECTIVO MÁQUINAS'
			WHEN 'CASHLESS' THEN 'SERVICIO DE RESTAURANTE BENEFICIO MÁQUINAS NACIONAL'
		END																					AS notas,
		'3001'																				AS 'f470_id_ccosto_movto',
		'002'																				AS 'f470_id_co_movto',
		m.unidad_medida																		AS 'unidad_medida',
		CONVERT(VARCHAR(8), REPLACE(JSON_VALUE(jsonOrigen, '$.date'), '-', ''), 112)		AS fecha,



		------------------
		Vw.Co as 'Co_Item',
		Vw.Id_Bodega as 'Bodega_Item',
		Vw.Id_Bodega AS UbicacionQ,
		CASE Vw.Id_Bodega --bodega
			WHEN '001' THEN TRIM(m.Ubicacion)
		ELSE ''
		END AS Ubicacion

		------------------
		,paquete
		
		INTO #TemDoctos
	FROM [dbo].[Remisiones] AS r
	LEFT JOIN MAESTRO_ITEMS_UBICACIONES m ON JSON_VALUE(r.jsonOrigen, '$.productName') = m.Referencia OR JSON_VALUE(r.jsonOrigen, '$.productName') = m.Descripcion
	LEFT JOIN VW_CO_Bodega_Dispensador Vw ON JSON_VALUE(r.jsonOrigen, '$.dispenserName') = Vw.Descripcion_Dispensadora
	WHERE paquete = @row_id
	ORDER BY transactionId


	--SELECT * FROM #TemDoctos
		

	---TMPEncabezados
	---Remisión
	SELECT DISTINCT 
	'Remision'									AS 'NombreSeccion',
	co											AS 'F350_ID_CO',
	'RM'										AS 'F350_ID_TIPO_DOCTO',
	ROW_NUMBER() OVER (ORDER BY Co)	AS F350_CONSEC_DOCTO,
	fecha										AS 'F350_FECHA',
	tercero										AS 'F350_ID_TERCERO',
	'002'										AS 'f460_id_sucursal_fact',
	co											AS 'f460_id_co_fact',
	tercero										AS 'f460_id_tercero_rem',
	'002'										AS 'f460_id_sucursal_rem',
	condicion									AS 'f460_id_cond_pago',
	notas										AS 'f460_notas',	 
    STRING_AGG(CAST(transactionID AS NVARCHAR(MAX)), '|') AS id
	INTO #TemRemision
	FROM #TemDoctos
	WHERE paquete = @row_id
	GROUP BY	co,	
				fecha,
				tercero,	
				tercero,
				condicion,
				notas	



	--Remisión
	SELECT DISTINCT 
	NombreSeccion,
	F350_ID_CO,
	F350_ID_TIPO_DOCTO,
	F350_CONSEC_DOCTO,
	F350_FECHA,
	F350_ID_TERCERO,
	f460_id_sucursal_fact,
	f460_id_co_fact,
	f460_id_tercero_rem,
	f460_id_sucursal_rem,
	f460_id_cond_pago,
	f460_notas
	FROM #TemRemision
	  


	---MovtoVentasComercial
	SELECT DISTINCT
	'MovtoVentasComercial'																AS 'NombreSeccion',
	co																				AS 'f470_id_co',
    'RM'																				AS 'f470_id_tipo_docto',
    r.F350_CONSEC_DOCTO																	AS 'f470_consec_docto',
    ROW_NUMBER() OVER (PARTITION BY r.F350_CONSEC_DOCTO ORDER BY r.F350_CONSEC_DOCTO)	AS 'f470_nro_registro',	
    Bodega_Item																					AS 'f470_id_bodega',
    Ubicacion																			AS 'f470_id_ubicacion_aux',
    '01'																				AS 'f470_id_motivo',
    Co_Item																				AS 'f470_id_co_movto',
    '3001'																				AS 'f470_id_ccosto_movto',
    unidad_medida																		AS 'f470_id_unidad_medida',
    1																					AS 'f470_cant_base',
    value																				AS 'f470_vlr_bruto',
    ''																					AS 'f470_notas',
    CASE productName
		WHEN 'TORTA' THEN 'TORTA MÁQUINAS' 
		WHEN 'GALLETA MUUU' THEN 'GALLETA MUU' 
		WHEN 'MUFFIN' THEN 'MUFFINS' 
		WHEN 'GALLETA MILO' THEN 'GALLETAS MILO' 
	ELSE productName
	END AS 'f470_referencia_item' 
	FROM #TemDoctos d
	INNER JOIN #TemRemision r ON d.transactionId IN (SELECT value FROM STRING_SPLIT(r.id, '|'))
	WHERE paquete = @row_id
	ORDER BY F350_CONSEC_DOCTO, f470_nro_registro

	DROP TABLE #TemDoctos
	DROP TABLE #TemRemision
END
GO
