# Chapter 8, Postgres for generative AI

Code listings for Chapter 8, Postgres for generative AI.

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

**Preload sample dataset**

```shell
docker cp data/movie_pgvector/. postgres-pgvector:/home/.

docker exec -it postgres-pgvector psql -U postgres -c "\i /home/schema.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/movies.sql"
docker exec -it postgres-pgvector psql -U postgres -c "\i /home/phrases.sql"
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
ORDER BY movie_embedding <=> omdb.get_embedding('May the force be with you')
LIMIT 3;
```

**Listing 8.6 Adding cosine distance to query output**
```sql
WITH phrase AS (
  SELECT omdb.get_embedding('May the force be with you') AS embedding
)
SELECT id, name, description, m.movie_embedding <=> p.embedding AS distance
FROM omdb.movies m CROSS JOIN phrase p
ORDER BY distance LIMIT 3;
```

**Listing 8.7 Changing the search phrase to improve the result accuracy**
```sql
WITH phrase AS (
  SELECT omdb.get_embedding(
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
ORDER BY movie_embedding <=> omdb.get_embedding('May the force be with you') 
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
    WHERE phrase = 'A movie about a Jedi who fights against the dark side of the force')
LIMIT 3;

COMMIT;
```

**Listing 8.15 Answering user questions using LLM and provided context**
```python 
def answer_question(question, context):
    # Connecting to the tinyllama model with the LangChain Ollama interface
    llm = OllamaLLM(model="tinyllama", temperature=0.6)

    # Generating a final prompt for the LLM based considering the provided context
    prompt = f"""
    You're a movie expert and your task is to answer questions about movies based on the provided context.

    This is the user's question: {question}  
    Consider the following context to provide a detailed and accurate answer: {context}  

    The context includes the following details for each movie:
    - "Title" of the movie
    - "Vote Average" - the average rating of the movie
    - "Budget" - the budget allocated for the movie in the US dollars
    - "Revenue" - the total revenue generated by the movie in the US dollars
    - "Release Date" - the date the movie was released

    Respond in an engaging style that inspires the user to watch the movies.
    """
    
    # Invoke the LLM passing the prompt. The LLM will generate a response.
    response = llm.invoke(prompt)
    return response
```

**Listing 8.16 Retrieving context from Postgres**
```python   
def retrieve_context_from_postgres(question):
    # Connect to the Postgres intance with the pgvector extension
    db_params = {
    "host": "localhost",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres",
    "password": "password"
    }
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Connect to the embedding model using the OllamaEmbeddings interface
    embedding_model = OllamaEmbeddings(model="mxbai-embed-large:335m")

    # Generate the embedding for the user's question
    embedding = embedding_model.embed_query(question)

    # Perform vector similarity search to find relevant movies
    query = """
    SELECT name, vote_average, budget, revenue, release_date
    FROM omdb.movies
    ORDER BY movie_embedding <=> %s::vector LIMIT 3
    """
    
    cursor.execute(query, (embedding, ))
    
    context = ""

    # Generate context from the retrieved rows
    for row in cursor.fetchall():
        context += f"Movie title: {row[0]}, Vote Average: {row[1]}"
        context += f", Budget: {row[2]}, Revenue: {row[3]}, Release Date: {row[4]}\n"

    cursor.close()
    conn.close()

    return context
```

**Listing 8.17 Using RAG to answer user questions**
```python  
# Prepare a sample question.
question = f"I'd like to watch the best movies about pirates. Any suggestions?"

# Retrieve context from Postgres based on the user's question
context = retrieve_context_from_postgres(question)

print("Context from Postgres:")
print(context)

# Use the context to answer the user's question using the LLM
answer = answer_question(question, context)

print("LLM's answer:")
print(answer)
```



