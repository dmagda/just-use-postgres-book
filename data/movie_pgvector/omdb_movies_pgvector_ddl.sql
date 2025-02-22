CREATE EXTENSION IF NOT EXISTS vector;

CREATE SCHEMA omdb;

CREATE TABLE omdb.movies (
    id BIGINT PRIMARY KEY, 
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    movie_embedding VECTOR(1024),
    release_date DATE, 
    runtime INT, 
    budget NUMERIC, 
    revenue NUMERIC, 
    vote_average NUMERIC, 
    votes_count BIGINT
);

CREATE TABLE omdb.phrases_dictionary ( 
    phrase TEXT NOT NULL,
    phrase_embedding VECTOR(1024)
);

CREATE OR REPLACE FUNCTION get_embedding(input_phrase TEXT)
RETURNS VECTOR(1024) AS $$
DECLARE
    embedding VECTOR(1024);
BEGIN
    SELECT phrase_embedding INTO embedding
    FROM omdb.phrases_dictionary
    WHERE LOWER(phrase) = LOWER(input_phrase);
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    RETURN embedding;
END;
$$ LANGUAGE plpgsql;