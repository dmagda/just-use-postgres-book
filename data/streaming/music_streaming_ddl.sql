CREATE SCHEMA streaming;

-- Users table
CREATE TABLE streaming.users (
    id INT PRIMARY KEY,
    name TEXT,
    location TEXT
);

-- Songs table
CREATE TABLE streaming.songs (
    id INT PRIMARY KEY,
    title TEXT,
    duration INT -- Duration in seconds
);

-- Plays table (tracks when a user plays a song)
CREATE TABLE streaming.plays (
    id BIGINT PRIMARY KEY,
    user_id INT REFERENCES streaming.users(id),
    song_id INT REFERENCES streaming.songs(id),
    play_start_time TIMESTAMP,
    play_duration INT, -- Duration in seconds,
    played_after INT -- the id of the previous play or NULL if this is the first song played within the 15 minutes interval
);