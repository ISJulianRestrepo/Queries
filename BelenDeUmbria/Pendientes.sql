---Facturas pendientes por cargar:
SELECT
    consolidated_id AS Consolidado
	, document
	, date_sale AS  Fecha
	, bill_number AS EDSI
	, customer_document AS IdTercero
	, customer_first_name AS Tercero
	, plate AS 'U. N.'
	, product_name AS Producto
	, quantity AS Cantidad
	, price AS Precio
	, total AS Total
	, code AS 'Medio de Pago'
FROM GTIntegration.dbo.tempFacturas1 LOCAL
    LEFT JOIN [siesa-m3-sqlsw-sbs01.cihpfbkcx35e.us-east-1.rds.amazonaws.com].[SUnoEE_CoopTransBelen_Real].[dbo].[t350_co_docto_contable] SIESA
    ON LOCAL.bill_number = SIESA.f350_consec_docto
WHERE estado = 0
    AND (SIESA.f350_consec_docto IS NULL OR LEN(bill_number) = 0)
ORDER BY bill_number, customer_first_name

---Cambiar estado de facturas cargadas manualmente para evitar que la integración los siga tomando. 449822
--UPDATE GTIntegration.dbo.tempFacturas1
--SET estado = 4
--WHERE document = 539933