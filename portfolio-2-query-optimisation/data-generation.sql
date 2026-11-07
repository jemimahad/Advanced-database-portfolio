INSERT INTO category(name)
SELECT 'Category '||g FROM generate_series(1,10) g;

INSERT INTO supplier(name, city)
SELECT 'Supplier '||g,
  (ARRAY['Kunming','Guangzhou','Shenzhen','Yiwu'])[1+g%4]
FROM generate_series(1,20) g;

INSERT INTO customer(full_name,email,country)
SELECT 'Customer '||g, 'customer'||g||'@example.com',
  (ARRAY['Nigeria','Ghana','Kenya','South Africa','Uganda'])[1+g%5]
FROM generate_series(1,3000) g;

INSERT INTO product(name,category_id,supplier_id,price,stock)
SELECT 'Product '||g, 1+g%10, 1+g%20,
  round((5+random()*95)::numeric,2), (random()*500)::int
FROM generate_series(1,500) g;

INSERT INTO orders(customer_id,order_date,status)
SELECT 1+(random()*2999)::int,
  NOW() - (random()*365)*interval '1 day',
  (ARRAY['pending','paid','shipped','delivered','cancelled'])[1+(random()*4)::int]
FROM generate_series(1,20000);

INSERT INTO order_item(order_id,product_id,quantity,unit_price)
SELECT o.order_id, p.product_id, 1+(random()*4)::int, p.price
FROM orders o
CROSS JOIN generate_series(1,3) k
JOIN product p ON p.product_id = ((o.order_id + k*37) % 500) + 1;
