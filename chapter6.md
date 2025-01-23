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

**Listing 6.7 Executing first full-text search query**
```sql
SELECT id, name 
FROM omdb.movies
WHERE lexemes @@ plainto_tsquery('a computer animated film');
```

**Listing 6.8 Using combination of AND and OR operators**
```sql
SELECT id, name 
FROM omdb.movies
WHERE lexemes @@ to_tsquery('computer & animated & (lion | clownfish | donkey)');
```

**Listing 6.9 Using the NOT operator and filtering by phrase**
```sql
SELECT id, name 
FROM omdb.movies
WHERE lexemes @@ to_tsquery('lion & !''The Lion King''');
```

**Listing 6.10 Returning movies containing word “ghosts”**
```sql
SELECT id, name, vote_average
FROM omdb.movies
WHERE lexemes @@ to_tsquery('ghosts')
ORDER BY vote_average DESC NULLS LAST LIMIT 10;
```



