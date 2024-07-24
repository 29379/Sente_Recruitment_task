SELECT 
	o.order_id, 
    o.total_amount, 
    (oi.quantity * oi.price_per_unit) as total_price
FROM orders as o
JOIN order_items as oi
on o.order_id = oi.order_id;