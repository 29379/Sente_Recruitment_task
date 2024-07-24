BEGIN;
INSERT INTO 
	invoices (
      invoice_id,
      supplier_id,
      client_id,
      issue_date,
      due_date,
      invoice_type,
      order_id,
      total_amount_due,
      payment_received
	)
SELECT 
    COALESCE((SELECT MAX(invoice_id) FROM invoices), 0) + ROW_NUMBER() 
    	OVER(ORDER BY o.order_id) AS new_invoice_id, -- table indexing - 'invoices'
    o.supplier_id,
    o.client_id,
    date('now') AS issue_date,
    date('now', '+7 days') AS due_date, -- payment deadline - 7 calendar days
    'FAK' AS invoice_type,
    o.order_id,
    SUM(oi.quantity * oi.price_per_unit) AS total_amount_due,
    1 AS payment_received -- true
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id, o.supplier_id, o.client_id;
COMMIT;

BEGIN;
INSERT INTO invoice_items (invoice_item_id, invoice_id, description, quantity, price_per_unit)
SELECT 
    COALESCE((SELECT MAX(invoice_item_id) FROM invoice_items), 0) + ROW_NUMBER() 
    	OVER(ORDER BY oi.order_id, oi.product_name) AS new_invoice_item_id, -- table indexing - 'invoice_items'
    i.invoice_id,
    oi.product_name AS description,
    oi.quantity,
    oi.price_per_unit
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
JOIN 
    invoices i ON i.order_id = o.order_id
WHERE 
    i.issue_date = date('now');  
COMMIT;