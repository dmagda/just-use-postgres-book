CREATE SCHEMA game;

CREATE TABLE game.player_stats (
    player_id BIGINT PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 10),
    score INTEGER DEFAULT 0,
    champion_title TEXT,
    join_date DATE NOT NULL,
    last_active TIMESTAMP,
    region TEXT CHECK (region IN ('NA', 'EMEA', 'APAC')),
    play_time INTERVAL DEFAULT '0 seconds',
    win_count INTEGER DEFAULT 0,
    loss_count INTEGER DEFAULT 0
);