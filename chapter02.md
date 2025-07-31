# Chapter 2, Standard RDBMS Capabilities

Code listings for Chapter 2, Standard RDBMS Capabilities.

**Listing 2.1 Creating product catalog table**
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

**Listing 2.2 Creating product reviews table**
```sql
CREATE TABLE products.reviews (  
    id BIGSERIAL PRIMARY KEY,  
    product_id INT,
    customer_id INT,
    review TEXT,
    rank SMALLINT 
);
```

**Listing 2.3 Inserting products**
```sql
INSERT INTO products.catalog (name, description, category, price, stock_quantity)
VALUES
    ('Sunrise Blend', 'A smooth and balanced blend with notes of caramel and citrus.', 'coffee', 14.99, 50),
    ('Midnight Roast', 'A dark roast with rich flavors of chocolate and toasted nuts.', 'coffee', 16.99, 40),
    ('Morning Glory', 'A light roast with bright acidity and floral notes.', 'coffee', 13.99, 30),
    ('Sunrise Brew Co. Mug', 'A ceramic mug with the Sunrise Brew Co. logo.', 'mug', 9.99, 100),
    ('Sunrise Brew Co. T-Shirt', 'A soft cotton t-shirt with the Sunrise Brew Co. logo.', 't-shirt', 19.99, 25);
```

**Listing 2.4 Adding price constraint**
```sql
ALTER TABLE products.catalog 
ADD CONSTRAINT catalog_price_check CHECK (price > 0);
```

**Listing 2.5 Adding constraints for review table**
```sql
ALTER TABLE products.reviews 
    ALTER COLUMN review SET NOT NULL,
    ADD CONSTRAINT review_rank_check CHECK (rank BETWEEN 1 AND 5);
```

**Listing 2.6 Creating foreign key on product_id**
```sql
ALTER TABLE products.reviews
    ADD CONSTRAINT products_review_product_id_fk
    FOREIGN KEY (product_id) REFERENCES products.catalog(id);
```

**Listing 2.7 Creating customers account table**
```sql
CREATE TABLE customers.accounts (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    passwd_hash TEXT NOT NULL
);
```

**Listing 2.8 Creating foreign key on customer_id**
```sql
ALTER TABLE products.reviews 
    ADD CONSTRAINT products_review_customer_id_fk
    FOREIGN KEY (customer_id) REFERENCES customers.accounts(id);
```

**Listing 2.9 Adding new customers**
```sql
INSERT INTO customers.accounts (name, email, passwd_hash)
VALUES
    ('Alice Johnson', 'alice.johnson@example.com', '5f4dcc3b5aa765d61d8327deb882cf99'),
    ('Bob Smith', 'bob.smith@example.com', 'd8578edf8458ce06fbc5bb76a58c5ca4'), 
    ('Charlie Brown', 'charlie.brown@example.com', '5f4dcc3b5aa765d61d8327deb882cf99');
```

**Listing 2.10 Posting product review**
```sql
INSERT INTO products.reviews (product_id, customer_id, review, rank)
VALUES (4, 1, 'This mug is perfect — sturdy, stylish, and keeps my coffee warm for a good while.', 5);
```

**Listing 2.11 Adding deleted column to customers table**
```sql 
ALTER TABLE customers.accounts 
    ADD COLUMN deleted boolean DEFAULT false;
```

**Listing 2.12 Updating quantity for a single product**
```sql
UPDATE products.catalog SET stock_quantity = stock_quantity + 100 
WHERE id = 1;
```

**Listing 2.13 Updating quantity for two products product**
```sql
UPDATE products.catalog SET stock_quantity = stock_quantity + 50 
WHERE id = 1 or id = 3;
```

**Listing 2.14 Creating order and order_item tables**
```sql
CREATE TABLE sales.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    customer_id INT REFERENCES customers.accounts(id),
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2)
);

CREATE TABLE sales.order_items (
    order_id UUID REFERENCES sales.orders(id),
    product_id INT REFERENCES products.catalog(id),
    quantity INT CHECK (quantity > 0),
    price DECIMAL (10, 2), 
    PRIMARY KEY (order_id, product_id)  
);
```

