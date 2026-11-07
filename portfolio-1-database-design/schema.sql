CREATE TABLE customer (
  customer_id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  country VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(80) UNIQUE NOT NULL
);
CREATE TABLE supplier (
  supplier_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(50)
);
CREATE TABLE product (
  product_id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  category_id INT NOT NULL REFERENCES category,
  supplier_id INT NOT NULL REFERENCES supplier,
  price NUMERIC(10,2) CHECK (price > 0),
  stock INT CHECK (stock >= 0)
);
CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customer,
  order_date TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20) CHECK (status IN ('pending','paid','shipped','delivered','cancelled'))
);
CREATE TABLE order_item (
  order_id INT REFERENCES orders,
  product_id INT REFERENCES product,
  quantity INT CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id)
);
CREATE TABLE payment (
  payment_id SERIAL PRIMARY KEY,
  order_id INT UNIQUE REFERENCES orders,
  amount NUMERIC(10,2) NOT NULL,
  method VARCHAR(30),
  paid_at TIMESTAMP
);
CREATE TABLE shipment (
  shipment_id SERIAL PRIMARY KEY,
  order_id INT UNIQUE REFERENCES orders,
  tracking_no VARCHAR(50),
  status VARCHAR(20),
  shipped_at TIMESTAMP
);
