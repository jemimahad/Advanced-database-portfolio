-- Q1: Revenue per category
SELECT c.name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_item oi
JOIN product p ON p.product_id = oi.product_id
JOIN category c ON c.category_id = p.category_id
GROUP BY c.name
ORDER BY revenue DESC;

-- Q2: Top 5 customers by spending
SELECT cu.full_name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customer cu
JOIN orders o ON o.customer_id = cu.customer_id
JOIN order_item oi ON oi.order_id = o.order_id
GROUP BY cu.full_name
ORDER BY total_spent DESC
LIMIT 5;

-- Q3: Orders per status
SELECT status, COUNT(*) AS total_orders
FROM orders
GROUP BY status
ORDER BY total_orders DESC;
-- Optimisation test: orders for one customer

-- Step 1: BEFORE the index (shows Seq Scan on orders)
EXPLAIN ANALYZE
SELECT o.order_id, o.order_date, SUM(oi.quantity * oi.unit_price)
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
WHERE o.customer_id = 150
GROUP BY o.order_id, o.order_date;

-- Step 2: create the index
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Step 3: AFTER the index (same query, shows Bitmap Index Scan)
EXPLAIN ANALYZE
SELECT o.order_id, o.order_date, SUM(oi.quantity * oi.unit_price)
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
WHERE o.customer_id = 150
GROUP BY o.order_id, o.order_date;
