# Chapter 5, JSON

Code listings for the Chapter 5, JSON.

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

