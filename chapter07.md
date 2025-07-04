# Chapter 7, Postgres extensions

Code listings for Chapter 7, Postgres extensions.

**Listing 7.1 Checking pgcrypto extension version**
```sql
SELECT name, default_version, installed_version 
FROM pg_available_extensions 
WHERE name = 'pgcrypto';
```

**Listing 7.2 Creating accounts table**
```sql
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    password_hash TEXT NOT NULL
);
```

**Listing 7.3 Encrypting password for new user**
```sql
INSERT INTO accounts (username, password_hash)
VALUES ('ahamilton', crypt('SuperSecret123', gen_salt('bf')));
```

**Listing 7.4 Authenticating user with pgcrypto**
```sql
SELECT username FROM accounts
WHERE username = 'ahamilton' 
AND password_hash = crypt('SuperSecret123', password_hash);
```

