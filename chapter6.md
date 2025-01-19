# Chapter 6, Full-Text Search

Code listings for Chapter 6, Full-Text Search.

**Listing 6.1 Analyzing tokenization and normalization with ts_debug**
```sql
SELECT token, description, lexemes, dictionary
FROM ts_debug('5 explorers are travelling to a distant galaxy');
```

**Listing 6.2 Using Russian configuration for full-text search**
```sql
SELECT token, description, lexemes, dictionary
FROM ts_debug('russian', '5 исследователей путешествуют к далёкой галактике.');
```

**Listing 6.3 Using to_tsvector function**
```sql
SELECT * FROM to_tsvector(
    'The explorers must save the fragile peace between Earth and the aliens.');
```

**Listing 6.4 Using to_tsvector function for concatenated text string**
```sql
SELECT * FROM to_tsvector(
    'Space Explorers' ||
    ' ' ||
    'The explorers must save the fragile peace between Earth and the aliens.');
```

**Listing 6.5 Generating lexemes for title and description separately**
```sql
SELECT title_lexemes, description_lexemes FROM 
  to_tsvector('Space Explorers') as title_lexemes,
  to_tsvector(
    'The explorers must save the fragile peace between Earth and the aliens.'
    ) as description_lexemes;
```

**Listing 6.6 Adding stored generated column for lexemes**
```sql
ALTER TABLE omdb.movies
ADD COLUMN lexemes tsvector 
GENERATED ALWAYS AS (
  to_tsvector(
    'english', coalesce(name, '') || 
    ' ' || 
    coalesce(description, ''))) STORED;
```

