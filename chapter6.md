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

