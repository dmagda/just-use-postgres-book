# Chapter 9, Postgres for time series

Code listings for Chapter 9, Postgres for time series.

**Listing 9.1 Starting Postgres with TimescaleDB on Unix**
```shell
docker volume create postgres-timescale-volume

docker run --name postgres-timescale \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v postgres-timescale-volume:/var/lib/postgresql/data \
    -d timescale/timescaledb:2.19.2-pg17
```

**Listing 9.2 Starting Postgres with TimescaleDB on Windows**
```shell
docker volume create postgres-timescale-volume

docker run --name postgres-timescale `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v postgres-timescale-volume:/var/lib/postgresql/data `
    -d timescale/timescaledb:2.19.2-pg17
```

**Listing 9.3 Checking available TimescaleDB version**
```sql
SELECT * FROM pg_available_extensions
WHERE name = 'timescaledb';
```

**Prealoading dataset**
```shell
docker cp data/smartwatch/. postgres-timescale:/home/.

docker exec -it postgres-timescale psql -U postgres -c "\i /home/schema.sql"
docker exec -it postgres-timescale psql -U postgres -c  "\i /home/data.sql"
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

**Listing 9.6 Calculating average and max heart rates during workouts**
```sql
SELECT
  time_bucket('10 minutes', recorded_at) AS period, activity,
  AVG(heart_rate)::int AS avg_rate, MAX (heart_rate)::int AS max_rate
FROM watch.heart_rate_measurements
WHERE watch_id = 1 AND activity = 'workout' 
  AND recorded_at >= '2025-04-23' AND recorded_at < '2025-04-24'
GROUP BY period, activity ORDER BY period;
```

**Listing 9.7 Calculating weekly summary for every type of activity**
```sql
SELECT
  time_bucket('1 week', recorded_at) AS period, activity,
  AVG(heart_rate)::int AS avg_rate, 
  MAX (heart_rate)::int AS max_rate, MIN (heart_rate)::int AS min_rate
FROM watch.heart_rate_measurements
WHERE watch_id = 1 AND recorded_at >= '2025-04-01' AND recorded_at < '2025-04-15'
GROUP BY period, activity ORDER BY period, activity;
```

**Listing 9.8 Changing time origin for the weekly summary**
```sql
SELECT
  time_bucket('1 week', recorded_at, '2025-04-01'::timestamptz) AS period, activity,
  AVG(heart_rate)::int AS avg_rate, 
  MAX (heart_rate)::int AS max_rate, MIN (heart_rate)::int AS min_rate
FROM watch.heart_rate_measurements
WHERE watch_id = 1 AND recorded_at >= '2025-04-01' AND recorded_at < '2025-04-15'
GROUP BY period, activity ORDER BY period, activity;
```

**Listing 9.9 Setting user specific time zone for calculation and output**
```sql
BEGIN;

SET LOCAL time zone 'Asia/Tokyo';

SELECT
  time_bucket('1 week', recorded_at, 'Asia/Tokyo', '2025-04-01'::timestamptz) AS period, activity,
  AVG(heart_rate)::int AS avg_rate, 
  MAX (heart_rate)::int AS max_rate, MIN (heart_rate)::int AS min_rate
FROM watch.heart_rate_measurements
WHERE watch_id = 2 AND recorded_at >= '2025-04-01' AND recorded_at < '2025-04-15'
GROUP BY period, activity ORDER BY period, activity;

COMMIT;
```

**Listing 9.10 Observing gaps in time buckets**
```sql
SELECT watch_id, time_bucket('1 minute', recorded_at) AS minute,
    AVG(heart_rate)::int AS avg_rate
FROM watch.heart_rate_measurements
WHERE watch_id=1 AND recorded_at BETWEEN '2025-03-02 07:25' AND '2025-03-02 07:36'
GROUP BY watch_id, minute ORDER BY minute;
```

**Listing 9.11 Adding gaps to time buckets**
```sql
SELECT watch_id, time_bucket_gapfill('1 minute', recorded_at) AS minute,
    AVG(heart_rate)::int AS avg_rate
FROM watch.heart_rate_measurements
WHERE watch_id=1 AND recorded_at BETWEEN '2025-03-02 07:25' AND '2025-03-02 07:36'
GROUP BY watch_id, minute ORDER BY minute;
```

**Listing 9.12 Filling gaps with LOCF function**
```sql
SELECT watch_id, time_bucket_gapfill('1 minute', recorded_at) AS minute,
    LOCF(AVG(heart_rate)::int) AS avg_rate
FROM watch.heart_rate_measurements
WHERE watch_id=1 AND recorded_at BETWEEN '2025-03-02 07:25' AND '2025-03-02 07:36'
GROUP BY watch_id, minute ORDER BY minute;
```

**Listing 9.13 Filling gaps with interpolate function**
```sql
SELECT watch_id, time_bucket_gapfill('1 minute', recorded_at) AS minute,
    interpolate(AVG(heart_rate)::int) AS avg_rate
