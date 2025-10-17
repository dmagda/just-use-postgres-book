# Chapter 10, Postgres for geospatial

Code listings for Chapter 10, Postgres for geospatial.

**Listing 10.1 Starting Postgres with PostGIS on Unix with amd64**
```shell
docker volume create postgres-postgis-volume

docker run --name postgres-postgis \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v postgres-postgis-volume:/var/lib/postgresql/data \
    -d postgis/postgis:17-3.5
```

**Listing 10.2 Starting Postgres with PostGIS on Mac with Apple Silicon**
```shell
docker volume create postgres-postgis-volume

docker run --platform linux/amd64 --name postgres-postgis \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v postgres-postgis-volume:/var/lib/postgresql/data \
    -d postgis/postgis:17-3.5
```

**Listing 10.3 Starting Postgres with PostGIS on Windows**
```shell
docker volume create postgres-postgis-volume

docker run --name postgres-postgis `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v postgres-postgis-volume:/var/lib/postgresql/data `
    -d postgis/postgis:17-3.5
```

**Listing 10.4 Checking available PostGIS version**
```sql
SELECT * FROM pg_available_extensions
WHERE name = 'postgis';
```

**Listing 10.5 Preloading OSM dataset on Unix**
```shell
docker volume create osm2pgsql-volume

docker run --name osm2pgsql --network="host" \
 -e PGPASSWORD=password \
 -v osm2pgsql-volume:/data \
 iboates/osm2pgsql:2.1.1 \
 -H 127.0.0.1 -P 5432 -d postgres -U postgres --schema florida \
 http://d3e4uq6jj8ld3m.cloudfront.net/florida-250501.osm.pbf
```

**Listing 10.6 Preloading OSM dataset on Windows**
```shell
docker volume create osm2pgsql-volume

docker run --name osm2pgsql --network="host" `
 -e PGPASSWORD=password `
 -v osm2pgsql-volume:/data `
 iboates/osm2pgsql:2.1.1 `
 -H 127.0.0.1 -P 5432 -d postgres -U postgres --schema florida `
 http://d3e4uq6jj8ld3m.cloudfront.net/florida-250501.osm.pbf
```

**Listing 10.7 Listing tables created for dataset**
```sql
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'florida';
```

**Listing 10.8 Getting coordinates for three stores**
```sql
SELECT name, shop, way as WKB, ST_AsText(way) as WKT
FROM florida.planet_osm_point
WHERE name = 'Whole Foods Market' LIMIT 3;
```

**Listing 10.9 Getting shortest named ways**
```sql
SELECT name, ST_AsText(way)
FROM florida.planet_osm_line 
WHERE name IS NOT NULL
ORDER BY ST_Length(way) ASC LIMIT 3;
```

**Listing 10.10 Getting shortest named regions**
```sql
SELECT name, ST_AsText(way)
FROM florida.planet_osm_polygon 
WHERE name IS NOT NULL
ORDER BY ST_Area(way) ASC LIMIT 3;
```

**Listing 10.11 Searching for center of Tampa**
```sql
SELECT name, ST_AsText(way) AS coordinates
FROM florida.planet_osm_point
WHERE name = 'Tampa' and place = 'city';
```

**Listing 10.12 Transforming coordinates to latitude and longitude**
```sql
SELECT name, ST_AsText(ST_Transform(way, 4326)) AS coordinates 
FROM florida.planet_osm_point
WHERE name = 'Tampa' and place = 'city';
```

**Listing 10.13 Generating URL for OpenStreetMaps**
```sql
WITH tampa_city_point AS (
  SELECT ST_Transform(way, 4326) AS coordinate
  FROM florida.planet_osm_point
  WHERE name = 'Tampa' AND place = 'city'
)
SELECT 'https://www.openstreetmap.org/?mlat=' || ST_Y(coordinate)
  || '&mlon=' || ST_X(coordinate) AS osm_url
FROM tampa_city_point;
```

**Listing 10.14 Finding closest restaurants**
```sql
WITH roost_hotel AS (
  SELECT way FROM florida.planet_osm_point
  WHERE name = 'Roost Apartment Hotel' AND tourism='hotel'
)
SELECT p.name, p.amenity,
  round(ST_Distance(h.way,p.way)) as distance_meters,
  round(ST_Distance(h.way,p.way) * 3.28) as distance_feet
FROM roost_hotel as h 
JOIN florida.planet_osm_point AS p
  ON ST_DWithin(h.way, p.way, 500)
WHERE p.amenity = 'restaurant'
ORDER BY distance_meters LIMIT 5;
```

**Listing 10.15 Finding nearest restaurants to provided coordinates**
```sql 
WITH roost_hotel AS (
  SELECT ST_SetSRID(
    ST_MakePoint(-9178356.224987695, 3242002.0503882724), 3857) as point
)
SELECT p.name, p.amenity,
  round(ST_Distance(h.point,p.way)) as distance_meters,
  round(ST_Distance(h.point,p.way) * 3.28) as distance_feet
FROM roost_hotel as h 
JOIN florida.planet_osm_point AS p
  ON ST_DWithin(h.point, p.way, 500)
