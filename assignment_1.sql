
-- ============================================================
-- PLSQL Assignment One - Sunrise Supermarket
-- DBMS: PostgreSQL
-- Student: Jane Kacyeye Igihozo
-- Student ID: 20251SEN127
-- ============================================================

-- ============================================================
-- 1. CREATE TABLES
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers(customer_id INTEGER PRIMARY KEY,customer_name VARCHAR(100) NOT NULL,email VARCHAR(100),city VARCHAR(50));
CREATE TABLE products (product_id INTEGER PRIMARY KEY, product_name VARCHAR(100) NOT NULL, category VARCHAR(50), price NUMERIC(10,2));
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER REFERENCES customers(customer_id), order_date DATE);
CREATE TABLE order_items (order_item_id INTEGER PRIMARY KEY, order_id INTEGER REFERENCES orders(order_id), product_id INTEGER REFERENCES products(product_id), quantity INTEGER);

INSERT INTO customers (customer_id, customer_name, email, city) VALUES (1, 'Alice Uwase', 'alice@gmail.com', 'Kigali'), (2, 'Brian Mugisha', 'brian@gmail.com', 'Musanze'), (3, 'Claire Mukamana', 'claire@gmail.com', 'Huye'), (4, 'David Niyonzima', 'david@gmail.com', 'Kigali'), (5, 'Esther Uwamahoro', 'esther@gmail.com', 'Rubavu'), (6, 'Frank Habimana', 'frank@gmail.com', 'Kigali');
INSERT INTO products (product_id, product_name, category, price) VALUES (1, 'Milk 1L', 'Dairy', 1200.00), (2, 'Bread', 'Bakery', 1500.00), (3, 'Rice 1kg', 'Grains', 2500.00), (4, 'Sugar 1kg', 'Groceries', 1800.00), (5, 'Coffee 250g', 'Beverages', 4500.00), (6, 'Tea 100g', 'Beverages', 2500.00), (7, 'Biscuits', 'Bakery', 1000.00), (8, 'Yogurt', 'Dairy', 1800.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES (1, 1, '2026-09-01'), (2, 2, '2026-09-02'), (3, 3, '2026-09-03'), (4, 1, '2026-09-05'), (5, 4, '2026-09-06'), (6, 5, '2026-09-07'), (7, 2, '2026-09-09'), (8, 3, '2026-09-10'), (9, 6, '2026-09-12'), (10, 1, '2026-09-14'), (11, 4, '2026-09-15'), (12, 5, '2026-09-16'), (13, 2, '2026-09-18'), (14, 3, '2026-09-19'), (15, 1, '2026-09-20');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (1, 1, 1, 2), (2, 1, 2, 1), (3, 2, 3, 2), (4, 2, 4, 1), (5, 3, 5, 1), (6, 3, 7, 2), (7, 4, 8, 2), (8, 4, 2, 1), (9, 5, 3, 3), (10, 5, 6, 1), (11, 6, 4, 2), (12, 6, 7, 3), (13, 7, 1, 3), (14, 7, 5, 1), (15, 8, 2, 2), (16, 8, 8, 1), (17, 9, 3, 1), (18, 9, 4, 2), (19, 10, 5, 2), (20, 10, 6, 1), (21, 11, 1, 2), (22, 11, 7, 4), (23, 12, 8, 3), (24, 12, 2, 2), (25, 13, 3, 2), (26, 13, 5, 1), (27, 14, 4, 3), (28, 14, 6, 2), (29, 15, 1, 4), (30, 15, 8, 2);

SELECT o.order_id, c.customer_name, c.city, o.order_date FROM orders o INNER JOIN customers c ON o.customer_id = c.customer_id ORDER BY o.order_date;

SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity FROM order_items oi INNER JOIN products p ON oi.product_id = p.product_id ORDER BY oi.order_id;

SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id ORDER BY c.customer_id, o.order_date;

WITH customer_totals AS (SELECT c.customer_id, c.customer_name, COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id LEFT JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend FROM customer_totals WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals) ORDER BY total_spend DESC;

WITH customer_totals AS (SELECT c.customer_id, c.customer_name, COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id LEFT JOIN products p ON oi.product_id = p.product_id GROUP BY c.customer_id, c.customer_name) SELECT customer_id, customer_name, total_spend, RANK() OVER (ORDER BY total_spend DESC) AS spending_rank FROM customer_totals ORDER BY spending_rank;

SELECT order_id, customer_id, order_date, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS customer_order_number FROM orders ORDER BY customer_id, order_date;

WITH daily_revenue AS (SELECT o.order_date, SUM(oi.quantity * p.price) AS daily_revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id GROUP BY o.order_date) SELECT order_date, daily_revenue, SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total_revenue FROM daily_revenue ORDER BY order_date;

WITH customer_orders AS (SELECT order_id, customer_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date, COUNT(*) OVER (PARTITION BY customer_id) AS order_count FROM orders) SELECT order_id, customer_id, order_date, previous_order_date, order_date - previous_order_date AS days_between_orders FROM customer_orders WHERE order_count > 1 AND previous_order_date IS NOT NULL ORDER BY customer_id, order_date;
