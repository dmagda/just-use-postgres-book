# Chapter 11, Postgres as message queue

Code listings for Chapter 11, Postgres as message queue.

**Listing 11.1 Creating queue as regular Postgres table**
```sql
CREATE SCHEMA mq;

CREATE TYPE mq.status AS ENUM ('new', 'processing', 'completed');

CREATE TABLE mq.queue (
    id BIGSERIAL PRIMARY KEY,
    message JSON NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status mq.status NOT NULL DEFAULT 'new'
);
```