WHERE p.amenity = 'restaurant'
ORDER BY distance_meters LIMIT 5;
```

**Listing 10.16 Finding polygon and number of points it’s made of**
```sql 
SELECT name, tourism, ST_NPoints(way)
FROM florida.planet_osm_polygon
WHERE name = 'Walt Disney World';
```

**Listing 10.17 Calculating area of Walt Disney World**
```sql
SELECT name, tourism,
  ST_Area(way) / 1000000.0 AS area_sq_km,
  ST_Area(way) / 4046.86 AS area_acres
FROM florida.planet_osm_polygon
WHERE name = 'Walt Disney World';
```

**Listing 10.18 Finding distinct parks within Walt Disney World**
```sql
WITH disney_world AS (
  SELECT way AS boundaries
  FROM florida.planet_osm_polygon
  WHERE name = 'Walt Disney World'
)
SELECT p.name, p.tourism
FROM florida.planet_osm_polygon AS p
JOIN disney_world AS d ON ST_Within(p.way, d.boundaries)
WHERE p.name IS NOT NULL 
  AND p.tourism = 'theme_park'
  AND NOT ST_Equals(p.way, d.boundaries)
ORDER BY p.name;
```

**Listing 10.19 Finding attractions within Disney’s Hollywood Studios**
```sql
WITH disney_world AS (
  SELECT way AS boundaries 
  FROM florida.planet_osm_polygon
  WHERE name = 'Disney''s Hollywood Studios'
)
SELECT p.name, p.tourism
FROM florida.planet_osm_polygon AS p
JOIN disney_world AS d ON ST_Within(p.way, d.boundaries)
WHERE p.name is NOT NULL AND p.tourism = 'attraction';
```

**Listing 10.20 Finding all amenities within Disney's Hollywood Studios**
```sql  
WITH disney_world AS (
  SELECT way AS boundaries 
  FROM florida.planet_osm_polygon
  WHERE name = 'Disney''s Hollywood Studios'
)
SELECT p.name, p.amenity
FROM florida.planet_osm_point AS p
JOIN disney_world AS d ON ST_Within(p.way, d.boundaries)
WHERE p.name IS NOT NULL AND p.amenity IS NOT NULL;
```

**Listing 10.21 Finding top ten types of roads**
```sql  
SELECT highway, count(highway) AS total_count
FROM florida.planet_osm_line
WHERE highway IS NOT NULL
GROUP BY highway ORDER BY total_count DESC LIMIT 10;
```

**Listing 10.22 Finding top ten roads within or crossing Miami**
```sql  
WITH miami AS (
  SELECT way AS boundaries
  FROM florida.planet_osm_polygon
  WHERE name = 'Miami' AND place = 'city'
)
SELECT l.name, l.highway, 
  ST_NPoints(l.way) AS points_number,
  round(ST_Length(l.way)) AS len_meters,
  round(ST_Length(l.way) * 3.28084) AS len_feet
FROM florida.planet_osm_line l
JOIN miami m ON ST_Intersects(l.way, m.boundaries)  
WHERE l.highway IN ('primary', 'secondary')
ORDER BY len_meters DESC LIMIT 10;
```

**Listing 10.23 Finding ten closest shops near Brickell City Centre**
```sql  
WITH brickell AS (
  SELECT way FROM florida.planet_osm_point
  WHERE name = 'Brickell City Centre' and railway = 'station'
)
SELECT p.name, p.shop,
  round(ST_Distance(b.way,p.way)) as distance_meters,
  round(ST_Distance(b.way,p.way) * 3.28) as distance_feet
FROM brickell as b
JOIN florida.planet_osm_point AS p
  ON ST_DWithin(b.way, p.way, 500)
WHERE p.shop IS NOT NULL
ORDER BY distance_meters LIMIT 10;
```

**Listing 10.24 Checking a list of existing indexes**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'florida' AND tablename LIKE 'planet_osm_%';
```

**Listing 10.25 Creating B-tree index on name column**
```sql  
CREATE INDEX florida_point_name_idx 
ON florida.planet_osm_point(name) 
WHERE name IS NOT NULL;
```

**Listing 10.26 Checking execution plan using GiST index**
```sql  
EXPLAIN (analyze, costs off)
WITH brickell AS (
  SELECT way FROM florida.planet_osm_point
  WHERE name = 'Brickell City Centre' and railway = 'station'
)
SELECT p.name, p.shop,
  round(ST_Distance(b.way,p.way)) as distance_meters,
  round(ST_Distance(b.way,p.way) * 3.28) as distance_feet
FROM brickell as b
JOIN florida.planet_osm_point AS p
  ON ST_DWithin(b.way, p.way, 500)
WHERE p.shop IS NOT NULL
ORDER BY distance_meters LIMIT 10;
```

**Listing 10.27 Checking execution plan with ST_Distance**
```sql 
EXPLAIN (analyze, costs off)
WITH brickell AS (
  SELECT way FROM florida.planet_osm_point
  WHERE name = 'Brickell City Centre' and railway = 'station'
)
SELECT p.name, p.shop,
  round(ST_Distance(b.way,p.way)) as distance_meters,
  round(ST_Distance(b.way,p.way) * 3.28) as distance_feet
FROM brickell as b
JOIN florida.planet_osm_point AS p
  ON ST_Distance(b.way, p.way) <= 500
WHERE p.shop IS NOT NULL
ORDER BY distance_meters LIMIT 10;
```











