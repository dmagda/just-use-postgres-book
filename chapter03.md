# Chapter 3, Modern SQL

Code listings for the Chapter 3, Modern SQL.

**Preload sample dataset**
```shell
docker cp data/streaming/. postgres:/home/.

docker exec -it postgres psql -U postgres -c "\i /home/music_streaming_ddl.sql"
docker exec -it postgres psql -U postgres -c "\i /home/music_streaming_data.sql"
```

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
    (play_duration = 150) as is_change_visible_to_primary
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
    (play_duration = 160) as is_change_visible_to_primary
FROM updated_play up
JOIN current_play_duration cp ON up.song_id = cp.song_id;
```

**Listing 3.7 Recursive query execution flow in pseudo-code**
```javascript
// Step 1: Evaluate the non-recursive term, which is a SQL query defined 
// at the beginning of the recursive CTE and executed only once.
non_recursive_result = execute(non_recursive_term); 
						
// Step 2: Remove duplicates, if UNION is used
// Skip if the UNION ALL is used instead.
if (using UNION)
    non_recursive_result = remove_duplicates(non_recursive_result);
					    
// Step 3: Add the non-recursive result to the final result set
final_result.add(non_recursive_result);
					
// Step 4: Initialize the working table with the non-recursive result
working_table = non_recursive_result;
					
// Step 5: Execute the recursive term until the working table is not empty
// The working table is empty when the recursive condition resolves to true
while (working_table is not empty) {
    // Step 6: Evaluate the recursive term using the current working table as input.
    // The recursive term is the SQL query defined in the recursive CTE
    // after the UNION clause.
    intermediate_table = execute(recursive_term, using=working_table);
							
    // Step 7: If UNION is used (not UNION ALL), discard duplicates from:
    //    1. The recursive result stored in the intermediate_table
    //    2. Any rows that already exist in the final result set
    if (using UNION)
        intermediate_table = 
            remove_duplicates(intermediate_table, excluding=final_result);
							
    // Step 8: Add the recursive result from the intermediate table to the final result
    final_result.add(intermediate_table);
						
    // Step 9: Replace the working table with the contents of the intermediate
    // table
    working_table = intermediate_table;
}					
					
// Step 10: Return the final result
return final_result;
```

**Listing 3.8 Songs played in sequence after a specific one**
```sql
WITH RECURSIVE play_sequence AS (
    SELECT id, user_id, song_id, play_start_time, play_duration, played_after
    FROM streaming.plays
    WHERE id = 5	 	 
			
    UNION ALL		
				
    SELECT p.id, p.user_id, p.song_id, p.play_start_time, p.play_duration, p.played_after
    FROM streaming.plays p
    JOIN play_sequence ps ON p.played_after = ps.id
)		
SELECT * FROM play_sequence
ORDER BY play_start_time;
```

**Listing 3.9 Calculating total play duration for sequence**
```sql
WITH RECURSIVE play_sequence(parent_id, path, total_duration) AS (
    SELECT id, ARRAY[id], play_duration
    FROM streaming.plays
    WHERE id = 5

    UNION ALL

    SELECT p.id, ps.path || p.id, total_duration + p.play_duration
    FROM streaming.plays p
    JOIN play_sequence ps ON p.played_after = ps.parent_id
)
SELECT ps.parent_id, p.song_id, p.play_start_time, p.play_duration,
ps.path, ps.total_duration
FROM play_sequence ps
JOIN streaming.plays p ON ps.parent_id = p.id
ORDER BY ps.path, p.play_start_time;
```

**Listing 3.10 Total play duration for every song**
```sql
SELECT song_id, SUM(play_duration) as total_duration
FROM streaming.plays
GROUP BY song_id ORDER BY total_duration DESC;
```

**Listing 3.11 Total play duration with users using self-join**
```sql
SELECT DISTINCT p.song_id,
       p.user_id, 
       t.total_duration
FROM streaming.plays p
JOIN (
    SELECT song_id, 
           SUM(play_duration) AS total_duration
    FROM streaming.plays
    GROUP BY song_id
) t ON p.song_id = t.song_id
ORDER BY p.song_id;
```

**Listing 3.12 Total play duration with users using window functions**
```sql 
WITH plays_with_total AS (
  SELECT 
    song_id, user_id, SUM(play_duration) 
    OVER (PARTITION BY song_id) AS total_duration
  FROM streaming.plays
)
SELECT DISTINCT song_id, user_id, total_duration
FROM plays_with_total
ORDER BY song_id, user_id;
```

**Listing 3.13 Calculating running totals and total duration**
```sql  
SELECT song_id, user_id, play_duration, SUM(play_duration) 
OVER (PARTITION BY song_id ORDER BY user_id) AS total_play_duration
FROM streaming.plays
WHERE song_id = 2;
```

**Listing 3.14 Ranking songs by total play duration**
```sql
SELECT song_id, SUM(play_duration) AS total_play_duration,
RANK() OVER (ORDER BY SUM(play_duration) DESC) AS song_rank
FROM streaming.plays
GROUP BY song_id
ORDER BY song_rank;
```

