-- PART 1: COMMIT (place an order and reduce stock together)
BEGIN;
INSERT INTO orders(customer_id, status) VALUES (1, 'paid');
INSERT INTO order_item(order_id, product_id, quantity, unit_price)
SELECT currval('orders_order_id_seq'), product_id, 2, price
FROM product WHERE product_id = 5;
UPDATE product SET stock = stock - 2 WHERE product_id = 5;
COMMIT;

-- PART 2A: ROLLBACK (undo on purpose)
BEGIN;
UPDATE product SET stock = stock - 5 WHERE product_id = 5;
SELECT product_id, stock FROM product WHERE product_id = 5;
ROLLBACK;

-- PART 2B: ROLLBACK (order fails halfway, CHECK constraint stops it)
BEGIN;
INSERT INTO orders(customer_id, status) VALUES (2, 'paid');
UPDATE product SET stock = stock - 1000 WHERE product_id = 5;  -- fails: stock >= 0
ROLLBACK;

-- PART 3: LOST UPDATE (run in two sessions)
-- Session 1:  BEGIN; SELECT stock FROM product WHERE product_id = 5;
-- Session 2:  BEGIN; SELECT stock FROM product WHERE product_id = 5;
-- Session 1:  UPDATE product SET stock = 485 WHERE product_id = 5; COMMIT;
-- Session 2:  UPDATE product SET stock = 485 WHERE product_id = 5; COMMIT;
-- Result: stock is 485 but two units were sold (should be 484).

-- PART 4: FIX WITH ROW LOCK
-- Session 1:  BEGIN; SELECT stock FROM product WHERE product_id = 5 FOR UPDATE;
-- Session 2:  BEGIN; SELECT stock FROM product WHERE product_id = 5 FOR UPDATE;  -- waits
-- Session 1:  UPDATE product SET stock = 484 WHERE product_id = 5; COMMIT;
-- Session 2:  (resumes, reads 484)
--             UPDATE product SET stock = 483 WHERE product_id = 5; COMMIT;
-- Result: stock is 483, both sales counted.
