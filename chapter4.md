# Chapter 4, Indexes

Code listings for the Chapter 4, Indexes.

**Listing 4.1 Querying Index Details**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'game'
  AND tablename = 'player_stats'
  AND indexdef LIKE '%player_id%';
```
