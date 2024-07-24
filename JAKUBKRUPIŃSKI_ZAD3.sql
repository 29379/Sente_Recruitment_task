WITH OrderTotals AS ( -- zapytanie zbierające informacje o wszystkich zamówieniach i ich całkowitych kwotach
    SELECT 
        o.order_id,
        o.client_id,
        SUM(oi.quantity * oi.price_per_unit) AS total_order_amount
    FROM 
        orders o
    JOIN 
        order_items oi ON o.order_id = oi.order_id
    GROUP BY 
        o.order_id, o.client_id
),
ClientOrdersWithA AS ( -- zapytanie zbierające o zamówieniach dotyczących osób, których imie kończy się na literę 'A'
    SELECT 
        ot.order_id,
        ot.total_order_amount
    FROM 
        OrderTotals ot
    JOIN 
        clients c 
  	ON 
  		ot.client_id = c.client_id
    WHERE 
        c.name LIKE '%A'
),
AverageAmount AS ( -- zaytanie obliczające średnią kwotę wynikającą z pozycji
    SELECT 
        AVG(ot.total_order_amount) AS avg_order_amount
    FROM 
        OrderTotals ot
    JOIN 
        clients c ON ot.client_id = c.client_id
    WHERE 
        c.name LIKE '%A'
)

SELECT 
    co.order_id,
    co.total_order_amount
FROM 
    ClientOrdersWithA co
JOIN 
    AverageAmount avg 
ON 
	co.total_order_amount > avg.avg_order_amount;