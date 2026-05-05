#!/bin/bash
set -e

echo "Running migrations..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < /docker-entrypoint-initdb.d/migrations/001_init.sql

echo "Running seeds..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < /docker-entrypoint-initdb.d/seeds/001_seed.sql

echo "Database initialized!"
