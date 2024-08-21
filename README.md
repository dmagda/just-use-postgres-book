# Just Use Postgres Book

Code listings for the "Just Use Postgres" book.


## Chapter 1, Meeting Postgres

**Listin 1.1 Starting Postgres Container in Docker**
```shell
docker run --name postgres \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-volume/:/var/lib/postgresql/data \
    -d postgres:latest
```
