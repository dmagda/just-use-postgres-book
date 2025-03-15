# Chapter 8, Postgres for AI

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

Preload sample data:
```shell
docker cp data/movie_pgvector/omdb_movies_pgvector_ddl.sql postgres-pgvector:/home/.
docker cp data/movie_pgvector/omdb_movies_pgvector_data.sql postgres-pgvector:/home/.
docker cp data/movie_pgvector/omdb_movies_pgvector_phrases_data.sql postgres-pgvector:/home/.

docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_pgvector_ddl.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_pgvector_data.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/omdb_movies_pgvector_phrases_data.sql"
```