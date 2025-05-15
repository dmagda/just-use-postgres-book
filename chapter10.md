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

