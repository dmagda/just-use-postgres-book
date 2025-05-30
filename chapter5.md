# Chapter 5, JSON

Code listings for the Chapter 5, JSON.

**Preload sample dataset**
```shell
docker cp data/pizzeria/. postgres:/home/.

docker exec -it postgres psql -U postgres -c "\i /home/pizzeria_ddl.sql"
docker exec -it postgres psql -U postgres -c "\i /home/pizzeria_data.sql"
```

**Listing 5.1 Extracting Pizza Size and Crust Type**       
```sql                                                           
SELECT
    order_id, order_item_id,
    pizza->'size' as pizza_size,
    pizza->>'crust' as pizza_crust
FROM pizzeria.order_items
WHERE order_id = 100;
```

**Listing 5.2 Filtering Data With -> and ->> Operators**
```sql                                                                      
SELECT
    order_id, order_item_id,
    pizza->'size' as pizza_size,
    pizza->>'crust' as pizza_crust
FROM pizzeria.order_items
WHERE 
    order_id = 100 AND
    pizza->'size' = '"small"' AND pizza->>'crust' = 'gluten_free';
```

**Listing 5.3 Chaining With -> Operator**
```sql                                                                          
SELECT
    order_id, order_item_id,
    pizza->'toppings'->'veggies' as veggies_toppings
FROM pizzeria.order_items
WHERE order_id = 100;
```

**Listing 5.4 Checking Field Key Existence**
```sql
SELECT
    order_id, order_item_id,
    pizza->'toppings'->'meats' as meats
FROM pizzeria.order_items
WHERE pizza->'toppings' ? 'meats'
ORDER BY order_id LIMIT 5;
```

**Listing 5.5 Checking Field Key Existence Within Array**     
```sql       
SELECT
    order_id, order_item_id,
    pizza->'toppings'->'meats' AS meats
FROM pizzeria.order_items
WHERE EXISTS (
    SELECT 1
    FROM jsonb_array_elements(pizza->'toppings'->'meats') AS meats
    WHERE meats ? 'sausage'
)
ORDER BY order_id LIMIT 5;
```

**Listing 5.6 Filtering data with @> operator**
```sql           
SELECT count(*) 
FROM pizzeria.order_items
WHERE pizza @> '{"crust": "gluten_free"}';
```

**Listing 5.7 Accessing nested fields with path expressions**
```sql             
SELECT 
    count(*) as total_cnt, 
    jsonb_path_query(pizza,'$.type') as pizza_type
FROM pizzeria.order_items
GROUP BY pizza_type ORDER BY total_cnt DESC;
```

**Listing 5.8 Querying JSON arrays with path expressions**
```sql           
SELECT 
    count(*) as total_cnt,
    jsonb_object_keys(
        jsonb_path_query(pizza, '$.toppings.cheese[*]')
    ) as cheese_topping
FROM pizzeria.order_items
GROUP BY cheese_topping ORDER BY total_cnt DESC;
```

**Listing 5.9 Using filters within path expressions**
```sql            
SELECT 
    count(*) AS total_cnt,
    pizza->'type' as pizza_type
FROM pizzeria.order_items
WHERE jsonb_path_exists(pizza, '$.toppings.cheese[*] ? (exists(@.parmesan))')
GROUP BY pizza_type
ORDER BY total_cnt DESC;
```

**Listing 5.10 Chaining multiple filter expressions**
```sql               
SELECT count(*)
FROM pizzeria.order_items
WHERE jsonb_path_exists(
    pizza,
    '$ ? (@.type == "custom") .toppings.cheese[*].parmesan ? (@ == "extra")'
);
```

**Listing 5.11 Updating JSON fields with jsonb_set**
```sql             
UPDATE pizzeria.order_items 
SET pizza = jsonb_set(pizza,'{crust}', '"regular"', false)
WHERE order_id = 20 and order_item_id = 5;
```

**Listing 5.12 Updating JSON arrays with jsonb_set**
```sql             
UPDATE pizzeria.order_items 
SET pizza = jsonb_set(
    pizza,
    '{toppings,veggies}',
   '[{"tomato":"extra"}, {"spinach":"regular"}]',
   false
)
WHERE order_id = 20 and order_item_id = 5;
```

**Listing 5.13 Deleting JSON fields with #- operator**
```sql           
UPDATE pizzeria.order_items
SET pizza = pizza #- '{toppings,meats}'
WHERE order_id = 20 AND order_item_id = 5;
```

**Listing 5.14 Creating expression index on JSON field**
```sql        
CREATE INDEX idx_pizza_type
ON pizzeria.order_items ((pizza ->> 'type'));
```

**Listing 5.15 Checking index details**
```sql             
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'pizzeria'
  AND tablename = 'order_items'
  AND indexdef LIKE '%idx_pizza_type%';
```

**Listing 5.16 Creating default GIN index**
```sql            
CREATE INDEX idx_pizza_orders_gin 
ON pizzeria.order_items USING GIN(pizza);
```

**Listing 5.17 Creating GIN index with jsonb_path_ops class**
```sql               
CREATE INDEX idx_pizza_orders_paths_ops_gin
ON pizzeria.order_items 
USING GIN (pizza jsonb_path_ops);
```

**Listing 5.18 Comparing size of GIN indexes**
```sql             
SELECT 
    c.relname AS index_name,
    pg_size_pretty(pg_relation_size(c.oid)) AS index_size
FROM pg_class c
JOIN pg_index i ON c.oid = i.indexrelid
WHERE c.relname IN ('idx_pizza_orders_paths_ops_gin', 'idx_pizza_orders_gin');
```






