#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE testify_identity;
    CREATE DATABASE testify_platform;

    CREATE USER testify_identity_user WITH PASSWORD '$TESTIFY_IDENTITY_DB_PASSWORD';
    CREATE USER testify_platform_user WITH PASSWORD '$TESTIFY_PLATFORM_DB_PASSWORD';

    GRANT ALL PRIVILEGES ON DATABASE testify_identity TO testify_identity_user;
    GRANT ALL PRIVILEGES ON DATABASE testify_platform TO testify_platform_user;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "testify_identity" <<-EOSQL
    GRANT ALL ON SCHEMA public TO testify_identity_user;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "testify_platform" <<-EOSQL
    GRANT ALL ON SCHEMA public TO testify_platform_user;
EOSQL
