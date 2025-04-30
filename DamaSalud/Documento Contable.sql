-- Declare @tipoDocumento as varchar(3) = '{Documento}'
-- Declare @CentroOperacion as varchar(3) = '{CentroOpe}'
-- Declare @Numero as int = {Numero}

Declare @tipoDocumento as varchar(3) = '1'
Declare @CentroOperacion as varchar(3) = '1'
Declare @Numero as int = 1

SELECt tOP (10) 
	t350.f350_id_cia 								AS Compania							
	,t350.f350_rowid								AS RowIdDocumento
	,t350.f350_id_co								AS Co
	,t350.f350_id_tipo_docto						AS TipoDocumento
	,t350.f350_consec_docto							AS ConsecutivoDocto
	,CONVERt(VARCHAR(8), t350.f350_fecha, 112)		AS FechaDocto
	,t350.f350_id_periodo							AS Periodo
	,t200.f200_id									AS tercero
	,t350.f350_ind_estado							AS Estado
	,t350.f350_notas								AS Notas
	,t351.f351_rowid								AS RowIdMovDocto	
	--,t254.f254_id_mayor								
	,t200.f200_id 									AS IdTercero
	,t351.f351_id_un								AS 'U.N.'
	,t351.f351_valor_db								AS ValorDB
	,t351.f351_valor_cr								AS ValorCR
	,t351.f351_base_gravable						AS BaseGravable
	,t351.f351_docto_banco							AS DoctoBanco
	,t351.f351_nro_docto_banco						AS NroDoctoBanco
	,t351.f351_notas								AS NotasMov
	FROM t351_co_mov_docto t351
	INNER JOIN t350_co_docto_contable t350 on t351.f351_rowid_docto = t350.f350_rowid
	--INNER JOIN t254_co_mayores_auxiliares t254 on t351.f351_rowid_auxiliar = t254.f254_rowid_auxiliar
	LEFt JOIN t200_mm_terceros t200 on t200.f200_rowid = t351.f351_rowid_tercero
	--INNER JOIN dbo.t350_co_docto_contable t350  on t200.f200_rowid = t350.f350_rowid_tercero
  where t350.f350_id_cia = 1 
		-- and f350_consec_docto = @Numero 
		-- and F350_ID_tIPO_DOCtO= @tipoDocumento
		-- and t350.f350_id_co = @CentroOperacion 
  order by t350.f350_rowid 



  