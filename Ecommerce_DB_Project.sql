-- ============================================================
-- E-Commerce Database System
-- Database: PostgreSQL
-- Author: Rijan
-- Description: Full schema for an online store management system
-- ============================================================

-- ========================
-- 1. SCHEMA SETUP
-- ========================

DROP SCHEMA IF EXISTS ecommerce CASCADE;
CREATE SCHEMA ecommerce;
SET search_path TO ecommerce;

-- ========================
-- 2. TABLE DEFINITIONS
-- ========================

-- Categories
CREATE TABLE category (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT,
    parent_id     INT REFERENCES category(category_id) ON DELETE SET NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers
CREATE TABLE customer (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    is_active     BOOLEAN      DEFAULT TRUE,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Addresses
CREATE TABLE address (
    address_id    SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    street        VARCHAR(200) NOT NULL,
    city          VARCHAR(100) NOT NULL,
    state         VARCHAR(100),
    postal_code   VARCHAR(20)  NOT NULL,
    country       VARCHAR(100) NOT NULL DEFAULT 'Nepal',
    is_default    BOOLEAN      DEFAULT FALSE
);

-- Products
CREATE TABLE product (
    product_id    SERIAL PRIMARY KEY,
    category_id   INT REFERENCES category(category_id) ON DELETE SET NULL,
    name          VARCHAR(200) NOT NULL,
    description   TEXT,
    price         NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_qty     INT           NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    sku           VARCHAR(100)  UNIQUE,
    is_active     BOOLEAN       DEFAULT TRUE,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customer(customer_id),
    address_id    INT REFERENCES address(address_id),
    status        VARCHAR(30) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled')),
    total_amount  NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Items
CREATE TABLE order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INT NOT NULL REFERENCES product(product_id),
    quantity      INT           NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- Payments
CREATE TABLE payment (
    payment_id    SERIAL PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id),
    method        VARCHAR(50) NOT NULL CHECK (method IN ('credit_card','debit_card','paypal','esewa','khalti','cash_on_delivery')),
    status        VARCHAR(30) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','completed','failed','refunded')),
    amount        NUMERIC(12,2) NOT NULL,
    paid_at       TIMESTAMP
);

-- Reviews
CREATE TABLE review (
    review_id     SERIAL PRIMARY KEY,
    product_id    INT NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    customer_id   INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, customer_id)
);

-- ========================
-- 3. INDEXES
-- ========================

CREATE INDEX idx_product_category   ON product(category_id);
CREATE INDEX idx_order_customer      ON orders(customer_id);
CREATE INDEX idx_order_status        ON orders(status);
CREATE INDEX idx_order_item_order    ON order_item(order_id);
CREATE INDEX idx_order_item_product  ON order_item(product_id);
CREATE INDEX idx_payment_order       ON payment(order_id);
CREATE INDEX idx_review_product      ON review(product_id);

-- ========================
-- 4. SAMPLE DATA
-- ========================

-- Categories
INSERT INTO category (name, description) VALUES
  ('Electronics',   'Electronic gadgets and accessories'),
  ('Clothing',      'Men and Women clothing'),
  ('Books',         'Academic and fiction books'),
  ('Home & Garden', 'Furniture and home accessories');

INSERT INTO category (name, description, parent_id) VALUES
  ('Smartphones', 'Mobile phones and accessories', 1),
  ('Laptops',     'Portable computers',            1),
  ('Men Clothing','Clothing for men',              2),
  ('Women Clothing','Clothing for women',          2);

-- Customers
INSERT INTO customer (first_name, last_name, email, phone, password_hash) VALUES
  ('Aarav',   'Sharma',    'aarav@example.com',   '9801000001', 'hashed_pw_1'),
  ('Sita',    'Thapa',     'sita@example.com',    '9802000002', 'hashed_pw_2'),
  ('Bikram',  'KC',        'bikram@example.com',  '9803000003', 'hashed_pw_3'),
  ('Priya',   'Karki',     'priya@example.com',   '9804000004', 'hashed_pw_4'),
  ('Roshan',  'Shrestha',  'roshan@example.com',  '9805000005', 'hashed_pw_5');

-- Addresses
INSERT INTO address (customer_id, street, city, postal_code, country, is_default) VALUES
  (1, 'Putalisadak Rd', 'Kathmandu', '44600', 'Nepal', TRUE),
  (2, 'Lakeside Rd',    'Pokhara',   '33700', 'Nepal', TRUE),
  (3, 'Mahendra Rd',    'Biratnagar','56613', 'Nepal', TRUE),
  (4, 'New Road',       'Kathmandu', '44601', 'Nepal', TRUE),
  (5, 'Prithvi Hwy',    'Chitwan',   '44200', 'Nepal', TRUE);

-- Products
INSERT INTO product (category_id, name, description, price, stock_qty, sku) VALUES
  (5, 'Samsung Galaxy A54',  '6.4" FHD+ display, 5000mAh battery', 45000, 30, 'SAMS-A54-001'),
  (5, 'iPhone 15',           'Apple iPhone 15, 128GB, Black',       120000, 15, 'APPL-IP15-001'),
  (6, 'HP Pavilion 15',      'Intel i5, 8GB RAM, 512GB SSD',        95000, 20, 'HP-PAV15-001'),
  (6, 'Lenovo IdeaPad 3',    'Ryzen 5, 8GB RAM, 256GB SSD',         75000, 25, 'LEN-ID3-001'),
  (7, 'Cotton Polo Shirt',   'Premium cotton, S/M/L/XL',             1200,100, 'CLO-POLO-001'),
  (8, 'Women Kurti Set',     'Ethnic kurti, various sizes',           1800, 80, 'CLO-KUR-001'),
  (3, 'Database Systems',    'Elmasri & Navathe, 7th Edition',        2500, 40, 'BK-DB-001'),
  (3, 'Clean Code',          'Robert C. Martin - Programming guide',  1800, 35, 'BK-CC-001'),
  (4, 'Office Chair',        'Ergonomic mesh chair with lumbar support',12000,10,'HG-CHR-001'),
  (4, 'Bookshelf 5-tier',    'Wooden bookshelf, 180cm tall',          8500, 15, 'HG-BSH-001');

-- Orders
INSERT INTO orders (customer_id, address_id, status, total_amount) VALUES
  (1, 1, 'delivered',  46200),
  (2, 2, 'shipped',   121200),
  (3, 3, 'confirmed',  96200),
  (4, 4, 'pending',    10300),
  (5, 5, 'delivered',   3600),
  (1, 1, 'cancelled',  75000),
  (2, 2, 'delivered',  13500),
  (3, 3, 'shipped',    24500);

-- Order Items
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 45000), (1, 5, 1, 1200),
  (2, 2, 1,120000), (2, 5, 1, 1200),
  (3, 3, 1, 95000), (3, 8, 1, 1800),
  (4, 6, 2, 1800),  (4, 8, 2, 1800),  (4, 5, 1, 1200),
  (5, 7, 1, 2500),  (5, 8, 1, 1800),
  (6, 4, 1, 75000),
  (7, 9, 1,12000),  (7, 10,1, 8500),  (7, 5, 1,  1200),  (7, 6, 1, 1800),
  (8, 3, 1, 95000);

