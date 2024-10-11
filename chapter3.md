# Chapter 3, Modern SQL

Code listings for the Chapter 3, Modern SQL.

**Listing 3.1 Most Popular Songs**
```sql
WITH plays_cte AS ( 
    SELECT s.title, s.duration 
    FROM streaming.plays p
    JOIN streaming.songs s ON p.song_id = s.id
    WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
      AND p.play_duration = s.duration
)
SELECT title, COUNT(*) AS play_count 
FROM plays_cte
GROUP BY title
ORDER BY play_count DESC;
```

**Listing 3.2 Least Popular Songs**
```sql
WITH plays_cte AS (
    SELECT s.title, s.duration, p.play_duration
    FROM streaming.plays p
    JOIN streaming.songs s ON p.song_id = s.id
    WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
      AND p.play_duration < (s.duration / 2)
)
SELECT title, MIN(play_duration) AS min_play_duration
FROM plays_cte
GROUP BY title
ORDER BY min_play_duration ASC LIMIT 3;
```

**Listing 3.3 Least Popular Songs Across 3 and More Users**
```sql
WITH plays_cte AS ( 
    SELECT s.title, s.duration, p.play_duration, p.user_id
    FROM streaming.plays p
    JOIN streaming.songs s ON p.song_id = s.id
    WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
      AND p.play_duration < (s.duration / 2)
),
user_play_counts AS ( 
    SELECT title, duration, COUNT(DISTINCT user_id) AS user_count, MIN(play_duration) AS min_play_duration, COUNT(*) AS total_play_count
    FROM plays_cte
    GROUP BY title, duration
)
SELECT title, duration, min_play_duration, total_play_count 
FROM user_play_counts
WHERE user_count >= 3
ORDER BY min_play_duration ASC
LIMIT 3;
```

**Listing 3.4 Data-modifying CTE**
```sql
WITH updated_play AS (  
    UPDATE streaming.plays
    SET play_duration = 200 
    WHERE id = 30
    RETURNING song_id, play_duration
)
SELECT s.title, s.duration,
       CASE 
           WHEN up.play_duration = s.duration THEN 'Moved Up the Rank'
           ELSE 'Rank Not Changed'
       END AS rank_change_status
FROM updated_play up
JOIN streaming.songs s ON s.id = up.song_id;
```

**Listing 3.5 Querying and modifying CTEs executed concurrently**
```sql
WITH updated_play AS (
    UPDATE streaming.plays
    SET play_duration = 150 
    WHERE id = 12
    RETURNING song_id, play_duration
),
current_play_duration AS (
    SELECT song_id, (play_duration = 150) as is_change_visible_to_cte
    FROM streaming.plays
    WHERE id = 12
)
SELECT is_change_visible_to_cte, 
    (play_duration = 150) is_change_visible_to_primary
FROM updated_play up
JOIN current_play_duration cp ON up.song_id = cp.song_id;
```

**Listing 3.6 Querying and modifying CTEs executed sequentially**
```sql
WITH updated_play AS (
    UPDATE streaming.plays
    SET play_duration = 160
    WHERE id = 12
    RETURNING id, song_id, play_duration
),
current_play_duration AS (
    SELECT song_id, (play_duration = 160) as is_change_visible_to_cte
    FROM updated_play
    WHERE id = 12
)
SELECT is_change_visible_to_cte,
    (play_duration = 160) is_change_visible_to_primary
FROM updated_play up
JOIN current_play_duration cp ON up.song_id = cp.song_id;
```
