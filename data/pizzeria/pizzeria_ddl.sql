CREATE SCHEMA pizzeria;

CREATE TABLE pizzeria.order_items (
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    pizza JSONB NOT NULL,
    price numeric(5,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);