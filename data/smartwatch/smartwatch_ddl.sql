CREATE SCHEMA watch;

CREATE TABLE watch.heart_rate_measurements (
  watch_id INT NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL,
  heart_rate INT NOT NULL,
  activity TEXT NOT NULL CHECK (activity IN ('walking', 'sleeping', 'resting', 'workout'))
);

SELECT create_hypertable(
  relation => 'watch.heart_rate_measurements',
  dimension => by_range('recorded_at', interval '1 month'),
  create_default_indexes => false
);