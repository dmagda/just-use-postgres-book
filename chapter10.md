# Chapter 10, Postgres for geospatial

Code listings for Chapter 10, Postgres for geospatial.

**Listing 10.1 Starting Postgres with PostGIS on Unix with amd64**
```shell
mkdir ~/postgres-postgis-volume

docker run --name postgres-postgis \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-postgis-volume/:/var/lib/postgresql/data \
    -d postgis/postgis:17-3.5
```

**Listing 10.2 Starting Postgres with PostGIS on Mac with Apple Silicon**
```shell
mkdir ~/postgres-postgis-volume

docker run --platform linux/amd64 --name postgres-postgis \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-postgis-volume/:/var/lib/postgresql/data \
    -d postgis/postgis:17-3.5
```

**Listing 10.3 Starting Postgres with PostGIS on Windows**
```shell
docker run --name postgres-postgis `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v ${PWD}/postgres-postgis-volume/:/var/lib/postgresql/data `
    -d postgis/postgis:17-3.5
```

**Listing 10.4 Checking available PostGIS version**
```sql
SELECT * FROM pg_available_extensions
WHERE name = 'postgis';
```

**Listing 10.5 Preloading OSM dataset on Unix**
```shell
mkdir ~/osm2pgsql-volume

docker run --name osm2pgsql --network="host" \
 -e PGPASSWORD=password \
 -v ~/osm2pgsql-volume:/data \
 iboates/osm2pgsql:2.1.1 \
 -H 127.0.0.1 -P 5432 -d postgres -U postgres --schema florida \
 https://download.geofabrik.de/north-america/us/florida-250513.osm.pbf
```

**Listing 10.6 Preloading OSM dataset on Windows**
```shell
docker run --name osm2pgsql --network="host" `
 -e PGPASSWORD=password `
 -v ${PWD}:/data `
 iboates/osm2pgsql:2.1.1 `
 -H 127.0.0.1 -P 5432 -d postgres -U postgres --schema florida `
 https://download.geofabrik.de/north-america/us/florida-250513.osm.pbf
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
  || '&mlon=' || ST_X(coordinate) || '#map=12' AS osm_url
FROM tampa_city_point;
```