-- Payments
INSERT INTO payment (order_id, method, status, amount, paid_at) VALUES
  (1, 'esewa',           'completed', 46200,  '2024-11-10 10:30:00'),
  (2, 'credit_card',     'completed', 121200, '2024-11-15 14:00:00'),
  (3, 'khalti',          'completed', 96200,  '2024-11-20 09:45:00'),
  (4, 'cash_on_delivery','pending',   10300,  NULL),
  (5, 'paypal',          'completed', 3600,   '2024-11-22 16:20:00'),
  (6, 'khalti',          'refunded',  75000,  '2024-11-23 11:00:00'),
  (7, 'esewa',           'completed', 13500,  '2024-11-25 13:15:00'),
  (8, 'credit_card',     'completed', 24500,  '2024-11-28 08:00:00');

-- Reviews
INSERT INTO review (product_id, customer_id, rating, comment) VALUES
  (1, 1, 5, 'Excellent phone, great battery life!'),
  (2, 2, 4, 'Great phone but quite expensive.'),
  (3, 3, 5, 'Runs smoothly, highly recommended.'),
  (7, 5, 5, 'Best database textbook for students!'),
  (8, 1, 4, 'Very insightful book on clean coding.');


-- ========================
-- 5. VIEWS
-- ========================

-- Order summary view
CREATE VIEW vw_order_summary AS
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    o.status,
    o.total_amount,
    o.created_at,
    p.method AS payment_method,
    p.status  AS payment_status
