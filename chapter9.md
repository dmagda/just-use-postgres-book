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
