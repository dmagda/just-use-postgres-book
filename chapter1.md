# Chapter 1, Meeting Postgres

Code listings for the Chapter 1, Meeting Postgres.

**Listing 1.1 Starting Postgres container in Docker**
```shell
docker run --name postgres \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-volume/:/var/lib/postgresql/data \
    -d postgres:latest
```

For PowerShell on Windows, use this command instead:
```shell
docker run --name postgres `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v ${PWD}/postgres-volume:/var/lib/postgresql/data `
    -d postgres:latest
```

**Listing 1.2 Connecting with psql**
```shell
docker exec -it postgres psql -U postgres
```

**Listing 1.3 Creating sample table**
```sql
CREATE TABLE Trade(
    id bigint,
    buyer_id integer,
    symbol text,
    order_quantity integer,
    bid_price float,
    order_time timestamp
);
```

**Listing 1.4 Generating random buyers**
```sql
SELECT id, floor(1 + random() * 10) AS buyer_id 
FROM generate_series(1,5) AS id;
```

**Listing 1.5 Generating random stock symbols**
```sql
SELECT id, 
(array['AAPL','F','DASH'])[floor(1 + random() * 3)] AS symbol 
FROM generate_series(1,5) AS id;
```

**Listing 1.6 Inserting 1000 sample trades**
```sql
INSERT INTO trade (id, buyer_id, symbol, order_quantity, bid_price, order_time)
    SELECT
        id,
        floor(1 + random() * 10) as buyer_id,
        (array['AAPL','F','DASH'])[floor(1 + random() * 3)] as symbol,
        floor(1 + random() * 20) as order_quantity,
        round((10 + random() * 10)::numeric, 2) as bid_price,
        now() as order_time
    FROM generate_series(1,1000) AS id;
```

**Listing 1.7 Most traded stocks by volume**
```sql
SELECT symbol, count(order_quantity) AS total_volume
FROM trade
GROUP BY symbol
ORDER BY total_volume DESC;
```

**Listing 1.8 Top three buyers**
```sql
SELECT buyer_id, sum(bid_price * order_quantity) AS total_value
FROM trade
GROUP BY buyer_id
ORDER BY total_value DESC
LIMIT 3;
```