**Listing 2.15 Customer buys two products**
```sql
BEGIN; 

INSERT INTO sales.orders (id, customer_id, total_amount)  
VALUES ('19a0cffc-8757-453c-a4d2-b554fdc08954', 1, 26.53);

INSERT INTO sales.order_items (order_id, product_id, quantity, price)  
VALUES ('19a0cffc-8757-453c-a4d2-b554fdc08954', 1, 1, 16.54),
 ('19a0cffc-8757-453c-a4d2-b554fdc08954', 4, 1, 9.99);

UPDATE products.catalog  
SET stock_quantity = stock_quantity - 1
WHERE id IN (1, 4);

COMMIT;
```

**Listing 2.16 Reading and changing quantity for product**
```sql
BEGIN;
    
SELECT stock_quantity FROM products.catalog
WHERE id = 1;
    
UPDATE products.catalog
SET stock_quantity = stock_quantity - 1
WHERE id = 1;
    
COMMIT;
```

**Listing 2.17 Top  three customers by order volume**
```sql
SELECT c.name, c.id, count(*) as total_orders
FROM customers.accounts c
JOIN sales.orders s ON c.id = s.customer_id
GROUP BY c.id
ORDER BY total_orders DESC
LIMIT 3;
```

**Listing 2.18 Customers with no orders**
```sql
SELECT c.name 
FROM customers.accounts c 
LEFT JOIN sales.orders s ON c.id = s.customer_id 
WHERE s.customer_id IS NULL;
```

**Listing 2.19 Products popularity**
```sql
SELECT c.name, c.category, c.price, SUM(oi.quantity) AS total_sold
FROM products.catalog c
LEFT JOIN sales.order_items oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_sold DESC NULLS LAST, price DESC;
```

**Listing 2.20 Function that returns product price**
```sql
CREATE OR REPLACE FUNCTION get_product_price(product_id INT)
RETURNS NUMERIC(10, 2) AS $$
    SELECT price
    FROM products.catalog
    WHERE id = product_id;
$$ LANGUAGE sql;
```

**Listing 2.21 Adding status column to the orders table**
```sql
ALTER TABLE sales.orders 
ADD COLUMN status TEXT DEFAULT 'pending' CHECK (status in ('pending','ordered'));

UPDATE sales.orders SET status = 'ordered';  

ALTER TABLE sales.orders  
ADD CONSTRAINT one_pending_order_per_customer
EXCLUDE USING btree (customer_id WITH =)
WHERE (status = 'pending');
```

**Listing 2.22 Implementation of order_add_item function**
```sql
CREATE OR REPLACE FUNCTION order_add_item(customer_id_param INT, product_id_param INT, quantity_param INT)  
RETURNS TABLE (order_id UUID, prod_id INT, quantity INT, prod_price DECIMAL) AS $$
DECLARE
    pending_order_id UUID;  
BEGIN
    SELECT id INTO pending_order_id  
    FROM sales.orders
    WHERE customer_id = customer_id_param
      AND status = 'pending'
    LIMIT 1;

    IF pending_order_id IS NULL THEN  
        INSERT INTO sales.orders (customer_id, status)
        VALUES (customer_id_param, 'pending')
        RETURNING id INTO pending_order_id;
    END IF;

    MERGE INTO sales.order_items AS oi  
    USING (SELECT id, price FROM products.catalog WHERE id = product_id_param) AS prod
    ON oi.product_id = prod.id AND oi.order_id = pending_order_id
    WHEN MATCHED THEN
        UPDATE SET quantity = quantity_param
    WHEN NOT MATCHED THEN
        INSERT (order_id, product_id, quantity, price)
        VALUES (pending_order_id, prod.id, quantity_param, prod.price);

    RETURN QUERY  
    SELECT oi.order_id, oi.product_id, oi.quantity, oi.price as prod_price
    FROM sales.order_items as oi
    WHERE oi.order_id = pending_order_id;
END;
$$ LANGUAGE plpgsql;
```

**Listing 2.23 Adding product to shopping cart**
```sql
SELECT * FROM order_add_item(
    customer_id_param => 3,
    product_id_param => 3,
    quantity_param => 2
    );
```

