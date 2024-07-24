BEGIN;
UPDATE orders
SET 
	total_amount = (
    	SELECT 
        	SUM(oi.quantity * oi.price_per_unit)
      	FROM 
      		order_items as oi
      	JOIN 
      		orders as o
      	WHERE
      		oi.order_id = o.order_id
		GROUP BY 
			o.order_id, o.total_amount
)
WHERE 
	order_id IN (
    	SELECT 
      		o.order_id
    	FROM 
      		orders o
    	JOIN 
      		order_items oi 
      	ON 
      		o.order_id = oi.order_id
      	GROUP BY 
      		o.order_id, o.total_amount
      	HAVING 
      		o.total_amount != SUM(oi.quantity * oi.price_per_unit)
);
COMMIT;