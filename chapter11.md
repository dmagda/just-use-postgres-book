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

**Listing 11.2 Creating function for adding messages to queue**
```sql
CREATE OR REPLACE FUNCTION mq.enqueue(new_message JSON)
RETURNS VOID AS $$
BEGIN
  INSERT INTO mq.queue (message)
  VALUES (new_message);
END;
$$ LANGUAGE plpgsql;
```

**Listing 11.3 Creating function for retrieving messages from queue**
```sql
CREATE OR REPLACE FUNCTION mq.dequeue(messages_cnt INT)
RETURNS TABLE (msg_id BIGINT, message JSON, enqueued_at TIMESTAMPTZ) AS $$
BEGIN
  RETURN QUERY
  WITH new_messages AS (
    SELECT id FROM mq.queue
    WHERE status = 'new' ORDER BY created_at
    FOR UPDATE SKIP LOCKED
    LIMIT messages_cnt
  )
  UPDATE mq.queue q
  SET status = 'processing'
  FROM new_messages WHERE q.id = new_messages.id
  RETURNING q.id, q.message, q.created_at;
END;
$$ LANGUAGE plpgsql;
```

**Listing 11.4 Creating function for changing messages status**
```sql
CREATE OR REPLACE FUNCTION mq.mark_completed(message_ids BIGINT[], to_delete BOOLEAN DEFAULT FALSE)
RETURNS VOID AS $$
BEGIN
  IF to_delete THEN
    DELETE FROM mq.queue
    WHERE id = ANY(message_ids);
  ELSE
    UPDATE mq.queue
    SET status = 'completed'
    WHERE id = ANY(message_ids);
  END IF;
END;
$$ LANGUAGE plpgsql;
```

**Listing 11.5 Updating mq.enqueue function to send notifications**
```sql 
CREATE OR REPLACE FUNCTION mq.enqueue(new_message JSON)
RETURNS VOID AS $$
BEGIN
  INSERT INTO mq.queue (message)
  VALUES (new_message);

  -- Notify listeners that a new message has been added
  PERFORM pg_notify('queue_new_message', 'new_message');
END;
$$ LANGUAGE plpgsql;
```
