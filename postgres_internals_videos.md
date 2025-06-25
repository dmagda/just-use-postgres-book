# Postgres Internals Videos

Below you'll find a list of curated videos that do a deep dive into Postgres internals.

## PostgreSQL Internals in Action: MVCC

PostgreSQL uses MVCC (Multi-Version Concurrency Control) to execute transactions and queries in parallel over a consistent view/snapshot of data. Each record may exist in multiple versions simultaneously, with each version visible to a particular set of transactions. Even if the record is updated or deleted, it's not removed from the database immediately. The previous versions remain in the database and are garbage-collected later.

[![@DevMastersDB](https://github.com/dmagda/just-use-postgres-book/blob/main/images/postgres_mvcc_internals.png)](https://www.youtube.com/watch?v=TBmDBw1IIoY)

Resources:

* Video: https://www.youtube.com/watch?v=TBmDBw1IIoY
* Code: https://github.com/dmagda/DevMastersDb/blob/main/postgres/postgres_mvcc_backstage.md
