# Chapter 2, Standard RDBMS Capabilities

Code listings for Chapter 2, Standard RDBMS Capabilities.

**Listing 2.1 Creating custom databases**
```sql
CREATE DATABASE coffee_chain;
CREATE DATABASE brewery;
```

**Listing 2.2 Creating custom schemas**
```sql
CREATE SCHEMA products;
CREATE SCHEMA customers;
CREATE SCHEMA sales;
```

**Listing 2.3 Creating product catalog table**
```sql
CREATE TABLE products.catalog (
    id SERIAL PRIMARY KEY,
    name VARCHAR (100) NOT NULL,
    description TEXT NOT NULL,
    category TEXT CHECK (category IN ('coffee', 'mug', 't-shirt')),
    price NUMERIC(10, 2),
    stock_quantity INT CHECK (stock_quantity >= 0)
);
```

**Listing 2.4 Creating product reviews table**
```sql
CREATE TABLE products.review (
    id BIGSERIAL PRIMARY KEY,
    product_id INT,
    customer_id INT,
    review TEXT,
    rank SMALLINT 
);
```

**Listing 2.5 Inserting products**
```sql
INSERT INTO products.catalog (name, description, category, price, stock_quantity)
VALUES
    ('Sunrise Blend', 'A smooth and balanced blend with notes of caramel and citrus.', 'coffee', 14.99, 50),
    ('Midnight Roast', 'A dark roast with rich flavors of chocolate and toasted nuts.', 'coffee', 16.99, 40),
    ('Morning Glory', 'A light roast with bright acidity and floral notes.', 'coffee', 13.99, 30),
    ('Sunrise Brew Co. Mug', 'A ceramic mug with the Sunrise Brew Co. logo.', 'mug', 9.99, 100),
    ('Sunrise Brew Co. T-Shirt', 'A soft cotton t-shirt with the Sunrise Brew Co. logo.', 't-shirt', 19.99, 25);
```

**Listing 2.6 Selecting products of specific category**
```sql
SELECT id, name, price FROM products.catalog 
WHERE category = 'coffee';
```

**Listing 2.7 Updating product price**
```sql
UPDATE products.catalog SET price = 16.54 WHERE id = 1;
```

**Listing 2.8 Deleting product**
```sql
DELETE FROM products.catalog WHERE id = 2;
```

**Listing 2.9 Adding price constraint**
```sql
ALTER TABLE products.catalog 
ADD CONSTRAINT catalog_price_check CHECK (price > 0);
```

**Listing 2.10 Adding constraints for review table**
```sql
ALTER TABLE products.review 
ALTER COLUMN review SET NOT NULL,
ADD CONSTRAINT review_rank_check CHECK (rank BETWEEN 1 AND 5);
```

**Listing 2.11 Creating foreign key on product_id**
```sql
ALTER TABLE products.review
ADD CONSTRAINT products_review_product_id_fk
FOREIGN KEY (product_id) REFERENCES products.catalog(id);
```

**Listing 2.12 Creating customers account table**
```sql
CREATE TABLE customers.account (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    passwd_hash TEXT NOT NULL
);
```

**Listing 2.13 Creating foreign key on customer_id**
```sql
ALTER TABLE products.review 
ADD CONSTRAINT products_review_customer_id_fk
FOREIGN KEY (customer_id) REFERENCES customers.account(id);
```

**Listing 2.14 Adding new customers**
```sql
INSERT INTO customers.account (name, email, passwd_hash)
VALUES
    ('Alice Johnson', 'alice.johnson@example.com', '5f4dcc3b5aa765d61d8327deb882cf99'),
    ('Bob Smith', 'bob.smith@example.com', 'd8578edf8458ce06fbc5bb76a58c5ca4'), 
    ('Charlie Brown', 'charlie.brown@example.com', '5f4dcc3b5aa765d61d8327deb882cf99');
```

**Listing 2.15 Posting product review**
```sql
INSERT INTO products.review (product_id, customer_id, review, rank)
VALUES (4, 1, 'This mug is perfect — sturdy, stylish, and keeps my coffee warm for a good while.', 5);
```

**Listing 2.16 Adding deleted column to customers table**
```sql 
ALTER TABLE customers.account 
ADD COLUMN deleted boolean DEFAULT false;
```

**Listing 2.17 Updating quantity for a single product**
```sql
UPDATE products.catalog SET stock_quantity = stock_quantity + 100 
WHERE id = 1;
```

**Listing 2.18 Updating quantity for two products product**
```sql
UPDATE products.catalog SET stock_quantity = stock_quantity + 50 
WHERE id = 1 or id = 3;
```

**Listing 2.19 Creating order and order_item tables**
```sql
CREATE TABLE sales.order (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),   #A
    customer_id int REFERENCES customers.account(id),
    order_date timestamp DEFAULT CURRENT_TIMESTAMP,
    total_amount decimal(10, 2)
);
                        
CREATE TABLE sales.order_item (
    order_id UUID REFERENCES sales.order(id),
    product_id int REFERENCES products.catalog(id),
    quantity int CHECK (quantity > 0),
    price decimal(10, 2),  #B
    PRIMARY KEY (order_id, product_id)   #C
);
```

**Listing 2.20 Customer buys two products**
```sql
BEGIN;
    
INSERT INTO sales.order (id, customer_id, total_amount)
VALUES ('19a0cffc-8757-453c-a4d2-b554fdc08954', 1, 26.53);
    
INSERT INTO sales.order_item (order_id, product_id, quantity, price)
VALUES ('19a0cffc-8757-453c-a4d2-b554fdc08954', 1, 1, 16.54),
 ('19a0cffc-8757-453c-a4d2-b554fdc08954', 4, 1, 9.99);
    
UPDATE products.catalog
SET stock_quantity = stock_quantity - 1
WHERE id IN (1, 4);
    
COMMIT;
```

**Listing 2.21 Reading and changing quantity for product**
```sql
BEGIN;
    
SELECT stock_quantity FROM products.catalog
WHERE id = 1;
    
UPDATE products.catalog
SET stock_quantity = stock_quantity - 1
WHERE id = 1;
    
COMMIT;
```

**Listing 2.22 Top  three customers by order volume**
```sql
SELECT c.name, c.id, count(*) as total_orders
FROM customers.account c
JOIN sales.order s ON c.id = s.customer_id
GROUP BY c.id
ORDER BY total_orders DESC
LIMIT 3;
```

**Listing 2.23 Customers with no orders**
```sql
SELECT c.name
FROM customers.account c
LEFT JOIN sales.order s ON c.id = s.customer_id
WHERE s.customer_id IS NULL;
```

**Listing 2.24 Products popularity**
```sql
SELECT c.name, c.category, c.price, SUM(oi.quantity) AS total_sold
FROM products.catalog c
LEFT JOIN sales.order_item oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_sold DESC NULLS LAST, price DESC;
```
