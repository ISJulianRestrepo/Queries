SELECT TOP (200)
    id, bill_prefix AS EDSI, [document], prefix, date_sale, plate, total, consolidated_id, default_payment_code, default_payment_name, default_payment_value, customer_document, customer_first_name,
    id_product, sale_id, product_code, product_name, presentation, quantity, price, subtotal, total_products
FROM tempFacturas1
WHERE        (LEN(bill_prefix) = 0) AND (estado = 0)