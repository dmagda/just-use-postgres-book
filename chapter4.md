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

**Listing 4.6 Top gamer in each distinct region**
```sql
SELECT DISTINCT ON (region)
username, region, score, win_count
FROM game.player_stats
ORDER BY region, score DESC, win_count DESC;
```

**Listing 4.7 Regional players with specific score and wins count**
```sql
SELECT username, region, score, win_count
FROM game.player_stats
WHERE region = 'NA' and score > 5000 and win_count > 10
ORDER BY score DESC, win_count DESC;
```

**Listing 4.8 Creating composite index**
```sql
CREATE INDEX idx_region_score_win_count 
ON game.player_stats (region, score DESC, win_count DESC);
```

**Listing 4.9 Top regional players by wins count and score**
```sql
SELECT DISTINCT ON (region)
username, region, score, win_count
FROM game.player_stats
ORDER BY region, win_count DESC, score DESC;
```

**Listing 4.10 Creating covering index**
```sql
CREATE INDEX idx_composite_covering_index 
ON game.player_stats (region, score DESC, win_count DESC) INCLUDE (username);
```




