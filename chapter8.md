# Chapter 8, Postgres for AI

TBD

Preload sample data:
```shell
docker cp data/movie_pgvector/omdb_movies_pgvector_ddl.sql postgres-pgvector:/home/.
docker cp data/movie_pgvector/omdb_movies_pgvector_data.sql postgres-pgvector:/home/.
docker cp data/movie_pgvector/omdb_movies_pgvector_phrases_data.sql postgres-pgvector:/home/.

docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_pgvector_ddl.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_pgvector_data.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_pgvector_phrases_data.sql"
```