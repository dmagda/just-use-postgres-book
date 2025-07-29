# Chapter 1, Meeting Postgres

Code listings for the Chapter 1, Meeting Postgres.

**Listing 1.1 Starting Postgres container on Unix**
```shell
mkdir ~/postgres-volume

docker run --name postgres \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-volume/:/var/lib/postgresql/data \
    -d postgres:17.2
```

**Listing 1.2 Starting Postgres container on Windows**
```shell
docker run --name postgres `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v ${PWD}/postgres-volume:/var/lib/postgresql/data `
    -d postgres:17.2
```

**Listing 1.3 Connecting with psql**
```shell
docker exec -it postgres psql -U postgres
```

**Listing 1.4 Creating sample table**
```sql
CREATE TABLE trades(
    id bigint,
    buyer_id integer,
    symbol text,
    order_quantity integer,
    bid_price numeric(5,2),
    order_time timestamp
);
```

**Listing 1.5 Generating random buyers**
```sql
SELECT id, random(1,10) AS buyer_id 
FROM generate_series(1,5) AS id;
```

**Listing 1.6 Generating random stock symbols**
```sql
SELECT id, 
(array['AAPL','F','DASH'])[random(1,3)] AS symbol 
FROM generate_series(1,5) AS id;
```

**Listing 1.7 Inserting 1000 sample trades**
```sql
INSERT INTO trades (id, buyer_id, symbol, order_quantity, bid_price, order_time)
    SELECT
        id,
        random(1,10) as buyer_id,
        (array['AAPL','F','DASH'])[random(1,3)] as symbol,
        random(1,20) as order_quantity,
        round(random(10.00,20.00), 2) as bid_price,
        now() as order_time
    FROM generate_series(1,1000) AS id;
```

**Listing 1.8 Most traded stocks by volume**
```sql
SELECT symbol, count(*) AS total_volume
FROM trades
GROUP BY symbol
ORDER BY total_volume DESC;
```

**Listing 1.9 Top three buyers**
```sql
SELECT buyer_id, sum(bid_price * order_quantity) AS total_value
FROM trades
GROUP BY buyer_id
ORDER BY total_value DESC
LIMIT 3;
```
