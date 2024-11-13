# Chapter 4, Indexes

Code listings for the Chapter 4, Indexes.

**Listing 4.1 Primary Index Details**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'game'
  AND tablename = 'player_stats'
  AND indexdef LIKE '%player_id%';
```

**Listing 4.2 Score Index Details**
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'game'
  AND tablename = 'player_stats'
  AND indexdef LIKE '%idx_score%';
```

**Listing 4.3 Players Leaderboard**
```sql
SELECT username, score, level 
FROM game.player_stats 
ORDER BY score DESC 
LIMIT 5;
```

