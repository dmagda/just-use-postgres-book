# Chapter 8, Postgres for generative AI

Code listings for Chapter 8, Postgres for generative AI.

**Preload sample dataset**

Note, if the Postgres container with the pgvector is not yet started on your end, then do this first using one of the following listings.
```shell
docker cp data/movie_pgvector/. postgres-pgvector:/home/.

docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_ddl.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_data.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/movies_phrases_data.sql"
```

**Listing 8.1 Starting Postgres with pgvector on Unix**
```shell
mkdir ~/postgres-pgvector-volume

docker run --name postgres-pgvector \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v ~/postgres-pgvector-volume/:/var/lib/postgresql/data \
    -d pgvector/pgvector:pg17
```

**Listing 8.2 Starting Postgres with pgvector on Windows**
```shell
docker run --name postgres-pgvector `
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password `
    -p 5432:5432 `
    -v ${PWD}/postgres-pgvector-volume/:/var/lib/postgresql/data `
    -d pgvector/pgvector:pg17
```

**Listing 8.3 Checking available pgvector version**
```sql
SELECT * FROM pg_available_extensions
WHERE name = 'vector';
```

**Listing 8.4 Pseudo-code for generating movie embeddings**
```javascript
# Fetch all movies from the database
movies = database.execute("SELECT id, name, description FROM omdb.movies")

# Iterate over each movie and generate the embedding
for each movie in movies:
    id = movie.id
    name = movie.name
    description = movie.description
    
    # Combine name and description for embedding
    combined_text = name + " " + description
    
    # Generate embedding using the model
    embedding = embedding_model.generate_embedding(combined_text)
    
    # Update the database with the generated embedding
    database.execute("
        UPDATE omdb.movies SET movie_embedding = ? WHERE id = ?", embedding, id)
```

**Listing 8.5 Performing vector similarity search with cosine distance**
```sql
SELECT id, name, description
FROM omdb.movies
ORDER BY movie_embedding <=> get_embedding('May the force be with you')
LIMIT 3;
```

**Listing 8.6 Adding cosine distance to query output**
```sql
WITH phrase AS (
  SELECT get_embedding('May the force be with you') AS embedding
)
SELECT id, name, description, m.movie_embedding <=> p.embedding AS distance
FROM omdb.movies m CROSS JOIN phrase p
ORDER BY distance LIMIT 3;
```

**Listing 8.7 Changing the search phrase to improve the result accuracy**
```sql
WITH phrase AS (
  SELECT get_embedding(
    'A movie about a Jedi who fights against the dark side of the force') AS embedding
)
SELECT id, name, description, m.movie_embedding <=> p.embedding AS distance
FROM omdb.movies m CROSS JOIN phrase p
ORDER BY distance LIMIT 3;
```

**Listing 8.8 Execution plan for similarity search query**
```sql
EXPLAIN (analyze, costs off)
SELECT id, name, description
FROM omdb.movies
ORDER BY movie_embedding <=> get_embedding('May the force be with you') 
LIMIT 3;
```

**Listing 8.9 Creating IVFFlat index**
```sql
CREATE INDEX movie_embeddings_ivfflat_idx 
ON omdb.movies 
USING ivfflat (movie_embedding vector_cosine_ops) WITH (lists = 5);
```

**Listing 8.10 Creating IVFFlat index**
```sql 
EXPLAIN (analyze, costs off)
SELECT id, name, description
FROM omdb.movies
ORDER BY movie_embedding <=> 
    (SELECT phrase_embedding
    FROM omdb.phrases_dictionary
    WHERE phrase = 'May the force be with you')
LIMIT 3;
```

**Listing 8.11 Increasing number of probes for IVFFlat index**
```sql
BEGIN;

SET LOCAL ivfflat.probes = 2;

SELECT id, name
FROM omdb.movies
ORDER BY movie_embedding <=> 
    (SELECT phrase_embedding
    FROM omdb.phrases_dictionary
    WHERE phrase = 'May the force be with you')
LIMIT 3;

COMMIT;
```

**Listing 8.12 Creating HNSW index**
```sql 
CREATE INDEX movie_embeddings_hnsw_idx 
ON omdb.movies 
USING hnsw (movie_embedding vector_cosine_ops)
WITH (m = 8, ef_construction = 32);
```

**Listing 8.13 Checking execution plan with HNSW index**
```sql 
EXPLAIN (analyze, costs off)
SELECT id, name
FROM omdb.movies
ORDER BY movie_embedding <=> 
    (SELECT phrase_embedding
    FROM omdb.phrases_dictionary
    WHERE phrase = 'May the force be with you')
LIMIT 3;
```

**Listing 8.14 Improving search accuracy with HNSW**
```sql
BEGIN;
SET LOCAL hnsw.ef_search = 50;

SELECT id, name
FROM omdb.movies
ORDER BY movie_embedding <=> 
    (SELECT phrase_embedding
    FROM omdb.phrases_dictionary
    WHERE phrase = 'A pirate captain who sails the seven seas in search of treasure')
LIMIT 3;

COMMIT;
```