FROM orders o
JOIN customer c  ON o.customer_id  = c.customer_id
LEFT JOIN payment p ON o.order_id  = p.order_id;

-- Product sales summary view
CREATE VIEW vw_product_sales AS
SELECT
    pr.product_id,
    pr.name AS product_name,
    cat.name AS category,
    SUM(oi.quantity)               AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    ROUND(AVG(r.rating), 2)        AS avg_rating
FROM product pr
JOIN order_item oi ON pr.product_id  = oi.product_id
JOIN orders o      ON oi.order_id    = o.order_id
LEFT JOIN category cat ON pr.category_id = cat.category_id
LEFT JOIN review r ON pr.product_id  = r.product_id
WHERE o.status <> 'cancelled'
GROUP BY pr.product_id, pr.name, cat.name;

-- ========================
-- 6. FUNCTIONS & TRIGGERS
-- ========================

-- Function: Recalculate order total
CREATE OR REPLACE FUNCTION fn_recalculate_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_item
        WHERE order_id = NEW.order_id
    ),
    updated_at = CURRENT_TIMESTAMP
    WHERE order_id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update total on order item insert/update
CREATE TRIGGER trg_update_order_total
AFTER INSERT OR UPDATE ON order_item
FOR EACH ROW EXECUTE FUNCTION fn_recalculate_order_total();

-- Function: Reduce stock on order confirmation
CREATE OR REPLACE FUNCTION fn_reduce_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'confirmed' AND OLD.status = 'pending' THEN
        UPDATE product p
        SET stock_qty = stock_qty - oi.quantity
        FROM order_item oi
        WHERE oi.order_id = NEW.order_id
          AND oi.product_id = p.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Call stock reduction on order status change
CREATE TRIGGER trg_reduce_stock
AFTER UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION fn_reduce_stock();

-- ========================
-- 7. ANALYTICAL QUERIES
-- ========================

-- Q1: Top 5 best-selling products by revenue
SELECT
    pr.name,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    SUM(oi.quantity) AS units_sold
FROM order_item oi
JOIN product pr ON oi.product_id = pr.product_id
JOIN orders o   ON oi.order_id   = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY pr.name
ORDER BY revenue DESC
LIMIT 5;

-- Q2: Monthly revenue report
SELECT
    TO_CHAR(o.created_at, 'YYYY-MM') AS month,
    COUNT(DISTINCT o.order_id)        AS total_orders,
    SUM(o.total_amount)               AS total_revenue
FROM orders o
WHERE o.status NOT IN ('cancelled','pending')
GROUP BY month
ORDER BY month;

-- Q3: Customers who spent the most
SELECT
    c.first_name || ' ' || c.last_name AS customer,
    c.email,
    COUNT(o.order_id)    AS total_orders,
    SUM(o.total_amount)  AS total_spent
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status NOT IN ('cancelled')
GROUP BY c.customer_id, customer, c.email
ORDER BY total_spent DESC;

-- Q4: Products low on stock (< 20 units)
SELECT name, stock_qty, sku
FROM product
WHERE stock_qty < 20 AND is_active = TRUE
ORDER BY stock_qty ASC;

-- Q5: Average rating per category
SELECT
    cat.name AS category,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id)      AS total_reviews
FROM review r
JOIN product pr    ON r.product_id   = pr.product_id
JOIN category cat  ON pr.category_id = cat.category_id
GROUP BY cat.name
ORDER BY avg_rating DESC;