FROM watch.heart_rate_measurements
WHERE watch_id=1 AND recorded_at BETWEEN '2025-03-02 07:25' AND '2025-03-02 07:36'
GROUP BY watch_id, minute ORDER BY minute;
```

**Listing 9.14 Creating continuous aggregate**
```sql
CREATE MATERIALIZED VIEW watch.low_heart_rate_count_per_5min
WITH (timescaledb.continuous) AS
SELECT
  watch_id,
  time_bucket('5 minutes', recorded_at) AS bucket,
  MIN(heart_rate) as min_rate,
  COUNT(*) FILTER (WHERE heart_rate < 50) AS low_rate_count,
  COUNT(*) AS total_measurements
FROM watch.heart_rate_measurements
GROUP BY watch_id, bucket;
```

**Listing 9.15 Querying continuous aggregate**
```sql
SELECT 
  bucket, low_rate_count, 
  (low_rate_count >= 5) AS bradycardia_detected
FROM watch.low_heart_rate_count_per_5min
WHERE bucket = '2025-11-30 02:35' AND watch_id = 3;
```

**Listing 9.16 Getting data for 15 minutes window**
```sql
SELECT 
  bucket, low_rate_count, 
  (low_rate_count >= 5) AS bradycardia_detected
FROM watch.low_heart_rate_count_per_5min
WHERE bucket BETWEEN '2025-11-30 02:35' AND '2025-11-30 02:45' AND watch_id = 3
ORDER BY bucket;
```

**Listing 9.17 Inserting new heart beat measurements**
```sql
INSERT INTO watch.heart_rate_measurements 
(watch_id, recorded_at, heart_rate, activity) VALUES
(3, '2025-12-01 00:45:00+00', 48, 'sleeping'),
(3, '2025-12-01 00:46:00+00', 46, 'sleeping'),
(3, '2025-12-01 00:47:00+00', 44, 'sleeping'),
(3, '2025-12-01 00:47:30+00', 47, 'sleeping'),
(3, '2025-12-01 00:48:00+00', 48, 'sleeping'),
(3, '2025-12-01 00:48:30+00', 45, 'sleeping'),
(3, '2025-12-01 00:49:00+00', 43, 'sleeping');
```

**Listing 9.18 Defining refresh policy for continuous aggregate**
```sql
SELECT add_continuous_aggregate_policy('watch.low_heart_rate_count_per_5min',
  start_offset => INTERVAL '15 minutes',
  end_offset => INTERVAL '1 minute',
  schedule_interval => INTERVAL '1 minute');
```

**Listing 9.19 Refreshing aggregate manually**
```sql
CALL refresh_continuous_aggregate('watch.low_heart_rate_count_per_5min',
    '2025-12-01 00:45:00+00', '2025-12-01 00:50:00+00');
```

**Listing 9.20 Checking existing indexes on table**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'watch' AND tablename = 'heart_rate_measurements';
```

**Listing 9.21 Calculating average heart rate during walking**
```sql
SELECT 
  time_bucket('1 hour', recorded_at) AS period,
  AVG(heart_rate)::int AS avg_rate
FROM watch.heart_rate_measurements
WHERE activity = 'walking' AND watch_id = 1
  AND recorded_at >= '2025-03-15 00:00' 
  AND recorded_at < '2025-03-16 00:00'
GROUP BY period ORDER BY period;
```

**Listing 9.22 Creating composite index**
```sql
CREATE INDEX heart_rate_btree_idx
ON watch.heart_rate_measurements (recorded_at, watch_id);
```

**Listing 9.23 Checking indexes created on partitions**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = '_timescaledb_internal'
  AND tablename LIKE '_hyper_1\_%_chunk' ESCAPE '\';
```

**Listing 9.24 Creating BRIN index**
```sql
CREATE INDEX heart_rate_brin_idx
ON watch.heart_rate_measurements
USING brin (recorded_at);
```

**Listing 9.25 Comparing size of B-tree and BRIN indexes**
```sql
SELECT
  i.indexrelid::regclass AS index_name,
  pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size
FROM timescaledb_information.chunks c
JOIN pg_index i
  ON i.indrelid = format('%I.%I', c.chunk_schema, c.chunk_name)::regclass
WHERE c.hypertable_name = 'heart_rate_measurements'
ORDER BY index_name;
```

**Listing 9.26 Execution plan for average sleeping heart rate calculation**
```sql
EXPLAIN (analyze, costs off)
SELECT 
  time_bucket('1 hour', recorded_at) AS period,
  AVG(heart_rate)::int AS avg_rate
FROM watch.heart_rate_measurements
WHERE activity = 'sleeping'
  AND recorded_at >= '2025-03-15 00:00' 
  AND recorded_at < '2025-03-16 00:00'
GROUP BY period ORDER BY period;
```
