**Listing 2.24 Implementation of order_checkout function**
```sql
CREATE OR REPLACE FUNCTION order_checkout(customer_id_param INT) 
RETURNS TABLE (order_id UUID, customer_id INT, order_date timestamptz, total_amount DECIMAL) AS $$
DECLARE
    pending_order_id UUID; 
    final_total_amount DECIMAL := 0;
BEGIN
    SELECT id INTO pending_order_id 
    FROM sales.orders as o
    WHERE o.customer_id = customer_id_param
      AND status = 'pending'
    LIMIT 1;

    IF pending_order_id IS NULL THEN 
        RAISE EXCEPTION 'No pending order found for customer %', customer_id_param;
    END IF;

    SELECT SUM(oi.quantity * oi.price) INTO final_total_amount 
    FROM sales.order_items oi
    WHERE oi.order_id = pending_order_id;

    UPDATE sales.orders  
    SET status = 'ordered',
        total_amount = final_total_amount,
        order_date = CURRENT_TIMESTAMP
    WHERE id = pending_order_id;

    UPDATE products.catalog  
    SET stock_quantity = stock_quantity - oi.quantity
    FROM sales.order_items oi
    WHERE products.catalog.id = oi.product_id
      AND oi.order_id = pending_order_id;

    RETURN QUERY  
    SELECT o.id, o.customer_id, o.order_date, o.total_amount
    FROM sales.orders as o
    WHERE o.id = pending_order_id;
END;
$$ LANGUAGE plpgsql;
```

**Listing 2.25 Trigger function that updates order’s total amount**
```sql
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE sales.orders
    SET total_amount = (  
        SELECT COALESCE(SUM(oi.quantity * oi.price), 0)  
        FROM sales.order_items oi
        WHERE oi.order_id = COALESCE(NEW.order_id, OLD.order_id)  
    )
    WHERE id = COALESCE(NEW.order_id, OLD.order_id) AND status = 'pending';
		
    RETURN NEW;  
END;
$$ LANGUAGE plpgsql;
```

**Listing 2.26  Trigger that updates order’s total amount**
```sql
CREATE TRIGGER trigger_update_order_total
AFTER INSERT OR UPDATE OR DELETE ON sales.order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();
```

**Listing 2.27  Sales report summary**
```sql
SELECT 
    c.name AS product_name,
    c.category,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM products.catalog c
LEFT JOIN sales.order_items oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_quantity_sold DESC, total_revenue DESC;
```

**Listing 2.28 View for the sales report summary**
```sql
CREATE VIEW product_sales_summary AS  
SELECT  
    c.name AS product_name,
    c.category,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM products.catalog c
LEFT JOIN sales.order_items oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_quantity_sold DESC, total_revenue DESC;
```

**Listing 2.29 View for monthly sales**
```sql
CREATE MATERIALIZED VIEW monthly_sales_summary AS
SELECT 
    date_trunc('month', o.order_date) AS sales_month,
    SUM(oi.quantity * oi.price) AS total_revenue,
    COUNT(DISTINCT(o.id)) AS total_orders
FROM sales.orders o
JOIN sales.order_items oi ON o.id = oi.order_id
GROUP BY sales_month
ORDER BY sales_month;
```

**Listing 2.30 Buying two flavors of coffee**
```sql
SELECT order_add_item(
    customer_id_param => 3,
    product_id_param => 1,
    quantity_param => 3
    );
        
SELECT order_add_item(
    customer_id_param => 3,
    product_id_param => 3,
    quantity_param => 2
    );
        
SELECT * FROM order_checkout(customer_id_param => 3);
```

**Listing 2.31 Refreshing and querying materialized view**
```sql
REFRESH MATERIALIZED VIEW monthly_sales_summary;

SELECT * FROM monthly_sales_summary;
```

**Listing 2.32 Creating admin-level role for coffee chain**
```sql
CREATE ROLE coffee_chain_admin WITH LOGIN PASSWORD 'password';
							
GRANT CONNECT ON DATABASE coffee_chain TO coffee_chain_admin;
							
REVOKE CONNECT ON DATABASE coffee_chain FROM PUBLIC;
```

**Listing 2.33 Setting up permissions for the role**
```sql
GRANT USAGE ON SCHEMA public TO coffee_chain_admin;
GRANT USAGE ON SCHEMA products TO coffee_chain_admin;
GRANT USAGE ON SCHEMA customers TO coffee_chain_admin;
GRANT USAGE ON SCHEMA sales TO coffee_chain_admin;
							
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO coffee_chain_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA products TO coffee_chain_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA customers TO coffee_chain_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sales TO coffee_chain_admin;
							
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA products TO coffee_chain_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA customers TO coffee_chain_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sales TO coffee_chain_admin;
```

**Listing 2.34 Revoking access on brewery and postgres databases**
```sql
REVOKE CONNECT ON DATABASE brewery FROM PUBLIC;
REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;
```


