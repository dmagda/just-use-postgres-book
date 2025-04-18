# Chapter 9, Postgres for time series

Code listings for Chapter 9, Postgres for time series.

**Listing 9.1 Starting Postgres with TimescaleDB on Unix**
```shell
mkdir ~/postgres-timescaledb-volume

docker run --name postgres-timescaledb \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-timescaledb-volume/:/var/lib/postgresql/data \
    -d timescale/timescaledb:latest-pg17
```

**Listing 9.2 Starting Postgres with TimescaleDB on Windows**
```shell
docker run --name postgres-timescaledb `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v ${PWD}/postgres-timescaledb-volume/:/var/lib/postgresql/data `
    -d timescale/timescaledb:latest-pg17
```

**Listing 9.3 Checking available TimescaleDB version**
```sql
SELECT * FROM pg_available_extensions
WHERE name = 'timescaledb';
```

**Prealoading dataset**
```shell
docker cp data/smartwatch/. postgres-timescaledb:/home/.

docker exec -it postgres-timescaledb psql -U postgres -c "\i /home/smartwatch_ddl.sql"
docker exec -it postgres-timescaledb psql -U postgres -c "\i /home/smartwatch_data.sql"
```

**Listing 9.4 Number of measurements per user device**
```sql
SELECT watch_id, count(*) as total_measurements
FROM watch.heart_rate_measurements
GROUP BY watch_id ORDER BY watch_id;
```

**Listing 9.5 Time-series sequence for a specific period**
```sql
SELECT watch_id, recorded_at, heart_rate, activity
FROM watch.heart_rate_measurements
WHERE watch_id = 1 AND
  recorded_at BETWEEN '2025-01-01 06:50:00' AND '2025-01-01 06:55:00'
ORDER BY recorded_at;
```

