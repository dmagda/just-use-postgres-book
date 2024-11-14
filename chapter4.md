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

**Listing 4.4 Creating Hash Index**
```sql
CREATE INDEX idx_champion_title 
ON game.player_stats 
USING hash(champion_title);
```

**Listing 4.5 Getting All Champions**
```sql
SELECT username, champion_title, score, level 
FROM game.player_stats 
WHERE champion_title IN (
  'Airforce Warlord', 'Naval Warlord',
  'Land Warlord', 'Cyber Warlord',
  'Space Warlord');
```
