INSERT INTO streaming.users (id, name, location) VALUES
(1, 'Alice', 'San Diego'),
(2, 'Bob', 'Tampa'),
(3, 'Charlie', 'Savannah');

INSERT INTO streaming.songs (id, title, duration) VALUES
(1, 'Song A', 200),
(2, 'Song B', 240),
(3, 'Song C', 180),
(4, 'Song D', 300),
(5, 'Song E', 150),
(6, 'Song F', 210),
(7, 'Song G', 260),
(8, 'Song H', 220),
(9, 'Song I', 270),
(10, 'Song J', 230);

INSERT INTO streaming.plays (id, user_id, song_id, play_start_time, play_duration, played_after) VALUES
-- User 1: Sequences of 3-5 songs
(1, 1, 1, '2024-09-15 12:14:00', 200, NULL),         -- Start of sequence 1
(2, 1, 2, '2024-09-15 12:17:00', 144, 1),            -- Played after play_id 1
(3, 1, 3, '2024-09-15 12:21:00', 110, 2),            -- Played after play_id 2
(4, 1, 4, '2024-09-15 12:25:30', 300, 3),            -- Played after play_id 3 (sequence length: 4)

(5, 1, 5, '2024-09-15 01:34:00', 61, NULL),          -- Start of sequence 2
(6, 1, 6, '2024-09-15 01:37:30', 139, 5),            -- Played after play_id 5
(7, 1, 7, '2024-09-15 01:42:00', 104, 6),            -- Played after play_id 6
(8, 1, 8, '2024-09-15 01:45:00', 99, 7),             -- Played after play_id 7 (sequence length: 4)

-- User 2: Sequences of 3-5 songs
(9, 2, 10, '2024-09-15 02:42:00', 101, NULL),        -- Start of sequence 1
(10, 2, 1, '2024-09-15 02:45:00', 200, 9),           -- Played after play_id 9
(11, 2, 2, '2024-09-15 02:49:30', 206, 10),          -- Played after play_id 10
(12, 2, 3, '2024-09-15 02:54:00', 118, 11),          -- Played after play_id 11 (sequence length: 4)

(13, 2, 4, '2024-09-16 06:33:00', 300, NULL),        -- Start of sequence 2
(14, 2, 5, '2024-09-16 06:38:00', 32, 13),           -- Played after play_id 13
(15, 2, 6, '2024-09-16 06:42:00', 129, 14),          -- Played after play_id 14
(16, 2, 7, '2024-09-16 06:46:30', 260, 15),          -- Played after play_id 15
(17, 2, 8, '2024-09-16 06:51:30', 199, 16),          -- Played after play_id 16 (sequence length: 5)

(18, 2, 9, '2024-09-16 07:40:00', 209, NULL),        -- Start of sequence 3

-- User 3: Sequences of 3-5 songs
(19, 3, 10, '2024-09-16 21:49:00', 91, NULL),        -- Start of sequence 1
(20, 3, 1, '2024-09-16 21:51:30', 200, 19),          -- Played after play_id 19
(21, 3, 2, '2024-09-16 21:55:30', 186, 20),          -- Played after play_id 20
(22, 3, 3, '2024-09-16 22:00:00', 95, 21),           -- Played after play_id 21 (sequence length: 4)

(23, 3, 4, '2024-09-16 19:53:00', 300, NULL),        -- Start of sequence 2
(24, 3, 5, '2024-09-16 19:57:30', 48, 23),           -- Played after play_id 23
(25, 3, 6, '2024-09-16 20:01:00', 105, 24),          -- Played after play_id 24 (sequence length: 3)

(26, 3, 7, '2024-09-16 11:37:00', 260, NULL),        -- Start of sequence 3

(27, 3, 8, '2024-09-15 16:58:00', 132, NULL),        -- Start of sequence 4
(28, 3, 9, '2024-09-15 17:02:00', 254, 27),          -- Played after play_id 27
(29, 3, 10, '2024-09-15 17:07:30', 197, 28),         -- Played after play_id 28 (sequence length: 3)

(30, 3, 1, '2024-09-15 09:03:00', 106, NULL),        -- Start of sequence 5
(31, 3, 2, '2024-09-15 09:05:30', 118, 30),          -- Played after play_id 30 (sequence length: 2)

(32, 3, 3, '2024-09-15 18:53:00', 102, NULL),        -- Start of sequence 6

(33, 3, 4, '2024-09-15 01:07:00', 300, NULL),        -- Start of sequence 7
(34, 3, 5, '2024-09-15 01:13:00', 127, 33),          -- Played after play_id 33 (sequence length: 2)

(35, 3, 6, '2024-09-15 11:29:00', 78, NULL),         -- Start of sequence 8
(36, 3, 7, '2024-09-15 11:32:30', 174, 35);          -- Played after play_id 35 (sequence length: 2)