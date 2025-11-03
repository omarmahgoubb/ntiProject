-- init.sql (executed at container startup to initialize the database)
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL
);

