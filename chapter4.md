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

**Listing 4.11 Querying occasional player**
```sql
SELECT username, play_time, score, last_active
FROM game.player_stats
WHERE play_time <= '50 hours'
ORDER BY play_time;
```

**Listing 4.12 Creating partial index**
```sql
CREATE INDEX idx_occasional_players 
ON game.player_stats (play_time)
WHERE play_time <= '50 hours';
```

**Listing 4.13 Players list by performance margin**
```sql
SELECT username, win_count, loss_count, (win_count - loss_count) as margin 
FROM game.player_stats
WHERE (win_count - loss_count) BETWEEN 300 and 450
ORDER BY margin DESC;
```

**Listing 4.14 Creating expression index**
```sql
CREATE INDEX idx_perf_margin
ON game.player_stats ((win_count - loss_count));
```








