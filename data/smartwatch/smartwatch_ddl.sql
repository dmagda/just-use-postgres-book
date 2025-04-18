CREATE SCHEMA watch;

CREATE TABLE watch.heart_rate_measurements (
  watch_id INT NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL,
  heart_rate INT NOT NULL,
  activity TEXT NOT NULL CHECK (activity IN ('walking', 'sleeping', 'resting', 'workout'))
);

SELECT create_hypertable(
  'watch.heart_rate_measurements',
  'recorded_at',
  chunk_time_interval => interval '1 month',
  create_default_indexes => false
);